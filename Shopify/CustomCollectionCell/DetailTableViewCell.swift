//
//  DetailTableViewCell.swift
//  Shopify
//
//  Created by John Peng on 2019-01-07.
//  Copyright © 2019 John Peng. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var productImg: UIImageView!
    
    @IBOutlet weak var overlay: UIView!
    
    @IBOutlet weak var vendor: UILabel!
    
    @IBOutlet weak var bodyHTML: UILabel!
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setView() {
        backgroundColor = .clear
        
        self.baseView.layer.borderWidth = 1
        self.baseView.layer.cornerRadius = 12
        self.baseView.layer.borderColor = UIColor.clear.cgColor
        self.baseView.layer.masksToBounds = true
        
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 6
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
    }

}
