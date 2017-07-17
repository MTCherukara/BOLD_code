/*  qbold_models.h, 2-compartment qBOLD model fitting for ASE data

    Matthew Cherukara, IBME, University of Oxford

    Original: 17 July 2017

    Changelog:
        ...

*/
/*   CCOPYRIGHT   */

#ifndef FWDMODEL_QBOLD_LIB_H
#define FWDMODEL_QBOLD_LIB_H

#include "fabber_core/fwdmodel.h"
#include "miscmaths/miscmaths.h" // these are in asl_models.h, so it probably won't hurt
// #include "miscmaths/miscprob.h" // currently can't find this thing...

using namespace MISCMATHS;

// Have a look at the ASL version of this, because it looks pretty different from BOLD_models.h

// Required to export the correct functions to the DLL in Windows
#ifdef _WIN32
  #ifdef fabber_models_qbold_EXPORTS
    #define DLLAPI __declspec(dllexport)
  #else
    #define DLLAPI __declspec(dllimport)
  #endif
  #define CALL __stdcall
#else
  #define DLLAPI
  #define CALL
#endif

extern "C" {
  DLLAPI int CALL get_num_models();
  DLLAPI const char * CALL get_model_name(int index);
  DLLAPI NewInstanceFptr CALL get_new_instance_func(const char *name);
}

/*  At this point in asl_models.h, there is the definition of the generic model class (AIFModel),
    and then a bunch of more specific AIF models e.g. AIFModel_nodisp, which each have a bunch
    of public (virtual) methods
*/ 

namespace OXASL {

  // generic QBOLD model class
  class QBOLDModel {
  public:
    // evaluate the model
    virtual double EvaluateSignal(const double tau, const double TE, const double OEF, const double DBV, const double R2t) const = 0; // add some parameters in here

    // return default priors to parameters
    virtual ColumnVector Priors() const {return priors; }
    virtual string Name() const = 0;
    virtual void SetPriorMean(int paramn, double value) { priors(paramn) = value; }
  
  protected:
    ColumnVector priors; // list of prior means, followed by precisions

  }; // class QBOLDModel

  // specific QBOLD model - two-compartment ASE data
  class QBOLDModel_ASE2C : public QBOLDModel {
    virtual double EvaluateSignal(const double tau, const double TE, const double OEF, const double DBV, const double R2t) const;
    virtual string Name() const { return "ASE 2 Compartments"; }

  }; // class QBOLDModel_ASE2C

} // namespace OXASL

#endif // FWDMODEL_QBOLD_LIB_H
