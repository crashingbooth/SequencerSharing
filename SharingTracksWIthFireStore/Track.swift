//
//  Track.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-22.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit
import Firebase



struct Track {
    var trackNum: Int
    var channel: UInt8 = 0
    var events: [MIDIEvent]
    
    init(trackNum: Int, track: AKMusicTrack) {
        self.trackNum = trackNum
        
        let data = track.getMIDINoteData()
        self.events = data.map { MIDIEvent(data: $0)}
        if !data.isEmpty {
            channel = data[0].channel
        }
    }
    
}

struct MIDIEvent {
    var noteNumber: MIDINoteNumber
    var velocity: MIDIVelocity
    var channel: MIDIChannel
    var position: Double
    var duration: Double
    
    init(data: AKMIDINoteData){
        self.noteNumber = data.noteNumber
        self.velocity = data.velocity
        self.channel = data.channel
        self.position = data.position.beats
        self.duration = data.position.beats
    }
}

extension CustomSequencer {
    func postTracks() {
        let collection = Firestore.firestore().collection("tracks")
        
    }
}

