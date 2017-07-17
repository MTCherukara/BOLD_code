/*  qbold_models.cc, 2-compartment qBOLD model fitting for ASE data

    Matthew Cherukara, IBME, University of Oxford

    Original: 17 July 2017

    Changelog:
        ...

*/

#include "qbold_models.h"
#include "fwdmodel_qbold.h"

#include <fabber_core/fwdmodel.h>

extern "C" {
int CALL get_num_models()
{
    return 1;
}

const char *CALL get_model_name(int index)
{
    switch (index)
    {
    case 0:
        return "qbold";
        break;
    default:
        return NULL;
    }
} // get_model_name

NewInstanceFptr CALL get_new_instance_func(const char *name)
{
    if (string(name) == "qbold")
    {
        return QBoldFwdModel::NewInstance;
    }
    else
    {
        return NULL;
    }
} // get_new_instance_func
} // extern "C"

namespace OXASL {

// Evaluation of qBOLD model, 2 compartments, ASE acquisition
    double QBOLDModel_ASE2C::EvaluateSignal(const double tau, const double TE, const double OEF, const double DBV, const double R2t) const {
        Tracer_Plus tr("BOLD:evaluate_ase2c");

        // variables
        double SA;  // total signal
        double St;  // tissue signal
        double Sb;  // blood signal

        double R2b;     // R2 of blood, calculated from OEF
        double R2bs;    // R2* of blood

        double dw;      // change in characteristic frequency
        double R2tp;    // R2' of tissue

        // Evaluate St using the asymptotic version
        // dw = 4/3 * pi * gamma * B0 * dChi * Hct * OEF
        dw = 301.7433*OEF;
        R2tp = DBV*dw;

        if (tau < (-1.5/dw))
        {
            St = exp(DBV + (R2tp*tau));
        }
        else if (tau > (1.5/dw))
        {
            St = exp(DBV - (R2tp*tau));
        }
        else
        {
            St = exp(-0.3*DBV*pow(dw*tau,2))
        }
        
        // Evaluate Sb
        R2b  = 10.076 + (111.868*pow(OEF,2));
        R2bs = 19.766 + (144.514*pow(OEF,2));

        Sb = exp(-R2b*(TE-tau))*exp(-R2bs*abs(tau));

        // Total Signal
        SA = ((1-DBV)*St) + (DBV*Sb);

        return SA;

    } // QBOLDModel_ASE2C::EvaluateSignal(...)

}

// Here, define the kc function for the specific version of the qBOLD model we're using
