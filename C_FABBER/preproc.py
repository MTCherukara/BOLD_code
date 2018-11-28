#!/usr/bin/env python3
"""This function will perform all of the FSL-related pre-processing steps on an input NIFTI file
containing qBOLD ASE data. It's based on some shell scripts by Alan Stone.

Matthew Cherukara, 2018, Oxford.

CHANGELOG: 

2018-11-23 (MTC). Original version."""

# Imports
import sys
import subprocess  
import ast 

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# General Functions
def split_filename(input_name):
    """Split a string containing a filename into two strings, one of the directory, and the
    other of just the file's name (and extension)"""
    parts = input_name.split("/")

    if len(parts) == 1:
        out_dir  = "."
    else:
        out_dir = ""
        for part in parts[:-1]:
            out_dir += part + "/"
    
    out_name = parts[-1] 

    return out_dir, out_name

def find_voxel_size(dirname, filename):
    """Uses FSLVAL to find the pixel size along the first dimension, return it as an float"""
    fslval = ["fslval", (dirname + filename), "pixdim1"]
    vox_size = subprocess.Popen(fslval, stdout=subprocess.PIPE)
    return float(vox_size.stdout.read().decode())

def remove_temp_dir(dirname):
    """Removes the directory that was set up earlier"""
    subprocess.check_call(["rm", "-r", dirname])

def split_spinecho(dirname, filename, SEvol=1, outname="SE_FLAIR"):
    """Separates out a spin-echo volume from a stack of ASE volumes"""
    temp_dirname = (dirname + "killme.splitvols")
    subprocess.check_call(["mkdir", temp_dirname])
    subprocess.check_call(["fslsplit", (dirname + filename), (temp_dirname + "/splitvol"), "-t"])

    name_SEvol = "".join([temp_dirname, "/splitvol", str(SEvol).zfill(4), ".nii.gz"])
    subprocess.check_call(["mv", name_SEvol, (dirname + outname + ".nii.gz")])
    remove_temp_dir(temp_dirname)
    return outname

def apply_transform(dirname, inname, refname, txname, outname="PVE_GM"):
    """Use APPLYWARP to transform a map from anatomical to ASE space"""
    subprocess.check_call(["applywarp", ("--in=" + dirname + inname), ("--ref=" + dirname + refname), \
                           ("--out=" + dirname + outname), ("--premat=" + dirname + txname), \
                           "--super", "--superlevel=4", "--interp=trilinear"])
    return outname

def apply_threshold(dirname, filename, threshold=0.5, outname="mask_GM"):
    """Apply a binary threshold to a file"""
    subprocess.check_call(["fslmaths", (dirname + filename), "-thr", str(threshold), \
                           "-sub", str(1), "-uthr", str(threshold-1), "-add", str(1), \
                           (dirname + outname)])
    return outname


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Pre-processing Functions
def do_zaveraging(dirname, filename, outname="ASE_FLAIR"):
    """Call the zaverage.py script to processes GESEPI data"""
    subprocess.check_call(["./zaverage.py", (dirname + filename), (dirname + outname)])
    return outname

def do_mocorr(dirname, filename, SEvol=1, outname="ASE_FLAIR_mc"):
    """Perform motion correction using MCFLIRT"""
    print("     Performing motion correction relative to volume",str(SEvol),"...")
    subprocess.check_call(["mcflirt", "-in", (dirname + filename), "-out", (dirname + outname), \
                           "-refvol", str(SEvol)])
    return outname 

def do_smoothing(dirname, filename, outname="ASE_FLAIR_mc_av"):
    """Perform subvoxel smoothing"""
    print("     Performing subvoxel smoothing...")

    # Find voxel size
    vsize = find_voxel_size(dirname, filename)

    # We define our kernel this way, I'm not 100% sure why
    kernelsize = vsize/2.5

    subprocess.check_call(["fslmaths", (dirname + filename), "-kernel", "gauss", str(kernelsize), \
                           "-fmean", (dirname + outname)])
    return outname

def do_brainmask(dirname, filename, outname="ASE_FLAIR", f=0.5):
    """Create a brain mask using BET"""
    print("     Creating a brain mask...")
    subprocess.check_call(["bet", (dirname + filename), (dirname + outname), "-m", "-n", \
                           "-f", str(f)])
    return (outname + "_mask")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Anatomical-processing functions    
