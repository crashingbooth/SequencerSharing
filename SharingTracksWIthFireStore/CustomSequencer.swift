//
//  CustomSequencer.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-22.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit

class CustomSequencer {
    var seq: AKSequencer!
    var callbackInst: AKCallbackInstrument!
    var adminTrack: AKMusicTrack!
    var adminCallbackInst: AKCallbackInstrument!
    var midiTracks: [AKMusicTrack]!
    var oscBank: AKOscillatorBank!
    var mixer: AKMixer!
    let numTracks = 5
    let seqLength: MusicTimeStamp = 4.0
    weak var sequencerManagerDelegate: SequencerManagerDelegate?
    
    // MARK: - Set UP
    init() {
        setUpSequencer()
        setUpSound()
    }
    
    fileprivate func setUpSequencer() {
        seq = AKSequencer()
        setUpAdminTrack()
        midiTracks = [AKMusicTrack]()
        callbackInst = AKCallbackInstrument()
        callbackInst.callback = callback
        for _ in 0 ..< numTracks {
            let track = seq.newTrack()!
            track.setMIDIOutput(callbackInst.midiIn)
            midiTracks.append(track)
        }
        seq.enableLooping(AKDuration(beats: seqLength))
    }
    
    fileprivate func setUpAdminTrack() {
        adminTrack = seq.newTrack()!
        adminCallbackInst = AKCallbackInstrument()
        adminTrack.setMIDIOutput(adminCallbackInst.midiIn)
        adminTrack.add(noteNumber: 60,
                       velocity: 60,
                       position: AKDuration(beats: seqLength - 0.1),
                       duration: AKDuration(beats: 0.1))
        adminCallbackInst.callback = { status, note, vel in
            guard status == .noteOn else { return }
            guard let delegate = self.sequencerManagerDelegate else { return }
            if delegate.isUpdateAvailable {
                for trackIndex in delegate.changes.keys {
                    guard let data = delegate.changes[trackIndex] else { continue }
                    self.replaceTrack(id: trackIndex, data: data)
                }
            }
        }
    }
    
    fileprivate func setUpSound() {
        mixer = AKMixer()
        AudioKit.output = mixer
        oscBank = AKOscillatorBank(waveform: AKTable(.square))
        oscBank >>> mixer
        do { try AudioKit.start()
        } catch {
            fatalError()
        }
    }
    
    func callback(_ status: AKMIDIStatus, _ note: MIDINoteNumber, _ vel: MIDIVelocity) {
        if status == .noteOn {
            oscBank.play(noteNumber: note, velocity: vel)
            print(note)
        }  else if status == .noteOff {
            oscBank.stop(noteNumber: note)
        }
    }
    
    // MARK: - Interface
    var isPlaying: Bool {
        return seq.isPlaying
    }
    
    func play() {
        seq.play()
    }
    
    func stop() {
        seq.stop()
    }
    
    func clear() {
        seq.stop()
        setUpSequencer()
    }
    
    func loadFromURL(_ url: URL) {
        seq.loadMIDIFile(fromURL: url)
    }
    
    func replaceTrack(id: Int, data: [AKMIDINoteData]) {
        midiTracks[id].replaceMIDINoteData(with: data)
    }
}


extension AKMusicTrack {
    func transpose(steps: Int) {
        let data = getMIDINoteData()
        let transposedData: [AKMIDINoteData] = data.map {
            let newPitch = UInt8(Int($0.noteNumber) + steps)
            guard (0 ..< 128) ~= newPitch else { return $0 }
            var note = $0
            note.noteNumber = newPitch
            return note }
        replaceMIDINoteData(with: transposedData)
    }
}

class ExampleSeq {
    var sequencer: AKSequencer!
    var midiSampler: AKMIDISampler!
    var sampler: AKAppleSampler!
    var midiNode: AKMIDINode!
    var callbackInstr: AKCallbackInstrument!
    
    // MARK: - Vanilla Sequencer
    func vanillaSequencer() {
        midiSampler = AKMIDISampler()
        
        let track = sequencer.newTrack()
        track?.setMIDIOutput(midiNode.midiIn)
    }
    
    // MARK: - Callback Sequencer
    func callbackSequencer()  {
        sampler = AKAppleSampler()
        callbackInstr = AKCallbackInstrument()
        
        let track = sequencer.newTrack()
        track?.setMIDIOutput(callbackInstr.midiIn)
        
        callbackInstr.callback = { status, noteNumber, velocity in
            
            if status == .noteOn {
                try? self.sampler.play(noteNumber: noteNumber, velocity: velocity)
            } else if status == .noteOff {
                try? self.sampler.stop(noteNumber: noteNumber)
            }
        }
    }
    
    
    func debugCallback(_ status: AKMIDIStatus,
                       _ noteNumber: MIDINoteNumber,
                       _ velocity: MIDIVelocity) {
        // add a breakpoint here:
        print("status: \(status), noteNUmber: \(noteNumber), velocity: \(velocity)")
        
        if status == .noteOn {
            try? self.sampler.play(noteNumber: noteNumber, velocity: velocity)
        } else if status == .noteOff {
            try? self.sampler.stop(noteNumber: noteNumber)
        }
    }
    
    
    
