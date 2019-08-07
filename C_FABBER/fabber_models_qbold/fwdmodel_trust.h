/*   fwdmodel_trust.h - TRUST fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2019 University of Oxford  */

#ifndef FWDMODEL_TRUST_H
#define FWDMODEL_TRUST_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class TrustFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return (infer_OEF ? 1 : 0) + (infer_R2b ? 1 : 0) + (infer_S0  ? 1 : 0)
             + (infer_Hct ? 1 : 0) + (infer_R1b ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector TEs;


    // Lookup starting indices of parameters
    int OEF_index() const
    {
        return (infer_OEF ? 1 : 0);
    }
    
    int R2b_index() const
    {
        return OEF_index() + (infer_R2b ? 1 : 0);
    }

    int S0_index() const
    {
        return R2b_index() + (infer_S0 ? 1 : 0);
    }

    int Hct_index() const
    {
        return S0_index() + (infer_Hct ? 1 : 0);
    }

    int R1b_index() const
    {
        return Hct_index() + (infer_R1b ? 1 : 0);
    }


    // Which parameters will we infer on
    bool infer_OEF;
    bool infer_R2b;
    bool infer_S0;
    bool infer_Hct;
    bool infer_R1b;
   
private:
    static FactoryRegistration<FwdModelFactory, TrustFwdModel> registration;
};

#endif // FWDMODEL_TRUST_H
