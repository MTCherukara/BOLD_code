/*  fwdmodel_BOLD_2_MTC.h - BOLD model

    Matthew Cherukara, FMRIB Physics Group
    
    1 June 2016 */
    
#ifndef __FABBER_2BOLD_MODEL
#define __FABBER_2BOLD_MODEL 1

#include "fabbercore/fwdmodel.h"
#include "fabbercore/inference.h"
#include <string>

#include "asl_models.h"
#include "BOLD_models.h"

using namespace std;

class BOLD2cFwdModel : public FwdModel {
    
    public:
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
        virtual ~BOLD2cFwdModel() { return; }

        virtual void HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const;
        virtual void InitParams(MVNDist& posterior) const;
        
        // virtual void SetupARD(const MVNDist& posterior, MVNDist& prior, double& Fard) const;
        // virtual void UpdateARD(const MVNDist& posterior, MVNDist& prior, double& Fard) const;
        
        // This one might need some changing done to it
        virtual int NumParams() const
        {
            return ((infer_OEF?1:0) + (infer_zeta?1:0) + (infer_Hct?1:0) + (infer_R2t?1:0) + (infer_stat?1:0));
        }
        
        
    protected: // Constants
    
        // Fitting paramater look-up indices
        
        int p_index_OEF()  const {return (infer_OEF?1:0);}                      // OEF
        int p_index_zeta() const {return p_index_OEF()  + (infer_zeta?1:0); }   // DBV
        int p_index_Hct()  const {return p_index_zeta() + (infer_Hct?1:0);  }   // fractional hematocrit
        int p_index_R2t()  const {return p_index_Hct()  + (infer_R2t?1:0);  }   // R2 tissue
        int p_index_Stat() const {return p_index_R2t()  + (infer_stat?1:0); }   // static tissue intensity
        
        // derived parameters
        double dw;      // 1/Tc
        double R2b;     // R2 blood
        double R2bs;    // R2* blood
        double TE;      // Echo time 
        
        // inference inclusion parameters to define which parameters are being inferred on 
        bool infer_Hct;
        bool infer_zeta;
        bool infer_OEF;
        bool infer_R2t;
        bool infer_stat;
        
        // ARD
        // int ard_index() const { return 2;}
        
        // "scan parameters"
        ColumnVector tau_list;
        ColumnVector taus;
        
        // also declare some Models eg:     AIFModel* art_model;
        BOLDMODEL* BOLD_model;
        
    private:
        static FactoryRegistration<FwdModelFactory, BOLD2cFwdModel> registration;
        
};

#endif //__FABBER_2BOLD_MODEL
