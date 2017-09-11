/*   fwdmodel_qbold_vols.cc - Implements the ASE qBOLD curve fitting model
                              based on compartment volumes

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_qbold_vols.h"

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
FactoryRegistration<FwdModelFactory, qvolFwdModel>
    qvolFwdModel::registration("qboldvols");

FwdModel *qvolFwdModel::NewInstance() // unchanged
{
    return new qvolFwdModel();
} // NewInstance

string qvolFwdModel::GetDescription() const 
{
    return "ASE qBOLD model compartment volume version";
} // GetDescription

string qvolFwdModel::ModelVersion() const
{
    return "1.0";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void qvolFwdModel::Initialize(ArgsType &args)
{
    
    infer_S0  = args.ReadBool("inferS0");
    infer_R2p = args.ReadBool("inferR2p");
    infer_DBV = args.ReadBool("inferDBV");
    infer_lam = args.ReadBool("inferlam");
    infer_vw  = args.ReadBool("inferVW"); 

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
            TE_temp = args.ReadWithDefault("TE"+stringify(i), "0.074");
        }

        ColumnVector tmp(1);
        tmp = convertTo<double>(TE_temp);
        TEvals &= tmp;

    }


    // add information to the log
    LOG << "Inference using development model" << endl;    
    for (int i = 1; i <= taus.Nrows(); i++)
    {
        LOG << "    TE(" << i << ") = " << TEvals(i) << "    tau(" << i << ") = " << taus(i) << endl;
    }
    if (infer_S0)
    {
        LOG << "Inferring on scaling parameter S0" << endl;
    }
    if (infer_R2p)
    {
        LOG << "Infering on R2' " << endl;
    }
    if (infer_DBV)
    {
        LOG << "Inferring on deoxygenated blood volume" << endl;
    }
    if (infer_lam)
    {
        LOG << "Inferring on CSF volume fraction lambda" << endl;
    }
    if (infer_vw)
    {
        LOG << "Inferring on white matter volume fraction" << endl;
    }
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void qvolFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_S0)
    {
        names.push_back("S0");  // parameter 4 - S0 scaling factor
    }
    if (infer_R2p)
    {
        names.push_back("R2p"); // parameter 2 - R2-prime
    }
    if (infer_DBV)
    {
        names.push_back("DBV");  // parameter 3 - DBV
    }
    if (infer_lam)
    {
        names.push_back("lam");  // parameter 4 - lambda (CSF vol)
    }
    if (infer_vw)
    {
        names.push_back("VW");  // parameter 5 - vol white matter
    }

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void qvolFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    if (infer_S0)
    {
        prior.means(S0_index()) = 400;
        precisions(S0_index(), S0_index()) = 0.0001; // 1e-4
    }
    if (infer_R2p)
    {
        prior.means(R2p_index()) = 5.0;
        precisions(R2p_index(), R2p_index()) = 0.01; // 1e-2
    }

    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.05;
        precisions(DBV_index(), DBV_index()) = 0.1; // 1e-1
    }

    if (infer_lam)
    {
        prior.means(lam_index()) = 0.001;
        precisions(lam_index(), lam_index()) = 0.1; // 1-e1
    }

    if (infer_vw)
    {
        prior.means(lam_index()) = 0.1;
        precisions(lam_index(), lam_index()) = 0.1; // 1-e1
    }

    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void qvolFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    result.ReSize(data.Nrows());

    ColumnVector paramcpy = params;

    // calculated parameters
    double St;  // tissue signal, which will divide into: 
    double Sg;  // grey matter signal
    double Sw;  // white matter signal

    double Sb;  // blood signal
    double Se;  // extracellular signal
    complex<double> Sec; // complex version of the extracellular signal (may be unnecessary)

    complex<double> i(0,1);

    // derived parameters
    double dw;
    double R2b;
    double R2bs;
    double OEF;
    double vg;      // grey matter (everything else) volume

    // fixed parameters
    double R2g =  9.09;     // grey matter (all at 3T)
    double R2w = 12.50;     // white matter
    double R2e =  4.00;     // CSF
    double dF  =  5.00;     // frequency difference GM vs CSF

    // parameters
    double S0;
    double R2p;
    double DBV;
    double lam;
    double vw;      // white matter volume

    // assign values to parameters
    if (infer_S0)
    {
        S0 = abs(paramcpy(S0_index()));
    }
    else
    {
        S0 = 100.0;
    }
    if (infer_R2p)
    {
        R2p = abs(paramcpy(R2p_index()));
    }
    else
    {
        R2p = 5.0;
    }
    if (infer_DBV)
    {
        DBV = abs(paramcpy(DBV_index()));
    }
    else
    {
        DBV = 0.03;
    }
    if (infer_lam)
    {
        lam = abs(paramcpy(lam_index()));
    }
    else
    {
        lam = 0.0;
    }
    if (infer_vw)
    {
        vw = abs(paramcpy(vw_index()));
    }
    else
    {
        vw = 0.1;
    }

    // now evaluate the static dephasing qBOLD model for 2 compartments
    dw = R2p/DBV;
    OEF = dw/301.7433;
    vg = 1.0 - (vw + DBV + lam);

    R2b  = 10.076 + (111.868*pow(OEF,2.0));
    R2bs = 19.766 + (144.514*pow(OEF,2.0));

    // loop through taus
    result.ReSize(taus.Nrows());

    for (int i = 1; i <= taus.Nrows(); i++)
    {
        double tau = taus(i);
        double TE = TEvals(i);

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

        // calculate tissue signals in grey and white matter
        Sg = St*exp(-R2g*TE);
        Sw = St*exp(-R2w*TE);

        // calculate blood signal
        Sb = exp(-R2b*(TE-tau))*exp(-R2bs*abs(tau));

        // calculate extracellular signal
        Sec = exp(-R2e*TE)*exp(-2*i*M_PI*dF*abs(tau));
        Se = Sec.real();

        // Total signal
        result(i) = S0*((vg*Sg) + (vw*Sw) + (DBV*Sb) + (lam*Se));

    } // for (int i = 1; i <= taus.Nrows(); i++)

    
    // alternative, if DBV or Lambda or VW are outside the bounds
    if ( DBV > 1.0 )
    {
        for (int i = 1; i <= taus.Nrows(); i++)
        {
            result(i) = 1e8;
        }
    }
    else if ( lam > 1.0 )
    {
        for (int i = 1; i <= taus.Nrows(); i++)
        {
            result(i) = 1e8;
        }
    }
    else if ( vw > 1.0 )
    {
        for (int i = 1; i <= taus.Nrows(); i++)
        {
            result(i) = 1e8;
        }
    }
    

    return;

} // Evaluate
