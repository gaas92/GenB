
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
EVENTS=33927

# cmsDriver command
cmsDriver.py Configuration/GenProduction/python/$step0_fragmentfile --python_filename $step0_configfile --eventcontent RAWSIM --customise Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --fileout file:$step0_resultfile --conditions 124X_mcRun3_2022_realistic_v12 --beamspot Realistic25ns13p6TeVEarly2022Collision --customise_commands process.source.numberEventsInLuminosityBlock="cms.untracked.uint32(2397)" --step GEN,SIM --geometry DB:Extended --era Run3 --no_exec --mc -n $EVENTS || exit $? ;
#check if necessary
#sed -i "20 a from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper \nrandSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)\nrandSvc.populate()" $step0_configfile
