/*   fwdmodel_qbold_T2.cc - Implements the ASE qBOLD curve fitting model
                            with T2 decay

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_qbold_T2.h"

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
FactoryRegistration<FwdModelFactory, T2qBoldFwdModel>
    T2qBoldFwdModel::registration("qboldT2");

FwdModel *T2qBoldFwdModel::NewInstance() // unchanged
{
    return new T2qBoldFwdModel();
} // NewInstance

string T2qBoldFwdModel::GetDescription() const 
{
    return "ASE qBOLD model with T2 decay";
} // GetDescription

string T2qBoldFwdModel::ModelVersion() const
{
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void T2qBoldFwdModel::Initialize(ArgsType &args)
{
    // read through input arguments using &args
    TE = convertTo<double>(args.ReadWithDefault("TE","0.074"));

    // collect tau values
    string tau_temp;

    // this parses through the input args for tau1=X, tau2=X and so on, until it reaches a
    // tau that isn't supplied in the argument, and it adds all these to the ColumnVector
    // called tau_list
    while (true)
    {
        int N = tau_list.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        tau_list &= tmp;
    }

    taus = tau_list; // why is this necessary?
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void T2qBoldFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("OEF"); // parameter 1 - OEF
    names.push_back("DBV"); // parameter 2 - DBV
    names.push_back("T2");  // parameter 3 - T2 (of tissue)

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void T2qBoldFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) *1e-12;

    prior.means(1) = 0.5;   // set initial guess of R2p to be 5
    prior.means(2) = 0.05;  // set initial guess of DBV to be 0.05
    prior.means(3) = 0.11;  // set initial guess of T2 to be 110 ms

    precisions(1, 1) = 1;  // set all priors to be completely uniformative
    precisions(2, 2) = 1; 
    precisions(3, 3) = 1; 


    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)
    

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------

// gotta fix this so that it includes T2 decay properly
void T2qBoldFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double St;  // tissue signal
    double Sb;  // blood signal

    // derived parameters
    double dw;
    double R2b;
    double R2bs;
    double R2tp;

    // parameters
    double OEF = paramcpy(1);
    double DBV = paramcpy(2);
    double T2  = paramcpy(3);

    // now evaluate the static dephasing qBOLD model for 2 compartments
    dw = 301.7433*OEF;
    R2tp = DBV*dw;

    R2b  = 10.076 + (111.868*pow(OEF,2.0));
    R2bs = 19.766 + (144.514*pow(OEF,2.0));

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int i = 1; i <= taus.Nrows(); i++)
    {
        double tau = taus(i);

        if (tau < (-1.5/dw))
        {
            St = exp(DBV + (R2tp*tau));
        }
        else if (tau > (1.5/dw))
        {
            St = exp(DBV - (R2tp*tau));
        }
        else
        {
            St = exp(-0.3*DBV*pow(dw*tau,2.0));
        }

        // add in the T2 effect to St
        St *= exp(-TE/T2);

        // blood signal
        Sb = exp(-R2b*(TE-tau)*exp(-R2bs*abs(tau)));

        // Total signal
        result(i) = ((1-DBV)*St) + (DBV*Sb);

    } // for (int i = 1; i <= taus.Nrows(); i++)

    return;

} // Evaluate

