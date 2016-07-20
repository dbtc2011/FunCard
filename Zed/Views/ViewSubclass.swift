//
//  ViewSubclass.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit


//MARK: - Point Header View
class PointHeaderView: UIView {
    
    //MARK: Properties
    let labelPoints: UILabel = UILabel()
    let labelLastUpdate: UILabel = UILabel()

    
    //MARK: Method
    func setupView() {
        
        let totalHeight = UIScreen.mainScreen().bounds.size.height * 0.23
        
        self.labelLastUpdate.frame = CGRectMake(0, totalHeight - 18, self.frame.size.width, 13)
        self.labelLastUpdate.font = UIFont.systemFontOfSize(10)
        self.labelLastUpdate.text = "Last Updated  February 11, 2016 | 12:14 PM"
        self.labelLastUpdate.textAlignment = NSTextAlignment.Center
        self.labelLastUpdate.textColor = UIColor.whiteColor()
        self.addSubview(self.labelLastUpdate)
        
        let pointWidth = self.frame.size.width * 0.6
        
        
        let imagePoints = UIImageView(frame: CGRectMake((self.frame.size.width / 2) - ((pointWidth + 50)/2), CGRectGetMinY(self.labelLastUpdate.frame) - 40, pointWidth, 35))
        imagePoints.image = UIImage(named: "bar")
        self.addSubview(imagePoints)
        
        self.labelPoints.frame = CGRectMake(CGRectGetMinX(imagePoints.frame) + (0.45 * imagePoints.frame.size.width), CGRectGetMinY(imagePoints.frame), imagePoints.frame.size.width * 0.55, 35)
        self.labelPoints.textColor = UIColor.blueColor()
        self.labelPoints.text = "0.0"
        self.labelPoints.textAlignment = NSTextAlignment.Center
        self.labelPoints.font = UIFont.boldSystemFontOfSize(18)
        self.addSubview(self.labelPoints)
        
        let buttonRefresh = UIButton(type: UIButtonType.Custom)
        buttonRefresh.frame = CGRectMake(CGRectGetMaxX(imagePoints.frame) + 10, CGRectGetMinY(imagePoints.frame), 35, 35)
        buttonRefresh.setImage(UIImage(named: "refresh"), forState: UIControlState.Normal)
        self.addSubview(buttonRefresh)
        
        let buttonLogOff = UIButton(type: UIButtonType.Custom)
        buttonLogOff.frame = CGRectMake(self.frame.size.width - 45, 10, 35, 35)
        buttonLogOff.setImage(UIImage(named: "logoff"), forState: UIControlState.Normal)
        self.addSubview(buttonLogOff)
        

        
    }
    
    
}
//MARK: - Card Info View
class CardInfoView: UIView {
    
    //MARK: Properties
    let labelCard1: UILabel = UILabel()
    let labelCard2: UILabel = UILabel()
    let labelCard3: UILabel = UILabel()
    
    let labelPointsEarned: UILabel = UILabel()
    let labelPointsRedeemed: UILabel = UILabel()
    let labelPasaPoints: UILabel = UILabel()
    let labelTransactionDate: UILabel = UILabel()
    
