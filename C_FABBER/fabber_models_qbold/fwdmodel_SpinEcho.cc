/*   fwdmodel_qbold_R2p.cc - Implements the ASE qBOLD curve fitting model
                             measuring DBV and R2-prime

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_SpinEcho.h"

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
FactoryRegistration<FwdModelFactory, SpinEchoFwdModel>
    SpinEchoFwdModel::registration("spinEcho");

FwdModel *SpinEchoFwdModel::NewInstance() // unchanged
{
    return new SpinEchoFwdModel();
} // NewInstance

string SpinEchoFwdModel::GetDescription() const 
{
    return "Spin Echo R2 fitting model";
} // GetDescription

string SpinEchoFwdModel::ModelVersion() const
{
    return "1.2";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void SpinEchoFwdModel::Initialize(ArgsType &args)
{
    // see whether we want a bi-exponential model or not
    infer_theta = args.ReadBool("infer_theta");
    infer_r2 = args.ReadBool("infer_r2");
    
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
    if (infer_theta)
    {
        LOG << "Inferring a bi-exponential model" << endl;
    }
    for (int i = 1; i <= TEs.Nrows(); i++)
    {
        LOG << "    TE(" << i << ") = " << TEs(i) << endl;
    }    
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void SpinEchoFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    // parameter 1 - S0 scaling factor - we ALWAYS infer this
    names.push_back("S0");  // parameter 1 - S0 scaling factor - ALWAYS
    
    if (infer_theta)
    {
        // parameter 2 - mixing ratio - only for bi-exponential 
        names.push_back("theta"); 

        if (infer_r2)
        {
            // parameters 3 and 4 - R2 of the two compartments
            names.push_back("R2A");
            names.push_back("R2B");
        }
    }
    else if (infer_r2)
    {
        // parameter 2 - mono-exponential decay rate
        names.push_back("R2"); 
    }

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void SpinEchoFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    // parameter 1 - S0 scaling factor - we ALWAYS infer this
    prior.means(S0_index()) = 1000;
    precisions(S0_index(), S0_index()) = 1e-8; // 1e-4

    if (infer_theta)
    {
        // parameter 2 - mixing ratio - only for bi-exponential 
        prior.means(th_index()) = 0.5;
        precisions(th_index(), th_index()) = 1e-2; // 1e-1

        if (infer_r2)
        {
            // parameters 3 and 4 - R2 of the two compartments
            prior.means(R2A_index()) = 1/0.08;
            precisions(R2A_index(), R2A_index()) = 1e-3; // 1e-2
            prior.means(R2B_index()) = 1/0.5;
            precisions(R2B_index(), R2B_index()) = 1e-3; // 1e-2
        }
    }
    else if (infer_r2)
    {
        // parameter 2 - mono-exponential decay rate
        prior.means(R2A_index()) = 1/0.08;
        precisions(R2A_index(), R2A_index()) = 1e-3; // 1e-2
    }
    
    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void SpinEchoFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // parameters
    double S0;
    double tht;
    double R2A;
    double R2B;

    // assign values to parameters
    S0 = paramcpy(S0_index());

    if (infer_theta)
    {
        tht = paramcpy(th_index());
        /*if (tht < 0.0001)
        {
            tht = 0.0001;
        }
        else if (tht > 1.0)
        {
            tht = 1.0;
        }*/
        
        if (infer_r2)
        {
            R2A = paramcpy(R2A_index());
            R2B = paramcpy(R2B_index());
        }
        else
        {
            R2A = 11.5; // R2 of grey matter
            R2B = 4.0; // R2 of CSF
        }
    }
    else
    {
        tht = 0.0; // only one compartment
        R2B = 1.0; // this bit won't matter if there's only one compartment

        if (infer_r2)
        {
            R2A = paramcpy(R2A_index());
        }
        else
        {
            R2A = 1/0.08; // R2 of grey matter
        }
    }

    // now evaluate standard T2 decay

    // loop through TEs
    result.ReSize(TEs.Nrows());

    for (int i = 1; i <= TEs.Nrows(); i++)
    {
        double TE = TEs(i);

        result(i) = S0 * ( ((1-tht)*exp(-R2A*TE)) + (tht*exp(-R2B*TE)));

    } 

    // make sure that the weighting parameter theta is between 0 and 1
    /*
    if (infer_theta)
    {
        if ( tht > 1.0 || tht < 0.0 )
        {
            for (int ii = 1; ii <= TEs.Nrows(); ii++)
            {
                result(ii) = 0.0;
            }
        }
    }*/

    return;

} // Evaluate
