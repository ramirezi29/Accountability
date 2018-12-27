//
//  LocationTVCell.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/21/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class LocationTVCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var location: Location? {
        didSet {
            updateViews()
        }
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func updateViews() {
        
        guard let location = location else {return}
        locationTitleLabel.text = location.locationTitle
        locationImageView.image = UIImage(named: "noun_map pin_626096")
    }

}