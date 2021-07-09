#!/bin/bash

# Ben Zimmerman, July 9 2021
# Transfers over specified subjects into a local BIDS directory
# Runs xcpEngine (modified by Dr. Babu Adhimoolam (Adhi))
# Transfers back output into derivatives folder

##############TODO####################
# Build chron to automatically search for new subjects
# Determine whether we want any of the group functions of xcpEngine and how to handle that
# Convert this script into a callable function to insert into project script
######################################

###########################################
# Set up subject list and directories
###########################################

    ##### MOUNTING REMOTE #####
    # sudo mount -t drvfs X: /mnt/x/
    # X: (\\130.126.125.16) or \\files2.beckman.illinois.edu\FabGrat

subject_IDs="1681"

remote_BIDS_directory="/mnt/x/PEA/bids_mri"
remote_fmriprep="${remote_BIDS_directory}/derivatives/fmriprep"
remote_resting_state_derivatives="${remote_BIDS_directory}/derivatives/resting_state/output"

local_BIDS_directory="/mnt/c/data/temp_file_transfer/bids_mri"
local_derivatives="${local_BIDS_directory}/derivatives"
local_fmriprep="${local_derivatives}/fmriprep"
local_resting_state_derivatives="${local_derivatives}/resting_state"
local_working_directory="${local_derivatives}/working_directory"

design_file="fc-36p_scrub.dsn"
cohort_file="pea_xcpeng_test.csv"


############################################
# Build local temporary BIDS file structure
############################################

mkdir ${local_BIDS_directory} ${local_derivatives} ${local_fmriprep} ${local_resting_state_derivatives} ${local_working_directory}


############################################
# BEGIN SUBJECT LOOP
for subID in ${subject_IDs}; do
############################################
# Transfer relevant files
############################################

    cp -r "${remote_fmriprep}/sub-${subID}" ${local_fmriprep}
    cp "${remote_fmriprep}/${design_file}" ${local_fmriprep}
    cp "${remote_fmriprep}/${cohort_file}" ${local_fmriprep}

############################################
# Run xcpEngine
############################################

    docker -rm --it run \
    -v ${local_fmriprep}:/data \
    -v ${local_working_directory}:/tmp \
    -v ${local_resting_state_derivatives}:/output \
    pennbbl/xcpengine:latest \
    -c /data/${cohort_file}
    -d /data/${design_file}
    -o /output \
    -i /tmp

############################################
# Transfer back derivatives
############################################

    cp -r "${local_resting_state_derivatives}/sub-${subID}" ${remote_resting_state_derivatives}

############################################
# Remove local files
############################################

    rm -r ${local_BIDS_directory}

done