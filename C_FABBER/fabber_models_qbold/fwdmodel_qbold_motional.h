/*   fwdmodel_qbold_motional.h - An ASE qBOLD model based on Berman, 2017

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#ifndef FWDMODEL_QBOLD_MOTIONAL_H
#define FWDMODEL_QBOLD_MOTIONAL_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class MotionalFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return (infer_R2p ? 1 : 0) + (infer_DR2 ? 1 : 0) + (infer_R2t ? 1 : 0) + (infer_S0 ? 1 : 0) + (infer_lam ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector taus;
    NEWMAT::ColumnVector TEvals;

    // Lookup starting indices of parameters
    int R2p_index() const
    {
        return (infer_R2p ? 1 : 0);
    }

    int DR2_index() const
    {
        return R2p_index() + (infer_DR2 ? 1 : 0);
    }

    int R2t_index() const
    {
        return DR2_index() + (infer_R2t ? 1 : 0);
    }

    int S0_index() const
    {
        return R2t_index() + (infer_S0 ? 1 : 0);
    }

    int lam_index() const
    {
        return S0_index() + (infer_lam ? 1 : 0);
    }

    // Which parameters will we infer on
    bool infer_R2p;
    bool infer_DR2;
    bool infer_R2t;
    bool infer_S0;
    bool infer_lam;

private:
    static FactoryRegistration<FwdModelFactory, MotionalFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_MOTIONAL_H
