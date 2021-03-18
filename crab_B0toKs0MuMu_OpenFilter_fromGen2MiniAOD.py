from CRABClient.UserUtilities import config
import datetime
import time

config = config()

ts = time.time()
st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d-%H-%M')

channel = 'B0toKs0MuMu_BPH_OpenFilter'
gen_var = '-run_cfg.py'
step = 'PrivateMC-2018'
nEvents = 500
NJOBS = 400
mygen = "step0-GS-"+channel+gen_var
myname = step+'-'+channel

config.General.requestName = step+'-'+channel+'-'+st
config.General.transferOutputs = True
config.General.transferLogs = False
config.General.workArea = 'crab_'+step+'-'+channel

config.JobType.allowUndistributedCMSSW = True
config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = mygen

# For SIM  
config.JobType.inputFiles = ['step1-PREMIXRAW-'+channel+gen_var,
                             'step2-AODSIM-'+channel+gen_var,
                             'step3-MINIAODSIM-'+channel+gen_var]

config.JobType.disableAutomaticOutputCollection = True
config.JobType.eventsPerLumi = 10000
config.JobType.numCores = 1
config.JobType.maxMemoryMB = 3500
config.JobType.scriptExe = 'job_B0toKs0MuMu_OpenFilter_fromGen2MiniAOD.sh'
#config.JobType.scriptArgs = ["0"]

#config.JobType.outputFiles = ['step0-GS-'+channel+gen_frag+'-result.root']
config.JobType.outputFiles = ['step3-MINIAODSIM-'+channel+'-result.root']

config.Data.outputPrimaryDataset = myname
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = nEvents
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
#config.Data.outLFNDirBase = '/store/user/hcrottel/'
config.Data.publication = False

config.Data.outLFNDirBase = '/store/user/gayalasa/'+step+channel+'/'
config.Site.storageSite = 'T3_CH_CERNBOX'