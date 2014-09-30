//
//  MenuController.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 23.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate {
    func menuControllerDidSelectRow(indexPath:NSIndexPath)
}

class MenuTableViewController: UITableViewController {

    var delegate : MenuTableViewControllerDelegate?
    var tableData : Array<String> = []
    var iconData : Array<String> = []
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.imageView?.frame = CGRectMake(3,2, 20, 25)
            cell!.textLabel?.textColor = UIColor.whiteColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
    
        cell!.imageView?.image = UIImage(named: iconData[indexPath.row])
        cell!.textLabel?.text = tableData[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.menuControllerDidSelectRow(indexPath)
        
        var SBMain = UIStoryboard(name: "Main", bundle: nil)
        
        switch indexPath.row{
        case  0:
            let VCMain = SBMain.instantiateViewControllerWithIdentifier("primarySB") as UIViewController;
            self.showViewController(VCMain, sender: self)
        case  1:
            let VCPodcast = SBMain.instantiateViewControllerWithIdentifier("podcastingSB") as UIViewController;
            self.showViewController(VCPodcast, sender: self)
        default:
            println("is not a vowel or a consonant")
        }

        println(indexPath.row)
    }
    
}