    //MARK: Method
    func setupView() {
        
        let viewBackground: UIView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        viewBackground.backgroundColor = UIColor.whiteColor()
        viewBackground.layer.cornerRadius = 8.0
        viewBackground.alpha = 0.1
        self.addSubview(viewBackground)
        
        let card1: UILabel = UILabel(frame: CGRectMake(10, 10, 80, 15))
        if UIScreen.mainScreen().bounds.size.height == 480 {
            card1.frame = CGRectMake(10, 5, 80, 15)
        }
        card1.text = "Card 1:"
        card1.textColor = UIColor.yellowColor()
        card1.font = UIFont.systemFontOfSize(13)
        card1.textAlignment = NSTextAlignment.Left
        self.addSubview(card1)
        
        self.labelCard1.frame = CGRectMake(CGRectGetMaxX(card1.frame) + 5, CGRectGetMinY(card1.frame), self.frame.size.width - 105, 15)
        self.labelCard1.textColor = UIColor.whiteColor()
        self.labelCard1.font = UIFont.systemFontOfSize(13)
        self.labelCard1.textAlignment = NSTextAlignment.Right
        self.labelCard1.text = "123456789"
        self.addSubview(self.labelCard1)
        
        let card2: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(card1.frame), 80, 15))
        card2.text = "Card 2:"
        card2.textColor = UIColor.yellowColor()
        card2.font = UIFont.systemFontOfSize(13)
        card2.textAlignment = NSTextAlignment.Left
        self.addSubview(card2)
        
        self.labelCard2.frame = CGRectMake(CGRectGetMaxX(card2.frame) + 5, CGRectGetMinY(card2.frame), self.frame.size.width - 105, 15)
        self.labelCard2.textColor = UIColor.whiteColor()
        self.labelCard2.font = UIFont.systemFontOfSize(13)
        self.labelCard2.textAlignment = NSTextAlignment.Right
        self.labelCard2.text = "123456789"
        self.addSubview(self.labelCard2)
        
        let card3: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(card2.frame), 80, 15))
        card3.text = "Card 2:"
        card3.textColor = UIColor.yellowColor()
        card3.font = UIFont.systemFontOfSize(13)
        card3.textAlignment = NSTextAlignment.Left
        self.addSubview(card3)
        
        self.labelCard3.frame = CGRectMake(CGRectGetMaxX(card3.frame) + 5, CGRectGetMinY(card3.frame), self.frame.size.width - 105, 15)
        self.labelCard3.textColor = UIColor.whiteColor()
        self.labelCard3.font = UIFont.systemFontOfSize(13)
        self.labelCard3.textAlignment = NSTextAlignment.Right
        self.labelCard3.text = "123456789"
        self.addSubview(self.labelCard3)
        
        
        
        let transaction: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(card3.frame)+7, 300, 15))
        if UIScreen.mainScreen().bounds.size.height == 480 {
            transaction.frame = CGRectMake(10, CGRectGetMaxY(card3.frame)+3, 300, 15)
        }
        transaction.text = "LAST TRANSACTION"
        transaction.textColor = UIColor.blueColor()
        transaction.font = UIFont.boldSystemFontOfSize(15)
        transaction.textAlignment = NSTextAlignment.Left
        self.addSubview(transaction)
        
        let pointsEarned: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(transaction.frame) + 7, 130, 15))
        if UIScreen.mainScreen().bounds.size.height == 480 {
            pointsEarned.frame = CGRectMake(10, CGRectGetMaxY(transaction.frame) + 3, 130, 15)
        }
        pointsEarned.font = UIFont.systemFontOfSize(13)
        pointsEarned.textColor = UIColor.whiteColor()
        pointsEarned.textAlignment = NSTextAlignment.Left
        pointsEarned.text = "Points Earned:"
        self.addSubview(pointsEarned)
        
        self.labelPointsEarned.frame = CGRectMake(CGRectGetMaxX(pointsEarned.frame) + 5, CGRectGetMinY(pointsEarned.frame), self.frame.size.width - 155, 15)
        self.labelPointsEarned.font = UIFont.systemFontOfSize(13)
        self.labelPointsEarned.text = "12"
        self.labelPointsEarned.textColor = UIColor.whiteColor()
        self.labelPointsEarned.textAlignment = NSTextAlignment.Right
        self.addSubview(self.labelPointsEarned)
        
        let pointsRedeemed: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(pointsEarned.frame), 130, 15))
        pointsRedeemed.font = UIFont.systemFontOfSize(13)
        pointsRedeemed.textAlignment = NSTextAlignment.Left
        pointsRedeemed.textColor = UIColor.whiteColor()
        pointsRedeemed.text = "Points Redeemed:"
        self.addSubview(pointsRedeemed)
        
        self.labelPointsRedeemed.frame = CGRectMake(CGRectGetMaxX(pointsRedeemed.frame) + 5, CGRectGetMinY(pointsRedeemed.frame), self.frame.size.width - 155, 15)
        self.labelPointsRedeemed.font = UIFont.systemFontOfSize(13)
        self.labelPointsRedeemed.textColor = UIColor.whiteColor()
        self.labelPointsRedeemed.text = "---"
        self.labelPointsRedeemed.textAlignment = NSTextAlignment.Right
        self.addSubview(self.labelPointsRedeemed)
        
        let pasaPoints: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(pointsRedeemed.frame), 130, 15))
        pasaPoints.font = UIFont.systemFontOfSize(13)
        pasaPoints.textColor = UIColor.whiteColor()
        pasaPoints.textAlignment = NSTextAlignment.Left
        pasaPoints.text = "Pasa-Points:"
        self.addSubview(pasaPoints)
        
        self.labelPasaPoints.frame = CGRectMake(CGRectGetMaxX(pasaPoints.frame) + 5, CGRectGetMinY(pasaPoints.frame), self.frame.size.width - 155, 15)
        self.labelPasaPoints.font = UIFont.systemFontOfSize(13)
        self.labelPasaPoints.textColor = UIColor.whiteColor()
        self.labelPasaPoints.text = "---"
        self.labelPasaPoints.textAlignment = NSTextAlignment.Right
        self.addSubview(self.labelPasaPoints)
        
        let transactionDate: UILabel = UILabel(frame: CGRectMake(10, CGRectGetMaxY(pasaPoints.frame), 130, 15))
        transactionDate.font = UIFont.systemFontOfSize(13)
        transactionDate.textAlignment = NSTextAlignment.Left
        transactionDate.textColor = UIColor.whiteColor()
        transactionDate.text = "Transaction Date:"
        self.addSubview(transactionDate)
        
        self.labelTransactionDate.frame = CGRectMake(CGRectGetMaxX(transactionDate.frame) + 5, CGRectGetMinY(transactionDate.frame), self.frame.size.width - 155, 15)
        self.labelTransactionDate.textColor = UIColor.whiteColor()
        self.labelTransactionDate.font = UIFont.systemFontOfSize(13)
        self.labelTransactionDate.text = "---"
        self.labelTransactionDate.textAlignment = NSTextAlignment.Right
        self.addSubview(self.labelTransactionDate)
        
        
        
    }
    
    
}
//MARK: - MenuTypeTableViewCell
class MenuTypeTableViewCell: UITableViewCell {
    
