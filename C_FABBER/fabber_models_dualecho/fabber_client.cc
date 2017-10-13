/*  FABBER - Fast ASL and BOLD Bayesian Estimation Routine

    Michael Chappell, FMRIB Image Analysis & IBME QuBIc Groups

    Copyright (C) 2007-2015 University of Oxford  */

/*  CCOPYRIGHT */

#include "fabber_core/fabber_core.h"

// Models to be included from library
#include "fwdmodel_pcASL.h"
#include "fwdmodel_q2tips.h"
#include "fwdmodel_quipss2.h"

int main(int argc, char **argv)
{
    //add the ASL models from the library - these will autoregister at this point
    pcASLFwdModel::NewInstance();
    Quipss2FwdModel::NewInstance();
    Quipss2FwdModel::NewInstance();

    return execute(argc, argv);
}
