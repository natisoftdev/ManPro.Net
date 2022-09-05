/*
    HomeVC.swift
    ManPro.net

    Created by Lorenzo Malferrari on 27/03/19.
    Copyright © 2019 Natisoft. All rights reserved.
*/

import UIKit
import CoreLocation
import WebKit
import Photos

class HomeVC: BaseViewController, WKNavigationDelegate, WKUIDelegate, CLLocationManagerDelegate {

    var webView: WKWebView!
    var urlStr:String = ""
    var nameDB:String = "" //nagest come stringa di esempio
    var usere:String = ""
    var password:String = ""
    
    let primoAvvio: [String:String] = [
        "en":"https://sviluppo.manpronet.com/attracco_ios/avvioIOS/primo_avvio_IOS-en.php",
        "es":"https://sviluppo.manpronet.com/attracco_ios/avvioIOS/primo_avvio_IOS-es.php",
        "fr":"https://sviluppo.manpronet.com/attracco_ios/avvioIOS/primo_avvio_IOS-fr.php",
        "it":"https://sviluppo.manpronet.com/attracco_ios/avvioIOS/primo_avvio_IOS-it.php",
        "pl":"https://sviluppo.manpronet.com/attracco_ios/avvioIOS/primo_avvio_IOS-pl.php"
    ]
    
    //Oggetto per la gestione della localizzazione
    var locationManager: CLLocationManager!
    var refController:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadView()
        inizializeUserDefaultsString()
        
