//
//  ModulesViewController.swift
//  Zed
//
//  Created by Mark Louie Angeles on 12/07/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import ActionSheetPicker_3_0
import CoreData

let keyResult = "Result"
let keyOptions = "ANSWERSET"
let keyOption = "ANSWER"
let keyOptionID = "AID"
let keyQuestion = "QUESTION"
let keyQuestionID = "QID"

//MARK: - Module Delegate/Call back
protocol ModuleViewControllerDelegate {
    
    func surveyDidClose()
    func pulsifyDidClose()
    func branchesDidClose()
    func pasaPointsDidClose()
    func productsDidClose()

}

//MARK: - Survey View Controller
class SurveyViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate, WebServiceDelegate, CustomAlertViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelQuestion: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonSubmit: UIButton!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var buttonNext: NSLayoutConstraint!
    
    var tempOption: NSMutableArray = NSMutableArray()
    
    let webService = WebService()
    
    var user: UserModelRepresentation?
    var surveyContent = NSMutableArray()
    var currentIndex : Int = 0
    var selectedAnswer : Int = -1
    
    var delegate : ModuleViewControllerDelegate?
    
    //MARK: View life cycle
    override func viewDidLoad() {
        
        self.webService.delegate = self
        self.tableView.separatorColor = UIColor.clearColor()
        self.viewContent.layer.cornerRadius = 10
        self.surveyContent.removeAllObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getSurveyInfo()
        self.view.bringSubviewToFront(self.viewContent)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for contstraints in self.view.constraints {
            
            if contstraints.firstItem as? NSObject == self.view {
                
                if contstraints.firstAttribute == NSLayoutAttribute.Height {
                    contstraints.constant = UIScreen.mainScreen().bounds.size.height
                }else if contstraints.firstAttribute == NSLayoutAttribute.Width {
                    contstraints.constant = UIScreen.mainScreen().bounds.size.width
                }
                
            }
        }
    }
    
    //MARK: Method
    func reloadSurveyUI() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let content = self.surveyContent[self.currentIndex] as! NSDictionary
            self.labelNumber.text = "\(self.currentIndex + 1)."
            self.labelQuestion.text = content[keyQuestion] as? String
            self.tableView.reloadData()
            
        }

    }
    
    //MARK: API Call
    func getSurveyInfo() {
        dispatch_async(dispatch_get_main_queue()) {
            self.displayLoadingScreen()
        }
        
        self.webService.name = "surveyInfo"
        self.webService.connectAndGetSurveyInfo(self.user!.facebookID)
        
    }
    
    func submitAnswer() {
        if self.selectedAnswer == -1 {
            displayAlertValidationError()
            return
        }
        
        let content = self.surveyContent[self.currentIndex] as! NSDictionary
        
        let params = NSMutableDictionary()
        let options = content[keyOptions] as! NSArray
        let option = options[self.selectedAnswer] as! NSDictionary
        
        params.setObject(self.user!.facebookID, forKey: "fbid")
        params.setObject(content[keyQuestionID] as! String, forKey: "qid")
        params.setObject(option[keyOptionID] as! String, forKey: "aid")
        params.setObject("", forKey: "sParam")
        params.setObject(content[keyQuestionID] as! String, forKey: "qid")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.displayLoadingScreen()
        }
        
        self.webService.name = "surveySubmit"
        self.webService.connectAndSendSurvey(params)
    }
    
    //MARK: Button Actions
    @IBAction func submitClicked(sender: UIButton) {
        
    }
    
    @IBAction func backClicked(sender: UIButton) {
        self.delegate?.surveyDidClose()
    }
    
    @IBAction func nextClicked(sender: UIButton) {
        
    }
    
    //MARK: Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let content = self.surveyContent[self.currentIndex] as! NSDictionary
        let options = content[keyOptions] as! NSArray
        
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("cellOptions") as? OptionTableViewCell else {
            let newCell : OptionTableViewCell = OptionTableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cellContentIdentifier")
            newCell.selectionStyle = UITableViewCellSelectionStyle.None
            return newCell
        }
        
        let content = self.surveyContent[self.currentIndex] as! NSDictionary
        let options = content[keyOptions] as! NSArray
        let option = options[indexPath.row] as! NSDictionary
        cell.labelOption.text = option[keyOption] as? String
        cell.imageCircle.layer.cornerRadius = 8
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.backgroundView?.backgroundColor = self.tableView.backgroundColor
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = self.tableView.backgroundColor
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedAnswer = indexPath.row
        self.submitAnswer()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let content = self.surveyContent[self.currentIndex] as! NSDictionary
        let options = content[keyOptions] as! NSArray
        let option = options[indexPath.row] as! NSDictionary
        
        let label = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 120, 1000))
        return label.getLabelHeight((option[keyOption] as? String)!, font: UIFont.systemFontOfSize(17), maxSize: CGSizeMake(label.frame.size.width, label.frame.size.height)) + 10
    }
    
    //MARK: CustomAlertView Delegate
    func customAlertDidPressOkay() {
        self.delegate?.surveyDidClose()
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        dispatch_async(dispatch_get_main_queue()) {
            self.hideLoadingScreen()
        }
        
        if self.webService.name == "surveyInfo" {
            let result = parsedDictionary[keyResult] as! NSArray
            
            for content in result {
                
                let dictionaryContent = content as! NSDictionary
                self.surveyContent.addObject(dictionaryContent)
                
            }
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.reloadSurveyUI()
            
        } else {
            
            self.currentIndex = self.currentIndex + 1
            self.selectedAnswer = -1
            if self.currentIndex == self.surveyContent.count {
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in

                    self.displayAlert("Thank you for your participation!", title: "")
                    self.alertView!.delegate = self
                    
                }
                
                return
            }
            
            self.reloadSurveyUI()
        }
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
        
    }
    
    func webServiceDidTimeout() {
        dispatch_async(dispatch_get_main_queue()) {
            self.hideLoadingScreen()
        }
        
        var message = ""
        if self.webService.name == "surveyInfo" {
            message = "Failed to fetch survey questions."
        } else {
            message = "Failed to submit survey answers."
        }
        
        displayAlertTimedOut(message)
    }
    
    func webServiceDidFailWithError(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.hideLoadingScreen()
        }
        
        displayAlertWithError(error)
    }
}

