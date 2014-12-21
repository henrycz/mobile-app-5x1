//
//  mainCtrl.swift
//  appProjectApple5x1
//
//  Created by Nelkit on 26/09/14.
//  Copyright (c) 2014 Grupo 5x1. All rights reserved.
//

import UIKit

//url a la que se conecta para extraer datos en formato JSON
let kURL = "http://www.apple5x1.es/wp-json/posts?filter[cat]=21"
//let kURL = "http://localhost:3000/apple5x1.json"
let mainQueue = dispatch_get_main_queue()
let diffQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT

class mainCtrl: UIViewController, UITableViewDataSource, UITableViewDelegate, SideMenuDelegate{
    var dataJSON = [NSDictionary]()
    var imageNotice = [Int:UIImage?]()
    var imageAuthor = [Int:UIImage?]()
    var sideMenu : SideMenu?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBOutlet weak var groupButton: UIView!
    @IBOutlet var tableView: UITableView?
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //iniciar la animacion del indicador de estado
        loadIndicator.startAnimating()
        
        //diseño del grupo de botones de la parte superior de la pantalla
        groupButton.layer.cornerRadius = 3
        groupButton.clipsToBounds = true
        
        
        JSONrequest(kURL)
        

        //instaciando el menu en esta view
        sideMenu = SideMenu(sourceView: self.view)
        sideMenu!.delegate = self
        
        //colocando el logo en el navigationBar
        let logoApple5x1 = UIImage(named: "apple5x1.png")
        let imageViewLogo = UIImageView(image: logoApple5x1)
        self.navigationItem.titleView = imageViewLogo
        
        //border in GroupButtom
        
        groupButton.layer.borderWidth = 1.2;
        groupButton.layer.borderColor = UIColor(red:226.0/255.0, green:226.0/255.0, blue:226.0/255.0,alpha:1).CGColor
    }
    
    func JSONrequest(urlPath: String) {
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let sessionConf:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConf)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            var urlResponse:NSHTTPURLResponse = response as NSHTTPURLResponse
            if(urlResponse.statusCode == 200){
                var err: NSError?
                
                self.dataJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as [NSDictionary]!
                self.tableView?.reloadData()
                
                if(err != nil) {
                    //Si hay un error al analizar JSON, imprimirlo en la consola
                    println("JSON Error \(err!.localizedDescription)")
                }
            }
        })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /////////////funciones para hacer funcionar el boton del menu/////////////
    func sideMenuDidSelectItemAtIndex(index: Int) {
        sideMenu?.toggleMenu()
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        sideMenu?.toggleMenu()
    }
    
    /////////////////////definiendo las secciones de la tabla///////////////
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /////////////////////definiendo el numero de registros que mostrara la tabla///////////////
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataJSON.count
    }
    
    /////////////////////definiendo la estructura de la celda
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Celda") as UITableViewCell
        // usando el JSON que se obtuvo de internet y instanciandolo con la libreria swiftify para mejor manejo
        let json = JSON(object: self.dataJSON[indexPath.row])
        
        //creando la estructura y efectos de la celda
        if let containerNotice = cell.viewWithTag(6) as UIView! {
            containerNotice.layer.cornerRadius = 3
            containerNotice.clipsToBounds = true
            containerNotice.layer.shadowColor = UIColor.blackColor().CGColor
            containerNotice.layer.shadowOffset = CGSizeMake(15.0,15.0);
            containerNotice.layer.borderWidth = 1.2;
            containerNotice.layer.borderColor = UIColor(red:226.0/255.0, green:226.0/255.0, blue:226.0/255.0,alpha:1).CGColor
        }
        
        //obteniendo tamaño de la pantalla
        let sessionConf:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConf)
        let screenWidth = self.screenSize.width
        //comprobando el tamaño de la pantalla para cargar imagenes de la noticia con distintas resoluciones para cada iphone
        //iphone 4s, 5, 5s, 5c
            let URLimages = json["featured_image"]["attachment_meta"]["sizes"]["featured3"]["url"].stringValue
            let dataURL = NSURL(string: URLimages!)
            let imgUrlRequest = NSURLRequest(URL: dataURL!)
            let task = session.dataTaskWithRequest(imgUrlRequest, completionHandler: {data, response, error -> Void in
                var urlResponse:NSHTTPURLResponse = response as NSHTTPURLResponse
                
                if urlResponse.statusCode == 200 {
                    dispatch_async(dispatch_get_main_queue(),{
                        //colocando la imagen de la noticia
                        if let imgNotice = cell.viewWithTag(2) as? UIImageView {
                            imgNotice.image = UIImage(data: data)
                            self.loadIndicator.stopAnimating()
                            self.loadIndicator.hidden = true
                        }
                        if let titleNotice = cell.viewWithTag(1) as? UILabel {
                            let noticeTitle = json["title"].stringValue as String!
                            titleNotice.text = noticeTitle
                        }
                        if let author = cell.viewWithTag(5) as? UILabel {
                            let nameAuthor = json["author"]["username"].stringValue as String!
                            author.text = nameAuthor
                        }
                    })
                }else{
                    println("Algo anduvo mal")
                }
            })
            task.resume()
        
        
        let URLavatar = json["author"]["avatar"].stringValue
        let URLavatarAcentos = URLavatar?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let dataURLavatar = NSURL(string: URLavatarAcentos!)
        let imgAvatarRequest = NSURLRequest(URL: dataURLavatar!)
        let taskAvatar = session.dataTaskWithRequest(imgAvatarRequest, completionHandler: {data, response, error -> Void in
            var urlResponse:NSHTTPURLResponse = response as NSHTTPURLResponse
            
            if urlResponse.statusCode == 200 {
                dispatch_async(dispatch_get_main_queue(),{
                    //colocando la imagen del avatar                    
                    if let avatarAutor = cell.viewWithTag(4) as? UIImageView {
                        avatarAutor.image =  UIImage(data: data)
                        avatarAutor.layer.cornerRadius = 20
                        avatarAutor.clipsToBounds = true
                        self.loadIndicator.stopAnimating()
                        self.loadIndicator.hidden = true
                    }
                })
            }else{
                println("Algo anduvo mal")
            }
        })
        taskAvatar.resume()
        
        //extraendo imagen del autor de la noticia del JSON
        

        
        //colocando la imagen del autor
        //if let avatarAutor = cell.viewWithTag(4) as? UIImageView {
        //    avatarAutor.image = self.imageAuthor[indexPath.row]?
        //    avatarAutor.layer.cornerRadius = 20
        //    avatarAutor.clipsToBounds = true
        //}
        return cell
    }
    
    
    @IBAction func reload(sender: AnyObject) {
        self.tableView?.reloadData()
    }
    
    // metodo que se ejecuta cuando se toca una de las celdas, cuando se dispara este metodo se envian los datos de esta view a la del detailMainCtrl
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let json:AnyObject = self.dataJSON
        
        //instanciamos la la view detailMainVC
        let detailMainVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailMainSB") as detailMainCtrl
        //enviamos los datos esta view hacia una variable que se encuentra en detailMainVC llamada datosJSON
        detailMainVC.datosJSON = json[indexPath.row]
        //presentamos la view
        self.navigationController?.pushViewController(detailMainVC, animated: true)
    }
}

