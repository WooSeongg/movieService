//
//  MyTableViewCell.swift
//  MovieCWS
//
//  Created by 미미밍 on 2022/05/25.
//

import UIKit

class MyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainFilter: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var rank: UILabel!
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

        //순위View radius 적용
        rank.clipsToBounds = true
        rank.layer.cornerRadius = 15
        //배경 이미지 상단 좌,우 radius 적용
        mainImg.layer.cornerRadius = 18
        mainImg.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        //배경 이미지 필터 상단 좌,우 radius 적용
        mainFilter.layer.cornerRadius = 18
        mainFilter.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        //하단 View 하단 좌,우 radius 적용
        bottomView.layer.cornerRadius = 18
        bottomView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
        //하단 View border 적용
        bottomView.layer.borderColor = UIColor.gray.cgColor
        bottomView.layer.borderWidth = 0.5
        
        //테이블뷰 셀 inset 적용
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 15, right: 10))

    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
