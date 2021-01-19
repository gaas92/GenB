#script taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_setup/BPH-RunIIFall18GS-00226

#!/bin/bash

export SCRAM_ARCH=slc7_amd64_gcc700

source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_10_2_16_UL/src ] ; then
  echo release CMSSW_10_2_16_UL already exists
else
  scram p CMSSW CMSSW_10_2_16_UL
fi
cd CMSSW_10_2_16_UL/src
eval `scram runtime -sh`

# Download fragment from My GitHub
curl -s -k https://raw.githubusercontent.com/gaas92/GenB/master/GenFragments/BPHnoFilters_B0toK0MM_GenFrag.py --retry 3 --create-dirs -o Configuration/GenProduction/python/BPHnoFilters_B0toK0MM_GenFrag.py--retry
[ -s Configuration/GenProduction/python/BPHnoFilters_B0toK0MM_GenFrag.py--retry ] || exit $?;
scram b
cd ../..

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


# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/BPHnoFilters_B0toK0MM_GenFrag.py --python_filename BPHnoFilters_B0toK0MM_1_cfg.py --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:BPH_B0toK0MM_GenNF.root --conditions 102X_upgrade2018_realistic_v11 --beamspot Realistic25ns13TeVEarly2018Collision --step GEN,SIM --geometry DB:Extended --era Run2_2018 --no_exec --mc -n $EVENTS || exit $? ;

