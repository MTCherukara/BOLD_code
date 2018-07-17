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
#include <complex>

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
    return "1.6";
} // ModelVersion


// ------------------------------------------------------------------------------------------
// --------         Initialize                  ---------------------------------------------
// ------------------------------------------------------------------------------------------
void R2primeFwdModel::Initialize(ArgsType &args)
{
    infer_OEF = args.ReadBool("inferOEF");
    infer_R2p = args.ReadBool("inferR2p");
    infer_DBV = args.ReadBool("inferDBV");
    infer_R2t = args.ReadBool("inferR2t");
    infer_S0  = args.ReadBool("inferS0");
    infer_Hct = args.ReadBool("inferHct");
    infer_R2e = args.ReadBool("inferR2e");
    infer_dF  = args.ReadBool("inferdF");
    infer_lam = args.ReadBool("inferlam");
    single_comp = args.ReadBool("single_compartment");
    motion_narr = args.ReadBool("motional_narrowing");
    inf_priors  = args.ReadBool("infpriors");

    // since we can't do both, OEF will take precidence over R2p
    if (infer_OEF)
    {
        infer_R2p = false;
    }

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
            TE_temp = args.ReadWithDefault("TE"+stringify(i), "0.082");
        }

        ColumnVector tmp(1);
        tmp = convertTo<double>(TE_temp);
        TEvals &= tmp;

    }

    // read TR and TI
    TR = convertTo<double>(args.ReadWithDefault("TR","3.000"));
    TI = convertTo<double>(args.ReadWithDefault("TI","3.000"));

    // add information to the log
    LOG << "Inference using development model" << endl;
    LOG << "Using TR = " << TR << "s, and TI = " << TI << "s" << endl;
    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        LOG << "    TE(" << ii << ") = " << TEvals(ii) << "    tau(" << ii << ") = " << taus(ii) << endl;
    }
    if (infer_OEF)
    {
        LOG << "Inferring on OEF " << endl;
    }
    if (infer_R2p)
    {
        LOG << "Inferring on R2p " << endl;
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
    if (infer_Hct)
    {
        LOG << "Inferring on fractional hematocrit" << endl;
    }
    if (infer_R2e)
    {
        LOG << "Inferring on R2 of CSF" << endl;
    }
    if (infer_dF)
    {
        LOG << "Inferring on CSF frequency shift dF" << endl;
    }
    if (infer_lam)
    {
        LOG << "Inferring on CSF volume fraction lambda" << endl;
    }
    if (inf_priors)
    {
        LOG << "Using informative priors" << endl;
    }
    
} // Initialize


// ------------------------------------------------------------------------------------------
// --------         NameParameters              ---------------------------------------------
// ------------------------------------------------------------------------------------------

