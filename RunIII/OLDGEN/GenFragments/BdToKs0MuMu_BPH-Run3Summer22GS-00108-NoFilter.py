#Pythia fragment for filtered B0 -> mu+mu-Kshort(pi+pi-) at 13.6TeV
#author: georgios.melachroinos@cern.ch
#taken from https://cms-pdmv.cern.ch/mcm/requests?prepid=BPH-Run3Summer22EEGS-00102&page=0&shown=262271 
#and from https://cms-pdmv.cern.ch/mcm/requests?prepid=BPH-Run3Summer22GS-00108&page=0&shown=262271

import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.MCTunesRun3ECM13p6TeV.PythiaCP5Settings_cfi import *
from GeneratorInterface.EvtGenInterface.EvtGenSetting_cff import *

_generator = cms.EDFilter("Pythia8GeneratorFilter",
    pythiaPylistVerbosity = cms.untracked.int32(0),
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    maxEventsToPrint = cms.untracked.int32(0),
    comEnergy = cms.double(13600.0),
    ExternalDecays = cms.PSet(
        EvtGen130 = cms.untracked.PSet(
            decay_table = cms.string('GeneratorInterface/EvtGenInterface/data/DECAY_2014_NOLONGLIFE.DEC'),
            particle_property_file = cms.FileInPath('GeneratorInterface/EvtGenInterface/data/evt_2014.pdl'),
            list_forced_decays = cms.vstring('MyB0','Myanti-B0'),
            operates_on_particles = cms.vint32(511,-511),    # we care just about our signal particles
            convertPythiaCodes = cms.untracked.bool(False),
            user_decay_embedded= cms.vstring(
"""
Alias      MyB0   B0
Alias      Myanti-B0   anti-B0
ChargeConj Myanti-B0   MyB0
Alias      MyK_S0      K_S0
ChargeConj MyK_S0      MyK_S0
#
Decay MyB0
1.000  MyK_S0      mu+     mu-    PHOTOS BTOSLLBALL 6;
Enddecay
CDecay Myanti-B0
#
Decay MyK_S0
  1.000        pi+        pi-  PHSP;
Enddecay
#
End
"""
            ),
        ),
        parameterSets = cms.vstring('EvtGen130')
    ),
    PythiaParameters = cms.PSet(
        pythia8CommonSettingsBlock,
        pythia8CP5SettingsBlock,
        processParameters = cms.vstring('SoftQCD:nonDiffractive = on',
                                        'PTFilter:filter = on',
                                                                'PTFilter:quarkToFilter = 5',
                                                                'PTFilter:scaleToFilter = 1.0'
            ),
        parameterSets = cms.vstring('pythia8CommonSettings',
                                    'pythia8CP5Settings',
                                    'processParameters',
                                    )
    )
)

from GeneratorInterface.Core.ExternalGeneratorFilter import ExternalGeneratorFilter
generator = ExternalGeneratorFilter(_generator)
generator.PythiaParameters.processParameters.extend(EvtGenExtraParticles)

###### Filters ##########
decayfilter = cms.EDFilter(
    "PythiaDauVFilter",
    verbose         = cms.untracked.int32(1),
    NumberDaughters = cms.untracked.int32(3),
    ParticleID      = cms.untracked.int32(511),  
    DaughterIDs     = cms.untracked.vint32(310, 13, -13), 
    MinPt           = cms.untracked.vdouble(-1, -1, -1),
    MinEta          = cms.untracked.vdouble(-9999, -9999, -9999),
    MaxEta          = cms.untracked.vdouble(9999, 9999, 9999)
)



mufilter = cms.EDFilter("MCMultiParticleFilter",
            src = cms.untracked.InputTag("generator", "unsmeared"),
            Status = cms.vint32(1),
            ParticleID = cms.vint32(13),
            PtMin = cms.vdouble(3.5),
            NumRequired = cms.int32(1),
            MotherID = cms.untracked.vint32(511),
            EtaMax = cms.vdouble(2.5),
            AcceptMore = cms.bool(True)
            )

kshortfilter = cms.EDFilter(
    "PythiaDauVFilter",
    verbose         = cms.untracked.int32(1),
    NumberDaughters = cms.untracked.int32(2),
    MotherID        = cms.untracked.int32(511),
    ParticleID      = cms.untracked.int32(310), 
    DaughterIDs     = cms.untracked.vint32(211, -211),
    MinPt           = cms.untracked.vdouble(-1.0, -1.0),
    MinEta          = cms.untracked.vdouble(-9999, -9999),
    MaxEta          = cms.untracked.vdouble( 9999, 9999)
    )

ProductionFilterSequence = cms.Sequence(generator*decayfilter*mufilter*kshortfilter)