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
    var customSeq: CustomSequencer!
    override func viewDidLoad() {
        super.viewDidLoad()
        customSeq = CustomSequencer()
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
