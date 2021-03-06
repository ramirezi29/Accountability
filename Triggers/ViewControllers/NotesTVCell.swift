//
//  NotesTVCell.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class NotesTVCell: UITableViewCell {
    
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var note: Note? {
        didSet{
            udpateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func udpateViews() {
        guard let note = note else {return}
        noteTitleLabel.text = note.title
        timeStampLabel.text = "\(note.timeStamp)"
        noteTitleLabel.textColor = ColorPallet.offWhite.value
        timeStampLabel.textColor = ColorPallet.offWhite.value
    }
}
