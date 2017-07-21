/*   fwdmodel_qbold.h - The ASE qBOLD curve fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_QBOLD_H
#define FWDMODEL_QBOLD_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class QBoldFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    // virtual function overrides
    virtual void Initialize(ArgsType &args);
    virtual string ModelVersion() const;
    virtual void GetOptions(vector<OptionSpec> &opts) const;
    virtual string GetDescription() const;

    virtual void NameParams(vector<string> &names) const;
    virtual int NumParams() const { return 2; } // OEF, DBV
    virtual void HardcodedInitialDists(MVNDist &prior, MVNDist &posterior) const;
    virtual void Evaluate(const NEWMAT::ColumnVector &params, NEWMAT::ColumnVector &result) const;

protected:

    // Scan Parameters
    NEWMAT::ColumnVector tau_list;
    NEWMAT::ColumnVector taus;
    double TE;

    // Model declaration
    // QBOLDModel* QBOLD_Model;

    /* add Protected parameters for:
            - Fitting parameter look-up indices (may not be necessary if we always fit the same ones)
            - Inference inclusion parameters (bools)
    */
private:
    static FactoryRegistration<FwdModelFactory, QBoldFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_H