        print("Slider = \(UserDefaults.standard.float(forKey: "slider"))")
        print("NameDB = \(String(describing: UserDefaults.standard.string(forKey: "nameDB")))")
        print("arrayPortali = \(String(describing: UserDefaults.standard.string(forKey: "arrayPortali")))")
        print("Usere = \(String(describing: UserDefaults.standard.string(forKey: "usere")))")
        print("Password = \(String(describing: UserDefaults.standard.string(forKey: "password")))")
        print("Lingua = \(NSLocale.current.languageCode ?? "")")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //Richiedo le autorizzazioni per la Localizzazione
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways){ locationManager.requestAlwaysAuthorization() }
        
        //Richiedo le autorizzazioni per la Fotocamera e Album
        checkPermissionCamera()
        checkPermissionPhoto()
        
        addSlideMenuButton()
        
        self.nameDB = UserDefaults.standard.string(forKey: "nameDB") ?? ""
        //print(self.nameDB)
        self.usere = UserDefaults.standard.string(forKey: "usere") ?? ""
        //print(self.usere)
        self.password = UserDefaults.standard.string(forKey: "password") ?? ""
        //print(self.password)
        
        if(self.nameDB == ""){
            // This code must run on the main thread because it interacts with the UI.
            //DispatchQueue.main.async {
            //print("-> " + self.urlStr)
            //print(self.isValidUrl(url: self.urlStr))
            //print("-----------------------------")
            var str:String = ""
            let linguaDevide = NSLocale.current.languageCode ?? ""
            //Controllo se lingua è presente come chiave nel dizionario
            // - true : prendo valore corrispondente
            // - false : setto a inglese
            if let val = primoAvvio[linguaDevide] {str = val}
            else{str = primoAvvio["en"]!}
            
            //print(str)
            
            let url = URL(string: str)!
            /*
            refController.bounds = CGRect.init(x: 0.0, y: 50.0, width: refController.bounds.size.width, height: refController.bounds.size.height)
            refController.addTarget(self, action: #selector(self.refreshWebView), for: .valueChanged)
            refController.attributedTitle = NSAttributedString(string: "Pull to refresh")
            webView.scrollView.addSubview(refController)
            */
            self.webView.load(URLRequest(url: url))
            // 2
            let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self.webView, action: #selector(self.webView.reload))
            self.toolbarItems = [refresh]
            self.navigationController?.isToolbarHidden = false
            
            /*var items = [UIBarButtonItem]()

            items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
            items.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil))

            self.toolbarItems = items // this made the difference. setting the items to the controller, not the navigationcontroller
            */
            //}
        }
        else{
            // Do any additional setup after loading the view.
            risolutoreIndirizzo() { address in
            //print("Address preReplace -> " + address)
            self.urlStr = address.replacingOccurrences (of: "\\/", with: "/")
            
            if(self.urlStr.contains("\"")){
                let start = self.urlStr.index(self.urlStr.startIndex, offsetBy: 1)
                let end = self.urlStr.index(self.urlStr.endIndex, offsetBy: -1)
                let range = start..<end
                
                self.urlStr = String(self.urlStr[range])
            }
                // This code must run on the main thread because it interacts with the UI.
                DispatchQueue.main.async {
                    //print(self.urlStr)
                    //print(self.isValidUrl(url: self.urlStr))
                    //print("-----------------------------")
                    let url = URL(string: self.urlStr)!
                /*
                    self.refController.bounds = CGRect.init(x: 0.0, y: 50.0, width: self.refController.bounds.size.width, height: self.refController.bounds.size.height)
                    self.refController.addTarget(self, action: #selector(self.refreshWebView), for: .valueChanged)
                    self.refController.attributedTitle = NSAttributedString(string: "Pull to refresh")
                    self.webView.scrollView.addSubview(self.refController)
                  */
                    self.webView.uiDelegate = self
                    self.webView.navigationDelegate = self
                    self.webView.load(URLRequest(url: url))
                    
                    // 2
                    let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self.webView, action: #selector(self.webView.reload))
                    self.toolbarItems = [refresh]
                    self.navigationController?.isToolbarHidden = false
                    
                }
            }
        }
    }
    
    @objc func refreshWebView(refresh:UIRefreshControl!){
        webView.reload()
        refController.endRefreshing()
    }
    
    /*
     Metodo per chidere all'utente il permesso all'uso della applicazione Album, dalla quale verranno scelte le App
     */
    func checkPermissionPhoto(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
            case .authorized:
                print("success")
            case .notDetermined, .restricted, .denied, .limited:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in
                    print("status is \(newStatus)")
                    if newStatus ==  PHAuthorizationStatus.authorized {
                        print("success")
                    }
                })
    }
    
    /*
     Metodo per chidere all'utente il permesso all'uso della Fotocamera
     */
    func checkPermissionCamera(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
            case .authorized:
                print("success")
            case .notDetermined, .restricted, .denied:
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                    if granted {
                        print("Accesso autorizzato a \(cameraMediaType)")
                    } else {
                        print("Accesso negato a \(cameraMediaType)")
                    }
                }
        }
    }
    
    /*
     Verifico la corretta sintassi del URL
     */
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    override func loadView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let webConfiguration = WKWebViewConfiguration()
        //let userContentController = WKUserContentController()
        
        /*let userScript = WKUserScript (
            source: "loginIOS(\(usere),\(password))",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )*/
        
        //userContentController.addUserScript(userScript)
        
        webConfiguration.preferences = preferences
        //webConfiguration.userContentController = userContentController
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
        //view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Inizializzo le variabili usate dal Sistema per Salvare i dati usati all'interno dell'applicazione
    func inizializeUserDefaultsString() {
        //print("inizializeUserDefaultsString")
        //Inizializzazione degli attributi utili per il corretto uso del sistema Manpro.Net
        if(UserDefaults.standard.string(forKey: "slider") == nil){
            UserDefaults.standard.set(60, forKey: "slider")
            //print("slider")
        }
        //print("------------------------------")
        if(UserDefaults.standard.string(forKey: "nameDB") == nil){
            UserDefaults.standard.set("", forKey: "nameDB")
            //print("nameDB")
        }
        //print("------------------------------")
        if(UserDefaults.standard.string(forKey: "arrayPortali") == nil){
            UserDefaults.standard.set("", forKey: "arrayPortali")
            //print("arrayPortali")
        }
        //print("------------------------------")
        if(UserDefaults.standard.string(forKey: "usere") == nil){
            UserDefaults.standard.set("", forKey: "usere")
            //print("usere")
        }
        //print("------------------------------")
        if(UserDefaults.standard.string(forKey: "password") == nil){
            UserDefaults.standard.set("", forKey: "password")
            //print("password")
        }
    }
    
    func risolutoreIndirizzo(completion: @escaping (_ result: String) -> Void) {
        
        let indirizzoPortale:String = "https://manpronet.com/"
        let percorsoPortale:String = "attracco_android/risolutore_indirizzo/json-events-login_IOS.php"
        //print("URL -> \(indirizzoPortale+percorsoPortale)")
        let request = NSMutableURLRequest(url: NSURL(string: indirizzoPortale+percorsoPortale)! as URL)
        request.httpMethod = "POST"
        let postString = "StringaAccesso=\(nameDB)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            //print("response = \(response)")
            let responseString:String! = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String?
            //print("responseString = \(String(describing: responseString))")
            //print("---------------------------------")
            //Ora bisogna spezzare responseString per ottenere i campi indirizzoPortale e indirizzoPortaleEncoding
            let arrayResponse = responseString.split(separator: ",")
            // This variable must be declared inside the block.
            var indirizzoPortaleString: String = ""
            if(arrayResponse[0].split(separator: ":")[1].count > 0 && arrayResponse[0].split(separator: ":")[1] != "\"\""){
                // Since I'm not getting any real data, I'm replacing it with the ones you sent me earlier. You don't have to do this.
                indirizzoPortaleString = arrayResponse[0].split(separator: ":")[1] + ":" + arrayResponse[0].split(separator: ":")[2]
            }
            else{ indirizzoPortaleString = self.primoAvvio[(NSLocale.current.languageCode ?? "it")]! }
            //print("Indirizzo al quale accedere -> " + indirizzoPortaleString)
            completion(indirizzoPortaleString)
        }
        task.resume()
    }
    
    /*
     Metodo che mi consente di effettuare l'autologin se in impostazioni le voci sono compilate
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if ( (usere == nil || usere == "") || ( password == nil || password == "") ) {return}
        
        let fillForm = String(format: "document.getElementById('name').value = '\(usere)';document.getElementById('password').value = '\(password)';Login(true)")
        
        webView.evaluateJavaScript(fillForm) { (result, error) in
            if error != nil { print("AutoLogin effettuato correttamente") }
        }
    }
    
    func webView(_ webView: WKWebView,runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let title = NSLocalizedString("OK", comment: "OK Button")
        let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true)
        completionHandler()
    }
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (() -> Void)) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (@escaping (Bool) -> Void)) {
        print("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(true)
        }))
        present(alertController, animated: true, completion: nil)
    }
}

//Da Internet
extension UIImage {
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        print(percentage)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        print(width)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}
