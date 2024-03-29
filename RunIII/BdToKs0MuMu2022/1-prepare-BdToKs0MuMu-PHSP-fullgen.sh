
#!/bin/bash
#all steps from https://cms-pdmv-prod.web.cern.ch/mcm/requests?dataset_name=BdToJpsiK0s_Unbiased_TuneCP5_13p6TeV_pythia8-evtgen&page=0&shown=2151940099


#for some reason this doesn't work, doesnt work until 24/10/23
#export SCRAM_ARCH=el8_amd64_gcc10

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_14_patch3/src ] ; then
  echo release CMSSW_12_4_14_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_14_patch3
fi
cd CMSSW_12_4_14_patch3/src
eval `scram runtime -sh`


# Configuration parameters
CHANNEL_DECAY="1-BdToKs0MuMu-PHSP"
step0_fragmentfile="1-BdToKs0MuMu-BPH-Run3Summer22EEGS-00102.py"
step0_configfile="step0-RAWSIM-${CHANNEL_DECAY}-run_cfg.py"
step0_resultfile="step0-RAWSIM-${CHANNEL_DECAY}-result.root"

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
EVENTS=10000 #36554

#Step 0
# cmsDriver command origin: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/BPH-Run3Summer22EEGS-00102
#cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --beamspot Realistic25ns13p6TeVEarly2022Collision --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(8333)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile
echo cmsDriver for step-0 Gen ok 

# step1 DIGI, 

#export SCRAM_ARCH=el8_amd64_gcc10
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_14_patch3/src ] ; then
  echo release CMSSW_12_4_14_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_14_patch3
fi
cd CMSSW_12_4_14_patch3/src
eval `scram runtime -sh`

scram b
cd ../..

# Configuration parameters
step1_configfile="step1-PREMIXRAW-${CHANNEL_DECAY}-run_cfg.py"
step1_resultfile="step1-PREMIXRAW-${CHANNEL_DECAY}-result.root"

#cmsdriver origin: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/BPH-Run3Summer22EEDRPremix-00127
#cmsDriver.py  --python_filename $step1_configfile --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v14 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step0_resultfile --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
cmsDriver.py  --python_filename $step1_configfile --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v14 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step0_resultfile --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step1_configfile
echo cmsDriver for step-1 DIGI ok 


# step2 

#export SCRAM_ARCH=el8_amd64_gcc10
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_14_patch3/src ] ; then
  echo release CMSSW_12_4_14_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_14_patch3
fi
cd CMSSW_12_4_14_patch3/src
eval `scram runtime -sh`

scram b
cd ../..


# Configuration parameters
step2_configfile="step2-AODSIM-${CHANNEL_DECAY}-run_cfg.py"
step2_resultfile="step2-AODSIM-${CHANNEL_DECAY}-result.root"

#cmsdriver origin: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/BPH-Run3Summer22EEDRPremix-00127
#cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --procModifiers siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step1_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step RAW2DIGI,L1Reco,RECO,RECOSIM --procModifiers siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step1_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step2_configfile
echo cmsDriver for step-2 RECO ok 


# step3 MINIAODSIM
#for some reason this doesn't work

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_4_14_patch3/src ] ; then
  echo release CMSSW_12_4_14_patch3 already exists
else
  scram p CMSSW CMSSW_12_4_14_patch3
fi
cd CMSSW_12_4_14_patch3/src
eval `scram runtime -sh`

scram b
cd ../..

# Configuration parameters 
step3_configfile="step3-MINIAODSIM-${CHANNEL_DECAY}-run_cfg.py"
step3_resultfile="step3-MINIAODSIM-${CHANNEL_DECAY}-result.root"

#cmsDriver command origin: https://cms-pdmv-prod.web.cern.ch/mcm/public/restapi/requests/get_test/BPH-Run3Summer22EEMiniAODv3-00127
#cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 124X_mcRun3_2022_realistic_postEE_v1 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run3 --no_exec --mc -n $EVENTS || exit $? ;

echo cmsDriver for step-3 MINIAOD ok 