/*   fwdmodel_sqbold.h - The ASE streamlined qBOLD model, for i             inference on linear taus and the spin-echo only.

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#ifndef FWDMODEL_SQBOLD_H
#define FWDMODEL_SQBOLD_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class sqBOLDFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return 3;
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector taus;

    // Bayesian inference parameters
    double prec_R2p;
    double prec_DBV;

    // Model parameters
    double SR;      // this is a scaling factor for R2', applied in the asymptotic model

    // Lookup starting indices of parameters
    int R2p_index() const
    {
        return 1;
    }

    int DBV_index() const
    {
        return 2;
    }

    int S0_index() const
    {
        return 3;
    }


private:
    static FactoryRegistration<FwdModelFactory, sqBOLDFwdModel> registration;
};

#endif // FWDMODEL_SQBOLD_H
