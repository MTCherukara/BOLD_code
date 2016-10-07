/*  fwdmodel_BOLD_2_MTC.h - BOLD model

    Matthew Cherukara, FMRIB Physics Group
    
    1 June 2016 */
    
#ifndef __FABBER_3BOLD_MODEL
#define __FABBER_3BOLD_MODEL 1

#include "fabbercore/fwdmodel.h"
#include "fabbercore/inference.h"
#include <string>

#include "asl_models.h"
#include "BOLD_models.h"

using namespace std;

class BOLDR2FwdModel : public FwdModel {
    
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
        virtual ~BOLDR2FwdModel() { return; }

        virtual void HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const;
        virtual void InitParams(MVNDist& posterior) const;
        
        // virtual void SetupARD(const MVNDist& posterior, MVNDist& prior, double& Fard) const;
        // virtual void UpdateARD(const MVNDist& posterior, MVNDist& prior, double& Fard) const;
        
        // This one might need some changing done to it
        virtual int NumParams() const
        {
            return 2.0;
        }
        
        
    protected: // Constants
    
        // Fitting paramater look-up indices
        
        int p_index_R2t()  const {return 1;}    // R2 tissue
        int p_index_Stat() const {return p_index_R2t() + 1;}    // static tissue intensity
        
        // constants
        double TE;      // echo time (s)
        
        // inference inclusion parameters to define which parameters are being inferred on 
        bool infer_R2t;
        bool infer_stat;
        
        // "scan parameters"
        ColumnVector tau_list;
        ColumnVector taus;
        
        // also declare some Models eg:     AIFModel* art_model;
        BOLDMODEL* BOLD_model;
        
    private:
        static FactoryRegistration<FwdModelFactory, BOLDR2FwdModel> registration;
        
};

#endif //__FABBER_3BOLD_MODEL
