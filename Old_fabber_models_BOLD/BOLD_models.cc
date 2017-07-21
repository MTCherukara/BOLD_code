/*  BOLD_models.cc Kinetic curve models for qBOLD

    Matthew Cherukara - FMRIB Physics Group
    
    Original: 10 May 2016
    
    Modified:  21 June 2016 (MTC) - Changed the model calculation (in BOLDMODEL_2comp) to remove any
    dependence on R2t (this is now incorporated into S0). 23 June 2016 (MTC) - changed it back a bit 
    
    */
    
#include "BOLD_models.h"
#include <cmath>
using namespace std;

// --- Kinetic curve functions ---

// 3 Compartment model (Tissue, Blood, CSF) 
double BOLDMODEL_General::kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0 ) const
{
    Tracer_Plus tr("BOLD:kc_evaluate_3_compartments");
    
    double SA; // total signal
    double St; // tissue
    double Se; // extracellular
    double Sb; // blood
    
    double R2b;  // calculated from Hct and OEF
    double R2bs;
    
    double dw;   // calculated from Hct and OEF
    double R2tp; // calculated from zeta and dw
    
    // evaluate St
    // needs to use numerical integration and a bessel function 
    
    // asymptotic version of St
    dw = 887.4802*OEF*Hct;
    R2tp = zt*dw;
    
    if (tau < (-0.75/dw))
    {
        // St = exp(zt - 2*(R2t-R2tp)*tau);
        St = exp(zt - 2*(R2t-R2tp)*tau) * exp(- (TE - 2*tau)*R2t);
    }
    else if (tau > (0.75/dw))
    {
        // St = exp(zt - 2*(R2t+R2tp)*tau);
        St = exp(zt - 2*(R2t+R2tp)*tau) * exp(- (TE - 2*tau)*R2t);
    }
    else
    {
        St = exp(-(8/9)*zt*pow(dw*tau,2) - R2t*TE);
    }
    
   // St *= exp(- (TE - 2*tau)*R2t);
    
    // evaluate Se
    Se = exp(-R2e*TE)*cos(-(4.0*M_PI*df*tau));
    
    
    // evaluate Sb
    R2b  = 14.9*Hct + 14.7 + (302.1*Hct + 41.8)*pow(OEF,2);
    R2bs = 16.4*Hct +  4.5 + (165.2*Hct + 55.7)*pow(OEF,2);
    Sb = exp(-(R2b*(TE-2.0*tau)) - (2.0*R2bs*tau));

    // sum signal
    SA = ((1 - lam - zt)*St) + (lam*Se) + (zt*Sb);
    SA *= S0;
    
    return SA;
    
}

// Two Compartment Model (CSF-nulled)
double BOLDMODEL_2comp::kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0 ) const
{
    Tracer_Plus tr("BOLD:kc_evaluate_2_compartments");
    
    double SA; // total signal
    double St; // tissue
    double Sb; // blood
    
    double R2b;  // calculated from Hct and OEF
    double R2bs;
    
    double dw;   // calculated from Hct and OEF
    double R2tp; // calculated from zeta and dw;
    
    // fractions, which need to be converted from tanh functions
    double f_zt  = (zt);
    double f_Hct = (Hct);
    double f_OEF = (OEF);
    
    // evaluate St
    // needs to use numerical integration and a bessel function 
    
    // asymptotic version of St
    dw = 887.4802*f_OEF*f_Hct;
    R2tp = f_zt*dw;
    
    if (tau < (-0.75/dw)) // long tau regime (below 0)
    {
        // St = exp(zt - 2*(R2t-R2tp)*tau);
        St = exp(zt - 2*(R2t-R2tp)*tau) * exp(- (TE - 2*tau)*R2t);
        // St = exp(zt + 2*R2tp*tau);
    }
    else if (tau > (0.75/dw)) // long tau regime (above 0)
    {
        // St = exp(zt - 2*(R2t+R2tp)*tau);
        St = exp(zt - 2*(R2t+R2tp)*tau) * exp(- (TE - 2*tau)*R2t);
        // St = exp(zt - 2*R2tp*tau);
    }
    else // short tau regime 
    {
        St = exp(-(8/9)*zt*pow(dw*tau,2) - R2t*TE);
        // St = exp(-(8/9)*zt*pow(dw*tau,2));
    }
    
   // St *= exp(- (TE - 2*tau)*R2t);
    
    // evaluate Sb
    R2b  = 14.9*f_Hct + 14.7 + (302.1*f_Hct + 41.8)*pow(f_OEF,2);
    R2bs = 16.4*f_Hct +  4.5 + (165.2*f_Hct + 55.7)*pow(f_OEF,2);
    Sb = exp(-(R2b*(TE-2.0*tau)) - (2.0*R2bs*tau));

    // sum signal
    // SA = (S0*(1 - f_zt)*St) + (f_zt*Sb);
    SA = S0*( ((1-f_zt)*St) + (f_zt*Sb) );
    
    /*
    // print out a bunch of stuff so we know what's going on
    cout << "\n--- Calling BOLDMODEL_2comp::kc_evaluate for tau = " << tau << " \n";
    // cout << "     R2t = " << R2t << "\n";
    // cout << "     t(z)= " << f_zt << "\n";
    cout << "     St  = " << St << "\n";
    // cout << "     Sb  = " << Sb << "\n";
    cout << "     S0  = " << S0 << "\n";
    cout << "     SA  = " << SA << "\n";
    */
    return SA;
    
}

// Two Compartment Model (CSF-nulled)
double BOLDMODEL_R2prime::kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0 ) const
{
    Tracer_Plus tr("BOLD:kc_evaluate_R2_prime");
    
    double SA; // total signal
    
    // evaluate Signal (this will only work in the long tau regime)
    SA = S0 * exp(-(TE-(2*tau))*(-R2t));

    return SA;
    
}


