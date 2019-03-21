/*   fwdmodel_FreqShift.cc - ASE qBOLD fitting of frequency shift DF by comparing FLAIR and nonFLAIR data


 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#include "fwdmodel_FreqShift.h"

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
FactoryRegistration<FwdModelFactory, FreqShiftFwdModel>
    FreqShiftFwdModel::registration("freqShift");

FwdModel *FreqShiftFwdModel::NewInstance() // unchanged
{
    return new FreqShiftFwdModel();
} // NewInstance

string FreqShiftFwdModel::GetDescription() const 
{
    return "CSF Frequency Shift fitting model";
} // GetDescription

string FreqShiftFwdModel::ModelVersion() const
{
    return "1.2 (March 2019)";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::Initialize(ArgsType &args)
{
    // read boolean arguments
    infer_VC = args.ReadBool("inferVC");
    infer_DF = args.ReadBool("inferDF");
    infer_R2p = args.ReadBool("inferR2p");
    infer_DBV = args.ReadBool("inferDBV");
    infer_phi = args.ReadBool("inferphi");

    // allow for manual entry of prior precisions
    prec_R2p = convertTo<double>(args.ReadWithDefault("precR2p","1e-3"));
    prec_DBV = convertTo<double>(args.ReadWithDefault("precDBV","1e0"));
    prec_CSF = convertTo<double>(args.ReadWithDefault("precCSF","1e-1"));
    prec_DF = convertTo<double>(args.ReadWithDefault("precDF","1e-1"));

    
    string tau_temp; 

    while (true)
    {
        int N = taus.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;

        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        taus &= tmp;

    }

    // get scan information
    TE = convertTo<double>(args.ReadWithDefault("TE", "0.082"));
    TI = convertTo<double>(args.ReadWithDefault("TI", "1.210"));
    TR = convertTo<double>(args.ReadWithDefault("TR", "3.000"));

    // add information to the log
    LOG << "Inference using development model" << endl;     
    LOG << "Inferring on Magnetization M0" << endl;
    if (infer_R2p)
    {
        LOG << "Inferring on Reversible Transverse Dephasing R2'" << endl;
    }
    if (infer_DBV)
    {
        LOG << "Inferring on DBV" << endl;
    }
    if (infer_VC)
    {
        LOG << "Inferring on CSF Volume" << endl;
    }
    if (infer_DF)
    {
        LOG << "Inferring on CSF Frequency Shift" << endl;
    }
    if (infer_phi)
    {
        LOG << "Inferring on CSF Phase" << endl;
    }

    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void FreqShiftFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    names.push_back("M0");   // parameter 1 - Magnetization M0
    if (infer_VC)
    {
        names.push_back("VC");   // parameter 2 - V^CSF
    }
    if (infer_DF)
    {
        names.push_back("DF");   // parameter 3 - Delta F
    }
    if (infer_R2p)
    {
        names.push_back("R2p");  // parameter 4 - R2-prime (tissue)
    }
    if (infer_DBV)
    {
        names.push_back("DBV");  // parameter 5 - DBV
    }
    if (infer_phi)
    {
        names.push_back("phi");  // parameter 6 - Phase shift phi
    }

    

} // NameParams

// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const
{
    // make sure we have the right number of means specified
    assert(prior.means.Nrows() == NumParams());

    // create diagonal matrix to store precisions
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-6;
    
    // parameter 1 - Magnetization M0 
    prior.means(M0_index()) = 1500.0;
    precisions(M0_index(), M0_index()) = 1e-6; // 1e-6

    // parameter 2 - V^CSF
    if (infer_VC)
    {
        prior.means(VC_index()) = 0.05;
        precisions(VC_index(), VC_index()) = prec_CSF; // 1e-1
    }

    // parameter 3 - Delta F
    if (infer_DF)
    {
        prior.means(DF_index()) = 5.0;
        precisions(DF_index(), DF_index()) = prec_DF; // 1e-2
    }

    // parameter 4 - R2-prime (Tissue)
    if (infer_R2p)
    {
        prior.means(R2p_index()) = 2.6;
        precisions(R2p_index(), R2p_index()) = prec_R2p; // 1e-3
    }
    
    // parameter 5 - DBV
    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.036;
        precisions(DBV_index(), DBV_index()) = prec_DBV; // 1e0
    }

    // parameter 6 - CSF Phase shift phi
    if (infer_phi)
    {
        prior.means(phi_index()) = 0.0;
        precisions(phi_index(), phi_index()) = 1e-3; // 1e-1
    }


    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

} // HardcodedInitialDists

// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void FreqShiftFwdModel::Evaluate(const ColumnVector &params, ColumnVector &result) const
{
    // Check we have been given the right number of parameters
    assert(params.Nrows() == NumParams());
    // result.ReSize(data.Nrows()); // is this line necessary?

    ColumnVector paramcpy = params;

    // inferred parameters
    double M0;
    double VC;
    double DF;
    double R2p; 
    double DBV; 
    double phi;

    // fixed-value parameters
    double T1t = 1.200;     // Grey matter T1 (Lu et al., 2005)
    double T1e = 3.870;     // CSF T1 (Lu et al., 2005)  
    double T1b = 1.580;     // Blood T1 (Lu et al., 2004)
    double T1w = 0.730;     // White matter T1 (Lue et al., 2005)
    double R2t = 11.5;      // Grey matter T2=87ms (He & Yablonskiy, 2007)
    /// double R2e = 0.65;      // CSF T2=1573ms (Qin, 2011) 
    double R2e = 4.00;      // CSF T2=250ms (He & Yablonskiy, 2007)
    double Hct = 0.40;

    double nt = 0.723;
    double ne = 1.000;
    double nb = 0.775;

    // calculated parameters
    double OEF;
    double dw;
    double mt;
    double me;
    double mb;
    double lam0;        // apparent lambda
    double CBV;         // apparent DBV
    double tc;
    double R2b;
    double R2bp;

    complex<double> i(0,1);

    // assign values to parameters
    M0 = (paramcpy(M0_index()));
    if (infer_VC)
    {
        VC = (paramcpy(VC_index()));
        if (VC < 0.0001)
        {
            VC = 0.0001;
        }
        else if (VC > 1.0)
        {
            VC = 1.0;
        }
    }
    else
    {
        VC = 0.01;
    }
    if (infer_DF)
    {
        DF = (paramcpy(DF_index()));
    }
    else
    {
        DF = 5.0;
    }
    if (infer_R2p)
    {
        R2p = (paramcpy(R2p_index()));
    } 
    else
    {
        R2p = 2.6;
    }
    if (infer_DBV)
    {
        DBV = (paramcpy(DBV_index()));
        if (DBV < 0.0001)
        {
            DBV = 0.0001;
        }
        else if (DBV > 1.0)
        {
            DBV = 1.0;
        }
    }
    else
    {
        DBV = 0.03;
    }
    if (infer_phi)
    {
        phi = (paramcpy(phi_index()));
    }
    else
    {
        phi = 0.0; 
    }

    // calculate parameters
    dw = R2p/DBV;
    OEF = R2p/(887.4082*DBV*Hct);

    // calculate tc
    tc = 1.7/dw;

    // evaluate blood relaxation rates
    R2b  = ( 4.5 + (16.4*Hct)) + ( ((165.2*Hct) + 55.7)*pow(OEF,2.0) );
    R2bp = (10.2 - ( 1.5*Hct)) + ( ((136.9*Hct) - 13.9)*pow(OEF,2.0) );

    result.ReSize(2*taus.Nrows());

    // loop through FLAIR data
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        // component parameters
        double St;      // tissue (grey matter)
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        // magnetization
        mt = exp(-TE*R2t) * ( 1 - ( 1 + (2*exp(TE/(2*T1t))) ) * ( 2 - exp(-(TR-TI)/T1t)) * exp(-TI/T1t) );
        mb = exp(-TE*R2b) * ( 1 - ( 1 + (2*exp(TE/(2*T1b))) ) * ( 2 - exp(-(TR-TI)/T1b)) * exp(-TI/T1b) );
        me = exp(-TE*R2e) * ( 1 - ( 1 + (2*exp(TE/(2*T1e))) ) * ( 2 - exp(-(TR-TI)/T1e)) * exp(-TI/T1e) );

        // calculate tissue compartment weightings
        lam0 = (ne*me*VC) / ( (nt*mt*(1-VC)) + (ne*me*VC) );
        CBV = nb*mb*(1-lam0)*DBV;

        double tau = taus(ii);

        // Tissue Component
        if (tau < -tc)
        {
            St = exp(DBV + (R2p*tau));
        }
        else if (tau > tc)
        {    
            St = exp(DBV - (R2p*tau));
        }
        else
        {
            St = exp(-0.3*pow(R2p*tau,2.0)/DBV);
        }

        St *= (exp(-R2t*TE));

        // linear model
        Sb = exp(-R2b*TE)*exp(-R2bp*abs(tau));

        // CSF Component
        Sec = exp(-R2e*TE)*exp(-2.0*i*M_PI*DF*abs(tau));
        Se = real(Sec);

        // Total
        result(ii) = M0*(((1-CBV-lam0)*St) + (CBV*Sb) + (lam0*Se));
    }

    // loop through non-FLAIR data
    for (int jj = (taus.Nrows()+1); jj <= 2*taus.Nrows(); jj++)
    {
        // component parameters
        double St;      // tissue
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        // magnetization
        mt = exp(-TE*R2t) * ( 1 - ( 1 + (2*exp(TE/(2*T1t))) ) * ( 2 - exp(-TR/T1t)) );
        mb = exp(-TE*R2b) * ( 1 - ( 1 + (2*exp(TE/(2*T1b))) ) * ( 2 - exp(-TR/T1b)) );
        me = exp(-TE*R2e) * ( 1 - ( 1 + (2*exp(TE/(2*T1e))) ) * ( 2 - exp(-TR/T1e)) );

        // calculate tissue compartment weightings
        lam0 = (ne*me*VC) / ( (nt*mt*(1-VC)) + (ne*me*VC) );
        CBV = nb*mb*(1-lam0)*DBV;

        double tau = taus(jj-taus.Nrows());

        // Tissue Component
        if (tau < -tc)
        {
            St = exp(DBV + (R2p*tau));
        }
        else if (tau > tc)
        {    
            St = exp(DBV - (R2p*tau));
        }
        else
        {
            St = exp(-0.3*pow(R2p*tau,2.0)/DBV);
        }

        St *= (exp(-R2t*TE));

        // linear model
        Sb = exp(-R2b*TE)*exp(-R2bp*abs(tau));

        // CSF Component
        Sec = exp(-R2e*TE)*exp(-2.0*i*M_PI*DF*abs(tau));
        Se = real(Sec);

        // Total
        result(jj) = M0*(((1-CBV-lam0)*St) + (CBV*Sb) + (lam0*Se));
            
    }

return;

} // Evaluate
