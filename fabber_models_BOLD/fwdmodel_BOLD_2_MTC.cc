/*  fwdmodel_BOLD_2_MTC.cc

    2-compartment BOLD model, for use with CSF-nulled data

    Matthew Cherukara, FMRIB Physics Group
    
    1 June 2016 (created)
    15 June 2016 (modified) */
    
#include "fwdmodel_BOLD_2_MTC.h"

#include <iostream>
#include <newmatio.h>
#include <stdexcept>
#include "newimage/newimageall.h"
#include "miscmaths/miscprob.h"
using namespace NEWIMAGE;
#include "fabbercore/easylog.h"
#include "cmath"
using namespace std;

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
        precisions(p_index_OEF(),p_index_OEF()) = 1;
    }
    
    if (infer_zeta)     // dBV  
    {
        prior.means(p_index_zeta()) = 0.01;
        precisions(p_index_zeta(),p_index_zeta()) = 1;
    }
    
    if (infer_Hct)          // fractional hematocrit
    {
        prior.means(p_index_Hct()) = 0.3;
        precisions(p_index_Hct(),p_index_Hct()) = 1;
    }
        
    if (infer_R2t)      // R2 tissue 
    {
        prior.means(p_index_R2t()) = 5;
        precisions(p_index_R2t(),p_index_R2t()) = 0.01;
    }
    
    if (infer_stat)     // Tissue baseline intentisty
    {
        prior.means(p_index_Stat()) = 1.5;
        precisions(p_index_Stat(),p_index_Stat()) = 1e-3;
    }
       
    
    // Set precisions on priors
    prior.SetPrecisions(precisions);
    posterior = prior; // initial posterior
    
    // Set some informative initial posteriors on certain priors
    // OEF 
    if (infer_OEF)
    {
        posterior.means(p_index_OEF()) = 0.5;
        precisions(p_index_OEF(),p_index_OEF()) = 1e-6;
    }
    // zeta
    if (infer_zeta)
    { 
        posterior.means(p_index_zeta()) = 0.01;
        precisions(p_index_zeta(),p_index_zeta()) = 1e-6;
    }
    // Hct
    if (infer_Hct)
    {
        posterior.means(p_index_Hct()) = 0.3;
        precisions(p_index_Hct(),p_index_Hct()) = 1e-6;
    }
    // R2t
    if (infer_R2t)
    {
        posterior.means(p_index_R2t()) = 5;
        precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    }
    // static
    if (infer_stat)
    {
        posterior.means(p_index_Stat()) = 1.5;
        precisions(p_index_Stat(),p_index_Stat()) = 1e-3;
    }
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
    // Ensure all parameters are above 0
    ColumnVector paramcpy = params;
    
    // set fixed parameters
    double f_R2e = 4;     // R2 CSF
    double f_TE  = TE;      // TE
    
    // set inferrable parameters to their default values 
    double i_OEF = 0.5;     // Oxygen extraction fraction 
    double i_zt  = 0.02;    // dBv 
    double i_lam = 0.1;     // CSF fraction 
    double i_Hct = 0.29;    // fractional hematocrit (experimental value)    
    double i_df  = 5;       // Frequency shift 
    double i_R2t = 10;      // R2 tissue 
    double i_S0  = 1.5;     // static tissue
    
    // extract parameter values from the posterior parameters
    
    // Fractional hematocrit (between 0.25 and 0.5)
    if (infer_Hct)
    {
        i_Hct = tanh(paramcpy(p_index_Hct()));
        // if (i_Hct<0.25)  i_Hct = 0.25; 
        // if (i_Hct>0.50)  i_Hct = 0.50;
    }
    // Deoxygenated blood volume (between 0 and 1)
    if (infer_zeta) 
    {
        i_zt = tanh(paramcpy(p_index_zeta()));
        // if (i_zt>1.0)  i_zt = 1.0
    }
    // Oxygen extraction fraction (between 0 and 1)
    if (infer_OEF)
    {
        i_OEF = tanh(paramcpy(p_index_OEF()));
        // if (i_OEF>1.0)  i_OEF = 1.0;
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
    result.ReSize(taus.Nrows());
    
    for (int ii =1; ii<=taus.Nrows(); ii++)
    {
        ti = taus(ii);
        signal0 = BOLD_model->kc_evaluate(ti,f_TE,i_R2t,f_R2e,i_OEF,i_Hct,i_zt,i_lam,i_df,i_S0);
        result(ii) = signal0;
    }
    
    // cout << "Number of tau values " << tau_list.Nrows() << "\n";
    // cout << "Result vector size " << result.Nrows() << "\n"; 
    
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
    infer_stat = args.ReadBool("infer_stat");
    */
    
    // infer on everything
    infer_OEF  = true;
    infer_zeta = false;
    infer_Hct  = false; // we don't need to infer on this
    infer_R2t  = true; 
    infer_stat = false;
    
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
    if (infer_OEF)  names.push_back("OxygenExtractionFraction");
    if (infer_zeta) names.push_back("BloodVolumeZ");
    if (infer_Hct)  names.push_back("FractionalHematocrit");
    if (infer_R2t)  names.push_back("R2(tissue)");
    if (infer_stat) names.push_back("Signal");
    
} // NameParams


