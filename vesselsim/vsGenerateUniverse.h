/*  vsGenerateUniverse.h 

    Vessel Simulator for qBOLD
    
    Returns origin-coordinates and orientation vectors for a set of randomly positioned
    / oriented infinite cylinders (of radius R) in a spherical space, occupying total 
    volume fraction F.

    Matthew Cherukara, IBME QUBIC Group & FMRIB Physics Group

    Copyright (C) 2016 University of Oxford

*/

#ifndef __VSGENERATEUNIVERSE_H
#define __VSGENERATEUNIVERSE_H 1

#include <string>
#include <vector>

#include "newmatap.h"

using namespace std;
using namespace NEWMAT;

class vsUniverse {
    public:
        static vsUniverse* NewInstance(); // constructor
        virtual ~FwdModel() {return; }; // destructor
        
        // methods for: 

    protected:
        // variables
        int maxVessels; // 100000
        int cutoff;     // 0, to start with

        Matrix vesselOrigins;
        Matrix vesselNormals;

        double universeRadius;
        double universeVolume;
        double filledVolumeFraction;

};


# endif /* __VSGENERATEUNIVERSE_H */