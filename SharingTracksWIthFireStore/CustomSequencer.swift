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
    var tracks: [AKMusicTrack]!
    var oscBank: AKOscillatorBank!
    var mixer: AKMixer!
    let numTracks = 5
    
    init() {
        setUpSequencer()
        setUpSound()
        
    }
    
    fileprivate func setUpSequencer() {
        seq = AKSequencer()
        tracks = [AKMusicTrack]()
        callbackInst = AKCallbackInstrument()
        callbackInst.callback = callback
        for _ in 0 ..< numTracks {
            let track = seq.newTrack()!
            track.setMIDIOutput(callbackInst.midiIn)
            tracks.append(track)
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
