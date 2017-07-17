/*   CCOPYRIGHT   */

#ifndef FWDMODEL_QBOLD_LIB_H
#define FWDMODEL_QBOLD_LIB_H

#include "fabber_core/fwdmodel.h"

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

#endif // FWDMODEL_QBOLD_LIB_H