    //MARK: Properties
    var menuType: String = ""
    
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(frame: CGRect) {
        
        for views in self.contentView.subviews {
            
            views.removeFromSuperview()
            
        }
        
        let viewHolder = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height - 2))
        viewHolder.backgroundColor = UIColor.whiteColor()
        viewHolder.layer.cornerRadius = 5
        self.contentView.addSubview(viewHolder)
        
        let content: UILabel = UILabel(frame: CGRectMake(10, 0, viewHolder.frame.size.width-50, viewHolder.frame.size.height))
        content.textColor = UIColor.blueColor()
        content.text = self.menuType
        viewHolder.addSubview(content)
        
    }
    
    
}

//MARK: - MenuTypeContentTableViewCell
class MenuTypeContentTableViewCell: UITableViewCell {
    
    //MARK: Properties
    var content: MenuContentModelRepresentation = MenuContentModelRepresentation()
    
    //MARK: Method
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(frame: CGRect) {
        
        for views in self.contentView.subviews {
            
            views.removeFromSuperview()

        }
        
        let viewHolder = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height - 2))
        viewHolder.backgroundColor = UIColor.whiteColor()
        viewHolder.layer.cornerRadius = 5
        self.contentView.addSubview(viewHolder)
        
        let image = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        image.backgroundColor = UIColor.blackColor()
        viewHolder.addSubview(image)
        
        let foodName = UILabel(frame: CGRectMake(CGRectGetMaxX(image.frame) + 20, 20, frame.size.width - 90, 1000))
        foodName.text = self.content.menuName
        foodName.font = UIFont.systemFontOfSize(24)
        foodName.numberOfLines = 99
        
        let height: CGFloat = foodName.getLabelHeight(self.content.menuName, font: UIFont.systemFontOfSize(24), maxSize: CGSizeMake(frame.size.width - 120, 10000))
        
        foodName.frame.size.height = height
        viewHolder.addSubview(foodName)
        
        let labelAlaCarte : UILabel = UILabel(frame: CGRectMake(CGRectGetMinX(foodName.frame), CGRectGetMaxY(foodName.frame) + 10, 100, 14))
        labelAlaCarte.font = UIFont.systemFontOfSize(12)
        labelAlaCarte.textAlignment = NSTextAlignment.Left
        labelAlaCarte.text = self.content.labelOption1
        viewHolder.addSubview(labelAlaCarte)
        
        let alaCarte : UILabel = UILabel(frame: CGRectMake(frame.size.width - 110, CGRectGetMinY(labelAlaCarte.frame), 100, 14))
        alaCarte.font = UIFont.systemFontOfSize(12)
        alaCarte.textAlignment = NSTextAlignment.Right
        alaCarte.text = self.content.option1
        viewHolder.addSubview(alaCarte)
        
        let labelCombo : UILabel = UILabel(frame: CGRectMake(CGRectGetMinX(labelAlaCarte.frame), CGRectGetMaxY(alaCarte.frame), 100, 14))
        labelCombo.font = UIFont.systemFontOfSize(12)
        labelCombo.textAlignment = NSTextAlignment.Left
        labelCombo.text = self.content.labelOption2
        viewHolder.addSubview(labelCombo)
        
        let combo : UILabel = UILabel(frame: CGRectMake(CGRectGetMinX(alaCarte.frame), CGRectGetMinY(labelCombo.frame), 100, 14))
        combo.text = self.content.option2
        combo.font = UIFont.systemFontOfSize(12)
        combo.textAlignment = NSTextAlignment.Right
        viewHolder.addSubview(combo)
        
        let comboWith : UILabel = UILabel(frame: CGRectMake(CGRectGetMinX(combo.frame), CGRectGetMaxY(combo.frame), 100, 14))
        comboWith.text = self.content.option3
        comboWith.font = UIFont.systemFontOfSize(12)
        comboWith.textAlignment = NSTextAlignment.Right
        viewHolder.addSubview(comboWith)
        
        let labelComboWith : UILabel = UILabel(frame: CGRectMake(CGRectGetMinX(labelCombo.frame), CGRectGetMinY(comboWith.frame), frame.size.width - 210, 1000))
        labelComboWith.textAlignment = NSTextAlignment.Left
        labelComboWith.font = UIFont.systemFontOfSize(12)
        labelComboWith.numberOfLines = 99
        labelComboWith.text = self.content.labelOption3
        
        let heightComboWith : CGFloat = labelComboWith.getLabelHeight(self.content.labelOption3, font: UIFont.systemFontOfSize(12), maxSize: CGSizeMake(labelComboWith.frame.size.width, 1000))
        
        labelComboWith.frame.size.height = heightComboWith
        viewHolder.addSubview(labelComboWith)
        
        
    }
}

//MARK: - OptionCell
class OptionTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var labelOption: UILabel!
    
    @IBOutlet weak var imageCircle: UIImageView!
    //MARK: Method
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
}


//MARK: - Extension UI
extension UILabel {
    
    func getLabelHeight(text: String, font: UIFont, maxSize: CGSize) -> CGFloat {
        
        let attrString = NSAttributedString.init(string: text, attributes: [NSFontAttributeName:font])
        let rect = attrString.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        let size = CGSizeMake(rect.size.width, rect.size.height)
        
        return size.height
        
    }
    
}

