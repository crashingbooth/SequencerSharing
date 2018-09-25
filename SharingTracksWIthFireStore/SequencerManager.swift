//
//  SequencerManager.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-25.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import Foundation
class SequencerManager: NSObject {
    let numTracks = 4
    var tracks: [TrackDetails]
    
    override init() {
        tracks = (0 ..< numTracks).map { _ in TrackDetails() }
    }
}

struct TrackDetails {
    var currentlyPlaying: Int?
    var nextUp: Int?
    var numPossibleEvents = 4
}