    // Crap
    enum MIDIDestination {
        case sampler, externalMIDI, audiobusMIDI
    }
    var midiDestination: MIDIDestination
    var midi: AKMIDI!
    var audiobusMIDI: AKMIDI
    fileprivate func handleMIDINOteOff(_ noteNumber: MIDINoteNumber) {
        
    }
    
    
    // Extend callback with external MIDI
    func extendMIDICallback(_ status: AKMIDIStatus,
                            _ noteNumber: MIDINoteNumber,
                            _ velocity: MIDIVelocity) {
        
        if status == .noteOn {
            handleMIDINoteOn(noteNumber, velocity)
        } else if status == .noteOff {
            handleMIDINOteOff(noteNumber)
        }
    }
    
    fileprivate func handleMIDINoteOn(_ noteNumber: MIDINoteNumber,
                                      _ velocity: MIDIVelocity) {
        switch midiDestination {
        case .sampler:
            try? self.sampler.play(noteNumber: noteNumber, velocity: velocity)
        case .externalMIDI:
            midi.sendNoteOnMessage(noteNumber: noteNumber, velocity: velocity)
        case .audiobusMIDI:
            audiobusMIDI.sendNoteOnMessage(noteNumber: noteNumber, velocity: velocity)
        }
    }
    
    // Crap
    func sendToUI(_ noteNumber: MIDINoteNumber, _ status: AKMIDIStatus) {
        
    }
    
    // MARK: Signalling the UI
    func callbackForMIDIAndUI(_ status: AKMIDIStatus,
                            _ noteNumber: MIDINoteNumber,
                            _ velocity: MIDIVelocity) {
        
        if status == .noteOn {
            handleMIDINoteOn(noteNumber, velocity)
        } else if status == .noteOff {
            handleMIDINOteOff(noteNumber)
        }
        
        DispatchQueue.main.async {
            self.sendToUI(noteNumber, status)
        }
    }
    
    var isSustainButtonPressed = false
    var shouldTranspose = true
    
    // MARK: Sustain
    func callbackForSustainButton(_ status: AKMIDIStatus,
                                  _ noteNumber: MIDINoteNumber,
                                  _ velocity: MIDIVelocity) {
        
        if status == .noteOn {
            handleMIDINoteOn(noteNumber, velocity)
        } else if status == .noteOff && isSustainButtonPressed {
            handleMIDINOteOff(noteNumber)
        }
    }
    
    // MARK: Realtime Transpose
    func callbackWithTransposition(_ status: AKMIDIStatus,
                                  _ noteNumber: MIDINoteNumber,
                                  _ velocity: MIDIVelocity) {
        let newNote = shouldTranspose ? noteNumber + 2 : noteNumber
        if status == .noteOn {
            handleMIDINoteOn(newNote, velocity)
        } else if status == .noteOff {
            handleMIDINOteOff(newNote)
        }
    }
    
    func flashNoteViewInUI(isOn: Bool, track: UInt8, index: UInt8) {
        
    }
    var allTrackData: [[AKMIDINoteData]]!
    var midiCallbackInstrument: AKCallbackInstrument!
    var uiCallbackInstrument: AKCallbackInstrument!
    // MARK: - Complex UI
    func callbackWithComplexUIUpdates(_ status: AKMIDIStatus,
                                   _ trackNumber: UInt8,
                                   _ noteIndex: UInt8) {

        self.flashNoteViewInUI(isOn: status == .noteOn,
                               track: trackNumber,
                               index: noteIndex)
    }
    
    func writeMIDIAndUIInstructions() {
        let midiTrack = sequencer.newTrack()!
        midiTrack.setMIDIOutput(midiCallbackInstrument.midiIn)
        midiCallbackInstrument.callback = extendMIDICallback
        
        let uiTrack = sequencer.newTrack()!
        uiTrack.setMIDIOutput(uiCallbackInstrument.midiIn)
        uiCallbackInstrument.callback = callbackWithComplexUIUpdates
        
        
        for (i, trackData) in allTrackData.enumerated() {
            for (j, note) in trackData.enumerated() {
                midiTrack.add(noteNumber: note.noteNumber,
                              velocity: note.velocity,
                              position: note.position,
                              duration: note.duration)
                
                uiTrack.add(noteNumber: UInt8(i), // interpretted as 'trackNumber'
                            velocity: UInt8(j), // interpressted as 'noteIndex'
                            position: note.position,
                            duration: note.duration)
            }
        }
    }
    
    // MARK: - Admin Track
    enum CustomMIDIEvent: MIDINoteNumber {
        case checkForUpdates, newBar, metronomeTick, sequencerLooped
    }
    
    func adminCallback(_ status: AKMIDIStatus,
                       _ noteNumber: UInt8,
                       _ velocity: UInt8) {
        
        guard let event = CustomMIDIEvent(rawValue: noteNumber),
            status == .noteOn else { return }
        
        switch event {
        case .checkForUpdates:
            // run code checking for updates
        case .newBar:
            // run code at each new bar
        case .metronomeTick:
            // etc.
        case .sequencerLooped:
            // etc.
        }
    }
    
    
    
    
    
    
}
