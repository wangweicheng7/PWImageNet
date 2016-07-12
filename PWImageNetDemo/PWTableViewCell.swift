//
//  PWTableViewCell.swift
//  PWImageNetDemo
//
//  Created by 王炜程 on 16/7/12.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit

class PWTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var loadProgressView: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
