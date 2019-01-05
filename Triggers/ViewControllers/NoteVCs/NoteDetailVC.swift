//
//  NoteEntryVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import AVFoundation
import CloudKit

class NoteDetailVC: UIViewController {
    
    
    @IBOutlet weak var savebutton: UIBarButtonItem!
    @IBOutlet weak var textBodyView: UITextView!
    @IBOutlet weak var titelTextField: UITextField!
    
    //Landing Pad
    var note: Note?
    var folder: Folder?
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         self.tabBarController?.tabBar.isHidden = true 
        
        updateViews()
        
        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NoteDetailVC.hideKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        //Text View
        textBodyView.delegate = self
    }
    
    func updateViews() {
        
        if let note = note {
            titelTextField.text = note.title
            textBodyView.text = note.textBody
            
        } else {
            
            //Placeholder
            placeholderLabel = UILabel()
            placeholderLabel.text = "Whats on your mind...."
            placeholderLabel.font = UIFont.italicSystemFont(ofSize: (textBodyView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            textBodyView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (textBodyView.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor.black
            placeholderLabel.isHidden = !textBodyView.text.isEmpty
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Test Print
        print("/n/n⛲️Save Button Tapped")
        
        guard let noteTitle = titelTextField.text, let textBody = textBodyView.text, !textBody.isEmpty else { return }
        
        if let note = note {
            
            NoteController.shared.updateNote(note: note, title: noteTitle, textBody: textBody) { (success) in
                if success {
                    //Test print
                    print("🙏🏽 Successfully updated Note")
                    DispatchQueue.main.async {
                        
                        //ANY UI STUFF
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    DispatchQueue.main.async {
                        //UI ALERT WITH ERRROR
                        print("\n💀 Error updating NOte to CK\n")
                    }
                    return
                }
            }
        } else {
            if let folder = folder {
                //Test print
                print("\nWhen the Save Note Func was called this is the folder tha that got called:\(folder.folderTitle), \(folder.ckRecordID)\n")
                NoteController.shared.createNewNoteWith(title: noteTitle, textBody: textBody, folder: folder) { (success) in
                    if success {
                        print("\nSuccesfully created/saved note to CK and to a Folder\n")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("/n💀 Error Saving Note to CK and Folder /n")
                        DispatchQueue.main.async {
                            let saveErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Note", alertMessage: "Check Your Internet Connection", dismissActionTitle: "OK")
                            
                            self.present(saveErrorNotif, animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print("\n😭 THere is no Folder for the Note\n")
            }
        }
    }
}

extension NoteDetailVC: UITextViewDelegate, UITextFieldDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

