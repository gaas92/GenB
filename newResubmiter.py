#!/usr/bin/env python
import csv
import os
import subprocess
import tempfile

class jobState:
    def __init__(self, job, state):
       self.job = job
       self.state = str(state)
       self.jobsList = []
       self.suportD  = {}
    def addJob(self, tuple_):
      #print tuple_
      job          = tuple_[0]
      state        = tuple_[1]
      mRecentState = tuple_[2]
      runTime      = tuple_[3]
      mem          = tuple_[4]
      cpu          = tuple_[5]
      retries      = tuple_[6]
      restarts     = tuple_[7]
      waste        = tuple_[8]
      exitCode     = tuple_[9]
      self.jobsList.append([job, state, mRecentState, runTime, mem, cpu, retries, restarts, waste, exitCode])
    def getState(self):
      return str(self.state)
    def getInfo(self):
      failStr = ''
      print "Job = ", str(self.job).replace('crab_', '')
      for tuple_ in self.jobsList:
          if (not str(tuple_[1]) in self.suportD.keys()) and (not 'the' in tuple_):
             self.suportD[tuple_[1]] = []
          if str(tuple_[1]) in self.suportD.keys():
             self.suportD[tuple_[1]].append(tuple_[0])
      totalJobs = 0
      for k in self.suportD.keys():
          totalJobs+= len(self.suportD[k])
      for k in self.suportD.keys():
         percent = (float(len(self.suportD[k]))*100)/totalJobs
         print len(self.suportD[k]), " jobs ", k, '('+str(len(self.suportD[k]))+'/'+str(totalJobs)+')', str("%.2f" % percent)+' %'
         #if k == 'failed':  
         #   failStr = ','.join(map(str, self.suportD[k]))
         #   print "crab resubmit -d ", str(self.job), ' --jobid', failStr
    def getJobStats(self):
        statsD = {}
        for k in self.suportD.keys():
            statsD[k]= len(self.suportD[k])
        return statsD
    def resubmit(self): 
      if 'failed' in self.suportD.keys():
         failStr = ','.join(map(str, self.suportD['failed']))
         print "X----------------------------------------------------------X"
         print "Resubmitting ", str(self.job).replace('crab_', '')
         print "crab resubmit -d ", str(self.job), ' --jobid', failStr   
         os.system("crab resubmit -d "+str(self.job)+' --jobid '+failStr)   
         print "X----------------------------------------------------------X" 
print " "
print "ola ke ase?, re-submitiendo jobs fallidos a CRAB o ke ase?"
path = raw_input("please input the crab proyect directory: ")
#path = '2016promtElec'
os.chdir(path)
if os.path.isdir('temp.txt'): os.remove('temp.txt')
dirs = sorted(os.listdir(os.curdir))
j=0
jobsDict = {}
stats = {}
readed = False
for folder in dirs:
   if '.' in folder: continue
   #print " "
   #print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   #print "Reading ", folder, " status, please wait a few seconds ... "
   #os.system("crab status -d"+str(folder)+' --long | grep "failed" > temp.txt')
   os.system("crab status -d"+str(folder)+' --long > temp.txt')
   jobs = []
   f = open('temp.txt', 'r')
   file_content = f.read()
   print "reading ...", folder
   #print file_content
   f.close
   j+=1
   isTheTable = False
   readed = False
   with open('temp.txt') as text_file:
       for thisLine in text_file:
          #print thisLine,
          if 'Status on the CRAB server:' in thisLine:
              if 'SUBMITTED' in thisLine: 
                 jobsDict[folder]=jobState(folder, 'SUBMITTED')
                 print folder, " SUBMITTED"
                 readed = True
              if 'UNSUBMITTED' in thisLine: 
                 jobsDict[folder]=jobState(folder, 'UNSUBMITTED')
                 print folder, "UNSUBMITTED"
                 readed = True
              if 'SUBMITFAILED' in thisLine:
                 jobsDict[folder]=jobState(folder, 'SUBMITFAILED')
                 print folder, "SUBMITFAILED"
                 readed = True
          if readed:
             if str(jobsDict[folder].getState()) == 'SUBMITFAILED':
                if 'Failure message from server:' in thisLine:
                   print thisLine,
                if 'https://twiki.cern.ch/' in thisLine:
                   print thisLine,
             
          if 'Extended Job Status Table:' in thisLine: isTheTable = True
          if isTheTable: 
            tuple_ = thisLine.split()
            if 'Job' in tuple_: continue
            try :
                if len(tuple_) > 9: jobsDict[folder].addJob(tuple_)
            except KeyError:
                print "unable to add ", folder, " with tuple: "
                print tuple_
                exit()
          if 'Log file is' in thisLine:  isTheTable = False
   #if j > 4: break
totalJ = 0
for job in jobsDict.keys():
   print "<-----------INFO------------->"
   jobsDict[job].getInfo()
   tempD = jobsDict[job].getJobStats()
   for state in tempD.keys():
      if not state in stats: stats[state] = 0
      if state in stats:
         stats[state]+= tempD[state]
         totalJ += tempD[state]
print "<-------------STATS--------------->"
for state in stats.keys():
   percent = float(stats[state]*100)/totalJ
   print stats[state], "total jobs ", state, '('+str(stats[state])+'/'+str(totalJ)+')', str("%.2f" % percent)+' %'
print "<<<<<<<<<<<<<<<<<<<<<<<RESUBMITI>>>>>>>>>>>>>>>>>>>>>>>"
for job in jobsDict.keys():
    jobsDict[job].resubmit()
exit()
'''   
         if len(row)<50: continue        
         for j in range(len(row)):
           try:
             jobID = int(row[j]) 
             if jobID > 0:   
                jobs.append(row[j])
                break
           except ValueError:
             None
   str_lst = ','.join(map(str,jobs))
   print "for ", folder, "jobs", str_lst, " failed. Total failures: ", len(jobs)
   os.remove("temp.txt")
   if len(jobs) >0:
      print "Resubmiting ", folder, " failed jobs, wait a few more ..."
      print "crab resubmit -d ", folder, ' --jobid', str_lst 
      #Comment this line to avoid resubmitting 
      #os.system("crab resubmit -d "+str(folder)+' --jobid '+str(str_lst))
   else:
      print "No jobs to resubmit in ", folder 
   #if j >= 1: break
'''
