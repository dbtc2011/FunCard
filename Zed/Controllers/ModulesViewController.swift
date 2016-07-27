//
//  ModulesViewController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 12/07/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Survey View Controller
class SurveyViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    
    var tempOption: NSMutableArray = NSMutableArray()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
        tempOption.addObject("Yes")
        tempOption.addObject("No")
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    
    //MARK: Method
    
    
    //MARK: Button Actions
    @IBAction func submitClicked(sender: UIButton) {
        
        
    }
    
    //MARK: Delegate Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tempOption.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    

        
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cellOptions") as? OptionTableViewCell else {
            
            let newCell : OptionTableViewCell = OptionTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellContentIdentifier")
            newCell.selectionStyle = UITableViewCellSelectionStyle.None
            return newCell
        }
        cell.labelOption.text = self.tempOption[indexPath.row] as? String
        cell.imageCircle.layer.cornerRadius = 8
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor = self.tableView.backgroundColor
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 120, 1000))
        return label.getLabelHeight(self.tempOption[indexPath.row] as! String, font: UIFont.systemFontOfSize(17), maxSize: CGSizeMake(label.frame.size.width, label.frame.size.height)) + 10
        
    }


    
}

//MARK: - Pulsify View Controller
class PulsifyViewController : UIViewController {
    
    
    //MARK: Properties
    @IBOutlet weak var labelNumber: UILabel!
    
    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var labelOption1: UILabel!
    
    @IBOutlet weak var labelOption2: UILabel!
    
    @IBOutlet weak var labelOption3: UILabel!
    
    @IBOutlet weak var labelOption4: UILabel!
    
    @IBOutlet weak var viewOption1: UIView!
    
    @IBOutlet weak var viewOption2: UIView!
    
    @IBOutlet weak var viewOption3: UIView!
    
    @IBOutlet weak var viewOption4: UIView!
    
    var counter : Int = 0
    
    var answers: NSMutableDictionary = NSMutableDictionary()
    var contents: NSMutableArray = NSMutableArray()
    var cities: NSMutableArray = NSMutableArray()
    var branches: NSMutableArray = NSMutableArray()
    
