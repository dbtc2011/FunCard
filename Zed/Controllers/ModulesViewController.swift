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