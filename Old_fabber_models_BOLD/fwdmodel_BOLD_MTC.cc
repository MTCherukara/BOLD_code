/*  fwdmodel_BOLD_MTC.cc

    Matthew Cherukara, FMRIB Physics Group
    
    9 May 2016 (created)
    15 June 2016 (modified)  */
    
#include "fwdmodel_BOLD_MTC.h"

#include <iostream>
#include <newmatio.h>
#include <stdexcept>
#include "newimage/newimageall.h"
#include "miscmaths/miscprob.h"
using namespace NEWIMAGE;
#include "fabbercore/easylog.h"
#include "cmath"

FactoryRegistration<FwdModelFactory, BOLDFwdModel>
    BOLDFwdModel::registration("BOLD");
  
string BOLDFwdModel::ModelVersion() const
{
    return "$Id: fwdmodel_BOLD_MTC.cc, v 0.1, 2016/05/09 14:24:30 Cherukara Exp $";
}


// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDFwdModel::HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const
{
    Tracer_Plus tr("BOLDFwdModel::HardcodedInitialDists");
    assert(prior.means.Nrows() == NumParams());
    
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e12;
    
    // Assign initial mean values and variances to parameters being inferred on
    
    if (infer_OEF)      // OEF
    {
        prior.means(p_index_OEF()) = 0.5;
        precisions(p_index_OEF(),p_index_OEF()) = 1;
    }
    
    if (infer_zeta)     // dBV  
    {
        prior.means(p_index_zeta()) = 0.01;
        precisions(p_index_zeta(),p_index_zeta()) = 1;
    }
    
    if (infer_lam)      // CSF fraction 
    {
        prior.means(p_index_lam()) = 0.0;
        precisions(p_index_lam(),p_index_lam()) = 1;
    }
    
    if (infer_Hct)          // fractional hematocrit
    {
        prior.means(p_index_Hct()) = 0.5;
        precisions(p_index_Hct(),p_index_Hct()) = 1;
    }
    
    if (infer_df)       // frequency shift 
    {
        prior.means(p_index_df()) = 6;
        precisions(p_index_df(),p_index_df()) = 1e-3;
    }
        
    if (infer_R2t)      // R2 tissue 
    {
        prior.means(p_index_R2t()) = 10;
        precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    }
    
    if (infer_stat)     // Tissue baseline intentisty
    {
        prior.means(p_index_Stat()) = 800;
        precisions(p_index_Stat(),p_index_Stat()) = 1e-6;
    }
    
    if (infer_CSF)
    {
        prior.means(p_index_CSF()) = 5;
        precisions(p_index_CSF(),p_index_CSF()) = 1e-6;
    }
    
    // Set precisions on priors
    prior.SetPrecisions(precisions);
    posterior = prior; // initial posterior
    
    // Set some informative initial posteriors on certain priors 
    // OEF
    if (infer_OEF)
    {
        posterior.means(p_index_OEF()) = 0.5;
        precisions(p_index_OEF(),p_index_OEF()) = 1;
    }
    
    if (infer_zeta)
    {
        posterior.means(p_index_zeta()) = 0.05;
        precisions(p_index_zeta(),p_index_zeta()) = 1;
    }


    if (infer_lam)
    {
        posterior.means(p_index_lam()) = 0.1;
        precisions(p_index_lam(),p_index_lam()) = 1;
    }
    
    if (infer_Hct)
    { 
        posterior.means(p_index_Hct()) = 0.4;
        precisions(p_index_Hct(),p_index_Hct()) = 1;
    }
    
    if (infer_df)
    { 
        posterior.means(p_index_df()) = 5;
        precisions(p_index_df(),p_index_df()) = 1e-6;
    }
    
    if (infer_R2t)
    {
        posterior.means(p_index_R2t()) = 5;
        precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    }
    
    if (infer_stat)
    {
        posterior.means(p_index_Stat()) = 800;
        precisions(p_index_Stat(),p_index_Stat()) = 1e-6;
    }
    
    if (infer_CSF)
    {
        posterior.means(p_index_CSF()) = 5;
        precisions(p_index_CSF(),p_index_CSF()) = 1e-6;
    }
    
    posterior.SetPrecisions(precisions);
    
} // HardcodedInitialDists 


