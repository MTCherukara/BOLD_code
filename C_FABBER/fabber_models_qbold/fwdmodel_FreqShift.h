/*   fwdmodel_FreqShift.h - ASE qBOLD fitting of frequency shift DF by comparing FLAIR and nonFLAIR data

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_FREQSHIFT_H
#define FWDMODEL_FREQSHIFT_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class FreqShiftFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return 1 + (infer_VC ? 1 : 0) + (infer_DF ? 1 : 0) + (infer_R2p ? 1 : 0) + (infer_DBV ? 1 : 0) + (infer_phi ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector taus;
    double TE;
    double TI;
    double TR;

    // Parameters are: Magnetization M0, VCSF, DF
    // Lookup starting indices of parameters - 
    int M0_index() const
    {
        // Magnetization M0
        return 1;
    }
    int VC_index() const
    {
        // V^CSF
        return M0_index() + (infer_VC ? 1 : 0);
    }
    int DF_index() const
    {
        // Delta F
        return VC_index() + (infer_DF ? 1 : 0);
    }
    int R2p_index() const
    {
        // R2-prime tissue
        return DF_index() + (infer_R2p ? 1 : 0);
    }
    int DBV_index() const
    {
        // DBV
        return R2p_index() + (infer_DBV ? 1 : 0);
    }
    int phi_index() const
    {
        // DBV
        return DBV_index() + (infer_phi ? 1 : 0);
    }

    // For choosing which parameters to infer on
    bool infer_VC;
    bool infer_DF;
    bool infer_DBV;
    bool infer_phi;
    bool infer_R2p;

private:
    static FactoryRegistration<FwdModelFactory, FreqShiftFwdModel> registration;
};

#endif // FWDMODEL_FREQSHIFT_H
