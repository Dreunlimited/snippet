//
//  ArticleTableViewCell.swift
//  snippet
//
//  Created by Dandre Ealy on 3/16/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var photo: UIImageView!
  
    @IBOutlet weak var activity: UIActivityIndicatorView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
