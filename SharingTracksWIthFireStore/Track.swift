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

struct FirebaseURL {
    static let topLevel = Firestore.firestore().collection("tracks")
}

struct Track {
    var trackNum: Int
    var channel: UInt8 = 0
    var events: [MIDIEvent]
    var trackID: String {
        return "id-\(trackNum)"
    }
    
    init(trackNum: Int, track: AKMusicTrack) {
        self.trackNum = trackNum
        
        let data = track.getMIDINoteData()
        self.events = data.map { MIDIEvent(data: $0)}
        if !data.isEmpty {
            channel = data[0].channel
        }
    }
    
    init(trackNum: Int, channel: UInt8
        , events: [MIDIEvent]
        ) {
        self.trackNum = trackNum
        self.channel = channel
        self.events = events
    }
    
    var dictionary: [String: Any] {
        return [
            "trackNum": trackNum,
            "channel": channel,
//            "events": events
        ]
    }
    
//    init?(dictionary: [String : Any]) {
//        guard let trackNum = dictionary["trackNum"] as? Int,
//            let channel = dictionary["channel"] as? UInt8
////            let events = dictionary["events"] as? [MIDIEvent]
//            else { return nil }
//
//        self.init(trackNum: trackNum,
//                  channel: channel
////                  events: events
//        )
//    }
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
    
    var dictionary: [String: Any] {
        return [
            "noteNumber": self.noteNumber,
            "velocity": self.velocity,
            "channel": self.channel,
            "position": self.position,
            "duration": self.duration
        ]
    }
}

extension CustomSequencer {
    func postTracks() {
        let collection = FirebaseURL.topLevel
        for (i, track) in seq.tracks.enumerated() {
            let fbTrack = Track(trackNum: i, track: track)
            let doc = collection.document(fbTrack.trackID)
            doc.setData(fbTrack.dictionary)
            let events = doc.collection("events")
            for event in fbTrack.events {
                events.addDocument(data: event.dictionary)
            }
         
        }
    }
}

