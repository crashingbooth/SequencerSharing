//
//  SharedSequencerVC.swift
//  SharingTracksWIthFireStore
//
//  Created by Jeff Holtzkener on 2018-09-23.
//  Copyright © 2018 crashingbooth. All rights reserved.
//

import UIKit
import Firebase

class SharedSequencerVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var customSeq: CustomSequencer!
    var seqManager: SequencerManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        customSeq = CustomSequencer()
        seqManager = SequencerManager()
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView.collectionViewLayout = layout
    }
    
    @IBAction func loadFile(_ sender: Any) {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.midi-audio"], in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func sendTracks(_ sender: Any) {
        customSeq.postTracks()
    }
    
    @IBAction func play(_ sender: Any) {
        customSeq.play()
    }
    
    @IBAction func stop(_ sender: Any) {
        customSeq.stop()
    }
    
    @IBAction func getTracks(_ sender: Any) {
        let colRef = FirebaseURL.topLevel.document("id-2").collection("events").getDocuments() {
            (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let arr = querySnapshot!.documents.compactMap { MIDIEvent(dictionary: $0.data())?.noteData }
                self.customSeq.clear()
                self.customSeq.seq.tracks[0].replaceMIDINoteData(with: arr)
            }
        }
    }
}


extension SharedSequencerVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        customSeq.loadFromURL(urls[0])
        navigationController?.popViewController(animated: true)
        
        
    }
}

extension SharedSequencerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seqManager.tracks[section].numPossibleEvents
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.trackCell, for: indexPath) as? TrackCell else { return UICollectionViewCell() }
        cell.backgroundColor = indexPath.section % 2 == 0 ? .red : .black
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return seqManager.numTracks
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

