/*   fwdmodel_sqbold.cc - The ASE streamlined qBOLD model, for 
            inference on linear taus and the spin-echo only.

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#include "fwdmodel_sqbold.h"

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
FactoryRegistration<FwdModelFactory, sqBOLDFwdModel>
    sqBOLDFwdModel::registration("sqBOLD");

FwdModel *sqBOLDFwdModel::NewInstance() // unchanged
{
    return new sqBOLDFwdModel();
} // NewInstance

string sqBOLDFwdModel::GetDescription() const 
{
    return "ASE sqBOLD model linear version";
} // GetDescription

string sqBOLDFwdModel::ModelVersion() const
{
    return "1.1 (2019-02-11)";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void sqBOLDFwdModel::Initialize(ArgsType &args)
{

    // temporary holders for input values
    string tau_temp;

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

    // add information to the log
    LOG << "Inference using development model" << endl;    
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        LOG << "tau(" << ii << ") = " << taus(ii) << endl;
    }    
  
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void sqBOLDFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("R2p"); // parameter 1 - R2 prime
    names.push_back("DBV"); // parameter 2 - DBV
    names.push_back("S0");  // parameter 4 - S0 scaling factor
  

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void sqBOLDFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    prior.means(R2p_index()) = 4.0;
    precisions(R2p_index(), R2p_index()) = 1e-4; // 1e-3 or 1e0
    
    prior.means(DBV_index()) = 0.05;
    precisions(DBV_index(), DBV_index()) = 1e-1; // 1e0 or 1e3
    
    prior.means(S0_index()) = 100.0;
    precisions(S0_index(), S0_index()) = 1e-5; // 1e-5

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
void sqBOLDFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // parameters
    double R2p;
    double DBV;
    double S0;

    // pull out parameter values
    R2p = (paramcpy(R2p_index()));
    DBV = (paramcpy(DBV_index()));
    S0 = (paramcpy(S0_index()));

    // loop through taus (not the first one)
    result.ReSize(taus.Nrows());

    result(1) = S0;

    for (int ii = 2; ii <= taus.Nrows(); ii++)
    {
        double tau = taus(ii);
        
        // evaluate linear exponential
        result(ii) = S0*exp(DBV-(R2p*tau));

    }


    return;

} // Evaluate
