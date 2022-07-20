//
//  MyTableViewCell.swift
//  MovieCWS
//
//  Created by 미미밍 on 2022/05/25.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userRating: UILabel!
    @IBOutlet weak var mainFilter: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var movieDate: UILabel!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var audiAccumulate: UILabel!
    @IBOutlet weak var posterImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
