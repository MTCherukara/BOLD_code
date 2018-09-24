/*   fwdmode_phenom.h - Solving the phenomenological ASE qBOLD model (Dickson et al., 2011)

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#ifndef FWDMODEL_PHENOM_H
#define FWDMODEL_PHENOM_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"
#include <fabber_core/tools.h>

#include "newmat.h"

#include <string>
#include <vector>

using namespace std;

class PhenomFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return 9 + (infer_OEF ? 1 : 0) + (infer_DBV ? 1 : 0);
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

    using FwdModel::SetupARD;
    virtual void SetupARD(const MVNDist &posterior, MVNDist &prior, double &Fard);
    virtual void UpdateARD(const MVNDist &posterior, MVNDist &prior, double &Fard) const;

protected:

    // Simulation Parameters
    double fixedOEF;
    double fixedDBV; 
    double TE;

    NEWMAT::ColumnVector taus;

    double tau_start;
    double tau_step;
    double tau_end;

    // indices of parametes
    int OEF_index() const
    {
        return (infer_OEF ? 10 : 0);
    }
    int DBV_index() const
    {
        return (infer_DBV ? (10 + (infer_OEF ? 1 : 0)) : 0 );
    }

    // vector indices for the parameters to experience ARD
    std::vector<int> ard_index;

    // Do we want to infer on OEF and DBV
    bool infer_OEF;
    bool infer_DBV;

    // Are we doing ARD?
    bool doard;

private:
    static FactoryRegistration<FwdModelFactory, PhenomFwdModel> registration;
};

#endif // FWDMODEL_PHENOM_H
