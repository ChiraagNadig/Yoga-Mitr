//
//  ExercisesCell.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 3/16/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import UIKit

class ExercisesCell: UITableViewCell {
    
    @IBOutlet var exerciseLabel: UILabel!
    @IBOutlet var exerciseTimeLabel: UILabel!
    @IBOutlet var exerciseNumberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        exerciseNumberLabel.layer.cornerRadius = (exerciseNumberLabel.frame.width) / 2
        exerciseNumberLabel.layer.masksToBounds = true
        exerciseNumberLabel.layer.borderColor = UIColor.black.cgColor
        exerciseNumberLabel.layer.borderWidth = 1.6
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
