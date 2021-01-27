from CRABClient.UserUtilities import config
import datetime
import time

config = config()

ts = time.time()
st = datetime.datetime.fromtimestamp(ts).strftime('%Y-%m-%d-%H-%M')


nEvents = 100000
NJOBS = 50

config.General.requestName = '2018-PrivateMC-Step0'+'-BPHnoFilters_B0toK0MM'+'-'+st
config.General.transferOutputs = True
config.General.transferLogs = False
config.General.workArea = 'crab_'+'2018-PrivateMC-Step0'+'-BPHnoFilterB0toKMM'

config.JobType.allowUndistributedCMSSW = True
config.JobType.pluginName = 'PrivateMC'
config.JobType.psetName = 'BPHnoFilters_B0toK0MM_1_cfg.py'

# For SIM  
#config.JobType.inputFiles = ['step1-DR-'+channel+'_cfg.py',
#                             'step2-DR-'+channel+'_cfg.py',
#                             'step3-MiniAOD-'+channel+'_cfg.py',
#                             'step4-NanoAOD-'+channel+'_cfg.py']

config.JobType.disableAutomaticOutputCollection = True
config.JobType.eventsPerLumi = 10000
config.JobType.numCores = 1
config.JobType.maxMemoryMB = 3500
config.JobType.scriptExe = 'gen_job.sh'
#config.JobType.scriptArgs = ["0"]

config.JobType.outputFiles = ['BPH_B0toK0MM_GenNF.root']
#config.JobType.outputFiles = ['step0-GS-b_kmumu_PHSPS.root', 'step3-MiniAOD-b_kmumu_PHSPS.root', 'step4-NanoAOD-b_kmumu_PHSPS.root']

config.Data.outputPrimaryDataset = 'Step0-BPHnoFilters_B0toK0MM'
config.Data.splitting = 'EventBased'
config.Data.unitsPerJob = nEvents
config.Data.totalUnits = config.Data.unitsPerJob * NJOBS
#config.Data.outLFNDirBase = '/store/user/hcrottel/'
config.Data.publication = False

config.Site.storageSite = 'T3_CH_CERNBOX'