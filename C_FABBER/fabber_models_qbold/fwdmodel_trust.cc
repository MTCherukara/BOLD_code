/*   fwdmodel_trust.cc - TRUST fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2019 University of Oxford  */

#include "fwdmodel_trust.h"

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
FactoryRegistration<FwdModelFactory, TrustFwdModel>
    TrustFwdModel::registration("trust");

FwdModel *TrustFwdModel::NewInstance() // unchanged
{
    return new TrustFwdModel();
} // NewInstance

string TrustFwdModel::GetDescription() const 
{
    return "T2-relaxation under spin tagging (TRUST) model";
} // GetDescription

string TrustFwdModel::ModelVersion() const
{
    return "0.1 (2019-08-05)";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void TrustFwdModel::Initialize(ArgsType &args)
{
    infer_OEF = args.ReadBool("inferOEF");
    infer_R2b = args.ReadBool("inferR2b");
    infer_S0  = args.ReadBool("inferS0");
    infer_Hct = args.ReadBool("inferHct");
    infer_R1b = args.ReadBool("inferR1b");

    // since we can't do both, OEF will take precidence over R2b
    if (infer_OEF)
    {
        infer_R2b = false;
    }

    // temporary holders for input values
    string TE_temp; 


    // First read tau values, since these will always be specified

    // this parses through the input args for tau1=X, tau2=X and so on, until it reaches a tau
    // that isn't supplied in the argument, and it adds all these to the ColumnVector taus
    while (true)
    {
        int N = TEs.Nrows()+1;
        TE_temp = args.ReadWithDefault("TE"+stringify(N), "stop!");
        if (TE_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(TE_temp);
        TEs &= tmp;

    }

    // add information to the log
    LOG << "Inference using development model" << endl;
    for (int ii = 1; ii <= TEs.Nrows(); ii++)
    {
        LOG << "    TE(" << ii << ") = " << TEs(ii) << endl;
    }
    if (infer_OEF)
    {
        LOG << "Inferring on OEF " << endl;
    }
    if (infer_R2b)
    {
        LOG << "Inferring on R2 of blood" << endl;
    }
    if (infer_S0)
    {
        LOG << "Inferring on scaling parameter S0 " << endl;
    }
    if (infer_Hct)
    {
        LOG << "Inferring on fractional hematocrit " << endl;
    }
    if (infer_R1b)
    {
        LOG << "Inferring on R1 of blood" << endl;
    }

    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void TrustFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_OEF)
    {
        names.push_back("OEF"); // parameter 1 - Oxygen Extraction Fraction
    }
    if (infer_R2b)
    {
        names.push_back("R2b"); // parameter 1 - R2 of blood
    }
    if (infer_S0)
    {
        names.push_back("S0");  // parameter 2 - S0 scaling factor
    }
    if (infer_Hct)
    {
        names.push_back("Hct");  // parameter 3 - fractional haematocrit
    }
    if (infer_R1b)
    {
        names.push_back("R1b");  // parameter 4 - R1 of blood
    }
} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void TrustFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-6;

    if (infer_OEF)
    {
        prior.means(OEF_index()) = 0.4;
        precisions(OEF_index(), OEF_index()) = 1e-6; // 1e-3
    }
    
    if (infer_R2b)
    {
        prior.means(R2b_index()) = 20;
        precisions(R2b_index(), R2b_index()) = 1e-3; // 1e-3
    }

    if (infer_S0)
    {
        prior.means(S0_index()) = 500.0;
        precisions(S0_index(), S0_index()) = 1e-6; // 1e-6 - always imprecise
    }

    if (infer_Hct)
    {
        prior.means(Hct_index()) = 0.40;
        precisions(Hct_index(), Hct_index()) = 1e-6; // 1e-3
    }

    if (infer_R1b)
    {
        prior.means(R1b_index()) = 0.62;
        precisions(R1b_index(), R1b_index()) = 1e-3; // 1e-1 - always precise
    }
   
    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)
    posterior.SetPrecisions(precisions);

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void TrustFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double AA;
    double BB;
    double CC;

    // parameters
    double OEF;
    double R2b;
    double S0;
    double Hct;
    double R1b;

    if (infer_OEF)
    {
        OEF = (paramcpy(OEF_index()));
        if (OEF > 1.0)
        {
            OEF = 1.0;
        }
        else if (OEF < 0.0001)
        {
            OEF = 0.0001;
        } 
    }
    else
    {
        OEF = 0.40;
    }
    if (infer_S0)
    {
        S0 = (paramcpy(S0_index()));
    }
    else
    {
        S0 = 500.0;
    }
    if (infer_Hct)
    {
        Hct = (paramcpy(Hct_index()));
    }
    else
    {
        Hct = 0.40;
    }
    if (infer_R1b)
    {
        R1b = (paramcpy(R1b_index()));
    }
    else
    {
        R1b = 0.61;
    }

    // this one is different - it's where we calculate OEF from R2b
    if (infer_R2b)
    {
        R2b = (paramcpy(R2b_index()));
    }
    else
    {
        // calculate coefficients (from Lu 2012)
        AA = -13.5 + (80.2*Hct) - (75.9*pow(Hct,2.0));
        BB = (-0.5*Hct) + (3.4*pow(Hct,2.));
        CC = 247.4*Hct*(1.0-Hct);

        // calculate R2p
        R2b = AA + (BB*OEF) + (CC*pow(OEF,2.0));
    }

    // loop through TEs
    result.ReSize(TEs.Nrows());

    for (int ii = 1; ii <= TEs.Nrows(); ii++)
    {
        double TE = TEs(ii);

        // fit the exponetial function
        result(ii) = S0*exp(TE*(R1b-R2b));
        
    }

    return;

} // Evaluate
