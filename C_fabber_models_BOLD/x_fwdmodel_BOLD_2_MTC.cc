/*  fwdmodel_BOLD_2_MTC.cc

    2-compartment BOLD model, for use with CSF-nulled data

    Matthew Cherukara, FMRIB Physics Group
    
    9 May 2016  */
    
#include "fwdmodel_BOLD_2_MTC.h"

#include <iostream>
#include <newmatio.h>
#include <stdexcept>
#include "newimage/newimageall.h"
#include "miscmaths/miscprob.h"
using namespace NEWIMAGE;
#include "fabbercore/easylog.h"
#include "cmath"

FactoryRegistration<FwdModelFactory, BOLD2cFwdModel>
    BOLD2cFwdModel::registration("BOLD2c");
  
string BOLD2cFwdModel::ModelVersion() const
{
    return "$Id: fwdmodel_BOLD_2_MTC.cc, v 0.1, 2016/05/09 14:24:30 Cherukara Exp $";
}
 
// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLD2cFwdModel::HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const
{
    Tracer_Plus tr("BOLD2cFwdModel::HardcodedInitialDists");
    assert(prior.means.Nrows() == NumParams());
    
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e12;
    
    // Assign initial mean values and variances to parameters being inferred on
    
    if (infer_OEF)      // OEF
    {
        prior.means(p_index_OEF()) = 0.5;
        precisions(p_index_OEF(),p_index_OEF()) = 1e-6;
    }
    
    if (infer_zeta)     // dBV  
    {
        prior.means(p_index_zeta()) = 0.01;
        precisions(p_index_zeta(),p_index_zeta()) = 1e-6;
    }
    
    if (infer_Hct)          // fractional hematocrit
    {
        prior.means(p_index_Hct()) = 0.5;
        precisions(p_index_Hct(),p_index_Hct()) = 1e-6;
    }
        
    if (infer_R2t)      // R2 tissue 
    {
        prior.means(p_index_R2t()) = 10;
        precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    }
    
    if (infer_stat)     // Tissue baseline intentisty
    {
        prior.means(p_index_Stat()) = 1;
        precisions(p_index_Stat(),p_index_Stat()) = 1e-6;
    }
       
    
    // Set precisions on priors
    prior.SetPrecisions(precisions);
    posterior = prior; // initial posterior
    
    // Set some informative initial posteriors on certain priors
    // OEF 
    posterior.means(p_index_OEF()) = 0.5;
    precisions(p_index_OEF(),p_index_OEF()) = 1e-6;
    
    // zeta 
    posterior.means(p_index_zeta()) = 0.05;
    precisions(p_index_zeta(),p_index_zeta()) = 1e-6;
    
    // Hct 
    posterior.means(p_index_Hct()) = 0.4;
    precisions(p_index_Hct(),p_index_Hct()) = 1e-6;
    
    // R2t
    posterior.means(p_index_R2t()) = 20;
    precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    
    // static
    posterior.means(p_index_Stat()) = 100;
    precisions(p_index_Stat(),p_index_Stat()) = 1e-6;
    
    posterior.SetPrecisions(precisions);
    
    
    
} // HardcodedInitialDists 


// ------------------------------------------------------------------------------------------
// --------         InitParams                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLD2cFwdModel::InitParams(MVNDist& posterior) const
{
    Tracer_Plus tr("BOLD2cFwdModel::Initialize");
    // Maybe not so much stuff, but enough to sort out raw data intensities
    
    if (infer_stat)
    {
        double dataval = data.Maximum();
        posterior.means(p_index_Stat()) = dataval;
    }
    
} // InitParams 


