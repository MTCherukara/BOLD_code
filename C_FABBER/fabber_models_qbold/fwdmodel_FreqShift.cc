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

    // get scan information
    TE = convertTo<double>(args.ReadWithDefault("TE", "0.082"));
    TI = convertTo<double>(args.ReadWithDefault("TI", "1.210"));
    TR = convertTo<double>(args.ReadWithDefault("TR", "3.000"));

    // add information to the log
    LOG << "Inference using development model" << endl;     
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void FreqShiftFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("M0");   // parameter 1 - Magnetization M0
    names.push_back("VC");   // parameter 2 - V^CSF
    names.push_back("DF");   // parameter 3 - Delta F
    names.push_back("R2p");  // parameter 4 - R2-prime (tissue)

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
    
    // parameter 1 - Magnetization M0 
    prior.means(M0_index()) = 1000.0;
    precisions(M0_index(), M0_index()) = 1e-6; // 1e-6

    // parameter 2 - V^CSF
    prior.means(VC_index()) = 0.01;
    precisions(VC_index(), VC_index()) = 1e-1; // 1e-1

    // parameter 3 - Delta F
    prior.means(DF_index()) = 5.0;
    precisions(DF_index(), DF_index()) = 1e-3; // 1e-3

    // parameter 4 - R2-prime (Tissue)
    prior.means(R2p_index()) = 6.0;
    precisions(R2p_index(), R2p_index()) = 1e-2; // 1e-2

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
    double M0;
    double VC;
    double DF;
    double R2p; 

    // fixed-value parameters
    double T1t = 1.019;
    double T1e = 3.817;
    double T1b = 1.584;
    double R2t = 12.5;
    double R2e = 2.0;
    double R2b = 27.97;
    double Rsb = 48.89;
    double DBV = 0.03;

    // assign values to parameters
    M0 = abs(paramcpy(M0_index()));
    VC = abs(paramcpy(VC_index()));
    DF = abs(paramcpy(DF_index()));
    R2p = abs(paramcpy(R2p_index()));

    // now evaluate information
    result.ReSize(2*taus.Nrows());

    // loop through FLAIR data
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        // component parameters
        double St;      // tissue
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        double tau = taus(ii);

        // Tissue Component
        St = ( 1 - ( (2 - exp(-(TR-TI)/T1t) ) * exp(-TI/T1t))) * (exp(-R2t*TE)) * (exp(DBV - (R2p*tau)));

        // Blood Component
        Sb = ( 1 - ( (2 - exp(-(TR-TI)/T1b) ) * exp(-TI/T1b))) * (exp(-R2b*(TE-tau))) * (exp(-Rsb*tau));

        // CSF Component
        Sec = ( 1 - ( (2 - exp(-(TR-TI)/T1e) ) * exp(-TI/T1e))) * (exp(-R2e*TE)) * (exp(-2.0*i*M_PI*DF*tau));
        Se = abs(Sec);

        // Total
        result(ii) = M0 * ( (1-(DBV+VC))*St ) * (DBV*Sb) * (VC*Se);

    }

    // loop through non-FLAIR data
    for (int jj = (taus.Nrows()+1); jj <= 2*taus.Nrows(); jj++)
    {
        // component parameters
        double St;      // tissue
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        double tau = taus(taus.Nrows()+jj);

        // Tissue Component
        St = ( 1 - (exp(-TR/T1t)) ) * (exp(-R2t*TE)) * (exp(DBV - (R2p*tau)));

        // Blood Component
        Sb = ( 1 - (exp(-TR/T1b)) ) * (exp(-R2b*(TE-tau))) * (exp(-Rsb*tau));

        // CSF Component
        Sec = ( 1 - (exp(-TR/T1e)) ) * (exp(-R2e*TE)) * (exp(-2.0*i*M_PI*DF*tau));
        Se = abs(Sec);

        // Total
        result(jj) = M0 * ( (1-(DBV+VC))*St ) * (DBV*Sb) * (VC*Se);
        
    }

    return;

} // Evaluate
