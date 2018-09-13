/*   fwdmodel_phenom.cc - Fits the coefficients of the Dickson qBOLD model

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#include "fwdmodel_phenom.h"

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
FactoryRegistration<FwdModelFactory, PhenomFwdModel>
    PhenomFwdModel::registration("phenom");

FwdModel *PhenomFwdModel::NewInstance() // unchanged
{
    return new PhenomFwdModel();
} // NewInstance

string PhenomFwdModel::GetDescription() const 
{
    return "Fitting coefficients of phenomenological model";
} // GetDescription

string PhenomFwdModel::ModelVersion() const
{
    return "0.1 - 2018-09-13";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void PhenomFwdModel::Initialize(ArgsType &args)
{

    // First read tau values, since these will always be specified

    // temporary holder
    string tau_temp;

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

    OEF = convertTo<double>(args.ReadWithDefault("OEF","0.400"));
    DBV = convertTo<double>(args.ReadWithDefault("DBV","0.030"));
    TE  = convertTo<double>(args.ReadWithDefault("TE", "0.074"));

    // add information to the log
    LOG << "Inference using development model" << endl;
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        LOG << "    tau(" << ii << ") = " << taus(ii) << endl;
    }
    
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void PhenomFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("b11"); 
    names.push_back("b12"); 
    names.push_back("b13"); 
    names.push_back("b21"); 
    names.push_back("b22"); 
    names.push_back("b23"); 
    names.push_back("b31"); 
    names.push_back("b32"); 
    names.push_back("b33"); 

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void PhenomFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    prior.means(b11_index()) = 50.0;
    precisions(b11_index(), b11_index()) = 1e-6;

    prior.means(b12_index()) = 50.0;
    precisions(b12_index(), b12_index()) = 1e-6;

    prior.means(b13_index()) = 0.0;
    precisions(b13_index(), b13_index()) = 1e-6;

    prior.means(b21_index()) = 30.0;
    precisions(b21_index(), b21_index()) = 1e-6;

    prior.means(b22_index()) = 30.0;
    precisions(b22_index(), b22_index()) = 1e-6;

    prior.means(b22_index()) = 0.0;
    precisions(b22_index(), b22_index()) = 1e-6;

    prior.means(b22_index()) = 0.0;
    precisions(b22_index(), b22_index()) = 1e-6;

    prior.means(b22_index()) = 0.0;
    precisions(b22_index(), b22_index()) = 1e-6;

    prior.means(b22_index()) = 3.0;
    precisions(b22_index(), b22_index()) = 1e-6;


    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void PhenomFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double F;
    double ST;
    double a1;
    double a2;
    double a3;

    // model coefficients
    double b11;
    double b12;
    double b13;
    double b21;
    double b22;
    double b23;
    double b31;
    double b32;
    double b33;

    // assign values to parameters
    b11 = paramcpy(b11_index());
    b12 = paramcpy(b12_index());
    b13 = paramcpy(b13_index());
    b21 = paramcpy(b21_index());
    b22 = paramcpy(b22_index());
    b23 = paramcpy(b23_index());
    b31 = paramcpy(b31_index());
    b32 = paramcpy(b32_index());
    b33 = paramcpy(b33_index());

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        double tau = taus(ii);

        a1 = OEF*(b11 - (b12 * exp(-b13*OEF)));
        a2 = OEF*(b21 - (b22 * exp(-b23*OEF)));
        a3 = OEF*(b31 - (b32 * exp(-b33*OEF)));

        F = ( a1*(exp(-a2*abs(1000*tau)) - 1) ) + (a3*abs(1000*tau));

        result(ii) = exp(-DBV*F);
    

    }

    return;

} // Evaluate
