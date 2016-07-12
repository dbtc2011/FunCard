//
//  ViewController.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import UIKit

//MARK: - View Controller
class ViewController: UIViewController , UIScrollViewDelegate{
    
    var counter = 0
    let cardInfo: CardInfoView = CardInfoView()
    let header: PointHeaderView = PointHeaderView()

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.blackColor()
        
        
        self.pageIndicator.enabled = false
        self.pageIndicator.numberOfPages = 8
        self.pageIndicator.currentPageIndicatorTintColor = UIColor.yellowColor()
        self.pageIndicator.pageIndicatorTintColor = UIColor.blueColor()
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        let buttonHeight = (self.view.frame.size.height * 0.45) - 45
        
        var xLocation = (self.view.frame.size.width/2) - (buttonHeight/2)
        
        for index in 1...8 {
            
            let imageName = "category" +  "\(index)"
            
            let button = UIButton(type: UIButtonType.Custom)
            button.tag = index
            button.frame = CGRectMake(xLocation, 15, buttonHeight, buttonHeight)
            button.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
            self.scrollView.addSubview(button)
            
            xLocation = xLocation + self.view.frame.size.width
            
        }
        
        
        self.scrollView.scrollEnabled = true
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * 8, 0)
        
        self.header.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.23)
        self.header.setupView()
        self.view.addSubview(self.header)
        
        self.cardInfo.frame = CGRectMake(10, self.view.frame.size.height - ((self.view.frame.size.height * 0.43) + 165 + 20), self.view.frame.size.width - 20, 155)
        
        if self.view.frame.size.height == 480 {
            self.cardInfo.frame = CGRectMake(10, self.view.frame.size.height - ((self.view.frame.size.height * 0.43) + 155 + 5), self.view.frame.size.width - 20, 135)
        }
        self.cardInfo.setupView()
        self.view.addSubview(self.cardInfo)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        self.view.bringSubviewToFront(self.cardInfo)
        self.view.bringSubviewToFront(self.header)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        counter = (Int)(scrollView.contentOffset.x / self.view.frame.size.width)
        self.pageIndicator.currentPage = counter
    }
    
    //MARK: Button Actions
   

}

//MARK: - Menu View Controller
class MenuViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var imageBranchLOgo: UIImageView!
    
    @IBOutlet weak var viewHolder: UIView!
    @IBOutlet weak var branchName2: UILabel!
    @IBOutlet weak var menu2: UILabel!
    @IBOutlet weak var back2: UIButton!
    
    @IBOutlet weak var branchName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var showMenuType: Bool = true
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
    
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewHolder.sendSubviewToBack(self.imageBranchLOgo)
        
        self.branchName.text = "KFC MENU"
        self.branchName2.text = "KFC MENU"
        self.menu2.text =  "Chicken & Bowl Meals"
        
        self.viewHolder.bringSubviewToFront(self.branchName)
        self.viewHolder.bringSubviewToFront(self.branchName2)
        self.viewHolder.bringSubviewToFront(self.menu2)
        self.viewHolder.bringSubviewToFront(self.back2)
        
        self.imageBranchLOgo.layer.cornerRadius = 5.0
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
    }
    
    
    //MARK: Method
    
    
    func setMenuHidden(hidden: Bool) {
        
        if hidden {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.branchName.alpha = 0.0
                self.tableView.alpha = 0.0
                
                }, completion: { (animated: Bool) -> Void in
                    self.tableView.reloadData()
                    self.tableView.alpha = 1.0
                    self.menu2.alpha = 1.0
                    self.back2.alpha = 1.0
                    self.branchName2.alpha = 1.0
                    
            })
            
        }else {
            
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.tableView.alpha = 0.0
                self.menu2.alpha = 0.0
                self.back2.alpha = 0.0
                self.branchName2.alpha = 0.0
                
                }, completion: { (animated: Bool) -> Void in
                    
                    self.tableView.reloadData()
                    self.tableView.alpha = 1.0
                    self.branchName.alpha = 1.0
                    
            })
        }
        
    }
    //MARK: Button Action
    @IBAction func backClicked(sender: UIButton) {
        
        self.showMenuType = !self.showMenuType
        self.setMenuHidden(false)
        
    }
    
    //MARK: Delegate Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if self.showMenuType {
            
            guard let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier") as? MenuTypeTableViewCell else {
                
                let newCell : MenuTypeTableViewCell = MenuTypeTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellIdentifier")
                newCell.menuType = "Chicken"
                newCell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, 40))
                newCell.selectionStyle = UITableViewCellSelectionStyle.None
                return newCell
            }
            
            cell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, 40))
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
            return cell
        }
        
        let tempContent = MenuContentModelRepresentation()
        tempContent.menuName = "AM Chicken Longganisa"
        tempContent.labelOption1 = "Ala Carte:"
        tempContent.labelOption2 = "Combo:"
        tempContent.labelOption3 = "Combo w/ Hashbrown:"
        tempContent.option1 = "PHP 90.00"
        tempContent.option2 = "PHP 95.00"
        tempContent.option3 = "100.00"
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cellContentIdentifier") as? MenuTypeContentTableViewCell else {
            
            let newCell : MenuTypeContentTableViewCell = MenuTypeContentTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellContentIdentifier")
            newCell.content = tempContent
            newCell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, tempContent.getHeight()))
            newCell.selectionStyle = UITableViewCellSelectionStyle.None
            return newCell
        }
        
        cell.content = tempContent
        cell.setupCell(CGRectMake(0, 0, self.view.frame.size.width - 30, tempContent.getHeight()))
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = self.tableView.backgroundColor
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !self.showMenuType {
            return
        }
        self.showMenuType = !self.showMenuType
        self.setMenuHidden(true)
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if self.showMenuType {
            
            return 40
            
        }
        
        let tempContent = MenuContentModelRepresentation()
        tempContent.menuName = "AM Chicken Longganisa"
        tempContent.labelOption1 = "Ala Carte:"
        tempContent.labelOption2 = "Combo:"
        tempContent.labelOption3 = "Combo w/ Hashbrown:"
        tempContent.option1 = "PHP 90.00"
        tempContent.option2 = "PHP 95.00"
        tempContent.option3 = "100.00"
        return tempContent.getHeight()
    }
    
    
}

