//
//  Track.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-22.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit

struct Track {
    var trackNum: Int
    var events: [MIDIEvent]
    
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
