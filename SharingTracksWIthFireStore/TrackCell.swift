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
    
    fileprivate func setup() {
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
