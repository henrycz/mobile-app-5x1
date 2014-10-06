//
//  podcastCtrl.swift
//  appProjectApple5x1
//
//  Created by Nelkit on 29/09/14.
//  Copyright (c) 2014 Grupo 5x1. All rights reserved.
//

import UIKit

class podcastCtrl: UIViewController,SideMenuDelegate {

    var sideMenu : SideMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = SideMenu(sourceView: self.view)
        sideMenu!.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        sideMenu?.toggleMenu()
    }
    
    func sideMenuDidSelectItemAtIndex(index: Int) {
        sideMenu?.toggleMenu()
    }

}