def do_brainextract(dirname, filename, outdir="0", outname="Anat_Brain", f=0.5):
    """Extract brain from T1 image using BET"""
    print("     Performing brain extraction...")
    if outdir == "0":
        outdir = dirname
    #subprocess.check_call(["bet", (dirname + filename), (outdir + outname), "-f", str(f)])
    return outname

def do_fastsegment(dirname, filename):
    """Use FAST to segment the T1w anatomical into 3 compartments"""
    print("     Segmenting the brain...")
    #subprocess.check_call(["fast", (dirname + filename), "-o", (dirname + filename)])

def do_registration(ase_dir, ase_file, anat_dir, anat_file, brain_dir, brain_file, outname="ASE_high"):
    """Use EPI_REG (part of FLIRT) to register the ASE data to the anatomical"""
    print("     Registering ASE data to anatomical space...")
    subprocess.check_call(["epi_reg", ("--epi=" + ase_dir + ase_file), ("--t1=" + anat_dir + anat_file), \
                           ("--t1brain=" + brain_dir + brain_file), ("--out=" + ase_dir + outname)])
    return outname

def do_flirtreg(dirname, filename, refname, outname="ASE_high", txname="ASE_low_tx.mat"):
    """Use FLIRT to register the ASE data to the anatomical"""
    print("     Registering ASE data to anatomical space...")
    subprocess.check_call(["flirt", "-in", (dirname + filename), "-ref", (dirname + refname), \
                           "-out", (dirname + outname), "-omat", (dirname + outname + "_tx.mat")])
    subprocess.check_call(["convert_xfm", "-omat", (dirname + txname), "-inverse", \
                           (dirname + outname + "_tx.mat")])
    return outname, txname


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main Function
if __name__ == "__main__":
    
    # Make sure we have a legit argument supplied
    if len(sys.argv) < 2:
        print("preproc.py usage: preproc.py input_ASE_data [anatomical_data]")
        exit(1)
    
    # store the input as a constant
    FULL_IN_NAME = sys.argv[1] 
    print("\nPre-processing ASE data in",FULL_IN_NAME)

    # split input into directory and filename 
    FILE_DIR, CURR_FILE = split_filename(FULL_IN_NAME)  

    # Slice averaging
    CURR_FILE = do_zaveraging(FILE_DIR, CURR_FILE)

    # Motion correction using MCFLIRT - ideally referrenced to the spin echo volume
    CURR_FILE = do_mocorr(FILE_DIR, CURR_FILE, SEvol=3)

    # Subvoxel smoothing, based on the image voxel size
    CURR_FILE = do_smoothing(FILE_DIR, CURR_FILE) 

    # Separate the spin echo
    SE_FILE = split_spinecho(FILE_DIR, CURR_FILE) 

    # Create a brain mask
    MASK_FILE = do_brainmask(FILE_DIR, SE_FILE, f=0.4)

    print("...Done ASE Pre-Processing!")

    if len(sys.argv) == 3:
        ANAT_IN_NAME = sys.argv[2]
        print("\nProcessing Anatomical Data in",ANAT_IN_NAME)

        # split into directory and file name
        ANAT_DIR, ANAT_FILE = split_filename(ANAT_IN_NAME)

        # brain extract - store it in the ASE folder
        BRAIN_FILE = do_brainextract(ANAT_DIR, ANAT_FILE, outdir=FILE_DIR)

        # segmentation - this function doesn't have an output
        do_fastsegment(FILE_DIR, BRAIN_FILE)

        # generate an ANAT-to-ASE transformation matrix using FLIRT
        TX_ASE,TX_LOW_MAT = do_flirtreg(FILE_DIR, SE_FILE, BRAIN_FILE)

        # transform the grey-matter PVE map from ANAT to ASE space
        print("     Creating a grey-matter mask...")
        GM_MAP = apply_transform(FILE_DIR, (BRAIN_FILE + "_pve_1"), SE_FILE, TX_LOW_MAT)

        # threshold the GM PVE map
        GM_MASK = apply_threshold(FILE_DIR, GM_MAP)