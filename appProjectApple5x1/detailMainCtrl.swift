//
//  detailMainCtrl.swift
//  appProjectApple5x1
//
//  Created by Nelkit on 30/09/14.
//  Copyright (c) 2014 Grupo 5x1. All rights reserved.
//

import UIKit

class detailMainCtrl: UIViewController, UIWebViewDelegate {
    
    //en esta variable se almacenan todos los datos que vienen de la view principal
    var datosJSON:AnyObject = [NSDictionary]()
    //definino el tamaño por defecto que tendra el cuerpo de la noticia
    var fontSizeAccumulator = 14
    //en esta varible se inicializa una view donde se muestra la imagen y nombre del autor
    let authorInNavBar = UIView()
    //obteniendo el tamaño de la pantalla
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var mainImageNotice: UIImageView!
    @IBOutlet weak var contentNotice: UIWebView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var showSetting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appendWidgetNavbar()
        bodyGenerateNotice()
        bottomBarOptions()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func appendWidgetNavbar(){
        let json = JSON(object: datosJSON)
        
        let screenWidth = screenSize.width
        if(screenWidth == 320.0){
            authorInNavBar.frame = CGRectMake(110, 0, 100, 40)
        }else if(screenWidth == 375.0){
            authorInNavBar.frame = CGRectMake(140, 0, 100, 40)
        }else if(screenWidth == 414.0){
            authorInNavBar.frame = CGRectMake(155, 0, 100, 40)
        }
        
        let URLautor = json["author"]["avatar"].stringValue
        let URLautorAcentos = URLautor?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let authorData = NSData(contentsOfURL: NSURL(string: URLautorAcentos as String!)!)
        let authorImage = UIImage(data: authorData!)
        let imageView = UIImageView(image:authorImage)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.layer.frame = CGRectMake(0, 0, 40, 40);
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        let lblauthorName = UILabel(frame: CGRectMake(46, 7, 80, 40))
        let lblescrito = UILabel(frame: CGRectMake(46, -7, 80, 40))
        
        let shareIcon = UIImage(named: "share-btn.png")
        let btnCompartir = UIBarButtonItem(image: shareIcon, style:UIBarButtonItemStyle.Bordered, target: self, action: "shareNotice")
        
        lblauthorName.text = json["author"]["first_name"].stringValue
        lblauthorName.font = UIFont(name: lblauthorName.font.fontName, size: 14)
        
        lblescrito.text = "Escrito por: "
        lblescrito.font = UIFont(name: lblauthorName.font.fontName, size: 10)
        
        self.authorInNavBar.addSubview(imageView)
        self.authorInNavBar.addSubview(lblauthorName)
        self.authorInNavBar.addSubview(lblescrito)
        self.navigationController?.navigationBar.addSubview(authorInNavBar)
        self.navigationItem.rightBarButtonItem = btnCompartir
    }
    
    func bodyGenerateNotice(){
        let json = JSON(object: datosJSON)
        
        let URLimages = json["featured_image"]["attachment_meta"]["sizes"]["featured4"]["url"].stringValue as String!
        let titleNotice = json["title"].stringValue as String!
        let content = json["content"].stringValue as String!
        
        let style = "<style>#content{padding:15px;color:#575756;box-sizing:border-box} iframe{display:none}  img, div {width:100% !important;height:auto !important;} #mainImg{display:block} a{pointer-events: none;} body{-webkit-touch-calloust: none;font-size:\(fontSizeAccumulator)px;padding:0px;margin:0px; font-family:helvetica}</style>"
        
        let contentWithStyle = "\(style)<body><img id='mainImg' src='\(URLimages)' /><div id='content'><h2>\(titleNotice)</h2><hr>\(content)</div></body>"
        contentNotice.loadHTMLString(contentWithStyle, baseURL: nil)
    }
    
    func bottomBarOptions(){
        bottomBar.backgroundColor = UIColor.clearColor()
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = CGRectMake(-4, 0,screenSize.width+4, bottomBar.layer.frame.height)
        bottomBar.addSubview(visualEffectView)
        
        showSetting.backgroundColor = UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0,alpha:0.7)
        showSetting.layer.cornerRadius = 30
        showSetting.clipsToBounds = true
    }
    
    override func viewWillDisappear(animated: Bool) {
       authorInNavBar.hidden = true

    }
    
    @IBAction func hideBottomBar(sender: UISwipeGestureRecognizer) {
        bottomBar.hidden = true
        showSetting.hidden = false
    }
    
    @IBAction func showBottomBar(sender: AnyObject) {
        bottomBar.hidden = false
        showSetting.hidden = true
    }

    @IBAction func increaseFont(sender: AnyObject) {
        if(fontSizeAccumulator<=20){
            fontSizeAccumulator = fontSizeAccumulator+1
            contentNotice.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSizeAccumulator)'")
            contentNotice.scrollView.contentSize = CGSizeMake(contentNotice.frame.size.width,contentNotice.scrollView.contentSize.height)
        }
    }
    
    @IBAction func decreaseFont(sender: AnyObject) {
        if(fontSizeAccumulator>14){
            fontSizeAccumulator = fontSizeAccumulator-1
            contentNotice.stringByEvaluatingJavaScriptFromString("document.body.style.fontSize = '\(fontSizeAccumulator)'")
            contentNotice.scrollView.contentSize = CGSizeMake(contentNotice.frame.size.width,contentNotice.scrollView.contentSize.height)
        }
    }
    
    
    @IBAction func cambiarFondo(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex
            {
        case 0:
            contentNotice.stringByEvaluatingJavaScriptFromString("document.body.style.background = 'black'")
            contentNotice.stringByEvaluatingJavaScriptFromString("document.getElementById('content').style.color = '#ECF0F1'")
            mainView.backgroundColor = UIColor.blackColor()
            contentNotice.backgroundColor = UIColor.blackColor()
        case 1:
            contentNotice.stringByEvaluatingJavaScriptFromString("document.body.style.background = 'white'")
            contentNotice.stringByEvaluatingJavaScriptFromString("document.getElementById('content').style.color = '#575756'")
            mainView.backgroundColor = UIColor.whiteColor()
            contentNotice.backgroundColor = UIColor.whiteColor()
        default:
            break; 
        }
    }
    
    
    func shareNotice(){
        let json = JSON(object: datosJSON)
        let titleNotice = json["title"].stringValue as String!
        let textShare = "\(titleNotice) vía @Apple5x1"
        let URLimages = json["featured_image"]["attachment_meta"]["sizes"]["featured4"]["url"].stringValue as String!
        let imageData = NSData(contentsOfURL: NSURL(string: URLimages as String!)!)
        let imageShare = UIImage(data: imageData!)
       // let shareNotice:NSArray = [textShare, imageShare]
        
       // let activityShare = UIActivityViewController(activityItems: shareNotice, applicationActivities: nil)
       // self.presentViewController(activityShare, animated: true, completion: nil)
    }
    
}
