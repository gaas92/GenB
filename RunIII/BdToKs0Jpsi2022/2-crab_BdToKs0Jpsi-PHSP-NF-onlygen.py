from CRABClient.UserUtilities import config
import datetime
import time

config = config()

ts = time.time()
st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d-%H-%M')

channel = '2-BdToKs0JpsiMuMu-PHSP-NF'
gen_var = '-run_cfg.py'
step = 'PrivMC'
nEvents = 5000#36554
NJOBS = 100
mygen = "step0-RAWSIM-"+channel+gen_var
myname = step+'-'+channel

config.General.requestName = step+'-'+channel+'-'+st
config.General.transferOutputs = True
config.General.transferLogs = False
config.General.workArea = 'crab_'+step+'-'+channel

config.JobType.allowUndistributedCMSSW = True
config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = mygen

# For SIM  
#config.JobType.inputFiles = ['step1-GENSIMRAW-'+channel+gen_var,
#                             'step2-AODSIM-'+channel+gen_var,
#                             'step3-MINIAODSIM-'+channel+gen_var]

config.JobType.disableAutomaticOutputCollection = True
config.JobType.eventsPerLumi = 10000
config.JobType.numCores = 1
config.JobType.maxMemoryMB = 3500
config.JobType.scriptExe = '2-crabjob-BdToKs0Jpsi-PHSP-NF-onlygen.sh'
#config.JobType.scriptArgs = ["0"]

config.JobType.outputFiles = ['step0-RAWSIM-'+channel+'-result.root']

config.Data.outputPrimaryDataset = myname
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = nEvents
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
config.Data.publication = False

config.Data.outLFNDirBase = '/store/user/gayalasa/'+step+channel+'/'
config.Site.storageSite = 'T3_CH_CERNBOX'