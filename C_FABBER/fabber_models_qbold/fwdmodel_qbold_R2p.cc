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
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::Initialize(ArgsType &args)
{
    infer_R2p = args.ReadBool("inferR2p");
    infer_DBV = args.ReadBool("inferDBV");
    infer_R2t = args.ReadBool("inferR2t");
    infer_S0 = args.ReadBool("inferS0");

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

    // add information to the log
    LOG << "Inference using development model" << endl;
    LOG << "    Parameters: TE = " << TE << ", n taus = " << taus.Nrows() << endl;
    if (infer_R2p)
    {
        LOG << "Infering on R2p " << endl;
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

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) *1e-6;

    if (infer_R2p)
    {
        prior.means(R2p_index()) = 5.0;
        precisions(R2p_index(), R2p_index()) = 1e-3;
    }

    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 1;
    }

    if (infer_R2t)
    {
        prior.means(R2t_index()) = 9;
        precisions(R2t_index(), R2t_index()) = 1e-3;
    }

    if (infer_S0)
    {
        prior.means(S0_index()) = 100;
        precisions(S0_index(), S0_index()) = 1e-4;
    }

    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)
    
    if (infer_R2p)
    {
        posterior.means(R2p_index()) = 5.0;
        precisions(R2p_index(), R2p_index()) = 0.1;
    }

    if (infer_DBV)
    {
        posterior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 1;
    }

    if (infer_R2t)
    {
        posterior.means(R2t_index()) = 9;
        precisions(R2t_index(), R2t_index()) = 0.1;
    }

    if (infer_S0)
    {
        posterior.means(S0_index()) = 100;
        precisions(S0_index(), S0_index()) = 0.001;
    }

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

    // assign values to parameters
    if (infer_R2p)
    {
        R2p = pow(pow(paramcpy(R2p_index()),2.0),0.5);
    }
    else
    {
        R2p = 5.0;
    }
    if (infer_DBV)
    {
        DBV = pow(pow(paramcpy(DBV_index()),2.0),0.5);
    }
    else
    {
        DBV = 0.03;
    }
    if (infer_R2t)
    {
        R2t = pow(pow(paramcpy(R2t_index()),2.0),0.5);
    }
    else
    {
        R2t = 9.09;
    }
    if (infer_S0)
    {
        S0 = pow(pow(paramcpy(S0_index()),2.0),0.5);
    }
    else
    {
        S0 = 100.0;
    }

    // now evaluate the static dephasing qBOLD model for 2 compartments
    dw = R2p/DBV;
    OEF = dw/301.7433;

    R2b  = 10.076 + (111.868*pow(OEF,2.0));
    R2bs = 19.766 + (144.514*pow(OEF,2.0));

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int i = 1; i <= taus.Nrows(); i++)
    {
        double tau = taus(i);

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

        // add in the T2 effect to St
        St *= exp(-R2t*TE);

        // blood signal
        Sb = exp(-R2b*(TE-tau)*exp(-R2bs*abs(tau)));

        // Total signal
        result(i) = ((1-DBV)*St) + (DBV*Sb);

    } // for (int i = 1; i <= taus.Nrows(); i++)

    
    // alternative, if DBV is outside the bounds
    if ( DBV > 1.0 )
    {
        for (int i = 1; i <= taus.Nrows(); i++)
        {
            result(i) = 0.0001;
        }
    }
    

    return;

} // Evaluate
