
#!/bin/bash
#all steps from https://cms-pdmv.cern.ch/mcm/requests?dataset_name=B0ToJpsiK0s_JMM_BMuFilter_DGamma0_SoftQCDnonD_TuneCP5_13p6TeV-pythia8-evtgen&page=0&shown=2151677971 
#for some reason this doesn't work

#export SCRAM_ARCH=el8_amd64_gcc10

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_11_patch3/src ] ; then
  echo release CMSSW_12_4_11_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_11_patch3
fi
cd CMSSW_12_4_11_patch3/src
eval `scram runtime -sh`


# Configuration parameters
CHANNEL_DECAY="BdToKs0MuMu"
step0_fragmentfile="BdToKs0MuMu_genfragment.py"
step0_configfile="step0-GS-${CHANNEL_DECAY}-run_cfg.py"
step0_resultfile="step0-GS-${CHANNEL_DECAY}-result.root"

# Download fragment from myGitHub
curl -s -k https://raw.githubusercontent.com/gaas92/GenB/master/RunIII/GenFragments/$step0_fragmentfile --retry 3 --create-dirs -o Configuration/GenProduction/python/$step0_fragmentfile
[ -s Configuration/GenProduction/python/$step0_fragmentfile ] || exit $?;

# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/$step0_fragmentfile; then
  if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" Configuration/GenProduction/python/$step0_fragmentfile; then
    echo "Gridpack inside fragment is not in cvmfs."
    exit -1
  fi
fi
scram b
cd ../..

# Maximum validation duration: 57600s
# Margin for validation duration: 30%
# Validation duration with margin: 57600 * (1 - 0.30) = 40320s
# Time per event for each sequence: 1.1030s
# Threads for each sequence: 1
# Time per event for single thread for each sequence: 1 * 1.1030s = 1.1030s
# Which adds up to 1.1030s per event
# Single core events that fit in validation duration: 40320s / 1.1030s = 36554
# Produced events limit in McM is 10000
# According to 0.0140 efficiency, validation should run 10000 / 0.0140 = 712758 events to reach the limit of 10000
# Take the minimum of 36554 and 712758, but more than 0 -> 36554
# It is estimated that this validation will produce: 36554 * 0.0140 = 512 events
EVENTS=100 #10000  #36554

# cmsDriver command
#cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_v12 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(2397)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
#cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 125X_mcRun3_2022_realistic_v3 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(3571)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(7127)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
#check if necessary
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile
echo cmsDriver for step-0 Gen ok 

# step1 DIGI, 

#export SCRAM_ARCH=el8_amd64_gcc10
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_11_patch3/src ] ; then
  echo release CMSSW_12_4_11_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_11_patch3
fi
cd CMSSW_12_4_11_patch3/src
eval `scram runtime -sh`

scram b
cd ../..

# Configuration parameters
step1_configfile="step1-GENSIMRAW-${CHANNEL_DECAY}-run_cfg.py"
step1_resultfile="step1-GENSIMRAW-${CHANNEL_DECAY}-result.root"

#cmsDriver.py  --python_filename $step1_configfile --eventcontent RAWSIM --pileup 2022_LHC_Simulation_10h_2h --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/MinBias_TuneCP5_13p6TeV-pythia8/Commission22GS-125X_mcRun3_2022_realistic_v3-v1/GEN-SIM" --conditions 125X_mcRun3_2022_realistic_v3 --step DIGI,L1,DIGI2RAW,HLT:@relval2022 --geometry DB:Extended --filein file:$step0_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

cmsDriver.py  --python_filename $step1_configfile --eventcontent RAWSIM --pileup AVE_70_BX_25ns             --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/MinBias_TuneCP5_13p6TeV-pythia8/Run3Summer22GS-124X_mcRun3_2022_realistic_v10-v1/GEN-SIM" --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,L1,DIGI2RAW,HLT:2022v14 --geometry DB:Extended --filein file:$step0_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step1_configfile
echo cmsDriver for step-1 DIGI ok 


# step2 

#export SCRAM_ARCH=el8_amd64_gcc10
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_11_patch3/src ] ; then
  echo release CMSSW_12_4_11_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_11_patch3
fi
cd CMSSW_12_4_11_patch3/src
eval `scram runtime -sh`

scram b
cd ../..


# Configuration parameters
step2_configfile="step2-AODSIM-${CHANNEL_DECAY}-run_cfg.py"
step2_resultfile="step2-AODSIM-${CHANNEL_DECAY}-result.root"

cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:$step1_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step2_configfile
echo cmsDriver for step-2 RECO ok 


# step3 MINIAODSIM
#export SCRAM_ARCH=el8_amd64_gcc10
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_11_patch3/src ] ; then
  echo release CMSSW_12_4_11_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_11_patch3
fi
cd CMSSW_12_4_11_patch3/src
eval `scram runtime -sh`

scram b
cd ../..

# Configuration parameters 
step3_configfile="step3-MINIAODSIM-${CHANNEL_DECAY}-run_cfg.py"
step3_resultfile="step3-MINIAODSIM-${CHANNEL_DECAY}-result.root"

cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

echo cmsDriver for step-3 MINIAOD ok 