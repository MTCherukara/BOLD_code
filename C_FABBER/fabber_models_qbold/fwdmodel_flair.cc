/*   fwdmodel_flair.cc - Difference between two images, with and without FLAIR

 Matthew Cherukara, IBME

 Copyright (C) 2019 University of Oxford  */

#include "fwdmodel_flair.h"

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
FactoryRegistration<FwdModelFactory, FlairFwdModel>
    FlairFwdModel::registration("flair");

FwdModel *FlairFwdModel::NewInstance() // unchanged
{
    return new FlairFwdModel();
} // NewInstance

string FlairFwdModel::GetDescription() const 
{
    return "FLAIR ASE difference model";
} // GetDescription

string FlairFwdModel::ModelVersion() const
{
    return "1.0 (2019-06-11)";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FlairFwdModel::Initialize(ArgsType &args)
{
    // read some additional arguments
    prec_lam = convertTo<double>(args.ReadWithDefault("preclam","1e-1"));
    prec_M0  = convertTo<double>(args.ReadWithDefault("precM0","1e-6"));

    // temporary holders for input values
    string TI_temp;

    // Read TR, TE
    TR = convertTo<double>(args.ReadWithDefault("TR","3.000"));
    TE = convertTo<double>(args.ReadWithDefault("TE","0.082"));


    // this parses through the input args for tau1=X, tau2=X and so on, until it reaches a tau
    // that isn't supplied in the argument, and it adds all these to the ColumnVector taus
    while (true)
    {
        int N = TIs.Nrows()+1;
        TI_temp = args.ReadWithDefault("TI"+stringify(N), "stop!");
        if (TI_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(TI_temp);
        TIs &= tmp;

    }

    // add information to the log
    LOG << "Inference using development model" << endl;    
    for (int ii = 1; ii <= TIs.Nrows(); ii++)
    {
        LOG << "TI(" << ii << ") = " << TIs(ii) << endl;
    }    
  
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void FlairFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("M0"); // parameter 1 - M0 magnetization
    names.push_back("lam"); // parameter 2 - lambda CSF volume fraction  

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FlairFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    prior.means(M0_index()) = 1000.0;
    precisions(M0_index(), M0_index()) = prec_M0; // 1e-6
    
    prior.means(lam_index()) = 0.05;
    precisions(lam_index(), lam_index()) = prec_lam; // 1e-1

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
void FlairFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // inference parameters
    double M0;
    double lam;

    // intermediate parameters
    double Mtis;
    double Mcsf;

    // hardcoded parameters
    double T1t = 1.20;
    double T1e = 3.87;
    double T2t = 0.087;
    double T2e = 0.250;
    

    // pull out parameter values
    M0  = (paramcpy(M0_index()));
    lam = (paramcpy(lam_index()));


    // threshold lam
    if (lam < 0.0)
    {
        lam = 0.0;
    }
    else if (lam > 1.0)
    {
        lam = 1.0;
    }
    if (M0 < 1.0)
    {
        M0 = 1.0;
    }

    // loop through taus (not the first one)
    result.ReSize(TIs.Nrows());

    for (int ii = 1; ii <= TIs.Nrows(); ii++)
    {
        double TI = TIs(ii);

        Mtis = 1 - ( ( 2 - exp(-(TR-TI)/T1t) ) * exp(-TI/T1t) ); 
        Mcsf = 1 - ( ( 2 - exp(-(TR-TI)/T1e) ) * exp(-TI/T1e) ); 

        // add T2 effect
        Mtis *= exp(-TE/T2t);
        Mcsf *= exp(-TE/T2e);

        // evaluate linear exponential
        result(ii) = M0*( (lam * Mcsf) + ( (1-lam) * Mtis) );

    }


    return;

} // Evaluate