//MARK: - Pulsify View Controller
class PulsifyViewController : BaseViewController, WebServiceDelegate, CustomAlertViewDelegate {
    
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
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelBranch: UILabel!
    @IBOutlet weak var viewBranch: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewCity: UIView!
    
    var delegate : ModuleViewControllerDelegate?
    
    var counter : Int = 0
    
    var answers: NSMutableDictionary = NSMutableDictionary()
    var contents: NSMutableArray = NSMutableArray()
    
    let webService = WebService()
    var user: UserModelRepresentation?
    var customPicker: CustomPickerView?
    
    var arrayBranches = [BranchModelRepresentation]()
    var arrayCities = [String]()
    var arrayBranch = NSMutableArray()
    
    //MARK: View life cycle
    override func viewDidLoad() {
        self.webService.delegate = self
        self.presetValues()
        
        self.viewBranch.layer.cornerRadius = 10
        self.viewCity.layer.cornerRadius = 10
        self.viewContent.layer.cornerRadius = 10
        
        self.getBranches()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resetButtons()
        self.resetValues()
        self.setButtonColors()
    }
    
    //MARK: Custom
    func setButtonColors() {
        
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            print("Set Images!!!!!!")
            for views in self.viewOption1.subviews {
                
                let button = views as! UIButton
                let graySmiley = "graysmiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: graySmiley), forState: UIControlState.Normal)
                let smiley = "smiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: smiley), forState: UIControlState.Selected)
                button.backgroundColor = UIColor.clearColor()
            }
            
            for views in self.viewOption2.subviews {
                
                let button = views as! UIButton
                button.backgroundColor = UIColor.clearColor()
                let graySmiley = "graysmiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: graySmiley), forState: UIControlState.Normal)
                let smiley = "smiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: smiley), forState: UIControlState.Selected)
                
            }
            
            for views in self.viewOption3.subviews {
                
                let button = views as! UIButton
                button.backgroundColor = UIColor.clearColor()
                let graySmiley = "graysmiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: graySmiley), forState: UIControlState.Normal)
                let smiley = "smiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: smiley), forState: UIControlState.Selected)
                
            }
            
            for views in self.viewOption4.subviews {
                let button = views as! UIButton
                button.backgroundColor = UIColor.clearColor()
                let graySmiley = "graysmiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: graySmiley), forState: UIControlState.Normal)
                let smiley = "smiley" + "\(6 - button.tag)"
                button.setImage(UIImage(named: smiley), forState: UIControlState.Selected)
                
            }
        }
    
    }
    
    //MARK: Functions
    func presetValues() {
        
        self.labelCity.text = ""
        self.labelBranch.text = ""
        
        let dictionary1 = NSMutableDictionary()
        dictionary1.setObject("Please rate the overall quality of the restaurant.", forKey: "question")
        dictionary1.setObject("FOOD", forKey: "row1")
        dictionary1.setObject("CLEANLINESS", forKey: "row2")
        dictionary1.setObject("SERVICES", forKey: "row3")
        dictionary1.setObject("COURTESY", forKey: "row4")
        
        let dictionary2 = NSMutableDictionary()
        dictionary2.setObject("Please rate the services of this restaurant.", forKey: "question")
        dictionary2.setObject("ORDER", forKey: "row1")
        dictionary2.setObject("APPROACHABLE", forKey: "row2")
        dictionary2.setObject("", forKey: "row3")
        dictionary2.setObject("", forKey: "row4")
        
        let dictionary3 = NSMutableDictionary()
        dictionary3.setObject("Please rate the crews responds toward customers.", forKey: "question")
        dictionary3.setObject("READY TO GO", forKey: "row1")
        dictionary3.setObject("APPROACHABLE", forKey: "row2")
        dictionary3.setObject("", forKey: "row3")
        dictionary3.setObject("", forKey: "row4")
        
        self.contents.addObject(dictionary1)
        self.contents.addObject(dictionary2)
        self.contents.addObject(dictionary3)
        
        self.labelOption1.text = dictionary1["row1"] as? String
        self.labelOption2.text = dictionary1["row2"] as? String
        self.labelOption3.text = dictionary1["row3"] as? String
        self.labelOption4.text = dictionary1["row4"] as? String
        self.labelQuestion.text = dictionary1["question"] as? String
        
        self.labelNumber.text = "\(self.counter + 1)"
    }
    
    private func updateContent() {
        
        self.counter = self.counter + 1
        
        if self.counter >= self.contents.count {
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.displayAlert("Thank you for your participation!", title: "")
                self.alertView!.delegate = self
            }
            
            return
        }
        
        let dictionary = self.contents[self.counter] as! NSMutableDictionary
        
        self.viewOption1.hidden = false
        self.viewOption2.hidden = false
        self.viewOption3.hidden = false
        self.viewOption4.hidden = false
        
        if dictionary["row1"] as? String == "" {
            self.viewOption1.hidden = true
        }
        
        if dictionary["row2"] as? String == "" {
            self.viewOption2.hidden = true
        }
        
        if dictionary["row3"] as? String == "" {
            self.viewOption3.hidden = true
        }
        
        if dictionary["row4"] as? String == "" {
            self.viewOption4.hidden = true
        }
        
        self.labelOption1.text = dictionary["row1"] as? String
        self.labelOption2.text = dictionary["row2"] as? String
        self.labelOption3.text = dictionary["row3"] as? String
        self.labelOption4.text = dictionary["row4"] as? String
        self.labelQuestion.text = dictionary["question"] as? String
        self.labelNumber.text = "\(self.counter + 1)."
        
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
        
        if (self.answers["option1"] as? String == "" && self.labelOption1.text != "") ||
            (self.answers["option2"] as? String == "" && self.labelOption2.text != "") ||
            (self.answers["option3"] as? String == "" && self.labelOption3.text != "") ||
            (self.answers["option4"] as? String == "" && self.labelOption4.text != ""){
            
                return false
                
        }
        
        return true
    }
    
    private func parseResponse(arrayJSON: NSArray) {
        arrayJSON.enumerateObjectsUsingBlock { (obj, index, stop) -> Void in
            if obj.isKindOfClass(NSDictionary.classForCoder()) {
                let dictObj = obj as! NSDictionary
                let branch = BranchModelRepresentation()
                branch.convertDictionaryToBranchModelInfo(dictObj)
                
                self.arrayBranches.append(branch)
                
                let city = branch.city
                if !self.arrayCities.contains(city) {
                    self.arrayCities.append(city)
                }
            } else {
                print("format/server error")
            }
        }
    }
    
    private func completeData() -> Bool {
        if self.labelBranch.text! == "" || self.labelCity.text! == "" {
            
            self.view.userInteractionEnabled = true
            displayAlert("Please make sure that you have selected a City and a Branch.", title: "")
            return false
            
        }
        
        return true
        
    }
    
    //MARK: CustomAlertView Delegate
    func customAlertDidPressOkay() {
        self.delegate?.pulsifyDidClose()
    }
    
    //MARK: API Call
    private func getBranches() {
        /*
        self.webService.name = "getBranch"
        self.webService.connectAndGetBranches()
        */
        
        //fetch branches from core data
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Branch")
            
            do {
                let results = try managedContext.executeFetchRequest(fetchRequest) as! [Branch]
                
                if results.count > 0 {
                    (results as NSArray).enumerateObjectsUsingBlock({ (obj, index, stop) in
                        let branch = BranchModelRepresentation()
                        branch.convertManagedObjectToBranchModelInfo(obj as! Branch)
                        self.arrayBranches.append(branch)
                        
                        let city = branch.city
                        if !self.arrayCities.contains(city) {
                            self.arrayCities.append(city)
                        }
                        
                        if index == 0 {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.labelCity.text = branch.city
                                self.labelBranch.text = branch.branchName
                            })
                        }
                    })
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        })
    }
    
    private func sendPulsify(answer: String) {
        
        self.view.userInteractionEnabled = false
        let predicate = NSPredicate(format: "self.city == '\(self.labelCity!.text!)' && self.branchName == '\(self.labelBranch!.text!)'")
        let arrayFiltered = (self.arrayBranches as NSArray).filteredArrayUsingPredicate(predicate) as NSArray
        
        let content = arrayFiltered[0] as! BranchModelRepresentation
        
        let dictWebService = NSMutableDictionary()
        dictWebService["fbid"] = self.user!.facebookID
        dictWebService["storeid"] = content.branchId
        dictWebService["question"] = self.labelOption1.text
        dictWebService["answer"] = answer
        
        self.webService.name = "sendPulsify"
        self.webService.connectAndSendPulsifyInfo(dictWebService)
        
    }
    
    //MARK: Button Actions
    @IBAction func option1Clicked(sender: UIButton) {
        
        if !self.completeData() {
            
            return
            
        }
        
        for views in self.viewOption1.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        sender.selected = true
        
        self.answers.setObject("\(sender.tag)", forKey: "option1")
        
        self.sendPulsify("\(sender.tag)")
        
    }
    
    @IBAction func option2Clicked(sender: UIButton) {
        
        if !self.completeData() {
            
            return
            
        }
        
        for views in self.viewOption2.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        sender.selected = true
        
        self.answers.setObject("\(sender.tag)", forKey: "option2")
        
        self.sendPulsify("\(sender.tag)")
    }
    
    @IBAction func option3Clicked(sender: UIButton) {
        
        if !self.completeData() {
            
            return
            
        }
        
        for views in self.viewOption3.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        sender.selected = true
        self.answers.setObject("\(sender.tag)", forKey: "option3")
        
        self.sendPulsify("\(sender.tag)")
    }
    
    
    @IBAction func option4Clicked(sender: UIButton) {
        
        if !self.completeData() {
            
            return
            
        }
        
        for views in self.viewOption4.subviews {
            
            let button = views as! UIButton
            button.selected = false
            
        }
        sender.selected = true
        self.answers.setObject("\(sender.tag)", forKey: "option4")
        
        self.sendPulsify("\(sender.tag)")
    }
    
    @IBAction func buttonCityClicked(sender: UIButton) {
        if self.arrayCities.count == 0 {
            // City not yet available
            return
        }
        ActionSheetStringPicker.showPickerWithTitle("City", rows: self.arrayCities, initialSelection: 0, doneBlock: { (picker, index, value) -> Void in
            //print(index)
            // print(value)
            
            self.labelBranch.text = ""
            self.labelCity.text = value as? String
            
            let predicate = NSPredicate(format: "self.city == '\(value)'")
            let arrayFiltered = (self.arrayBranches as NSArray).filteredArrayUsingPredicate(predicate) as NSArray
            
            self.arrayBranch.removeAllObjects()
            
            for content in arrayFiltered {
                let branchModel = content as! BranchModelRepresentation
                self.arrayBranch.addObject(branchModel.branchName)
                
            }
            
            }, cancelBlock: { (picker) -> Void in
                print("cancel")
            }, origin: self.view)
    }
    
    @IBAction func buttonBranchClicked(sender: UIButton) {
        
        ActionSheetStringPicker.showPickerWithTitle("Branch", rows: self.arrayBranch as [AnyObject], initialSelection: 0, doneBlock: { (picker, index, value) -> Void in
            //print(index)
            // print(value)
            self.labelBranch.text = value as? String
            
            }, cancelBlock: { (picker) -> Void in
                print("cancel")
            }, origin: self.view)
        
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        
        self.delegate?.pulsifyDidClose()
        // remove view
        
    }
    
    //MARK: WebService Delegate
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        self.view.userInteractionEnabled = true
        print(parsedDictionary)
        
        if self.readyToNext() {
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                self.updateContent()
                
            }
        }
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        self.parseResponse(parsedArray)
    }
    
    func webServiceDidTimeout() {
        displayAlertTimedOut("Failed to submit Pulsify answers.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        displayAlertWithError(error)
    }
    
}

