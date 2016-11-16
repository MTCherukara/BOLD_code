/*  vsGenerateUniverse.cpp 

    Vessel Simulator for qBOLD
    
    Returns origin-coordinates and orientation vectors for a set of randomly positioned
    / oriented infinite cylinders (of radius R) in a spherical space, occupying total 
    volume fraction F.

    Matthew Cherukara, IBME QUBIC Group & FMRIB Physics Group

    Copyright (C) 2016 University of Oxford
*/

#include "vsGenerateUniverse.h"

#include <iostream>
#include "newmatio.h"
#include <stdexcept>

using namespace std;
using namespace NEWMAT;

// constructor
vsUniverse* vsUniverse::NewInstance()
{
    return new vsUniverse();
}

// destructor is defined in .h file

