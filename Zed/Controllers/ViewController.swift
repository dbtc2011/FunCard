//
//  ViewController.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import UIKit
import Foundation


//MARK: - View Controller
class ViewController: UIViewController , UIScrollViewDelegate{
    
    //MARK: Properties
    var counter = 0
    let cardInfo: CardInfoView = CardInfoView()
    let header: PointHeaderView = PointHeaderView()

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: View Life Cycle
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
            button.addTarget(self, action: #selector(ViewController.buttonsClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
    
    //MARK: Method
    func goToSurvey() {
        
        let storyboard = UIStoryboard(name: "Survey", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("surveyController")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    func goToPulsify() {
        
        let storyboard = UIStoryboard(name: "Pulsify", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("pulsify")
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    //MARK: Delegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        
        counter = (Int)(scrollView.contentOffset.x / self.view.frame.size.width)
        self.pageIndicator.currentPage = counter
    }
    
    //MARK: Button Actions
    func buttonsClicked(sender: UIButton) {
        
        if sender.tag == 1 {
            
        }else if sender.tag == 2 {
            
        }else if sender.tag == 3 {
            
        }else if sender.tag == 4 {
            
        }else if sender.tag == 5 {
            
        }else if sender.tag == 6 {
            
        }else if sender.tag == 7 {
            self.goToPulsify()
        }else if sender.tag == 8 {
            self.goToSurvey()
        }
        
    }
    
   

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

//MARK: - Registration Form View Controller
class RegsitrationFormViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableContents: NSMutableArray = NSMutableArray()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
        self.tableView.scrollEnabled = false
        self.tableView.backgroundColor = UIColor.clearColor()
        self.presetValues()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //MARK: Method
    func presetValues() {
        
        let firstName = NSMutableDictionary()
        firstName.setObject("First Name:", forKey: "label")
        firstName.setObject("", forKey: "value")
        firstName.setObject("text", forKey: "type")
        
        let lastName = NSMutableDictionary()
        lastName.setObject("Last Name:", forKey: "label")
        lastName.setObject("", forKey: "value")
        lastName.setObject("text", forKey: "type")
        
        let birthdate = NSMutableDictionary()
        birthdate.setObject("Birth Date:", forKey: "label")
        birthdate.setObject("", forKey: "value")
        birthdate.setObject("date", forKey: "type")
        birthdate.setObject("image_name", forKey: "button_icon")
        
        let gender = NSMutableDictionary()
        gender.setObject("Gender:", forKey: "label")
        gender.setObject("", forKey: "value")
        gender.setObject("gender", forKey: "type")
        gender.setObject("image_name", forKey: "button_icon")
        
        
        let address = NSMutableDictionary()
        address.setObject("Address:", forKey: "label")
        address.setObject("", forKey: "value")
        address.setObject("text", forKey: "type")
        
        let email = NSMutableDictionary()
        email.setObject("Email:", forKey: "label")
        email.setObject("", forKey: "value")
        email.setObject("text", forKey: "type")
        
        let pin = NSMutableDictionary()
        pin.setObject("Pin Code:", forKey: "label")
        pin.setObject("", forKey: "value")
        pin.setObject("text", forKey: "type")
        
        self.tableContents.addObject(firstName)
        self.tableContents.addObject(lastName)
        self.tableContents.addObject(birthdate)
        self.tableContents.addObject(gender)
        self.tableContents.addObject(address)
        self.tableContents.addObject(email)
        self.tableContents.addObject(pin)
        
    
    }
    
    //MARK: Delegate
    //MARK: Tableview
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tableContents.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let dictionary = self.tableContents[indexPath.row] as! NSMutableDictionary
        
        if dictionary["type"] as? String == "text" {
            
            let cellIdentifier = "textForm"
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TextFormTableViewCell
            
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.labelContent.text = dictionary["label"] as? String
//            cell.textContent.placeholder = dictionary["label"] as? String
            cell.textContent.text = dictionary["value"] as? String
            cell.labelContent.backgroundColor = UIColor.clearColor()
            cell.textContent.delegate = self
            cell.textContent.tag = indexPath.row
            cell.viewTextHolder.layer.cornerRadius = 10
            cell.viewLabelHolder.layer.cornerRadius = 10
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
        }
        
        let cellIdentifier = "dateForm"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DateFormTableViewCell
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.viewLabelHolder.layer.cornerRadius = 10
        cell.viewContentHolder.layer.cornerRadius = 10
        cell.labelQuestion.text = dictionary["label"] as? String
        cell.labelContent.text = dictionary["value"] as? String
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 45
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        
    }
    
    //MARK: TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textNSString = textField.text! as NSString
        
        let text = textNSString.stringByReplacingCharactersInRange(range, withString: string)
        
        let dictionary = self.tableContents[textField.tag] as! NSMutableDictionary
        dictionary.setObject(text, forKey: "value")
        self.tableContents.replaceObjectAtIndex(textField.tag, withObject: dictionary)
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        return true
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    
    //MARK: Button Actions

    @IBAction func saveButtonClicked(sender: UIButton) {
        
        for content in self.tableContents {
            
            let dictionary = content as! NSMutableDictionary
            
            print("Label: \(dictionary["label"] as! String) \(dictionary["value"] as! String)")
            
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("main") 
        self.presentViewController(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func resendButtonClicked(sender: UIButton) {
        
        
    }
}

//MARK: - Registration Card View Controller
class RegistrationCardViewController : UIViewController {
    
    //MARK: Properties
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
   
    
    @IBAction func withCardClicked(sender: UIButton) {
        
        
        
    }
    
    
    @IBAction func withoutCardClicked(sender: UIButton) {
        
        
        self.performSegueWithIdentifier("goToMobileNumber", sender: nil)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
   
    
}

//MARK: - Registration Mobile Number View Controller
class RegistrationMobileNumberViewController : UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var textNumber: UITextField!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        
        self.performSegueWithIdentifier("goToConnectToFacebook", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
}

//MARK: - Registration Facebook View Controller
class RegistrationFacebookViewController : UIViewController {
    
    //MARK: Properties
    
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        
        self.performSegueWithIdentifier("goToForm", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
    
    
}