//MARK: - Pasa Points View Controller
class PasaPointsViewController : BaseViewController, WebServiceDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var textCardNumber: UITextField!
    @IBOutlet weak var textAmount: UITextField!
    
    var user: UserModelRepresentation?
    let webService = WebService()

    var delegate : ModuleViewControllerDelegate?

    //MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webService.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.labelPoints.text = self.user!.points
    }
    
    //MARK: Button Actions
    
    @IBAction func backClicked(sender: UIButton) {
        
        self.delegate?.pasaPointsDidClose()
        
    }
    
    @IBAction func goClicked(sender: UIButton) {
        sender.enabled = false
        
        //validate fields first
        if self.validateFields() == true {
            //proceed
            btnSender = sender
            
            self.callPasaPointsApi()
            
            return
        }
        
        sender.enabled = true
        displayAlertValidationError()
    }
    
    //MARK: - Methods
    private func validateFields() -> Bool {
        if self.textCardNumber.text != "" && self.textAmount.text != "" && self.textCardNumber.text?.characters.count == 19 && Float(self.textAmount.text!) > 0.0 {
            return true
        }
        
        return false
    }
    
    private func callPasaPointsApi() {
        if self.user == nil {
            //for now (this should retrieve data from core data)
            self.user = UserModelRepresentation()
            self.user!.cardNumber = "6788880000001370"
        }
        
        let dictParams = NSMutableDictionary()
        let timeStamp = generateTimeStamp()
        
        dictParams["transactionId"] = generateTransactionIDWithTimestamp(timeStamp)
        dictParams["senderCardNumber"] = self.user!.cardNumber
        dictParams["receiverCardNumber"] = self.textCardNumber.text!.stringByReplacingOccurrencesOfString("-", withString: "")
        dictParams["amount"] = self.textAmount.text
        dictParams["currency"] = currency
        dictParams["paymentChannel"] = channel
        dictParams["requestTimezone"] = timezone
        dictParams["requestTimestamp"] = timeStamp
        
        //print(dictParams)
        displayLoadingScreen()
        self.webService.connectAndPasaPointsWithInfo(dictParams)
    }
    
    //MARK: UITextfield Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textAmount {
            return true
        }
        
        let text = textField.text! + string
        let charCount = text.characters.count
        
        if string.characters.count == 0 {
            if charCount%5 == 0 {
                textField.text = textField.text!.substringToIndex(textField.text!.endIndex.predecessor())
            }
            return true
        }
        
        if charCount == 0 {
            return true
        }
        
        if charCount == 20 {
            return false
        }
        
        let dashCount = charCount/4
        if (charCount-dashCount)%4 == 0 {
            textField.text = textField.text! + "-"
        }
        
        return true
    }
    
    //MARK: WebService Delegate
    
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) {
        print(parsedDictionary)
        
        let status = parsedDictionary["Status"] as! String
        let description = parsedDictionary["StatusDescription"] as! String
        
        btnSender!.enabled = true
        hideLoadingScreen()
        
        if status == "0" {
            displayAlert("You have successfully transferred some points to \(self.textCardNumber.text!).", title: "")
            
            return
        }
        
        displayAlertRequestError(status, descripion: description)
    }
    
    func webServiceDidFinishLoadingWithResponseArray(parsedArray: NSArray) {
        
    }
    
    func webServiceDidTimeout() {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertTimedOut("Unable to transfer points.")
    }
    
    func webServiceDidFailWithError(error: NSError) {
        btnSender!.enabled = true
        hideLoadingScreen()
        displayAlertWithError(error)
    }
}

