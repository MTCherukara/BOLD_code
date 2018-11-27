#include "mex.h"
#include <string>
#include <vector>
#include <time.h>
#include <stdint.h>
#include <cstdarg>
#include <complex>

// display prints in Matlab without delay
void mexPrintf_fast(const char * msg, ...)
{
   va_list argList;
   va_start(argList, msg);

   // buffer the input message
   int BUFSIZE = 256; 
   char msgbuf[BUFSIZE];
   vsnprintf(msgbuf, BUFSIZE-1, msg, argList); 

   // print buffered message
   mexPrintf(msgbuf);

   va_end(argList);
   mexEvalString("drawnow;"); // to dump string
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    const mxArray *mxtmpfid = prhs[0];
    
    if ( !mxIsComplex(mxtmpfid) || !mxIsSingle(mxtmpfid) )
        mexErrMsgIdAndTxt("MATLAB:rdMeas_mex_fid:real", "ERROR: Input <tmpfid> is not complex single!");
        
    float *tmpfid_r = (float*)mxGetData(mxtmpfid);
    float *tmpfid_i = (float*)mxGetImagData(mxtmpfid);
    
    // Print passed values
    mexPrintf_fast("tmpfid_r[0] = %f ,tmpfid_i[0] = %f.\n", tmpfid_r[0], tmpfid_i[0]);    
    
    // Modify
    tmpfid_r[0] = 1.2345;
    tmpfid_i[0] = 2.3456;
    
    tmpfid_r[1] = 0.012345;
    tmpfid_i[1] = 0.023456;
    
    // Print passed values
    mexPrintf_fast("After modification tmpfid_r[0] = %f ,tmpfid_i[0] = %f.\n", tmpfid_r[0], tmpfid_i[0]);    
}