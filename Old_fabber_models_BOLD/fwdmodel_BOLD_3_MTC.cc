/*  fwdmodel_BOLD_2_MTC.cc

    2-compartment BOLD model, for use with CSF-nulled data

    Matthew Cherukara, FMRIB Physics Group
    
    Original: 9 May 2016  
    
    Modified: 23 June 2016 (MTC) - Generating some results on different subjects */
    
#include "fwdmodel_BOLD_3_MTC.h"

#include <iostream>
#include <newmatio.h>
#include <stdexcept>
#include "newimage/newimageall.h"
#include "miscmaths/miscprob.h"
using namespace NEWIMAGE;
#include "fabbercore/easylog.h"
#include "cmath"

FactoryRegistration<FwdModelFactory, BOLDR2FwdModel>
    BOLDR2FwdModel::registration("BOLDR2");
  
string BOLDR2FwdModel::ModelVersion() const
{
    return "$Id: fwdmodel_BOLD_3_MTC.cc, v 0.1, 2016/05/09 14:24:30 Cherukara Exp $";
}
 
// ------------------------------------------------------------------------------------------
// --------         HardcodedInitialDists       ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDR2FwdModel::HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const
{
    Tracer_Plus tr("BOLDR2FwdModel::HardcodedInitialDists");
    assert(prior.means.Nrows() == NumParams());
    
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e12;
    
    // Assign initial mean values and variances to parameters being inferred on   
    if (infer_R2t)      // R2 tissue 
    {
        prior.means(p_index_R2t()) = 300;
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
    
    // R2t
    posterior.means(p_index_R2t()) = 300;
    precisions(p_index_R2t(),p_index_R2t()) = 1e-6;
    
    // static
    posterior.means(p_index_Stat()) = 1;
    precisions(p_index_Stat(),p_index_Stat()) = 1e-6;
    
    posterior.SetPrecisions(precisions);
    
    
    
} // HardcodedInitialDists 


// ------------------------------------------------------------------------------------------
// --------         InitParams                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDR2FwdModel::InitParams(MVNDist& posterior) const
{
    Tracer_Plus tr("BOLDR2FwdModel::Initialize");
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
void BOLDR2FwdModel::Evaluate(const ColumnVector& params, ColumnVector& result) const
{
    Tracer_Plus tr("BOLDR2FwdModel::Evaluate");
    ColumnVector paramcpy = params;
    /*
    for (int i=1; i<=NumParams();i++) {
        if (params(i)<0) {
            paramcpy(i) = 0;
        }
    } */
    
    
    double f_TE  = 0.08;      // TE
    double f_R2e = 5;         // this is never actually used
    
    // set inferrable parameters to their default values 
    double i_OEF = 0.5;     // Oxygen extraction fraction 
    double i_zt  = 0.01;    // dBv 
    double i_lam = 0.1;     // CSF fraction 
    double i_Hct = 0.45;    // fractional hematocrit    
    double i_df  = 5;       // Frequency shift 
    double i_R2t = 15;      // R2 tissue 
    double i_S0  = 1000;    // static tissue
    
    // extract parameter values from the posterior parameters

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
    
    // go back to measuring the length of taus, since taus is now correct
    result.ReSize(taus.Nrows());
    
    for (int ii =1; ii<=taus.Nrows(); ii++)
    {
        ti = taus(ii);
        signal0 = BOLD_model->kc_evaluate(ti,f_TE,i_R2t,f_R2e,i_OEF,i_Hct,i_zt,i_lam,i_df,i_S0);            
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

FwdModel* BOLDR2FwdModel::NewInstance()
{
    // cout << "---Making a NewInstance of BOLDR2FwdModel \n";
    return new BOLDR2FwdModel();
} 
// maybe we don't need this

// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void BOLDR2FwdModel::Initialize(ArgsType& args)
{
    Tracer_Plus tr("BOLDR2FwdModel::Initialize");
    // cout << "---Initializing BOLDR2FwdModel \n";
    string scanParams = args.ReadWithDefault("scan-params","cmdline");
    
    // inference
    // infer on everything
    infer_R2t  = true;
    infer_stat = true;
    
    // set voxel coordinates
    coord_x = 0;
    coord_y = 0;
    coord_z = 0;
    
    // set up the models
    BOLD_model = NULL;
    BOLD_model = new BOLDMODEL_R2prime();
    
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
vector<string> BOLDR2FwdModel::GetUsage() const
{
    vector<string> usage;
    usage.push_back( "Required Parameters:");
        usage.push_back("Fill in some stuff here");
    return usage;
}

void BOLDR2FwdModel::DumpParameters(const ColumnVector& vec, const string& indent) const 
{
    
} // DumpParameters

void BOLDR2FwdModel::NameParams(vector<string>& names) const 
{
    names.clear();
    names.push_back("R2(prime)");
    names.push_back("Signal");
    
} // NameParams


