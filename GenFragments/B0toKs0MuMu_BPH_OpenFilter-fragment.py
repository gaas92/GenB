# Script taken from https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/BPH-RunIIFall18GS-00226/0
# Found 26 output events for 12000 input events.
# Filter efficiency = 0.002167
# Timing = 0.401640 sec/event
# Event size = 703.7 kB/event
import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
from GeneratorInterface.EvtGenInterface.EvtGenSetting_cff import *

generator = cms.EDFilter("Pythia8GeneratorFilter",
                         comEnergy = cms.double(13000.0),
                         crossSection = cms.untracked.double(54000000000),
                         filterEfficiency = cms.untracked.double(3.0e-4),
                         pythiaHepMCVerbosity = cms.untracked.bool(False),
                         maxEventsToPrint = cms.untracked.int32(0),
                         pythiaPylistVerbosity = cms.untracked.int32(0),
                         ExternalDecays = cms.PSet(
        EvtGen130 = cms.untracked.PSet(
            decay_table = cms.string('GeneratorInterface/EvtGenInterface/data/DECAY_2014_NOLONGLIFE.DEC'),
            particle_property_file = cms.FileInPath('GeneratorInterface/EvtGenInterface/data/evt_2014.pdl'),
            user_decay_embedded= cms.vstring(
'#',
'# Particles updated from PDG2018 https://journals.aps.org/prd/abstract/10.1103/PhysRevD.98.030001',
'Particle   K_S0        4.9761100e-01   0.0000000e+00',
'Particle   J/psi       3.0969000e+00   9.2900006e-05',
'Particle   B0          5.2796300e+00   0.0000000e+00',
'Particle   anti-B0     5.2796300e+00   0.0000000e+00',
'#',
'Alias      MyB0        B0',
'Alias      Myanti-B0   anti-B0',
'ChargeConj Myanti-B0   MyB0',
'#',
'Decay MyB0',
'1.000    K_S0  mu+ mu-  PHOTOS  PHSP;',
'Enddecay',
'CDecay Myanti-B0',
'End'
), 
            list_forced_decays = cms.vstring('MyB0','Myanti-B0'),
            operates_on_particles = cms.vint32(),
            convertPythiaCodes = cms.untracked.bool(False)
            ),
        parameterSets = cms.vstring('EvtGen130')
        ),
        PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        processParameters = cms.vstring(
            "SoftQCD:nonDiffractive = on",
            "511:m0=5.279630",     ## changing also B0 mass in pythia
            'PTFilter:filter = on', # this turn on the filter
            'PTFilter:quarkToFilter = 5', # PDG id of q quark
            'PTFilter:scaleToFilter = 1.0'),
        parameterSets = cms.vstring(
            'pythia8CommonSettings',
            'pythia8CP5Settings',
            'processParameters',
        )
    )
)
###########
# Filters #
###########

bdfilter = cms.EDFilter("PythiaFilter", ParticleID = cms.untracked.int32(511))


decayfilter = cms.EDFilter("PythiaDauVFilter", ## signal filter
        verbose         = cms.untracked.int32(0),
        ParticleID      = cms.untracked.int32(511), 
        NumberDaughters = cms.untracked.int32(3),
        DaughterIDs     = cms.untracked.vint32(310, -13, 13),
        MinPt           = cms.untracked.vdouble(0.0, 0.0, 0.0),
        MaxEta          = cms.untracked.vdouble(999.9, 999.9, 999.9),
        MinEta          = cms.untracked.vdouble(-999.9, -999.9, -999.9), 
)
# 

probefilter = cms.EDFilter("PythiaProbeFilter", ## probe filter, use either this or mutagfilter
    verbose         = cms.untracked.int32(1),   ## requires muon with pt>munpt to be not from decay
    NumberOfSisters = cms.untracked.int32(2),
    ParticleID      = cms.untracked.int32(13),
    MomID           = cms.untracked.int32(511), #B0
    SisterIDs       = cms.untracked.vint32(310,-13), #Lambda0 and mu
    MinPt           = cms.untracked.double(0.0), # third Mu with Pt > 4
    MinEta          = cms.untracked.double(-999.9),
    MaxEta          = cms.untracked.double(999.9)
)
# 
 

ProductionFilterSequence = cms.Sequence(generator*bdfilter*decayfilter*probefilter)     

#ProductionFilterSequence = cms.Sequence(generator*bdfilter)     
# 
#ProductionFilterSequence = cms.Sequence(generator*bdfilter*decayfilter)     

# ProductionFilterSequence = cms.Sequence(generator*bdfilter*probefilter)  