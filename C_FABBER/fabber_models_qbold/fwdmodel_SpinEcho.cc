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
    return "1.1";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void SpinEchoFwdModel::Initialize(ArgsType &args)
{
    // see whether we want a bi-exponential model or not
    biexpon = args.ReadBool("biexpon");

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
    if (biexpon)
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

    names.push_back("R2A"); // parameter 1 - R2A
    names.push_back("S0");  // parameter 2 - S0 scaling factor
    if (biexpon)
    {
        names.push_back("R2B");
        names.push_back("theta");
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

    // R2
    prior.means(R2A_index()) = 9.0;
    precisions(R2A_index(), R2A_index()) = 0.001; // 1e-2

    // S0
    prior.means(S0_index()) = 500;
    precisions(S0_index(), S0_index()) = 0.00001; // 1e-4

    if (biexpon)
    {
        prior.means(R2B_index()) = 20.0;
        precisions(R2B_index(), R2B_index()) = 0.001; // 1e-2
        
        prior.means(th_index()) = 0.5;
        precisions(th_index(), th_index()) = 0.1; // 1e-1
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
    double R2A;
    double S0;
    double R2B;
    double tht;

    // assign values to parameters
    R2A = paramcpy(R2A_index());
    S0 = paramcpy(S0_index());

    // pull out bi-exponential parameters if required
    if (biexpon)
    {
        R2B = paramcpy(R2B_index());
        tht = abs(paramcpy(th_index()));
    }
    else
    {
        R2B = 1.0;
        tht = 0.0;
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
    
    if (biexpon)
    {
        if ( tht > 1.0 )
        {
            for (int ii = 1; ii <= TEs.Nrows(); ii++)
            {
                result(ii) = 0.0;
            }
        }
    }

    return;

} // Evaluate
