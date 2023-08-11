
#!/bin/bash

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
CHANNEL_DECAY="BdToKs0JpsiMuMu"
step0_fragmentfile="BdToKs0JpsiMuMu_BPH-Commission22GS-00001.py"
step0_configfile="step0-GS-${CHANNEL_DECAY}-run_cfg.py"
step0_resultfile="step0-GS-${CHANNEL_DECAY}-result.root"

# Download fragment from myGitHub
curl -s -k https://raw.githubusercontent.com/gaas92/GenB/master/RunIII/GenFragments/$step0_fragmentfile --retry 3 --create-dirs -o Configuration/GenProduction/python/$step0_fragmentfile
[ -s Configuration/GenProduction/python/$step0_fragmentfile ] || exit $?;

# Check if fragment contais gridpack path ant that it is in cvmfs
#if grep -q "gridpacks" Configuration/GenProduction/python/$step0_fragmentfile; then
#  if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" Configuration/GenProduction/python/$step0_fragmentfile; then
#    echo "Gridpack inside fragment is not in cvmfs."
#    exit -1
#  fi
#fi
scram b
cd ../..

# Maximum validation duration: 28800s
# Margin for validation duration: 30%
# Validation duration with margin: 28800 * (1 - 0.30) = 20160s
# Time per event for each sequence: 0.5942s
# Threads for each sequence: 1
# Time per event for single thread for each sequence: 1 * 0.5942s = 0.5942s
# Which adds up to 0.5942s per event
# Single core events that fit in validation duration: 20160s / 0.5942s = 33927
# Produced events limit in McM is 10000
# According to 0.0417 efficiency, validation should run 10000 / 0.0417 = 239714 events to reach the limit of 10000
# Take the minimum of 33927 and 239714, but more than 0 -> 33927
# It is estimated that this validation will produce: 33927 * 0.0417 = 1415 events
EVENTS=100 #33927

# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_v12 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(2397)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
#check if necessary
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile
echo cmsDriver for step-0 Gen ok 

# step1 DIGI, DATAMIX, L1, DIGIRAW, HLT

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
step1_configfile="step1-PREMIXRAW-${CHANNEL_DECAY}-run_cfg.py"
step1_resultfile="step1-PREMIXRAW-${CHANNEL_DECAY}-result.root"

# Z cmsDriver Example 
# cmsDriver command for DIGI,DATAMIX,L1,DIGI2RAW,HLT step1
# cmsDriver.py --python_filename $step1_configfile --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/Neutrino_E-10_gun/RunIISummer17PrePremix-PUAutumn18_102X_upgrade2018_realistic_v15-v1/GEN-SIM-DIGI-RAW" --conditions 102X_upgrade2018_realistic_v15 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:@relval2018 --procModifiers premix_stage2 --geometry DB:Extended --filein file:$step0_resultfile --datamix PreMix --era Run2_2018 --no_exec --mc -n $EVENTS;

# TAKEN FROM https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIAutumn18DR-00097
# cmsDriver command for DIGI,L1,DIGI2RAW,HLT step1 mising DataMix don't know why
# cmsDriver.py  --python_filename $step1_configfile --eventcontent FEVTDEBUGHLT --pileup "AVE_25_BX_25ns,{'N': 20}" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/MinBias_TuneCP5_13TeV-pythia8/RunIIFall18GS-102X_upgrade2018_realistic_v9-v1/GEN-SIM" --conditions 102X_upgrade2018_realistic_v15 --step DIGI,L1,DIGI2RAW,HLT:@relval2018 --geometry DB:Extended --filein file:$step0_resultfile --era Run2_2018 --no_exec --mc -n $EVENTS || exit $?;

# cmsDriver command for 2022 BPH analysis https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/TSG-Run3Summer22DRPremix-00057
# cmsDriver.py  --python_filename $step1_configfile --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/Neutrino_E-10_gun/Run3Summer21PrePremix-Summer22_124X_mcRun3_2022_realistic_v11-v2/PREMIX" --conditions 124X_mcRun3_2022_realistic_v12 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v12 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step0_resultfile --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
cmsDriver.py  --python_filename $step1_configfile --eventcontent PREMIXRAW --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RAW --fileout file:$step1_resultfile --pileup_input "/store/mc/RunIISummer20ULPrePremix/Neutrino_E-10_gun/PREMIX/UL16_106X_mcRun2_asymptotic_v13-v1/120004/358A7F8C-2ED3-3B4C-8F5D-64A7B2DF6B34.root" --conditions 124X_mcRun3_2022_realistic_v12 --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:2022v12 --procModifiers premix_stage2,siPixelQualityRawToDigi --geometry DB:Extended --filein file:$step0_resultfile --datamix PreMix --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step1_configfile
echo cmsDriver for step-1 DIGI ok 


# step2 AODSIM
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_12_6_4/src ] ; then
  echo release CMSSW_12_6_4 already exists
else
  scram p CMSSW CMSSW_12_6_4
fi
cd CMSSW_12_6_4/src
eval `scram runtime -sh`

scram b
cd ../..


# Configuration parameters
step2_configfile="step2-AODSIM-${CHANNEL_DECAY}-run_cfg.py"
step2_resultfile="step2-AODSIM-${CHANNEL_DECAY}-result.root"

# Z cmsDriver Example
# cmsDriver command for RAW2DIGI,L1Reco,RECO,RECOSIM,EI step2
# cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --procModifiers premix_stage2 --filein file:$step1_resultfile --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS; 

# taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIAutumn18RECOBParking-00080
# cmsDriver command for RAW2DIGI,L1Reco,RECO,RECOSIM,EI step2 missing --procModifiers premix_stage2 i guess is the same isue 
#cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:$step1_resultfile  --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS;
#cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --filein file:$step1_resultfile  --era Run2_2018,bParking --no_exec --mc -n $EVENTS || exit $?; 
#cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --filein file:$step1_resultfile  --era Run2_2018 --no_exec --mc -n $EVENTS || exit $?; 
#cmsDriver taken (check RECO filecontent and extra config) taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/TSG-Run3Winter23Reco-00136
cmsDriver.py  --python_filename $step2_configfile --eventcontent RECOSIM,AODSIM --customise RecoParticleFlow/PFClusterProducer/particleFlow_HB2023.customiseHB2023,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-RECO,AODSIM --fileout file:$step2_resultfile --conditions 126X_mcRun3_2023_forPU65_v3 --step RAW2DIGI,L1Reco,RECO,RECOSIM --geometry DB:Extended --filein file:$step1_resultfile --era Run3_2023 --no_exec --mc -n $EVENTS || exit $? ;
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step2_configfile
echo cmsDriver for step-2 RECO ok 


# step3 MINIAODSIM
# same cmssw  

# Configuration parameters 
step3_configfile="step3-MINIAODSIM-${CHANNEL_DECAY}-run_cfg.py"
step3_resultfile="step3-MINIAODSIM-${CHANNEL_DECAY}-result.root"

# Z cmsDriver Example
# cmsDriver command for MINIAOD
#cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 102X_upgrade2018_realistic_v15 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS;

#taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIAutumn18MiniAOD-00259
#cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 102X_upgrade2018_realistic_v15 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run2_2018,bParking --runUnscheduled --no_exec --mc -n $EVENTS || exit $?;
#cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 102X_upgrade2018_realistic_v15 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS || exit $?;
# cmadriver for miniAOD takrn from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_test/TSG-Run3Winter23MiniAOD-00136
cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 126X_mcRun3_2023_forPU65_v3 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run3_2023 --no_exec --mc -n $EVENTS || exit $? ;
echo cmsDriver for step-3 MINIAOD ok 