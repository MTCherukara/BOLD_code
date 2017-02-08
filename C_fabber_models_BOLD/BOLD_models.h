/*  BOLD_models.h - Kinetic curve models for qBOLD

    Matthew Cherukara - FMRIB Physics Group
    
    10 May 2016         */
    
#ifndef __FABBER_MODELS_BOLD
#define __FABBER_MODELS_BOLD 

#include "miscmaths/miscmaths.h"
#include "miscmaths/miscprob.h"

using namespace MISCMATHS;

#include "utils/tracer_plus.h"

using namespace Utilities;

// generic BOLD model class
class BOLDMODEL
{
    public:
        // evaluate
        virtual double kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0 ) const = 0 ;
        
        // report number of parameters
        virtual int NumDisp() const = 0;
        
        // return default priors
        virtual ColumnVector Priors() const {return priors;}
        virtual string Name() const = 0;
        virtual void SetPriorMean(int paramn, double value) { priors(paramn) = value; }
        
    protected:
        ColumnVector priors;
        
};

// BOLD models
class BOLDMODEL_General : public BOLDMODEL
{
    public:
        virtual double kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0) const;
        virtual int NumDisp() const {return 0;}
        virtual string Name() const {return "BOLD Model - General";  }
};

// 2 Compartment (CSF-nulled) BOLD
class BOLDMODEL_2comp : public BOLDMODEL
{
    public:
        virtual double kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0) const;
        virtual int NumDisp() const {return 0;}
        virtual string Name() const {return "BOLD Model - 2 Compartment";  }
};

class BOLDMODEL_R2prime : public BOLDMODEL
{
    public:
        virtual double kc_evaluate(const double tau, const double TE, const double R2t, const double R2e, const double OEF, const double Hct, const double zt, const double lam, const double df, const double S0) const;
        virtual int NumDisp() const {return 0;}
        virtual string Name() const {return "BOLD Model - R2 Prime only";  }
};

// define other functions which may be useful ...


#endif 