    var customPicker: CustomPickerView?
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.presetValues()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resetButtons()
        self.resetValues()
        self.setButtonColors()
        
    }
    
    /*

    Temporary function to show the button selection
*/
    func setButtonColors() {
        
        for views in self.viewOption1.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
        }
        
        for views in self.viewOption2.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
            
        }
        
        for views in self.viewOption3.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
            
        }
        
        for views in self.viewOption4.subviews {
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
            
        }
        
    }
    
    
    //MARK: Functions
    func presetValues() {
        
        let dictionary1 = NSMutableDictionary()
        dictionary1.setObject("Please rate the overall quality of the restaurant.", forKey: "question")
        dictionary1.setObject("FOOD", forKey: "row1")
        dictionary1.setObject("CLEANLINESS", forKey: "row2")
        dictionary1.setObject("SERVICES", forKey: "row3")
        dictionary1.setObject("COURTESY", forKey: "row4")
        
        let dictionary2 = NSMutableDictionary()
        dictionary2.setObject("Please rate the overall quality of the manager.", forKey: "question")
        dictionary2.setObject("MANNERS", forKey: "row1")
        dictionary2.setObject("ASSERTIVENESS", forKey: "row2")
        dictionary2.setObject("SERVICES", forKey: "row3")
        dictionary2.setObject("COURTESY", forKey: "row4")
        
        let dictionary3 = NSMutableDictionary()
        dictionary3.setObject("Please rate the overall quality of the crew.", forKey: "question")
        dictionary3.setObject("MANNERS", forKey: "row1")
        dictionary3.setObject("ASSERTIVENESS", forKey: "row2")
        dictionary3.setObject("SERVICES", forKey: "row3")
        dictionary3.setObject("COURTESY", forKey: "row4")
        
        self.contents.addObject(dictionary1)
        self.contents.addObject(dictionary2)
        self.contents.addObject(dictionary3)
        
        self.labelOption1.text = dictionary1["row1"] as? String
        self.labelOption2.text = dictionary1["row2"] as? String
        self.labelOption3.text = dictionary1["row3"] as? String
        self.labelOption4.text = dictionary1["row4"] as? String
        self.labelQuestion.text = dictionary1["question"] as? String
        
        
        self.labelNumber.text = "\(self.counter + 1)"
        
        self.cities.addObject("ANGELES")
        self.cities.addObject("BACOLOD")
        self.cities.addObject("BAGUIO")
        self.cities.addObject("ANGELES")
        self.cities.addObject("CEBU")
        self.cities.addObject("DAVAO")
        self.cities.addObject("MAKATI")
        self.cities.addObject("MANILA")
        self.cities.addObject("NAVOTAS")
        self.cities.addObject("PARANAQUE")
        self.cities.addObject("STA ROSA")
        self.cities.addObject("TAGAYTAY")
        self.cities.addObject("QUEZON CITY")
        self.cities.addObject("VALENZUELA")
        
        self.branches.addObject("1")
        self.branches.addObject("2")
        self.branches.addObject("3")
        self.branches.addObject("4")
        self.branches.addObject("5")
        self.branches.addObject("6")
        
    }
    func updateContent() {
        
        self.counter = self.counter + 1
        
        if self.counter >= self.contents.count {
            return
        }
        
        let dictionary = self.contents[self.counter] as! NSMutableDictionary
        
        self.labelOption1.text = dictionary["row1"] as? String
        self.labelOption2.text = dictionary["row2"] as? String
        self.labelOption3.text = dictionary["row3"] as? String
        self.labelOption4.text = dictionary["row4"] as? String
        self.labelQuestion.text = dictionary["question"] as? String
        self.labelNumber.text = "\(self.counter + 1)"
        
        self.resetValues()
        self.resetButtons()
        self.setButtonColors()
        
        
    }
    
    func resetButtons() {
        
        for views in self.viewOption1.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        
        for views in self.viewOption2.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        
        for views in self.viewOption3.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        
        for views in self.viewOption4.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        
    }
    
    func resetValues() {
        
        self.answers.setObject("", forKey: "option1")
        self.answers.setObject("", forKey: "option2")
        self.answers.setObject("", forKey: "option3")
        self.answers.setObject("", forKey: "option4")
        
    }
    
    func readyToNext() -> Bool {
        
        if self.answers["option1"] as? String == "" ||
            self.answers["option2"] as? String == "" ||
            self.answers["option3"] as? String == "" ||
            self.answers["option4"] as? String == ""{
            
                return false
                
        }
        
        return true
    }
    
    //MARK: Button Actions
    @IBAction func option1Clicked(sender: UIButton) {
        
        for views in self.viewOption1.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
        }
        
        sender.backgroundColor = UIColor.greenColor()
        
        self.answers.setObject("\(sender.tag)", forKey: "option1")
        
        if self.readyToNext() {
            
            self.updateContent()
            
        }
        
    }
    
    @IBAction func option2Clicked(sender: UIButton) {
        
        for views in self.viewOption2.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
        }
        
        sender.backgroundColor = UIColor.greenColor()
        
        self.answers.setObject("\(sender.tag)", forKey: "option2")
        
        if self.readyToNext() {
            
            self.updateContent()
            
        }
        
    }
    
    @IBAction func option3Clicked(sender: UIButton) {
        
        for views in self.viewOption3.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
        }
        
        sender.backgroundColor = UIColor.greenColor()
        
        self.answers.setObject("\(sender.tag)", forKey: "option3")
        
        if self.readyToNext() {
            
            self.updateContent()
            
        }
    }
    
    
    @IBAction func option4Clicked(sender: UIButton) {
        
        for views in self.viewOption4.subviews {
            
            let button = views as! UIButton
            button.backgroundColor = UIColor.blueColor()
        }
        
        sender.backgroundColor = UIColor.greenColor()
        
        self.answers.setObject("\(sender.tag)", forKey: "option4")
        
        if self.readyToNext() {
            
            self.updateContent()
            
        }
        
    }
    
    @IBAction func buttonCityClicked(sender: UIButton) {
        
        self.customPicker = nil
        self.customPicker = CustomPickerView()
        self.customPicker?.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        self.customPicker?.setupPicker("City", content: self.cities)
        self.view.addSubview(self.customPicker!)
        
        
    }
    
    @IBAction func buttonBranchClicked(sender: UIButton) {
        
        self.customPicker = nil
        self.customPicker = CustomPickerView()
        self.customPicker?.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        self.customPicker?.setupPicker("Branch", content: self.branches)
        self.view.addSubview(self.customPicker!)
        
    }
    
    
}

//MARK: - Pasa Points View Controller
class PasaPointsViewController : UIViewController {
    
    
    
}