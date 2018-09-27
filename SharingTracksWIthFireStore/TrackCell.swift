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
    var cellState: TrackCellState = .off {
        didSet {
            switch cellState {
            case .off:
                backgroundColor = .black
                layer.borderColor = UIColor.black.cgColor
            case .currentlyPlaying:
                backgroundColor = .red
            case .onDeck:
                layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    
    fileprivate func setup() {
        layer.cornerRadius = 10.0
        clipsToBounds = true
        layer.borderWidth = 3.0
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