//MARK: - Branch Selection View Controller

class BranchSelectionViewContoller : UIViewController {
    
    //MARK: Properties
    
    var delegate : ModuleViewControllerDelegate?
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    //MARK: Button Actions
    @IBAction func backButtonClicked(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.delegate?.branchesDidClose()
        }
        
    }
    
    @IBAction func didSelectBranch(sender: AnyObject) {
        self.performSegueWithIdentifier("goToBranches", sender: self)
    }
}

//MARK: - Branches View Controller

class BranchesViewController : UIViewController, GMSMapViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var lblMerchantName: UILabel!
    @IBOutlet var lblCityName: UILabel!
    @IBOutlet var viewHolderCity: UIView!
    
    var user: UserModelRepresentation?
    
    var arrayBranches = [BranchModelRepresentation]()
    var arrayCities = [String]()
    
    var currentBranch: BranchModelRepresentation?
    
    @IBOutlet weak var viewInfoHolder: UIView!
    @IBOutlet weak var viewInfoBranch: UIView!
    @IBOutlet weak var labelCityInfo: UILabel!
    @IBOutlet weak var labelAddressInfo: UILabel!
    @IBOutlet weak var labelPhoneInfo: UILabel!
    @IBOutlet weak var labelHoursInfo: UILabel!
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.presetValues()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchBranches()
        
        self.viewHolderCity.layer.cornerRadius = 8.0
        self.viewInfoBranch.layer.cornerRadius = 8.0
        self.viewInfoBranch.layer.borderWidth = 2.0
        self.viewInfoBranch.layer.borderColor = UIColor.blackColor().CGColor
        
    }
    
    //MARK: Methods
    
    private func presetValues() {
        //for now
        self.lblMerchantName.text = "KFC"
        self.lblCityName.text = ""
    }
    
    private func setupGoogleMaps() {
        self.mapView.delegate = self
        
        self.currentBranch = self.arrayBranches[0]
        self.lblCityName.text = self.currentBranch!.city
        
        let predicate = NSPredicate(format: "self.city == '\(self.lblCityName.text!)'")
        let arrayFiltered = (self.arrayBranches as NSArray).filteredArrayUsingPredicate(predicate) as NSArray
        
        arrayFiltered.enumerateObjectsUsingBlock({ (obj, index, stop) in
            let content = obj as! BranchModelRepresentation
            
            let target = CLLocationCoordinate2D(latitude: Double(content.longitude)!, longitude: Double(content.latitude)!)
            self.mapView.camera = GMSCameraPosition.cameraWithTarget(target, zoom: 15)
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(content.longitude)!, longitude: Double(content.latitude)!)
            marker.title = content.city
            marker.snippet = content.branchName
            marker.icon = UIImage(named: "mapPin")
            marker.userData = "\(index)"
            marker.map = self.mapView
        })
    }
    
    private func fetchBranches() {
        /*
        let url:NSURL = NSURL(string: "http://180.87.143.52/funapp/GetBranches.aspx")!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            do {
                let objJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                
                if objJSON.isKindOfClass(NSArray.classForCoder()) {
                    self.parseResponse(objJSON as! [[String:AnyObject]])
                } else {
                    print("format/server error")
                    
                }
                
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
            
        }
        
        task.resume()
        */
        
        //fetch branches from core data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Branch")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [Branch]
            
            if results.count > 0 {
                (results as NSArray).enumerateObjectsUsingBlock({ (obj, index, stop) in
                    let branch = BranchModelRepresentation()
                    branch.convertManagedObjectToBranchModelInfo(obj as! Branch)
                    self.arrayBranches.append(branch)
                    
                    let city = branch.city
                    if !self.arrayCities.contains(city) {
                        self.arrayCities.append(city)
                    }
                })
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.setupGoogleMaps()
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    private func parseResponse(arrayJSON: NSArray) {
        print("fetching branches..")
        arrayJSON.enumerateObjectsUsingBlock { (obj, index, stop) -> Void in
            if obj.isKindOfClass(NSDictionary.classForCoder()) {
                let dictObj = obj as! NSDictionary
                let branch = BranchModelRepresentation()
                branch.convertDictionaryToBranchModelInfo(dictObj)
                
                self.arrayBranches.append(branch)
                
                let city = branch.city
                if !self.arrayCities.contains(city) {
                    self.arrayCities.append(city)
                }
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.setupGoogleMaps()
                }
                
            } else {
                print("format/server error")
            }
        }
        
        self.lblCityName.text = self.arrayCities.first
    }
    
    private func displayBranchInfo(branch: BranchModelRepresentation) {
//        if self.viewInfo == nil {
//            self.setupInfoView()
//        }
        
        self.viewInfoHolder.hidden = false
        
        //display info here
//        self.lblBranchName!.text = self.currentBranch!.branchName
        self.labelCityInfo.text = self.currentBranch!.branchName.uppercaseString
        self.labelAddressInfo!.text = self.currentBranch!.address
        self.labelPhoneInfo!.text = self.currentBranch!.contactNumber
        self.labelHoursInfo!.text = self.currentBranch!.operatingHours
    }
    
    //MARK: Button Actions
    @IBAction func didPressBackButton(sender: UIButton) {
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    
    
    @IBAction func didPressButtonOkay(sender: UIButton) {
        
        self.viewInfoHolder.hidden = true
        
    }
   
    //MARK: IBAction Delegate
    @IBAction func didPressBranches(sender: AnyObject) {
        if self.arrayCities.count > 0 {
            ActionSheetStringPicker.showPickerWithTitle("", rows: self.arrayCities, initialSelection: self.arrayCities.indexOf(self.lblCityName.text!)!, doneBlock: { (picker, index, value) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.lblCityName.text = value as? String
                    //update map
                    
                    let stringCity = value as! String
                    let predicate = NSPredicate(format: "self.city == '\(stringCity)'")
                    let arrayFiltered = (self.arrayBranches as NSArray).filteredArrayUsingPredicate(predicate) as NSArray
                    
                    arrayFiltered.enumerateObjectsUsingBlock({ (obj, index, stop) in
                        let content = obj as! BranchModelRepresentation
                        
                        let target = CLLocationCoordinate2D(latitude: Double(content.longitude)!, longitude: Double(content.latitude)!)
                        self.mapView.camera = GMSCameraPosition.cameraWithTarget(target, zoom: 15)
                        
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: Double(content.longitude)!, longitude: Double(content.latitude)!)
                        marker.title = content.city
                        marker.snippet = content.branchName
                        marker.icon = UIImage(named: "mapPin")
                        marker.userData = "\(index)"
                        marker.map = self.mapView
                    })
                    
                }

                
                
                }, cancelBlock: { (picker) -> Void in
                    print("cancel")
                }, origin: self.view)
        }
    }
    
    //MARK: - GMSMapView Delegate
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        self.currentBranch = self.arrayBranches[(marker.userData as! NSString).integerValue]
        self.displayBranchInfo(self.currentBranch!)
        
        return true
    }
}

let productsLink = "http://180.87.143.55/fun.menu/"

//MARK: - Products View Controller

class ProductsViewController : BaseViewController, UIWebViewDelegate {
    
    //MARK: Properties
    @IBOutlet var lblStore: UILabel!
    @IBOutlet var webView: UIWebView!
    
    var delegate : ModuleViewControllerDelegate?
    var firstLoad = true
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.delegate = self
        self.webView.loadRequest(NSURLRequest(URL: NSURL(string: productsLink)!))
    }
    
    //MARK: Button Actions
    @IBAction func didPressBack(sender: AnyObject) {
        //go back to dashboard
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.delegate?.productsDidClose()
            
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        if firstLoad == true {
            displayLoadingScreen()
            firstLoad = false
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideLoadingScreen()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        hideLoadingScreen()
        displayAlertWithError(error!)
    }
}
