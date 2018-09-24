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
#include <miscmaths/miscmaths.h>
#include <cmath>

using namespace std;
using namespace NEWMAT;
using MISCMATHS::digamma;
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

    // Decide on inference targets
    infer_OEF = args.ReadBool("inferOEF");
    infer_DBV = args.ReadBool("inferDBV");

    // Decide on ARD
    doard = args.ReadBool("doard");

    // Read tau values

    // temporary holder
    string tau_temp;

    
    // Check whether tau_start has been supplied
    tau_temp = args.ReadWithDefault("tau_start", "nope");
 
    if (tau_temp == "nope")
    {
        // since there is no tau_start, read through individual taus as before:
        while (true)
        {
            int N = taus.Nrows()+1;
            tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
            if (tau_temp == "stop!") break;

            ColumnVector tmp(1);
            tmp = convertTo<double>(tau_temp);
            taus &= tmp;

        }
    } // if (tau_temp == "nope") 

    else
    { 
        // read in specificied tau parameters        
        tau_start = convertTo<double>(tau_temp);;
        tau_end   = convertTo<double>(args.ReadWithDefault("tau_end", "0.064"));;
        tau_step  = convertTo<double>(args.ReadWithDefault("tau_step", "0.004"));;

        // generate a column-vector of taus
        double tau_val = tau_start;

        // populate the taus vector
        while (tau_val <= tau_end + 0.0001)
        {
            ColumnVector tmp(1);
            tmp = tau_val;
            taus &= tmp;
            tau_val += tau_step;
        }
        

    } // if (tau_temp == "nope") ... else ...

    // Read TE
    TE  = convertTo<double>(args.ReadWithDefault("TE", "0.074"));

    // read OEF/DBV information
    if (!infer_OEF)
    {
        fixedOEF = convertTo<double>(args.ReadWithDefault("OEF","0.400"));
    }
    if (!infer_DBV)
    {
        fixedDBV = convertTo<double>(args.ReadWithDefault("DBV","0.030"));
    }

    // add information to the log
    LOG << "Inference using development model" << endl;
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        LOG << "    tau(" << ii << ") = " << taus(ii) << endl;
    }
    if (infer_OEF)
    {
        LOG << "Inferring on OEF " << endl;
    }
    else
    {
        LOG << "OEF fixed to " << fixedOEF << endl;
    }
    if (infer_DBV)
    {
        LOG << "Inferring on DBV " << endl;
    }
    else
    {
        LOG << "DBV fixed to " << fixedDBV << endl;
    }
    if (doard)
    {
        LOG << "Using Automatic Relevance Detection (ARD)" << endl;
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
    if (infer_OEF)
    {
        names.push_back("OEF"); // parameter 1 - Oxygen Extraction Fraction
    }
    if (infer_DBV)
    {
        names.push_back("DBV"); // parameter 2 - DBV
    }

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

    // b11
    prior.means(1) = 55.0; // 55.0
    precisions(1, 1) = 1e-2;

    // b12
    prior.means(2) = 55.0; // 55.0
    precisions(2, 2) = 1e-2;

    // b13
    prior.means(3) = -0.024; // -0.024
    precisions(3, 3) = 1e2;

    // b21
    prior.means(4) = 35.0; // 35.0
    precisions(4, 4) = 1e-2;

    // b22
    prior.means(5) = 35.0; // 35.0
    precisions(5, 5) = 1e-2;

    // b23
    prior.means(6) = -0.0034; // -0.0034;
    precisions(6, 6) = 1e3;

    // b31
    prior.means(7) = 0.3; // 0.3;
    precisions(7, 7) = 1e1;

    // b32
    prior.means(8) = 0.3; // 0.3;
    precisions(8, 8) = 1e1;

    // b33
    prior.means(9) = 3.0; // 3.0;
    precisions(9, 9) = 1e-1;

    if (infer_OEF)
    {
        prior.means(OEF_index()) = 0.40;
        precisions(OEF_index(), OEF_index()) = 1e-1;
    }
    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.03;
        precisions(DBV_index(), DBV_index()) = 1e1;
    }


    prior.SetPrecisions(precisions);

    posterior = prior;

    // set distributions for initial posteriors

    /*
    posterior.means(1) = 55.4;
    precisions(1, 1) = 1e-1; 
    posterior.means(2) = 52.7;
    precisions(2, 2) = 1e-1; 
    posterior.means(3) = -0.0242;
    precisions(3, 3) = 1e2; 
    posterior.means(4) = 35.0;
    precisions(4, 4) = 1e-1; 
    posterior.means(5) = 35.0;
    precisions(5, 5) = 1e-1; 
    posterior.means(6) = -0.003;
    precisions(6, 6) = 1e2; 
    posterior.means(7) = 0.3;
    precisions(7, 7) = 1e1; 
    posterior.means(8) = 0.3;
    precisions(8, 8) = 1e1; 
    posterior.means(9) = 3.0;
    precisions(9, 9) = 1e0; 
    
    posterior.SetPrecisions(precisions);
    */

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

    // physiological parameters
    double OEF;
    double DBV;

    if (infer_OEF)
    {
        OEF = paramcpy(OEF_index());
    }
    else
    {
        OEF = fixedOEF;
    }
    if (infer_DBV)
    {
        DBV = abs(paramcpy(DBV_index()));
    }
    else
    {
        DBV = fixedDBV;
    }

    // assign values to parameters
    b11 = paramcpy(1);
    b12 = paramcpy(2);
    b13 = paramcpy(3);
    b21 = paramcpy(4);
    b22 = paramcpy(5);
    b23 = paramcpy(6);
    b31 = paramcpy(7);
    b32 = paramcpy(8);
    b33 = paramcpy(9);

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

