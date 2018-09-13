/*   fwdmode_phenom.h - Solving the phenomenological ASE qBOLD model (Dickson et al., 2011)

 Matthew Cherukara, IBME

 Copyright (C) 2018 University of Oxford  */

#ifndef FWDMODEL_PHENOM_H
#define FWDMODEL_PHENOM_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

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
        return 9;
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Simulation Parameters
    double OEF;
    double DBV;
    double TE;
    NEWMAT::ColumnVector taus;

    // Model coefficients
    int b11_index() const
    {
        return 1;
    }

    int b12_index() const
    {
        return 2;
    }

    int b13_index() const
    {
        return 3;
    }

    int b21_index() const
    {
        return 4;
    }

    int b22_index() const
    {
        return 5;
    }

    int b23_index() const
    {
        return 6;
    }

    int b31_index() const
    {
        return 7;
    }

    int b32_index() const
    {
        return 8;
    }

    int b33_index() const
    {
        return 9;
    }


private:
    static FactoryRegistration<FwdModelFactory, PhenomFwdModel> registration;
};

#endif // FWDMODEL_PHENOM_H
