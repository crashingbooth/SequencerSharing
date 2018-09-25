//
//  TrackCell.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-25.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import UIKit


enum TrackCellState {
    case off, currentlyPlaying, onDeck
}
class TrackCell: UICollectionViewCell {
    var cellState: TrackCellState = .off
}
