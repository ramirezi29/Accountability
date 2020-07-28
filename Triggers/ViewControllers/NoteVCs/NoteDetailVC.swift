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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textBodyView.delegate = self
        textBodyView.backgroundColor = ColorPallet.offWhite.value
        
        //notification listening
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //Hide
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateViews()
        
        if let note = note {
            title = note.title
        } else {
            title = "Note"
        }
        
        self.view.addVerticalGradientLayer()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NoteDetailVC.hideKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func updateViews() {
        guard let note = note else {return}
        titelTextField.text = note.title
        textBodyView.text = note.textBody
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let noteTitle = titelTextField.text, let textBody = textBodyView.text, !textBody.isEmpty else { return }
        
        if let note = note {
            NoteController.shared.updateNote(note: note, title: noteTitle, textBody: textBody) { (success) in
                if success {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    let errorUpdatingNote = AlertController.presentAlertControllerWith(alertTitle: "Error Updating Note", alertMessage: "Check your internet connection and ensure you are signed into you iCloud account", dismissActionTitle: "OK")
                    DispatchQueue.main.async {
                        self.present(errorUpdatingNote, animated: true, completion: nil)
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
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        let saveErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Note", alertMessage: "Check Your Internet Connection and ensure that you are signed into your iCloud account", dismissActionTitle: "OK")
                        DispatchQueue.main.async {
                            self.present(saveErrorNotif, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension NoteDetailVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.backgroundColor = ColorPallet.offGrey.value
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.backgroundColor = ColorPallet.offWhite.value
    }
    
    //Able to send those notifications
    @objc func updateTextView(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyBoardEndFrameCoords = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyBoardEndFrame = self.view.convert(keyBoardEndFrameCoords, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textBodyView.contentInset = UIEdgeInsets.zero
        } else {
            textBodyView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardEndFrame.height, right: 0)
            textBodyView.scrollIndicatorInsets = textBodyView.contentInset
        }
        textBodyView.scrollRangeToVisible(textBodyView.selectedRange)
    }
}
