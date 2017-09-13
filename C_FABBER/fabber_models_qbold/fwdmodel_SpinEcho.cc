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
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void SpinEchoFwdModel::Initialize(ArgsType &args)
{

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

    names.push_back("R2"); // parameter 1 - R2
    names.push_back("S0"); // parameter 2 - S0 scaling factor

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
    prior.means(R2_index()) = 9.0;
    precisions(R2_index(), R2_index()) = 0.01; // 1e-2

    // S0
    prior.means(S0_index()) = 500;
    precisions(S0_index(), S0_index()) = 0.0001; // 1e-4
    
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
    double R2;
    double S0;

    // assign values to parameters
    R2 = paramcpy(R2_index());
    S0 = paramcpy(S0_index());

    // now evaluate standard T2 decay

    // loop through TEs
    result.ReSize(TEs.Nrows());

    for (int i = 1; i <= TEs.Nrows(); i++)
    {
        double TE = TEs(i);

        result(i) = S0*exp(-R2*TE);

    } 

    return;

} // Evaluate
