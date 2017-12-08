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

def split_data(dirname, filename):
    """Split the ASE image into separate slices"""
    subprocess.check_call(["fslslice", filename, ''.join([dirname, "/data"])])

def count_slices(filename):
    """Return the number of slices in the ASE image"""
    fslval = ["fslval", filename, "dim3"]
    num_slices = subprocess.Popen(fslval, stdout=subprocess.PIPE)
    return num_slices.stdout.read()

def name_slice(dirname, slicenum):
    """Return a string containing the name of a single-slice nifti"""
    return ''.join([dirname, "/data_slice_", str(slicenum).zfill(4)])

def read_header(niiname, txtname="tmp_hdr.txt"):
    """Read a nifti header file NIINAME and write its contents to a text file TXTNAME"""
    # Call FSLHD
    hdr_pipe = subprocess.Popen(["fslhd", "-x", niiname], stdout=subprocess.PIPE)
    hdr_str = hdr_pipe.stdout.read().decode()
    
    # Split the string
    hdr_arr = filter(None, hdr_str.split("\n"))

    # Write it out element by element
    with open(txtname, "a") as txt_file:
        for hdr_entry in hdr_arr:
            print(hdr_entry, file=txt_file)

def edit_header(niiname, field, value):
    """Edit nifti header NIINAME such that FIELD has a new VALUE""" 
    # First read the header
    read_header(niiname, "killme.hdr.txt")

    # Then read the contents of the header into an array
    with open("killme.hdr.txt","r") as txt_hdr:
        hdr_arr = txt_hdr.readlines()
    
    # Open a new text file to write to line by line
    with open("killme.newhdr.txt","a") as new_hdr:

        # Search through elements
        for element in hdr_arr:

            # Find the element we want to change
            if "".join([field," ="]) in element:

                # Change it
                elem = element.split(" = ")
                elem[1] = "'{}'\n".format(value)

                # Write it out
                new_hdr.write("".join([elem[0],' = ',elem[1]]))
            else:
                new_hdr.write(element)


    # Write out the edited header
    p = subprocess.Popen(["fslcreatehd", "killme.newhdr.txt", niiname])
    p.communicate()

    # Delete the temporary header text files
    subprocess.check_call(["rm","killme.hdr.txt","killme.newhdr.txt"])

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

    # Merge new slices together

    # Correct the slice spacing dz

    # Delete everything that was left over
        

    return 1

# Main Function
if __name__ == "__main__":

    # Make sure the correct number of arguments are supplied
    if len(sys.argv) != 3:
        print("zaverage.py usage: zaverage.py ASE_data_in ASE_data_out")
        exit(1)

    # Store the relevant filenames as Constants
    FILE_IN_NAME = sys.argv[1]
    FILE_OUT_NAME = sys.argv[2]

    # Testing of read_header function
    edit_header(FILE_IN_NAME,"dz","7.5")

    """
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
    """