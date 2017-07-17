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

    void GetOptions(std::vector<OptionSpec>& opts) const;
    std::string GetDescription() const;
    std::string ModelVersion() const;

    void Initialize(FabberRunData& args);
    int NumParams() const;
    void NameParams(std::vector<std::string>& names) const;
    void HardcodedInitialDists(MVNDist& prior, MVNDist& posterior) const;
    void Evaluate(const NEWMAT::ColumnVector& params, NEWMAT::ColumnVector& result) const;

private:
    bool m_include_offset;
    static FactoryRegistration<FwdModelFactory, QBoldFwdModel> registration;
};

#endif // FWDMODEL_QBOLD_H
