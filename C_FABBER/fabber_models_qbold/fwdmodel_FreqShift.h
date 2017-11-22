/*   fwdmodel_FreqShift.h - ASE qBOLD fitting of frequency shift DF by comparing FLAIR and nonFLAIR data

 Matthew Cherukara, IBME

 Copyright (C) 2017 University of Oxford  */

#ifndef FWDMODEL_FREQSHIFT_H
#define FWDMODEL_FREQSHIFT_H

#include "fabber_core/fwdmodel.h"
#include "fabber_core/inference.h"

#include "newmat.h"

#include <string>

using namespace std;

class FreqShiftFwdModel : public FwdModel {
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
    double TE;
    double TI;

    // Parameters are: Magnetization M0, VCSF, DF
    // Lookup starting indices of parameters - 
    int M0_index() const
    {
        // Magnetization M0
        return 1;
    }
    int VC_index() const
    {
        // V^CSF
        return 2;
    }
    int DF_index() const
    {
        // Delta F
        return 3;
    }

    // don't need any boolean options (for now)

private:
    static FactoryRegistration<FwdModelFactory, FreqShiftFwdModel> registration;
};

#endif // FWDMODEL_FREQSHIFT_H
