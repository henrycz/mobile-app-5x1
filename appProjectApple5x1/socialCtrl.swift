//
//  socialCtrl.swift
//  appProjectApple5x1
//
//  Created by Nelkit on 05/10/14.
//  Copyright (c) 2014 Grupo 5x1. All rights reserved.
//

import UIKit

class socialCtrl: UIViewController, SideMenuDelegate  {

    var sideMenu : SideMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = SideMenu(sourceView: self.view)
        sideMenu!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideMenuDidSelectItemAtIndex(index: Int) {
        sideMenu?.toggleMenu()
    }

    @IBAction func toggleMenu(sender: AnyObject) {
        sideMenu?.toggleMenu()
    }
}
