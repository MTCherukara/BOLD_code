/*   fwdmodel_qbold_vols.h - The ASE qBOLD curve fitting model, fitting based on comparmtnet vols

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_QBOLD_VOL_H
#define FWDMODEL_QBOLD_VOL_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class qvolFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return (infer_S0 ? 1 : 0) + (infer_R2p ? 1 : 0) + (infer_DBV ? 1 : 0) + (infer_lam ? 1 : 0) + (infer_vw ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector taus;
    NEWMAT::ColumnVector TEvals;

    // Lookup starting indices of parameters
    int S0_index() const
    {
        return (infer_S0 ? 1 : 0); // ALWAYS infer on S0
    }

    int R2p_index() const
    {
        return S0_index() + (infer_R2p ? 1 : 0);
    }

    int DBV_index() const
    {
        return R2p_index() + (infer_DBV ? 1 : 0);
    }

    int lam_index() const
    {
        return DBV_index() + (infer_lam ? 1 : 0);
    }

    int vw_index() const
    {
        return lam_index() + (infer_vw ? 1 : 0);
    }

    // Which parameters will we infer on
    bool infer_S0;
    bool infer_R2p;
    bool infer_DBV;
    bool infer_lam;
    bool infer_vw;
    // infer_S0 = TRUE always

private:
    static FactoryRegistration<FwdModelFactory, qvolFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_VOL_H
