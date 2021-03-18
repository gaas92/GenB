
#!/bin/bash


# step0 GEN-SIM
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_16_UL/src ] ; then
  echo release CMSSW_10_2_16_UL already exists
else
  scram p CMSSW CMSSW_10_2_16_UL
fi
cd CMSSW_10_2_16_UL/src
eval `scram runtime -sh`

# Configuration parameters
CHANNEL_DECAY="B0toKs0MuMu_BPH_OpenFilter"
step0_fragmentfile="${CHANNEL_DECAY}-fragment.py"
step0_configfile="step0-GS-${CHANNEL_DECAY}-run_cfg.py"
step0_resultfile="step0-GS-${CHANNEL_DECAY}-result.root"

# Maximum validation duration: 86400s
# Margin for validation duration: 20%
# Validation duration with margin: 86400 * (1 - 0.20) = 69120s
# Time per event for each sequence: 1.0321s
# Threads for each sequence: 1
# Time per event for single thread for each sequence: 1 * 1.0321s = 1.0321s
# Which adds up to 1.0321s per event
# Single core events that fit in validation duration: 69120s / 1.0321s = 66973
# Produced events limit in McM is 10000
# According to 0.0022 efficiency, up to 10000 / 0.0022 = 4614674 events should run
# Clamp (put value) 66973 within 1 and 4614674 -> 66973
# It is estimated that this validation will produce: 66973 * 0.0022 = 145 events
EVENTS=100000

# Download fragment from myGitHub
curl -s -k https://raw.githubusercontent.com/gaas92/MCgenScripts/master/$step0_fragmentfile --retry 3 --create-dirs -o Configuration/GenProduction/python/$step0_fragmentfile
#curl -s -k https://raw.githubusercontent.com/gaas92/MCgenScripts/master/BPHnoFilters_B0toK0MM_GenFrag.py  --retry 3 --create-dirs -o Configuration/GenProduction/python/BPHnoFilters_B0toK0MM_GenFrag.py  
[ -s Configuration/GenProduction/python/$step0_fragmentfile ] || exit $?;
scram b
cd ../../

# taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIFall18GS-00251
# cmsDriver command for GEN-SIM step0
cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN,SIM --geometry DB:Extended --era Run2_2018 --python_filename $step0_configfile --fileout file:$step0_resultfile --no_exec --mc -n $EVENTS || exit $?; 
#cmsDriver.py Configuration/GenProduction/python/BPHnoFilters_B0toK0MM_GenFrag.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN,SIM --geometry DB:Extended --era Run2_2018 --python_filename $step0_configfile --fileout file:$step0_resultfile --no_exec --mc -n $EVENTS; 
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile

# step1 DIGI, DATAMIX, L1, DIGIRAW, HLT
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_13/src ] ; then
  echo release CMSSW_10_2_13 already exists
else
  scram p CMSSW CMSSW_10_2_13
fi
cd CMSSW_10_2_13/src
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
cmsDriver.py  --python_filename $step1_configfile --eventcontent FEVTDEBUGHLT --pileup "AVE_25_BX_25ns,{'N': 20}" --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM-DIGI-RAW --fileout file:$step1_resultfile --pileup_input "dbs:/MinBias_TuneCP5_13TeV-pythia8/RunIIFall18GS-102X_upgrade2018_realistic_v9-v1/GEN-SIM" --conditions 102X_upgrade2018_realistic_v15 --step DIGI,L1,DIGI2RAW,HLT:@relval2018 --geometry DB:Extended --filein file:$step0_resultfile --era Run2_2018 --no_exec --mc -n $EVENTS || exit $?;

sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step1_configfile


# step2 AODSIM
#same CMSSW

# Configuration parameters
step2_configfile="step2-AODSIM-${CHANNEL_DECAY}-run_cfg.py"
step2_resultfile="step2-AODSIM-${CHANNEL_DECAY}-result.root"

# Z cmsDriver Example
# cmsDriver command for RAW2DIGI,L1Reco,RECO,RECOSIM,EI step2
# cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --procModifiers premix_stage2 --filein file:$step1_resultfile --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS; 

# taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIAutumn18RECOBParking-00080
# cmsDriver command for RAW2DIGI,L1Reco,RECO,RECOSIM,EI step2 missing --procModifiers premix_stage2 i guess is the same isue 
#cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --geometry DB:Extended --filein file:$step1_resultfile  --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS;
cmsDriver.py  --python_filename $step2_configfile --eventcontent AODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier AODSIM --fileout file:$step2_resultfile --conditions 102X_upgrade2018_realistic_v15 --step RAW2DIGI,L1Reco,RECO,RECOSIM,EI --filein $step1_resultfile  --era Run2_2018,bParking --no_exec --mc -n $EVENTS || exit $?; 
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper\nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step2_configfile


# step3 MINIAODSIM
export SCRAM_ARCH=slc7_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_14/src ] ; then
  echo release CMSSW_10_2_14 already exists
else
  scram p CMSSW CMSSW_10_2_14
fi
cd CMSSW_10_2_14/src
eval `scram runtime -sh`
scram b
cd ../..

# Configuration parameters 
step3_configfile="step3-MINIAODSIM-${CHANNEL_DECAY}-run_cfg.py"
step3_resultfile="step3-MINIAODSIM-${CHANNEL_DECAY}-result.root"

# Z cmsDriver Example
# cmsDriver command for MINIAOD
#cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 102X_upgrade2018_realistic_v15 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run2_2018 --runUnscheduled --no_exec --mc -n $EVENTS;

#taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIAutumn18MiniAOD-00259
cmsDriver.py  --python_filename $step3_configfile --eventcontent MINIAODSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier MINIAODSIM --fileout file:$step3_resultfile --conditions 102X_upgrade2018_realistic_v15 --step PAT --geometry DB:Extended --filein file:$step2_resultfile --era Run2_2018,bParking --runUnscheduled --no_exec --mc -n $EVENTS || exit $?;