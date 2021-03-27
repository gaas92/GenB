 #!/bin/bash

START=0
#Configuration 

SCRAM="slc7_amd64_gcc700"
#RELEASE FOR EVERY STEP
#NOTE! AOD STEP REQUIRES SAME RELEASE W.R.T MINIAOD
#AT LEAST FOR THIS MC PRODUCTION
S0_REL="CMSSW_10_2_16_UL"
CHANNEL_DECAY="B0toKs0MuMu_BPH_noProbeFilterDecayFilter"


if [ $START -le 0 ];
then
	echo "\n\n==================== cmssw environment prepration Gen step ====================\n\n"
	source /cvmfs/cms.cern.ch/cmsset_default.sh
	export SCRAM_ARCH=$SCRAM

	if [ -r $S0_REL/src ] ; then
	  echo release $S0_REL already exists
	else
	  scram p CMSSW $S0_REL
	fi
	cd $S0_REL/src
	eval `scram runtime -sh`

	scram b
	cd ../../

	echo "==================== PB: CMSRUN starting Gen step ===================="
	#cmsRun -e -j ${CHANNEL_DECAY}_step0.log  -p PSet.py
    cmsRun -e -j FrameworkJobReport.xml -p PSet.py
	#cmsRun -j ${CHANNEL_DECAY}_step0.log -p step0-GS-${CHANNEL_DECAY}_cfg.py
fi

