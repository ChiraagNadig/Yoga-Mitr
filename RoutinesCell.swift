//
//  RoutinesCell.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 3/11/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import UIKit

class RoutinesCell: UITableViewCell {
    
    @IBOutlet var routineLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var orderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = UIColor(red: 251/255.0, green: 230/255.0, blue: 194/255.0, alpha: 1.0)
        
        orderLabel.layer.cornerRadius = (orderLabel.frame.width) / 2
        orderLabel.layer.masksToBounds = true
        orderLabel.layer.borderColor = UIColor.black.cgColor
        orderLabel.layer.borderWidth = 1.6
        
        
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        // Toggles the edit button state
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        
        if self.isEditing {
            playButton.isHidden = true
        }
        else {
            playButton.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
