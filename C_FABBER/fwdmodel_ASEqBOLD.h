/*   fwdmodel_ASEqBOLD.h - ASE qBOLD curve fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#ifndef FWDMODEL_ASEQBOLD_H
#define FWDMODEL_ASEQBOLD_H

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
        return (infer_R2p ? 1 : 0) + (infer_DBV ? 1 : 0) + (infer_R2t ? 1 : 0) + (infer_S0  ? 1 : 0) + (infer_Hct ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    double TR;
    double TI;
    NEWMAT::ColumnVector taus;
    NEWMAT::ColumnVector TEvals;

    // Lookup starting indices of parameters  
    int R2p_index() const
    {
        return (infer_R2p ? 1 : 0);
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


    // Which parameters will we infer on
    bool infer_R2p;
    bool infer_DBV;
    bool infer_R2t;
    bool infer_S0;
    bool infer_Hct;
    bool single_comp;

private:
    static FactoryRegistration<FwdModelFactory, R2primeFwdModel> registration;
};

#endif // FWDMODEL_ASEQBOLD_H
