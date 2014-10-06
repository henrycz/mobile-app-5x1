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

        //instaciando el menu en esta view
        sideMenu = SideMenu(sourceView: self.view)
        sideMenu!.delegate = self

        //llamando funcion que hace la consulta AJAX a la API
        JSONrequest(kURL)
        
        //colocando el logo en el navigationBar
        let logoApple5x1 = UIImage(named: "apple5x1.png")
        let imageViewLogo = UIImageView(image: logoApple5x1)
        self.navigationItem.titleView = imageViewLogo
    }
    
    func JSONrequest(urlPath: String) {
        
        let url: NSURL = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                //Si hay un error en la solicitud web, imprimirlo en la consola
                println(error.localizedDescription)
            }
            var err: NSError?
            var resultJson = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as [NSDictionary]!
            if(err != nil) {
                //Si hay un error al analizar JSON, imprimirlo en la consola
                println("JSON Error \(err!.localizedDescription)")
            }
            dispatch_async(dispatch_get_main_queue(), {
                //pasando los datos de la peticion a una variable global
                self.dataJSON =  resultJson
                //recargar la tableView para que genere las celdas
                self.tableView?.reloadData()
                dispatch_async(dispatch_get_main_queue(), {
                    //recargar la tableView de nuevo para que muestre ya los datos en las celdas
                    self.tableView?.reloadData()
                    //deteniendo animacion del indicador de estado y ocultandola
                    self.loadIndicator.stopAnimating()
                    self.loadIndicator.hidden = true
                })
            })
            
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
        let json = JSON(object: self.dataJSON)
        
        //obteniendo tamaño de la pantalla
        let screenWidth = screenSize.width
        
        //comprobando el tamaño de la pantalla para cargar imagenes de la noticia con distintas resoluciones para cada iphone
        //iphone 4s, 5, 5s, 5c
        if(screenWidth == 320.0){
            let URLimages = json[indexPath.row]["featured_image"]["attachment_meta"]["sizes"]["featured3"]["url"].stringValue
            let imageData = NSData(contentsOfURL: NSURL(string: URLimages as String!))
            let image = UIImage(data: imageData)
            self.imageNotice[indexPath.row] = image
        //iphone 6, 6 plus
        }else if(screenWidth >= 375.0){
            let URLimages = json[indexPath.row]["featured_image"]["attachment_meta"]["sizes"]["featured4"]["url"].stringValue
            let imageData = NSData(contentsOfURL: NSURL(string: URLimages as String!))
            let image = UIImage(data: imageData)
            self.imageNotice[indexPath.row] = image
        }
        
        //extraendo imagen del autor de la noticia del JSON
        let URLauthor = json[indexPath.row]["author"]["avatar"].stringValue
        let URLauthorAcentos = URLauthor?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let authorData = NSData(contentsOfURL: NSURL(string: URLauthorAcentos as String!))
        let imgAuthor = UIImage(data: authorData)
        self.imageAuthor[indexPath.row] = imgAuthor
        
        //colocando el titulo de la noticia
        if let titleNotice = cell.viewWithTag(1) as? UITextView {
            let noticeTitle = json[indexPath.row]["title"].stringValue as String!
            titleNotice.text = NSString(format: noticeTitle, NSHTMLTextDocumentType)
        }
        
        //colocando el nombre del autor
        if let nameAuthor = cell.viewWithTag(5) as? UILabel {
            nameAuthor.text = (json[indexPath.row]["author"]["name"].stringValue)
        }
        
        //colocando la imagen de la noticia
        if let imgNotice = cell.viewWithTag(2) as? UIImageView {
            imgNotice.image = imageNotice[indexPath.row]?
        }
        
        //colocando la imagen del autor
        if let avatarAutor = cell.viewWithTag(4) as? UIImageView {
            avatarAutor.image = self.imageAuthor[indexPath.row]?
            avatarAutor.layer.cornerRadius = 20
            avatarAutor.clipsToBounds = true
        }
        
        //creando la estructura y efectos de la celda
        if let containerNotice = cell.viewWithTag(6) as UIView! {
            containerNotice.layer.cornerRadius = 3
            containerNotice.clipsToBounds = true
            containerNotice.layer.shadowColor = UIColor.blackColor().CGColor
            containerNotice.layer.shadowOffset = CGSizeMake(15.0,15.0);
            containerNotice.layer.borderWidth = 0.5
            containerNotice.layer.borderColor = UIColor(red:188.0/255.0, green:188.0/255.0, blue:188.0/255.0,alpha:0.4).CGColor
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
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

