/*   fwdmodel_flair.h - difference between two images, with and without FLAIR

 Matthew Cherukara, IBME

 Copyright (C) 2019 University of Oxford  */

#ifndef FWDMODEL_FLAIR_H
#define FWDMODEL_FLAIR_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class FlairFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const 
    {
        return 2;
    }    
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector TIs;
    double TR;
    double TE;

    // Bayesian inference parameters
    double prec_lam;
    double prec_M0;

    // Lookup starting indices of parameters
    int M0_index() const
    {
        return 1;
    }

    int lam_index() const
    {
        return 2;
    }



private:
    static FactoryRegistration<FwdModelFactory, FlairFwdModel> registration;
};

#endif // FWDMODEL_FLAIR_H