// ------------------------------------------------------------------------------------------
// --------         Evaluate                    ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLD2cFwdModel::Evaluate(const ColumnVector& params, ColumnVector& result) const
{
    Tracer_Plus tr("BOLD2cFwdModel::Evaluate");
    // cout << "---Evaluating BOLD2cFwdModel \n";
    // cout << "tau:" << tau_list << "\n";
    
    ColumnVector paramcpy = params;
    /* // Ensure all parameters are above 0
    for (int i=1; i<=NumParams();i++) {
        if (params(i)<0) {
            paramcpy(i) = 0;
        }
    } */
    
    
    // set fixed parameters
    double f_R2e = 4;     // R2 CSF
    double f_TE  = 0.08;      // TE
    
    // set inferrable parameters to their default values 
    double i_OEF = 0.5;     // Oxygen extraction fraction 
    double i_zt  = 0.01;    // dBv 
    double i_lam = 0.1;     // CSF fraction 
    double i_Hct = 0.45;    // fractional hematocrit    
    double i_df  = 5;       // Frequency shift 
    double i_R2t = 4;      // R2 tissue 
    double i_S0  = 100;    // static tissue
    
    // extract parameter values from the posterior parameters
    // get rid of hard boundaries on fractions, replace them with tanh functions
    
    // Fractional hematocrit
    if (infer_Hct)
    {
        i_Hct = paramcpy(p_index_Hct());
    }
    // Deoxygenated blood volume
    if (infer_zeta) 
    {
        i_zt = paramcpy(p_index_zeta());
    }
    // Oxygen extraction fraction
    if (infer_OEF)
    {
        i_OEF = paramcpy(p_index_OEF());
    }
    // R2 tissue (no limits imposed)
    if (infer_R2t)
    {
        i_R2t = paramcpy(p_index_R2t());
    }
    // S0 intensity
    if (infer_stat)
    {
        i_S0 = paramcpy(p_index_Stat());
    }

    
    // Lots of stuff
    double ti;
    double signal0;
    
    //cout << "Number of tau values we're about to evaluate: " << taus.Nrows() << "\n";
    
    // for now, to get stuff moving
    result.ReSize(11);
    
    for (int ii =1; ii<=taus.Nrows(); ii++)
    {
        ti = taus(ii);
        signal0 = BOLD_model->kc_evaluate(ti,f_TE,i_R2t,f_R2e,i_OEF,i_Hct,i_zt,i_lam,i_df,i_S0);
        // cout << "\n--- Calling kc_evaluate from BOLD2cFwdModel::Evaluate \n";
        result(ii) = signal0;
    }
    
    // cout << "Number of tau values " << tau_list.Nrows() << "\n";
    // cout << "Result vector size " << result.Nrows() << "\n"; 
    // result = S_total;
    
    return;
    
} // Evaluate 

// ------------------------------------------------------------------------------------------
// --------         New Instance                ---------------------------------------------
// ------------------------------------------------------------------------------------------

FwdModel* BOLD2cFwdModel::NewInstance()
{
    // cout << "---Making a NewInstance of BOLD2cFwdModel \n";
    return new BOLD2cFwdModel();
} 
// maybe we don't need this

// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLD2cFwdModel::Initialize(ArgsType& args)
{
    Tracer_Plus tr("BOLD2cFwdModel::Initialize");
    // cout << "---Initializing BOLD2cFwdModel \n";
    string scanParams = args.ReadWithDefault("scan-params","cmdline");
    
    // inference
    /*
    infer_OEF  = args.ReadBool("infer_OEF");
    infer_zeta = args.ReadBool("infer_zeta");
    infer_Hct  = args.ReadBool("infer_Hct");
    infer_R2t  = args.ReadBool("infer_R2t");
    */
    
    // infer on everything
    infer_OEF  = true;
    infer_zeta = true;
    infer_Hct  = true;
    infer_R2t  = false;
    infer_stat = true;
    
    // set voxel coordinates - these aren't declared anywhere?
    coord_x = 0;
    coord_y = 0;
    coord_z = 0;

    // ARD - what is this?
    // bool doard=false;
    
    // set up the models
    BOLD_model = NULL;
    BOLD_model = new BOLDMODEL_2comp();
    
    // pull out values of tau from input
    string tau_temp;
    
    // cout << "Initializing. Number of tau_list rows = " << tau_list.Nrows() << "\n";
    
    while (true)
    {
        int N = tau_list.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;
        
        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        tau_list &= tmp;
    }
    
    // cout << "Finished Initializing. Number of tau_list rows = " << tau_list.Nrows() << "\n";
    // cout << "tau:" << tau_list << "\n";

    taus = tau_list;
    
} // Initialize 

// ------------------------------------------------------------------------------------------
// --------         Random other functions      ---------------------------------------------
// ------------------------------------------------------------------------------------------
vector<string> BOLD2cFwdModel::GetUsage() const
{
    vector<string> usage;
    usage.push_back( "Required Parameters:");
        usage.push_back("Fill in some stuff here");
    return usage;
}

void BOLD2cFwdModel::DumpParameters(const ColumnVector& vec, const string& indent) const 
{
    
} // DumpParameters

void BOLD2cFwdModel::NameParams(vector<string>& names) const 
{
    names.clear();
    names.push_back("OxygenExtractionFraction");
    names.push_back("BloodVolumeZ");
    names.push_back("FractionalHematocrit");
    names.push_back("R2(tissue)");
    names.push_back("Signal");
    
} // NameParams


