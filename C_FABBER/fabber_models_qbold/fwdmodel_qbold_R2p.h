/*   fwdmodel_qbold_R2p.h - The ASE qBOLD curve fitting model, fitting R2-prime and DBV

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_QBOLD_R2P_H
#define FWDMODEL_QBOLD_R2P_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class R2primeFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return (infer_OEF ? 1 : 0) + (infer_R2p ? 1 : 0) + (infer_DBV ? 1 : 0)
             + (infer_R2t ? 1 : 0) + (infer_S0  ? 1 : 0) + (infer_R2e ? 1 : 0) 
             + (infer_dF  ? 1 : 0) + (infer_lam ? 1 : 0) + (infer_Hct ? 1 : 0) 
             + (infer_geo ? 1 : 0) + (infer_CBV ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector taus;
    NEWMAT::ColumnVector TEvals;

    // Lookup starting indices of parameters
    int OEF_index() const
    {
        return (infer_OEF ? 1 : 0);
    }
    
    int R2p_index() const
    {
        return OEF_index() + (infer_R2p ? 1 : 0);
    }

    int DBV_index() const
    {
        return R2p_index() + (infer_DBV ? 1 : 0);
    }

    int R2t_index() const
    {
        return DBV_index() + (infer_R2t ? 1 : 0);
    }

    int S0_index() const
    {
        return R2t_index() + (infer_S0 ? 1 : 0);
    }

    int Hct_index() const
    {
        return S0_index() + (infer_Hct ? 1 : 0);
    }

    int R2e_index() const
    {
        return Hct_index() + (infer_R2e ? 1 : 0);
    }

    int dF_index() const
    {
        return R2e_index() + (infer_dF ? 1 : 0);
    }

    int lam_index() const
    {
        return dF_index() + (infer_lam ? 1 : 0);
    }

    int geo_index() const
    {
        return lam_index() + (infer_geo ? 1 : 0);
    }

    int CBV_index() const
    {
        return geo_index() + (infer_CBV ? 1 : 0);
    }

    // Which parameters will we infer on
    bool infer_OEF;
    bool infer_R2p;
    bool infer_DBV;
    bool infer_R2t;
    bool infer_S0;
    bool infer_Hct;
    bool infer_R2e;
    bool infer_dF;
    bool infer_lam;
    bool infer_geo;
    bool infer_CBV;
    bool single_comp;
    bool motion_narr;

private:
    static FactoryRegistration<FwdModelFactory, R2primeFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_R2P_H
