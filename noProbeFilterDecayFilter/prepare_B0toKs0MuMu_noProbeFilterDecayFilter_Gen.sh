
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
CHANNEL_DECAY="B0toKs0MuMu_BPH_noProbeFilterDecayFilterGen"
step0_fragmentfile="${CHANNEL_DECAY}-fragment.py"
#step0_fragmentfile="BPHnoFilters_B0toK0MM_GenFrag.py"
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
EVENTS=10000

# Download fragment from myGitHub
curl -s -k https://raw.githubusercontent.com/gaas92/GenB/master/GenFragments/$step0_fragmentfile --retry 3 --create-dirs -o Configuration/GenProduction/python/$step0_fragmentfile
[ -s Configuration/GenProduction/python/$step0_fragmentfile ] || exit $?;
scram b
cd ../../

# taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIFall18GS-00251
# cmsDriver command for GEN-SIM step0
cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN --geometry DB:Extended --era Run2_2018 --python_filename $step0_configfile --fileout file:$step0_resultfile --no_exec --mc -n $EVENTS || exit $?; 
sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile

