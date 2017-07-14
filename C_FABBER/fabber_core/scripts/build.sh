#!/bin/sh
#
# Make a clean build of Fabber
#
# Usage: build.sh [debug|release]

if [ -z $1 ]
then
  TYPE=debug
else
  TYPE=$1
fi

ORIGDIR=$PWD

scriptdir=`dirname $0`
rm -rf $scriptdir/../build_$TYPE
mkdir $scriptdir/../build_$TYPE
cd $scriptdir/../build_$TYPE
cmake .. -DCMAKE_BUILD_TYPE=$TYPE -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++
make

cd $ORIGDIR
