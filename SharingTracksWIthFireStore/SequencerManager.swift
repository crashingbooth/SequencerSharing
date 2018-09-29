//
//  SequencerManager.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-25.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
import AudioKit

class SequencerManager: NSObject {
    let numTracks = 4
    var tracks: [TrackDetails]
    var isUpdateAvailable: Bool {
        let needsUpdateTracks = tracks.filter { $0.nextUp != nil }
        return needsUpdateTracks.isNotEmpty
    }
    
    var changes: [Int: [AKMIDINoteData]] {
        var trackDict = [Int: [AKMIDINoteData]]()
        for track in tracks {
            if let _ = track.nextUp,
                let nextData = track.nextTrackData{
                trackDict[track.sequencerIndex] = nextData
            }
        }
        return trackDict
    }
    
    override init() {
        tracks = (0 ..< numTracks).map { _ in TrackDetails() }
    }
    
    
}

protocol SequencerManagerDelegate: class {
    var isUpdateAvailable: Bool { get }
    var changes: [Int: [AKMIDINoteData]] { get }
    
}

class TrackDetails {
    var currentlyPlaying: Int?
    var nextUp: Int?
    var numPossibleEvents = 4
    var firebaseAddress: String = ""
    var sequencerIndex: Int = 0
    var nextTrackData: [AKMIDINoteData]?
    
    func update() {
        guard let next = nextUp else { return }
        currentlyPlaying = next
        nextUp = nil
        nextTrackData = nil
    }
    
    func trackWillChange(newData: [AKMIDINoteData], newSelection: Int) {
        nextTrackData = newData
        nextUp = newSelection
    }
    
}


