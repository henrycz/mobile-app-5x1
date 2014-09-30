//
//  mainCtrl.swift
//  appProjectApple5x1
//
//  Created by Nelkit on 26/09/14.
//  Copyright (c) 2014 Grupo 5x1. All rights reserved.
//

import UIKit

let kURL = "http://www.apple5x1.es/wp-json/posts"
//let kURL = "http://localhost:3000/apple5x1.json"

class mainCtrl: UIViewController, UITableViewDataSource, UITableViewDelegate, SideMenuDelegate{
    var datos = [NSDictionary]()
    var images = [Int:UIImage?]()
    var imgAutor = [Int:UIImage?]()
    var sideMenu : SideMenu?
    
    @IBOutlet weak var groupButton: UIView!
    @IBOutlet var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupButton.layer.cornerRadius = 3
        groupButton.clipsToBounds = true

        sideMenu = SideMenu(sourceView: self.view, menuData: ["Inicio", "Podcast", "Videos", "Social", "Conócenos", "Contacto"], iconData: ["icon-home.png", "icon-podcast.png", "icon-videos.png", "icon-social.png", "icon-conocenos.png", "icon-contact.png"])
        sideMenu!.delegate = self

        peticionJSON(kURL)

    }
    
    func peticionJSON(urlPath: String) {
        
        let url: NSURL = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var resultadoJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as [NSDictionary]!
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.datos =  resultadoJson
                self.tableView!.reloadData()
            })
        })
            
        task.resume()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sideMenuDidSelectItemAtIndex(index: Int) {
        sideMenu?.toggleMenu()
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        sideMenu?.toggleMenu()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Celda") as UITableViewCell
        let json = JSON(object: self.datos)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        if(screenWidth == 320.0){
            let URLimages = json[indexPath.row]["featured_image"]["attachment_meta"]["sizes"]["featured8"]["url"].stringValue
            let imageData = NSData(contentsOfURL: NSURL(string: URLimages as String!))
            let image = UIImage(data: imageData)
            self.images[indexPath.row] = image
        }else if(screenWidth == 375.0){
            let URLimages = json[indexPath.row]["featured_image"]["attachment_meta"]["sizes"]["featured11"]["url"].stringValue
            let imageData = NSData(contentsOfURL: NSURL(string: URLimages as String!))
            let image = UIImage(data: imageData)
            self.images[indexPath.row] = image
        }
        
        let URLautor = json[indexPath.row]["author"]["avatar"].stringValue
        let URLautorAcentos = URLautor?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let authorData = NSData(contentsOfURL: NSURL(string: URLautorAcentos as String!))
        let imgAutor = UIImage(data: authorData)
        self.imgAutor[indexPath.row] = imgAutor
        
        if let titleNotice = cell.viewWithTag(1) as? UIWebView {
            let noticeTitle = json[indexPath.row]["title"].stringValue as String!
            let styleFontTitle = "<style>body{font-size:14px; color:#363636;font-weight:bold; font-family:helvetica}</style><body>\(noticeTitle)</body>"
            titleNotice.loadHTMLString(styleFontTitle, baseURL: nil)
        }

        if let nameAuthor = cell.viewWithTag(5) as? UILabel {
            nameAuthor.text = (json[indexPath.row]["author"]["name"].stringValue)
        }
        
        if let imgNotice = cell.viewWithTag(2) as? UIImageView {
            imgNotice.image = images[indexPath.row]?
        }
        
        if let avatarAutor = cell.viewWithTag(4) as? UIImageView {
            avatarAutor.image = self.imgAutor[indexPath.row]?
            avatarAutor.layer.cornerRadius = 20
            avatarAutor.clipsToBounds = true
        }
        
        if let containerNotice = cell.viewWithTag(6) as UIView! {
            containerNotice.layer.cornerRadius = 3
            containerNotice.clipsToBounds = true
            containerNotice.layer.borderWidth = 0.5
            containerNotice.layer.borderColor = UIColor(red:188.0/255.0, green:188.0/255.0, blue:188.0/255.0,alpha:0.4).CGColor
        }
        return cell
    }
    
    @IBAction func reload(sender: AnyObject) {
        self.tableView?.reloadData()
    }
    
    // UITableViewDelegate methods
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        let alert = UIAlertController(title: "Item selected", message: "You selected item \(indexPath.row)", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler: {
                (alert: UIAlertAction!) in println("An alert of type \(alert.style.hashValue) was tapped!")
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}

