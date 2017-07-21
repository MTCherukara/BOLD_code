/*  fwdmodel_BOLD_MTC.h - BOLD model

    Matthew Cherukara, FMRIB Physics Group
    
    9 May 2016 */
    
#ifndef __FABBER_BOLD_MODEL
#define __FABBER_BOLD_MODEL 1

#include "fabbercore/fwdmodel.h"
#include "fabbercore/inference.h"
#include <string>

#include "asl_models.h"
#include "BOLD_models.h"

using namespace std;

class BOLDFwdModel : public FwdModel {
    
    public:
        // this may also be unnecessary, since we have a constructor below
        static FwdModel* NewInstance();
        
        // Virtual function overrides
        virtual void Initialize(ArgsType& args);
        virtual void Evaluate(const ColumnVector& params, 
                        ColumnVector& result) const;
        virtual vector<string> GetUsage() const;
        virtual string ModelVersion() const;
                        
        virtual void DumpParameters(const ColumnVector& vec,
                                        const string& indents = "") const;
                                        
        virtual void NameParams(vector<string>& names) const;
        virtual ~BOLDFwdModel() { return; }

        virtual void HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const;
        virtual void InitParams(MVNDist& posterior) const;
        
        // This one might need some changing done to it
        virtual int NumParams() const
        {
            return ((infer_OEF?1:0) + (infer_zeta?1:0) + (infer_lam?1:0) + (infer_Hct?1:0) + (infer_df?1:0) + (infer_R2t?1:0) + (infer_stat?1:0) + (infer_CSF?1:0));
            // return 7.0;
        }
        
        //constructor
        // BOLDFwdModel(ArgsType& args);
        
    protected: // Constants
    
        // Fitting paramater look-up indices
        
        int p_index_OEF()  const {return (infer_OEF?1:0); }                     // OEF
        int p_index_zeta() const {return p_index_OEF()  + (infer_zeta?1:0); }   // DBV
        int p_index_lam()  const {return p_index_zeta() + (infer_lam?1:0);  }   // CSF fraction
        int p_index_Hct()  const {return p_index_lam()  + (infer_Hct?1:0);  }   // fractional hematocrit
        int p_index_df()   const {return p_index_Hct()  + (infer_df?1:0);   }   // frequency shift
        int p_index_R2t()  const {return p_index_df()   + (infer_R2t?1:0);  }   // R2 tissue
        int p_index_Stat() const {return p_index_R2t()  + (infer_stat?1:0); }   // S0 tissue intensity
        int p_index_CSF()  const {return p_index_Stat() + (infer_CSF?1:0); }    // R2 csf

        /*
        int p_index_OEF()  const {return 1; }                    // OEF
        int p_index_zeta() const {return p_index_OEF()  + 1; }   // DBV
        int p_index_lam()  const {return p_index_zeta() + 1; }   // CSF fraction
        int p_index_Hct()  const {return p_index_lam()  + 1; }   // fractional hematocrit
        int p_index_df()   const {return p_index_Hct()  + 1; }   // frequency shift
        int p_index_R2t()  const {return p_index_df()   + 1; }   // R2 tissue
        int p_index_Stat() const {return p_index_R2t()  + 1; }   // S0 tissue intensity
        */
        // derived parameters
        double dw;      // 1/Tc
        double R2b;     // R2 blood
        double R2bs;    // R2* blood
        double TE;      // Echo time
        
        // inference inclusion parameters to define which parameters are being inferred on 
        bool infer_Hct;
        bool infer_lam;
        bool infer_zeta;
        bool infer_OEF;
        bool infer_df;
        bool infer_R2t;
        bool infer_stat;
        bool infer_CSF;
        
        // "scan parameters"
        ColumnVector tau_list;
        
        // also declare some Models eg:     AIFModel* art_model;
        BOLDMODEL* BOLD_model;
        
    private:
        static FactoryRegistration<FwdModelFactory, BOLDFwdModel> registration;
        
};

#endif //__FABBER_BOLD_MODEL
