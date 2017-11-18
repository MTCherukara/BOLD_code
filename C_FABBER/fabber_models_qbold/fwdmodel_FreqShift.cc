/*   fwdmodel_FreqShift.cc - ASE qBOLD fitting of frequency shift DF by comparing FLAIR and nonFLAIR data


 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_FreqShift.h"

#include "fabber_core/fwdmodel.h"

#include <math.h>
#include <iostream>
#include <vector>
#include <string>
#include <newmatio.h>
#include <stdexcept> 
#include <cmath>

using namespace std;
using namespace NEWMAT;

// ------------------------------------------------------------------------------------------
// --------         Generic Methods             ---------------------------------------------
// ------------------------------------------------------------------------------------------
FactoryRegistration<FwdModelFactory, FreqShiftFwdModel>
    FreqShiftFwdModel::registration("freqShift");

FwdModel *FreqShiftFwdModel::NewInstance() // unchanged
{
    return new FreqShiftFwdModel();
} // NewInstance

string FreqShiftFwdModel::GetDescription() const 
{
    return "CSF Frequency Shift fitting model";
} // GetDescription

string FreqShiftFwdModel::ModelVersion() const
{
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::Initialize(ArgsType &args)
{
    // no boolean arguments here
    
    string tau_temp; 

    while (true)
    {
        int N = taus.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        taus &= tmp;

    }

    // add information to the log
    LOG << "Inference using development model" << endl;     
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void FreqShiftFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.pushback("SF");   // parameter 1 - S0(FLAIR)
    names.pushback("SN");   // parameter 2 - S0(no-FLAIR)
    names.pushback("VC");   // parameter 3 - V^CSF
    names.pushback("DF");   // parameter 4 - Delta F

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-6;
    
    // parameter 1 - S0(FLAIR)
    prior.means(SF_index()) = 1000;
    precisions(SF_index(), SF_index()) = 1e-6; // 1e-6

    // parameter 2 - S0(no-FLAIR)
    prior.means(SF_index()) = 1000;
    precisions(SF_index(), SF_index()) = 1e-6; // 1e-6

    // parameter 3 - V^CSF
    prior.means(SF_index()) = 0.01;
    precisions(SF_index(), SF_index()) = 1e-1; // 1e-1

    // parameter 4 - Delta F
    prior.means(SF_index()) = 5;
    precisions(SF_index(), SF_index()) = 1e-3; // 1e-3

    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows()); // is this line necessary?

    ColumnVector paramcpy = params;

    // inferred parameters
    double SF;
    double SN;
    double VC;
    double DF;

    // fixed-value parameters
    double R2t = 12.5;
    double R2e = 2.0;

    // assign values to parameters
    SF = paramcpy(SF_index());
    SN = paramcpy(SN_index());
    VC = paramcpy(VC_index());
    DF = paramcpy(DF_index());

    // now evaluate information

    // loop through two taus
    result.ReSize(2*taus.Nrows());

    // FLAIR results
    for (int i = 1; i <= taus.Nrows(); i++)
    {
        double tau = taus(i);

        result(i) = S0 * ( ((1-tht)*exp(-R2A*TE)) + (tht*exp(-R2B*TE)));

    } 

    // make sure that the weighting parameter theta is between 0 and 1
    
    if (infer_theta)
    {
        if ( tht > 1.0 || tht < 0.0 )
        {
            for (int ii = 1; ii <= TEs.Nrows(); ii++)
            {
                result(ii) = 0.0;
            }
        }
    }

    return;

} // Evaluate