// ------------------------------------------------------------------------------------------
// --------         InitParams                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDFwdModel::InitParams(MVNDist& posterior) const
{
    Tracer_Plus tr("BOLDFwdModel::Initialize");
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
void BOLDFwdModel::Evaluate(const ColumnVector& params, ColumnVector& result) const
{
    Tracer_Plus tr("BOLDFwdModel::Evaluate");
    
    // Ensure all parameters are above 0
    ColumnVector paramcpy = params;
    
    // set fixed parameters
    double f_TE  = 0.08;      // TE
    
    // set inferrable parameters to their default values 
    double i_OEF = 0.5;     // Oxygen extraction fraction 
    double i_zt  = 0.01;    // dBv 
    double i_lam = 0.0;     // CSF fraction 
    double i_Hct = 0.5;    // fractional hematocrit    
    double i_df  = 5;       // Frequency shift 
    double i_R2t = 5;      // R2 tissue 
    double i_S0  = 1000;    // static tissue (this is based on brain_3_csf.nii.gz
    double i_R2e = 5;       // R2 extracellular compartment
    
    // extract parameter values from the posterior parameters
    
    // Fractional hematocrit (between 0.25 and 0.5)
    if (infer_Hct)
    {
        i_Hct = (paramcpy(p_index_Hct()));
    }
    // CSF signal fraction (between 0 and 1)
    if (infer_lam) 
    {
        i_lam = (paramcpy(p_index_lam()));
    }
    // Deoxygenated blood volume (between 0 and 1)
    if (infer_zeta) 
    {
        i_zt = (paramcpy(p_index_zeta()));
    }
    // Oxygen extraction fraction (between 0 and 1)
    if (infer_OEF)
    {
        i_OEF = (paramcpy(p_index_OEF()));
    }
    // Frequency shift (no limits imposed)
    if (infer_df)
    {
        i_df = paramcpy(p_index_df());
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
    // R2 extracellular
    if (infer_CSF)
    {
        i_R2e = paramcpy(p_index_CSF());
    }
    
    // Lots of stuff
    double ti;
    double signal0;
    
    result.ReSize(tau_list.Nrows());
    
    for (int ii =1; ii<=tau_list.Nrows(); ii++)
    {
        ti = tau_list(ii);
        signal0 = BOLD_model->kc_evaluate(ti,f_TE,i_R2t,i_R2e,i_OEF,i_Hct,i_zt,i_lam,i_df,i_S0);
        result(ii) = signal0;
    }
    
    // cout << "\n Result vector size " << result.Nrows() << "\n"; 
    
    return;
    
} // Evaluate 

// ------------------------------------------------------------------------------------------
// --------         New Instance                ---------------------------------------------
// ------------------------------------------------------------------------------------------

FwdModel* BOLDFwdModel::NewInstance()
{
    return new BOLDFwdModel();
} 

// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDFwdModel::Initialize(ArgsType& args)
{
    Tracer_Plus tr("BOLDFwdModel::Initialize");
    string scanParams = args.ReadWithDefault("scan-params","cmdline");
    
    // inference
    /*
    infer_OEF  = args.ReadBool("infer_OEF");
    infer_zeta = args.ReadBool("infer_zeta");
    infer_lam  = args.ReadBool("infer_lam");
    infer_Hct  = args.ReadBool("infer_Hct");
    infer_df   = args.ReadBool("infer_df");
    infer_R2t  = args.ReadBool("infer_R2t");
    infer_stat = args.ReadBool("infer_stat");
    infer_CSF  = args.ReadBool("infer_CSF");
    */
    
    // infer on everything
    infer_OEF  = true;
    infer_zeta = false;
    infer_lam  = true;
    infer_Hct  = false;
    infer_df   = false;
    infer_R2t  = false;
    infer_stat = true;
    infer_CSF  = false;
    
    // read TE value from command line
    string TE_str;
    TE_str = args.ReadWithDefault("TE","0.08");
    TE = convertTo<double>(TE_str);
    
    // set voxel coordinates - these aren't declared anywhere?
    coord_x = 0;
    coord_y = 0;
    coord_z = 0;

    // set up the models
    BOLD_model = NULL;
    BOLD_model = new BOLDMODEL_General();
    
    // pull out values of tau from input
    string tau_temp;
    
    while (true)
    {
        int N = tau_list.Nrows()+1;
        tau_temp = args.ReadWithDefault("tau"+stringify(N), "stop!");
        if (tau_temp == "stop!") break;
        
        ColumnVector tmp(1);
        tmp = convertTo<double>(tau_temp);
        tau_list &= tmp;
    }
    
    

} // Initialize 



// ------------------------------------------------------------------------------------------
// --------         Random other functions      ---------------------------------------------
// ------------------------------------------------------------------------------------------
vector<string> BOLDFwdModel::GetUsage() const
{
    vector<string> usage;
    usage.push_back( "Required Parameters:");
        usage.push_back("Fill in some stuff here");
    return usage;
}

void BOLDFwdModel::DumpParameters(const ColumnVector& vec, const string& indent) const 
{
    
} // DumpParameters

void BOLDFwdModel::NameParams(vector<string>& names) const 
{
    names.clear();
    if (infer_OEF)  names.push_back("OxygenExtractionFraction");
    if (infer_zeta) names.push_back("BloodVolumeZ");
    if (infer_lam)  names.push_back("CSFVolumeL");
    if (infer_Hct)  names.push_back("FractionalHematocrit");
    if (infer_df)   names.push_back("FrequencyShift");
    if (infer_R2t)  names.push_back("R2(tissue)");
    if (infer_stat) names.push_back("Signal");
    if (infer_CSF)  names.push_back("R2(CSF)");

} // NameParams


