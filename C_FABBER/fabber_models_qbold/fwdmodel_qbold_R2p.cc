/*   fwdmodel_qbold_R2p.cc - Implements the ASE qBOLD curve fitting model
                             measuring DBV and R2-prime

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_qbold_R2p.h"

#include "fabber_core/fwdmodel.h"

#include <math.h>
#include <iostream>
#include <vector>
#include <string>
#include <newmatio.h>
#include <stdexcept> 
#include <cmath>
#include <complex>

using namespace std;
using namespace NEWMAT;

// ------------------------------------------------------------------------------------------
// --------         Generic Methods             ---------------------------------------------
// ------------------------------------------------------------------------------------------
FactoryRegistration<FwdModelFactory, R2primeFwdModel>
    R2primeFwdModel::registration("qboldR2p");

FwdModel *R2primeFwdModel::NewInstance() // unchanged
{
    return new R2primeFwdModel();
} // NewInstance

string R2primeFwdModel::GetDescription() const 
{
    return "ASE qBOLD model R2-prime version";
} // GetDescription

string R2primeFwdModel::ModelVersion() const
{
    return "1.2";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::Initialize(ArgsType &args)
{
    infer_R2p = args.ReadBool("inferR2p");
    infer_DBV = args.ReadBool("inferDBV");
    infer_R2t = args.ReadBool("inferR2t");
    infer_S0  = args.ReadBool("inferS0");
    infer_Hct = args.ReadBool("inferHct");
    infer_R2e = args.ReadBool("inferR2e");
    infer_dF  = args.ReadBool("inferdF");
    infer_lam = args.ReadBool("inferlam");
    single_comp = args.ReadBool("single_compartment");


    // temporary holders for input values
    string tau_temp;
    string TE_temp; 

    // First read tau values, since these will always be specified

    // this parses through the input args for tau1=X, tau2=X and so on, until it reaches a tau
    // that isn't supplied in the argument, and it adds all these to the ColumnVector taus
    while (true)
    {
        int N = taus.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        taus &= tmp;

    }

    // Then read TE values

    // see if there is a single TE specified
    TE_temp = args.ReadWithDefault("TE","noTE");

    // now loop through the number of tau values, and assign each one a TE
    for (int i = 1; i <= taus.Nrows(); i++)
    {
        // see if there is an input called "TE"
        TE_temp = args.ReadWithDefault("TE","noTE");

        // if there is no "TE", read TE1, TE2, etc.
        if (TE_temp == "noTE")
        {
            TE_temp = args.ReadWithDefault("TE"+stringify(i), "0.082");
        }

        ColumnVector tmp(1);
        tmp = convertTo<double>(TE_temp);
        TEvals &= tmp;

    }


    // add information to the log
    LOG << "Inference using development model" << endl;    
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        LOG << "    TE(" << ii << ") = " << TEvals(ii) << "    tau(" << ii << ") = " << taus(ii) << endl;
    }    
    if (infer_R2p)
    {
        LOG << "Inferring on R2p " << endl;
    }
    if (infer_DBV)
    {
        LOG << "Inferring on DBV " << endl;
    }
    if (infer_R2t)
    {
        LOG << "Inferring on R2/T2 of tissue" << endl;
    }
    if (infer_S0)
    {
        LOG << "Inferring on scaling parameter S0" << endl;
    }
    if (infer_Hct)
    {
        LOG << "Inferring on fractional hematocrit" << endl;
    }
    if (infer_R2e)
    {
        LOG << "Inferring on R2 of CSF" << endl;
    }
    if (infer_dF)
    {
        LOG << "Inferring on CSF frequency shift dF" << endl;
    }
    if (infer_lam)
    {
        LOG << "Inferring on CSF volume fraction lambda" << endl;
    }
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void R2primeFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_R2p)
    {
        names.push_back("R2p"); // parameter 1 - R2 prime
    }
    if (infer_DBV)
    {
        names.push_back("DBV"); // parameter 2 - DBV
    }
    if (infer_R2t)
    {
        names.push_back("R2t");  // parameter 3 - R2 (of tissue)
    }
    if (infer_S0)
    {
        names.push_back("S0");  // parameter 4 - S0 scaling factor
    }
    if (infer_Hct)
    {
        names.push_back("Hct");  // parameter 4 - S0 scaling factor
    }
    if (infer_R2e)
    {
        names.push_back("R2e");  // parameter 5 - R2 (of CSF)
    }
    if (infer_dF)
    {
        names.push_back("dF");  // parameter 6 - frequency shift of CSF
    }
    if (infer_lam)
    {
        names.push_back("lambda");  // parameter 7 - CSF volume fraction
    }

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    if (infer_R2p)
    {
        prior.means(R2p_index()) = 6.0;
        precisions(R2p_index(), R2p_index()) = 1e-2; // 1e-2
    }

    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 1e-1; // 1e-1
    }

    if (infer_R2t)
    {
        prior.means(R2t_index()) = 11.5;
        precisions(R2t_index(), R2t_index()) = 1e-2; // 1e-2
    }

    if (infer_S0)
    {
        prior.means(S0_index()) = 1000.0;
        precisions(S0_index(), S0_index()) = 1e-5; // 1e-5
    }

    if (infer_Hct)
    {
        prior.means(Hct_index()) = 0.40;
        precisions(Hct_index(), Hct_index()) = 1e-2; // 1e-5
    }

    if (infer_R2e)
    {
        prior.means(R2e_index()) = 0.5;
        precisions(R2e_index(), R2e_index()) = 1e-2; // 1e-2
    }
    
    if (infer_dF)
    {
        prior.means(dF_index()) = 5.0;
        precisions(dF_index(), dF_index()) = 1e-2; // 1e-2
    }

    if (infer_lam)
    {
        prior.means(lam_index()) = 0.001;
        precisions(lam_index(), lam_index()) = 1e2; // 1e-1
    }

    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)
    
    // this whole section seems unnecessary - changing the initial posterior appears to have no
    // effect on the final outcome, which is good, because we'd expect the algorithm to converge
    // onto the correct result regardless of where it started from. I'm still not sure, however,
    // where our priors are truly uninformative. 

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double St;  // tissue signal
    double Sb;  // blood signal
    double Se;  // extracellular signal
    complex<double> Sec; // complex version of the extracellular signal (may be unnecessary)

    complex<double> i(0,1);

    // derived parameters
    double dw;
    double R2b;
    double R2bs;
    double OEF;

    // parameters
    double R2p;
    double DBV;
    double R2t;
    double S0;
    double Hct;
    double R2e;
    double dF;
    double lam;

    // assign values to parameters
    if (infer_R2p)
    {
        R2p = abs(paramcpy(R2p_index()));
    }
    else
    {
        R2p = 4.0;
    }
    if (infer_DBV)
    {
        DBV = abs(paramcpy(DBV_index()));
    }
    else
    {
        DBV = 0.03;
    }
    if (infer_R2t)
    {
        R2t = abs(paramcpy(R2t_index()));
    }
    else
    {
        R2t = 11.5;
    }
    if (infer_S0)
    {
        S0 = (paramcpy(S0_index()));
    }
    else
    {
        S0 = 100.0;
    }
    if (infer_Hct)
    {
        Hct = (paramcpy(Hct_index()));
    }
    else
    {
        Hct = 0.4;
    }
    if (infer_R2e)
    {
        R2e = abs(paramcpy(R2e_index()));
    }
    else
    {
        R2e = 0.50;
    }
    if (infer_dF)
    {
        dF = abs(paramcpy(dF_index()));
    }
    else
    {
        dF = 6.00;
    }
    if (infer_lam)
    {
        lam = abs(paramcpy(lam_index()));
    }
    else
    {
        lam = 0.0;
    }

    // now evaluate the static dephasing qBOLD model for 2 compartments
    dw = R2p/DBV;
    OEF = dw/(887.4082*Hct);

    R2bs = (14.9*Hct + 14.7) + ((302.1*Hct + 41.8)*pow(OEF,2.0));
    R2b  = (16.4*Hct +  4.5) + ((165.2*Hct + 55.7)*pow(OEF,2.0));
    

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        double tau = taus(ii);
        double TE = TEvals(ii);

        if (tau < (-1.5/dw))
        {
            St = exp(DBV + (R2p*tau));
        }
        else if (tau > (1.5/dw))
        {
            St = exp(DBV - (R2p*tau));
        }
        else
        {
            St = exp(-0.3*DBV*pow(dw*tau,2.0));
        }

        // calculate blood signal
        Sb = exp(-R2b*(TE-tau))*exp(-R2bs*abs(tau));

        // calculate blood signal using motion narrowing model

        // calculate extracellular signal
        Sec = exp(-R2e*TE)*exp(-2.0*i*M_PI*dF*abs(tau));
        Se = abs(Sec);

        // Total signal
        if (single_comp)
        {
            // Ignore T2 effect, and other compartments
            result(ii) = S0*St;
        }
        else
        {
            // add in the T2 effect to St
            St *= exp(-R2t*TE);

            // add up compartments
            result(ii) = S0*(((1-DBV-lam)*St) + (DBV*Sb) + (lam*Se));
        }

    } // for (int i = 1; i <= taus.Nrows(); i++)

    
    // alternative, if values are outside reasonable bounds
    if ( DBV > 0.5 || lam > 0.5 )
    {
        for (int ii = 1; ii <= taus.Nrows(); ii++)
        {
            result(ii) = 10000*result(ii);
        }
    }


    return;

} // Evaluate
