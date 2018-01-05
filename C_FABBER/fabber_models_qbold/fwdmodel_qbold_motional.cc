/*   fwdmodel_qbold_motional.cc - Implements an ASE qBOLD model with motional narrowing terms,
                                  based on Berman, 2017.

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#include "fwdmodel_qbold_motional.h"

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
FactoryRegistration<FwdModelFactory, MotionalFwdModel>
    MotionalFwdModel::registration("qboldmotional");

FwdModel *MotionalFwdModel::NewInstance() // unchanged
{
    return new MotionalFwdModel();
} // NewInstance

string MotionalFwdModel::GetDescription() const 
{
    return "ASE qBOLD model with motional narrowing terms";
} // GetDescription

string MotionalFwdModel::ModelVersion() const
{
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void MotionalFwdModel::Initialize(ArgsType &args)
{
    infer_R2p = args.ReadBool("inferR2p");
    infer_DR2 = args.ReadBool("inferDR2");
    infer_R2t = args.ReadBool("inferR2t");
    infer_S0  = args.ReadBool("inferS0");
    infer_lam = args.ReadBool("inferlam");

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
    if (infer_DR2)
    {
        LOG << "Inferring on Delta R2 " << endl;
    }
    if (infer_R2t)
    {
        LOG << "Inferring on R2/T2 of tissue" << endl;
    }
    if (infer_S0)
    {
        LOG << "Inferring on scaling parameter S0" << endl;
    }
    if (infer_lam)
    {
        LOG << "Inferring on CSF volume fraction lambda" << endl;
    }
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void MotionalFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_R2p)
    {
        names.push_back("R2p"); // parameter 1 - R2 prime
    }
    if (infer_DR2)
    {
        names.push_back("DR2"); // parameter 2 - DBV
    }
    if (infer_R2t)
    {
        names.push_back("R2t");  // parameter 3 - R2 (of tissue)
    }
    if (infer_S0)
    {
        names.push_back("S0");  // parameter 4 - S0 scaling factor
    }
    if (infer_lam)
    {
        names.push_back("lambda");  // parameter 7 - CSF volume fraction
    }

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void MotionalFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
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

    if (infer_DR2)
    {
        prior.means(DR2_index()) = 3.0;
        precisions(DR2_index(), DR2_index()) = 1e-2; // 1e-2
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
void MotionalFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double St;  // tissue signal
    double Mt;  // motional narrowing term
    double Se;  // extracellular signal
    complex<double> Sec; // complex version of the extracellular signal (may be unnecessary)

    complex<double> i(0,1);

    // constants
    double R2e = 0.50;
    double dF = 6.0;

    // parameters
    double R2p;
    double DR2;
    double R2t;
    double S0;
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
    if (infer_DR2)
    {
        DR2 = abs(paramcpy(DR2_index()));
    }
    else
    {
        DR2 = 3.0;
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
    if (infer_lam)
    {
        lam = abs(paramcpy(lam_index()));
    }
    else
    {
        lam = 0.0;
    }

    // now evaluate the Berman motional narrowing model

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        double tau = taus(ii);
        double TE = TEvals(ii);

        // Motional narrowing term
        Mt = pow((TE-tau),2.0)*pow(DR2,2.0);

        // tissue signal
        St = exp(-R2t*TE)*exp(-R2p*tau)*exp(-Mt);

        // calculate extracellular signal
        Sec = exp(-R2e*TE)*exp(-2.0*i*M_PI*dF*abs(tau));
        Se = abs(Sec);

        // Total signal
        result(ii) = S0*(((1-lam)*St) + (lam*Se));
 

    } // for (int i = 1; i <= taus.Nrows(); i++)

    
    // alternative, if values are outside reasonable bounds
    if ( lam > 0.5 )
    {
        for (int ii = 1; ii <= taus.Nrows(); ii++)
        {
            result(ii) = 10000*result(ii);
        }
    }


    return;

} // Evaluate
