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
    // Parse input to decide which parameters to infer on
    infer_OEF = args.ReadBool("inferOEF");
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
    if (infer_OEF)
    {
        LOG << "Infering on OEF " << endl;
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

void T2qBoldFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_OEF)
    {
        names.push_back("OEF"); // parameter 1 - OEF
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
void T2qBoldFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) *1e-3;

    if (infer_OEF)
    {
        prior.means(OEF_index()) = 0.7;
        precisions(OEF_index(), OEF_index()) = 0.1;
    }

    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 0.1;
    }

    if (infer_R2t)
    {
        prior.means(R2t_index()) = 9;
        precisions(R2t_index(), R2t_index()) = 0.01;
    }

    if (infer_S0)
    {
        prior.means(S0_index()) = 100;
        precisions(S0_index(), S0_index()) = 0.0001;
    }

    prior.SetPrecisions(precisions);

    posterior = prior;

    // Choose more sensible initial posteriors

    if (infer_OEF)
    {
        posterior.means(OEF_index()) = 0.7;
        precisions(OEF_index(), OEF_index()) = 1e-3;
    }

    if (infer_DBV)
    {
        posterior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 1e-3;
    }

    if (infer_R2t)
    {
        posterior.means(R2t_index()) = 9.0;
        precisions(R2t_index(), R2t_index()) = 1e-3;
    }

    if (infer_S0)
    {
        posterior.means(S0_index()) = 100;
        precisions(S0_index(), S0_index()) = 1e-3;
    }

    posterior.SetPrecisions(precisions);
    

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
    double OEF;
    double DBV;
    double R2t;
    double S0;

    // make sure parameter values are sensible - this may not be so great...
    /*
    if (infer_OEF)
    {
        if (params(OEF_index()) > 1.0)
        {
            paramcpy(OEF_index()) = 1.0;
        }
        if (params(OEF_index()) < 0.0001)
        {
            paramcpy(OEF_index()) = 0.0001;
        }
    }
    if (infer_DBV)
    {
        if (params(DBV_index()) > 1.0)
        {
            paramcpy(DBV_index()) = 1.0;
        }
        if (params(DBV_index()) < 0.0001)
        {
            paramcpy(DBV_index()) = 0.0001;
        }
    }
    if (infer_R2t)
    {
        if (params(R2t_index()) < 0.0001)
        {
            paramcpy(R2t_index()) = 0.0001;
        }
    }
    if (infer_S0)
    {
        if (params(S0_index()) < 0.0001)
        {
            paramcpy(S0_index()) = 0.0001;
        }
    }
    */

    // assign values to parameters
    if (infer_OEF)
    {
        OEF = abs(paramcpy(OEF_index()));
    }
    else
    {
        OEF = 0.4;
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
        R2t = 9.09;
    }
    if (infer_S0)
    {
        S0 = abs(paramcpy(S0_index()));
    }
    else
    {
        S0 = 100.0;
    }

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

        // No IV version
        //result(i) = S0*St;

        
        // add in the T2 effect to St
        St *= exp(-R2t*TE);

        // blood signal
        Sb = exp(-R2b*(TE-tau))*exp(-R2bs*abs(tau));

        // Total signal
        result(i) = S0*(((1-DBV)*St) + (DBV*Sb));
        

    } // for (int i = 1; i <= taus.Nrows(); i++)

    // alternatives for ridiculous values
    if (OEF > 1.0 || DBV > 1.0 )
    {
        for (int i = 1; i <= taus.Nrows(); i++)
        {
            result(i) = 0.0001;
        }
    }


    return;

} // Evaluate

