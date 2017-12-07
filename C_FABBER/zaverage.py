#!/usr/bin/env python3
"""This function takes an ASE nifti file and performs slice averaging,
it's based on a C-shell script by Alan Stone.

Matthew Cherukara, 2017, Oxford."""

# Imports
import sys
import subprocess

# Functions
def make_temp_dir():
    """Create the temporary output directory"""
    output_dir = "killme.zaverage"
    subprocess.check_call(["mkdir", output_dir])
    return output_dir

def remove_temp_dir(dirname):
    """Removes the directory that was set up earlier"""
    subprocess.check_call(["rm", "-r", dirname])
    return

def split_data(dirname, filename):
    """Split the ASE image into separate slices"""
    subprocess.check_call(["fslslice", filename, ''.join([dirname, "/data"])])
    return

def count_slices(filename):
    """Return the number of slices in the ASE image"""
    fslval = ["fslval", filename, "dim3"]
    num_slices = subprocess.Popen(fslval, stdout=subprocess.PIPE)
    return num_slices.stdout.read()

def name_slice(dirname, slicenum):
    """Return a string containing the name of a single-slice nifti"""
    return ''.join([dirname, "/data_slice_", str(slicenum).zfill(4)])

def average_slices(dirname, numslices):
    """Averages sets of 4 slices, up to numslices slices (e.g. 10)"""

    # Loop through new slices
    for ss in range(0, 1):

        # Name 4 slices
        slice_1 = name_slice(dirname, (4*ss))
        slice_2 = name_slice(dirname, (4*ss)+1)
        slice_3 = name_slice(dirname, (4*ss)+2)
        slice_4 = name_slice(dirname, (4*ss)+3)

        # Copy Geometries
        subprocess.check_call(["fslcpgeom", slice_1, slice_2])
        subprocess.check_call(["fslcpgeom", slice_1, slice_3])
        subprocess.check_call(["fslcpgeom", slice_1, slice_4])

        # Average
        slice_av = ''.join([dirname, "/average_", str(ss).zfill(3)])
        subprocess.check_call(["fslmaths", slice_1, "-add", slice_2, "-add", \
                               slice_3, "-add", slice_4, "-div", str(4), slice_av])

        # Sort out the Z-spacing in the header
        hdr_pipe = subprocess.Popen(["fslhd", "-x", slice_av], stdout=subprocess.PIPE)
        open("tmp_hdr.txt", "a").write(str(hdr_pipe.stdout.read()))
        
        

    return

# Main Function
if __name__ == "__main__":

    # Make sure the correct number of arguments are supplied
    if len(sys.argv) != 3:
        print("zaverage.py usage: zaverage.py ASE_data_in ASE_data_out")
        exit(1)

    # Store the relevant filenames as Constants
    FILE_IN_NAME = sys.argv[1]
    FILE_OUT_NAME = sys.argv[2]

    # Set up temporary directory
    TEMPDIR = make_temp_dir()

    # Split the image into slices
    split_data(TEMPDIR, FILE_IN_NAME)

    # Count the number of slices
    NZ = int(count_slices(FILE_IN_NAME))

    # Averaging
    average_slices(TEMPDIR, int(NZ/4))

    # Delete the directory
    #remove_temp_dir(TEMPDIR)
