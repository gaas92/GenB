 #!/bin/bash

START=0
#Configuration 

SCRAM="el8_amd64_gcc10"
#RELEASE FOR EVERY STEP
#NOTE! AOD STEP REQUIRES SAME RELEASE W.R.T MINIAOD
#AT LEAST FOR THIS MC PRODUCTION
S0_REL="CMSSW_12_4_14_patch3"
S1_REL="CMSSW_12_4_14_patch3"
S2_REL="CMSSW_12_4_14_patch3"
S3_REL="CMSSW_12_4_14_patch3"
CHANNEL_DECAY="1-BdToKs0JpsiMuMu-PHSP"


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
    #cmsRun -e -j FrameworkJobReport.xml -p PSet.py
	cmsRun -j ${CHANNEL_DECAY}_step0.log -p PSet.py
fi

if [ $START -le 1 ];
then
	echo "\n\n==================== cmssw environment prepration Reco step ====================\n\n"

	if [ -r $S1_REL/src ] ; then
	  echo release $S1_REL already exists
	else
	  scram p CMSSW $S1_REL
	fi
	cd $S1_REL/src
	eval `scram runtime -sh`
	scram b
	cd ../../

	echo "==================== PB: CMSRUN starting Reco step ===================="
	cmsRun -e -j ${CHANNEL_DECAY}_step1.log step1-PREMIXRAW-${CHANNEL_DECAY}-run_cfg.py
	#cleaning
	#rm -rfv step0-GS-${CHANNEL_DECAY}.root
fi

if [ $START -le 2 ];
then
	echo "================= PB: CMSRUN starting Reco step 2 ===================="
	if [ -r $S2_REL/src ] ; then
	  echo release $S2_REL already exists
	else
	  scram p CMSSW $S2_REL
	fi
	cd $S2_REL/src
	eval `scram runtime -sh`
	scram b
	cd ../../

	cmsRun -e -j ${CHANNEL_DECAY}_step2.log step2-AODSIM-${CHANNEL_DECAY}-run_cfg.py
fi

if [ $START -le 3 ];
then
	echo "================= PB: CMSRUN starting step 3 ===================="
	if [ -r $S3_REL/src ] ; then
	  echo release $S3_REL already exists
	else
	  scram p CMSSW $S3_REL
	fi
	cd $S3_REL/src
	eval `scram runtime -sh`
	scram b
	cd ../../

	cmsRun -e -j FrameworkJobReport.xml  step3-MINIAODSIM-${CHANNEL_DECAY}-run_cfg.py
	#cleaning
	#rm -rfv step2-DR-${CHANNEL_DECAY}.root
fi