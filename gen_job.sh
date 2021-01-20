 #!/bin/bash

START=0

#Configuration 
CHANNEL_DECAY="B0toK0MM"



SCRAM="slc7_amd64_gcc700"
#RELEASE FOR EVERY STEP
GEN_REL="CMSSW_10_2_16_UL"

if [ $START -le 0 ];
then
	echo "\n\n==================== cmssw environment prepration Gen step ====================\n\n"
	source /cvmfs/cms.cern.ch/cmsset_default.sh
	export SCRAM_ARCH=$SCRAM

	if [ -r $GEN_REL/src ] ; then
	  echo release $GEN_REL already exists
	else
	  scram p CMSSW $GEN_REL
	fi
	cd $GEN_REL/src
	eval `scram runtime -sh`

	scram b
	cd ../../

	echo "==================== PB: CMSRUN starting Gen step ===================="
	#cmsRun -j ${CHANNEL_DECAY}_step0.log  -p PSet.py
    cmsRun -e -j FrameworkJobReport.xml -p PSet.py
	#cmsRun -j ${CHANNEL_DECAY}_step0.log -p step0-GS-${CHANNEL_DECAY}_cfg.py
fi