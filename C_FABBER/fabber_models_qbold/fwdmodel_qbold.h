/*   fwdmodel_qbold.h - The ASE qBOLD curve fitting model

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_QBOLD_H
#define FWDMODEL_QBOLD_H

#include "fabber_core/fwdmodel.h"

#include "newmat.h"

#include <string>

class QBoldFwdModel : public FwdModel {
public:
    static FwdModel* NewInstance();

    QBoldFwdModel()
        : m_include_offset(false)
    {
    }

    // in the old version, these functions are virtual, maybe this isn't necessary given that
    // we will only have one model?
    void GetOptions(std::vector<OptionSpec>& opts) const;
    std::string GetDescription() const;
    std::string ModelVersion() const;

    void Initialize(FabberRunData& args);
    int NumParams() const; // this is hard-coded to a number of parameters in the .cc 
    void NameParams(std::vector<std::string>& names) const;
    void HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const;
    void Evaluate(const NEWMAT::ColumnVector& params, NEWMAT::ColumnVector& result) const;

    /* add Protected parameters for:
            - Fitting parameter look-up indices (may not be necessary if we always fit the same ones)
            - Derived parameters (e.g. dw, R2b, R2bs)
            - Inference inclusion parameters (bools)
            - Scan parameters (tau, TE)
            - Model declaration (e.g. QBOLDMODEL* QBOLD_model)
    */
private:
    bool m_include_offset; // is this a sine-specific thing? Perhapsibly
    static FactoryRegistration<FwdModelFactory, QBoldFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_H
