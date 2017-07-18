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