// ------------------------------------------------------------------------------------------
// --------         SetupARD                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void PhenomFwdModel::SetupARD(const MVNDist &theta, MVNDist &thetaPrior, double &Fard)
{
    if (doard)
    {
        Fard = 0;

        // loop over 9 parameters in a hard-coded way
        for (int ii = 1; ii < 10; ii++)
        {
            SymmetricMatrix PriorPrec;

            PriorPrec = thetaPrior.GetPrecisions();

            PriorPrec(ii, ii) = 1e-12; // non-informative

            thetaPrior.SetPrecisions(PriorPrec);

            thetaPrior.means(ii) = 0; // no mean

            // calculate Free energy contribution
            SymmetricMatrix PostCov = theta.GetCovariance();

            double b = 2 / (theta.means(ii) * theta.means(ii) + PostCov(ii, ii));

            Fard += -1.5 * (log(b) + digamma(0.5)) - 0.5 - gammaln(0.5) - 0.5 * log(b);

        } // for (int ii = 1; ii < 10; ii++)
    }
    return;
}

// ------------------------------------------------------------------------------------------
// --------         UpdateARD                   ---------------------------------------------
// ------------------------------------------------------------------------------------------
void PhenomFwdModel::UpdateARD(const MVNDist &theta, MVNDist &thetaPrior, double &Fard) const
{
    if (doard)
        Fard = 0;
    {

        // loop over 9 parameters
        for (int ii = 1; ii < 10; ii++)
        {
            SymmetricMatrix PriorCov;
            SymmetricMatrix PostCov;

            PriorCov = thetaPrior.GetCovariance();
            PostCov = theta.GetCovariance();

            PriorCov(ii, ii) = theta.means(ii) * theta.means(ii) + PostCov(ii, ii);

            thetaPrior.SetCovariance(PriorCov);

            // Calculate Free energy contribution
            double b = 2 / (theta.means(ii) * theta.means(ii) + PostCov(ii, ii));
            Fard += -1.5 * (log(b) + digamma(0.5)) - 0.5 - gammaln(0.5) - 0.5 * log(b);

        } // for (int ii = 1; ii < 10; ii++)
    }
    return;
}