void R2primeFwdModel::NameParams(vector<string> &names) const
{
    names.clear();

    if (infer_OEF)
    {
        names.push_back("OEF"); // parameter 1 - Oxygen Extraction Fraction
    }
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
    if (infer_Hct)
    {
        names.push_back("Hct");  // parameter 4 - S0 scaling factor
    }
    if (infer_R2e)
    {
        names.push_back("R2e");  // parameter 5 - R2 (of CSF)
    }
    if (infer_dF)
    {
        names.push_back("dF");  // parameter 6 - frequency shift of CSF
    }
    if (infer_lam)
    {
        names.push_back("VC");  // parameter 7 - CSF volume fraction
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
    SymmetricMatrix precisions = IdentityMatrix(NumParams()) * 1e-3;

    if (infer_OEF)
    {
        prior.means(OEF_index()) = 0.2;
        if (inf_priors)
        {
            precisions(OEF_index(), OEF_index()) = 1e1; // 1e1
        }
        else
        {
            precisions(OEF_index(), OEF_index()) = 1e-1; // 1e-1
        }
    }
    
    if (infer_R2p)
    {
        prior.means(R2p_index()) = 2.6;
        if (inf_priors)
        {
            precisions(R2p_index(), R2p_index()) = 1e-2; // 1e-1
        }
        else
        {
            precisions(R2p_index(), R2p_index()) = 1e-3; // 1e-2
        }
    }

    if (infer_DBV)
    {
        prior.means(DBV_index()) = 0.036;
        if (inf_priors)
        {
            precisions(DBV_index(), DBV_index()) = 1e2; // 1e3
        }
        else
        {
            precisions(DBV_index(), DBV_index()) = 1e0; // 1e0
        }
    }

    if (infer_R2t)
    {
        prior.means(R2t_index()) = 1/0.087;
        precisions(R2t_index(), R2t_index()) = 1e-2; // 1e0 - more precise
    }

    if (infer_S0)
    {
        prior.means(S0_index()) = 500.0;
        precisions(S0_index(), S0_index()) = 1e-5; // 1e-5 - always imprecise
    }

    if (infer_Hct)
    {
        prior.means(Hct_index()) = 0.40;
        precisions(Hct_index(), Hct_index()) = 1e3; // 1e3 - always very precise
    }

    if (infer_R2e)
    {
        prior.means(R2e_index()) = 0.5;
        precisions(R2e_index(), R2e_index()) = 1e-2; // 1e-2
    }
    
    if (infer_dF)
    {
        prior.means(dF_index()) = 5.0;
        precisions(dF_index(), dF_index()) = 1e-2; // 1e-2
    }

    if (infer_lam)
    {
        prior.means(lam_index()) = 0.1;
        precisions(lam_index(), lam_index()) = 1e2; // 1e1
    }

    prior.SetPrecisions(precisions);

    posterior = prior; // we don't need to change the initial guess (at least, not at this stage)

    
    // Set distributions for initial posteriors
    if (infer_OEF)
    {
        posterior.means(OEF_index()) = 0.21;
        precisions(OEF_index(), OEF_index()) = 1e1; // 1e1
    }
    
    if (infer_R2p)
    {
        posterior.means(R2p_index()) = 2.6;
        precisions(R2p_index(), R2p_index()) = 1e-3;
    }

    if (infer_DBV)
    {
        posterior.means(DBV_index()) = 0.036;
        precisions(DBV_index(), DBV_index()) = 1e3; 
    }

    if (infer_R2t)
    {
        posterior.means(R2t_index()) = 1/0.087;
        precisions(R2t_index(), R2t_index()) = 1e0; 
    }

    if (infer_S0)
    {
        posterior.means(S0_index()) = 700.0;
        precisions(S0_index(), S0_index()) = 1e-5;
    }

    if (infer_Hct)
    {
        posterior.means(Hct_index()) = 0.40;
        precisions(Hct_index(), Hct_index()) = 1e3;
    }

    if (infer_R2e)
    {
        posterior.means(R2e_index()) = 0.5;
        precisions(R2e_index(), R2e_index()) = 1e-2; // 1e-2
    }
    
    if (infer_dF)
    {
        posterior.means(dF_index()) = 5.0;
        precisions(dF_index(), dF_index()) = 1e-2; // 1e-2
    }

    if (infer_lam)
    {
        posterior.means(lam_index()) = 0.1;
        precisions(lam_index(), lam_index()) = 1e2; // 1e1
    } 

    
    posterior.SetPrecisions(precisions);

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
    double Se;  // extracellular signal
    complex<double> Sec; // complex version of the extracellular signal (may be unnecessary)

    complex<double> i(0,1);

    // derived parameters
    double dw;          // characteristic time (protons in water)
    double R2b;
    double R2bp;
    double tc;
    double lam0;        // apparent lambda (opposite way round from literature!)
    double mt;
    double me;
    double mb;

    // parameters
    double OEF;
    double R2p;
    double DBV;
    double R2t;
    double S0;
    double Hct;
    double R2e;
    double dF;
    double lam;
    double CBV;


    // assign values to parameters
    if (infer_R2p)
    {
        R2p = (paramcpy(R2p_index()));
    }
    else
    {
        R2p = 2.5;
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
        R2t = 11.5;
    }
    if (infer_S0)
    {
        S0 = (paramcpy(S0_index()));
    }
    else
    {
        S0 = 100.0;
    }
    if (infer_Hct)
    {
        Hct = abs(paramcpy(Hct_index()));
    }
    else
    {
        Hct = 0.4;
    }
    if (infer_R2e)
    {
        R2e = abs(paramcpy(R2e_index()));
    }
    else
    {
        R2e = 4.0;
    }
    if (infer_dF)
    {
        dF = abs(paramcpy(dF_index()));
    }
    else
    {
        dF = 6.00;
    }
    if (infer_lam)
    {
        lam = abs(paramcpy(lam_index()));
    }
    else
    {
        lam = 0.0;
    }


    // this one is a little bit different
    if (infer_OEF)
    {
        OEF = (paramcpy(OEF_index()));
        dw = 887.4082*Hct*OEF;
        R2p = dw*DBV;
    }
    else if (infer_R2p)
    {
        dw = R2p/DBV;
        OEF = R2p/(887.4082*Hct*DBV);
    }
    else
    {
        OEF = 0.3;
    }

    // calculate tc and threshold it if necessary
    tc = 1.7/dw;
    if (tc > 0.021)
    {
        tc = 0.021;
    }
    else if (tc < 0.010)
    {
        tc = 0.010;
    }

    // evaluate blood relaxation rates
    R2b  = ( 4.5 + (16.4*Hct)) + ( ((165.2*Hct) + 55.7)*pow(OEF,2.0) );
    R2bp = (10.2 - ( 1.5*Hct)) + ( ((136.9*Hct) - 13.9)*pow(OEF,2.0) );

    // here are some more constants we will need
    double T1t = 1.20;
    double T1e = 3.87;
    double T1b = 1.58;

    double nt = 0.723;
    double ne = 0.075;
    double nb = 0.723;


    // loop through taus
    result.ReSize(taus.Nrows());

    for (int ii = 1; ii <= taus.Nrows(); ii++)
    {
        double tau = taus(ii);
        double TE = TEvals(ii);

        // calculate tissue signal
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
 
        // compartments
        if (single_comp)
        {
            // total signal is tissue signal only
            result(ii) = S0*St;
        }
        else
        {
            // apply T2 effect to tissue compartment
            St *= exp(-R2t*TE);

            // add blood compartment
            if (motion_narr)
            {
                // parameters
                double td   = 0.0045067;       // (based on rc=2.6 um and D=1.5 um^2 / ms)
                double gm   = 2.67513e8;
                double dChi = (((-0.736 + (0.264*OEF))*Hct) + (0.722*(1-Hct)))*1e-6;
                double G0   = (4/45)*Hct*(1-Hct)*pow((dChi*3.0),2.0);
                double kk   = 0.5*pow(gm,2.0)*G0*pow(td,2.0);

                // motion narrowing model
                Sb = exp(-kk* ( (TE/td) + pow((0.25 + (TE/td)),0.5) + 1.5 - 
                                (2*pow((0.25 + (pow((TE+tau),2.0)/td) ),0.5)) - 
                                (2*pow((0.25 + (pow((TE-tau),2.0)/td) ),0.5)) ) );

                // T2 effect 
                Sb *= exp(-R2b*TE);    

            } // if (motion_narr)
            else 
            {
                // linear model
                Sb = exp(-R2b*TE)*exp(-R2bp*abs(tau));

            } // if (motion_narr) ... else

            // add extracellular compartment
            Sec = exp(-R2e*TE)*exp(-2.0*i*M_PI*dF*abs(tau));
            Se = real(Sec);

            // calculate steady state magnetization values, for tissue, blood, and CSF
            mt = exp(-(TE-tau)*R2t) * ( 1 - ( 1 + (2*exp((TE-tau)/(2*T1t))) ) 
                                        * ( 2 - exp(-(TR-TI)/T1t)) * exp(-TI/T1t)  );
            mb = exp(-(TE-tau)*R2b) * ( 1 - ( 1 + (2*exp((TE-tau)/(2*T1b))) ) 
                                        * ( 2 - exp(-(TR-TI)/T1b)) * exp(-TI/T1b)  );
            mt = exp(-(TE-tau)*R2e) * ( 1 - ( 1 + (2*exp((TE-tau)/(2*T1e))) ) 
                                        * ( 2 - exp(-(TR-TI)/T1e)) * exp(-TI/T1e)  );
            
            // calculate tissue compartment weightings
            lam0 = (ne*me*lam) / ( (nt*mt*(1-lam)) + (ne*me*lam) );
            CBV = nb*mb*(1-lam0)*DBV;

            // add up compartments
            result(ii) = S0*(((1-CBV-lam0)*St) + (CBV*Sb) + (lam0*Se));

        } // if (single_comp) ... else

    } // for (int i = 1; i <= taus.Nrows(); i++)

    
    // alternative, if values are outside reasonable bounds
    if ( DBV > 0.5 || Hct > 1.0 || OEF > 1.0 || lam0 > 1.0 )
    {
        for (int ii = 1; ii <= taus.Nrows(); ii++)
        {
            result(ii) = result(ii)*100.0;
        }
    }
    

    return;

} // Evaluate
