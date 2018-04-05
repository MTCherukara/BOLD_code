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
    return "1.0";
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
        prior.means(VC_index()) = 0.01;
        precisions(VC_index(), VC_index()) = 1e-1; // 1e-1
    }

    // parameter 3 - Delta F
    if (infer_DF)
    {
        prior.means(DF_index()) = 5.0;
        precisions(DF_index(), DF_index()) = 1e-1; // 1e-2
    }

    // parameter 4 - R2-prime (Tissue)
    if (infer_R2p)
    {
        prior.means(R2p_index()) = 3.0;
        precisions(R2p_index(), R2p_index()) = 1e-1; // 1e-2
    }
    
    // parameter 5 - DBV
    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.03;
        precisions(DBV_index(), DBV_index()) = 1e1; // 1e-1
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

    // fixed-value parameters
    double T1t = 1.200;     // Grey matter T1 (Lu et al., 2005)
    double T1e = 3.870;     // CSF T1 (Lu et al., 2005)  
    double T1b = 1.580;     // Blood T1 (Lu et al., 2004)
    double R2t = 11.5;      // Grey matter T2=87ms (He & Yablonskiy, 2007)
    // double R2e = 0.65;      // CSF T2=1573ms (Qin, 2011) 
    double R2e = 4.00;      // CSF T2=250ms (He & Yablonskiy, 2007)
    double R2b = 27.97;     //    Calculated based on OEF=0.4, Hct=0.4, using formula from 
    double Rsb = 48.89;     //    Zhao et al., 2007 (cited in Simon et al., 2016)

    complex<double> i(0,1);

    // assign values to parameters
    M0 = (paramcpy(M0_index()));
    if (infer_VC)
    {
        VC = abs(paramcpy(VC_index()));
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
        DF = 7.0;
    }
    if (infer_R2p)
    {
        R2p = (paramcpy(R2p_index()));
    } 
    else
    {
        R2p = 2.0;
    }
    if (infer_DBV)
    {
        DBV = abs(paramcpy(DBV_index()));
    }
    else
    {
        DBV = 0.00; 
    }
    // now evaluate information
    result.ReSize(2*taus.Nrows());

    // loop through FLAIR data
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        // component parameters
        double St;      // tissue
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        double tau = taus(ii);

        // Tissue Component
        St = ( 1 - ( (2 - exp(-(TR-TI)/T1t) ) * exp(-TI/T1t))) * (exp(-R2t*TE)) * (exp(DBV - (R2p*tau)));

        // Blood Component
        Sb = ( 1 - ( (2 - exp(-(TR-TI)/T1b) ) * exp(-TI/T1b))) * (exp(-R2b*(TE-tau))) * (exp(-Rsb*tau));

        // CSF Component
        Sec = ( 1 - ( (2 - exp(-(TR-TI)/T1e) ) * exp(-TI/T1e))) * (exp(-R2e*TE)) * (exp(-2.0*i*M_PI*DF*tau));
        Se = real(Sec);

        // Total
        result(ii) = M0 * (( (1-(DBV+VC))*St ) + (DBV*Sb) + (VC*Se));

    }

    // loop through non-FLAIR data
    for (int jj = (taus.Nrows()+1); jj <= 2*taus.Nrows(); jj++)
    {
        // component parameters
        double St;      // tissue
        double Sb;      // blood
        double Se;      // CSF
        complex<double> Sec; // complex version of CSF signal

        double tau = taus(jj-taus.Nrows());

        // Tissue Component
        St = ( 1 - (exp(-TR/T1t)) ) * (exp(-R2t*TE)) * (exp(DBV - (R2p*tau)));

        // Blood Component
        Sb = ( 1 - (exp(-TR/T1b)) ) * (exp(-R2b*(TE-tau))) * (exp(-Rsb*tau));

        // CSF Component
        Sec = ( 1 - (exp(-TR/T1e)) ) * (exp(-R2e*TE)) * (exp(-2.0*i*M_PI*DF*tau));
        Se = real(Sec);

        // Total
        result(jj) = M0 * (( (1-(DBV+VC))*St ) + (DBV*Sb) + (VC*Se));
        
    }

    // alternative, if values are outside reasonable bounds
    if ( DBV > 0.5 || VC > 1.1 )
    {
        for (int ii = 1; ii <= 2*taus.Nrows(); ii++)
        {
            result(ii) = result(ii)*100.0;
        }
    }

    return;

} // Evaluate
