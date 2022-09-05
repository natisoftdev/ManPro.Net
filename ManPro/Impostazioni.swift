/*
    Impostazioni.swift
    ManPro.net
 
    Created by Lorenzo Malferrari on 27/03/19.
    Copyright © 2019 Natisoft. All rights reserved.
*/

import UIKit

class Impostazioni: BaseViewController {
    
    @IBOutlet weak var lbImpStrConn: UILabel!
    @IBOutlet weak var textFieldDB: UITextField!
    @IBOutlet weak var lbVersioneTesto: UILabel!
    @IBOutlet weak var lbVersioneNumero: UILabel!
    @IBOutlet weak var lbQualImg: UILabel!
    @IBOutlet weak var lbValore: UILabel!
    @IBOutlet weak var sliderQualImg: UISlider!
    
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var textFielsPassword: UITextField!
    
    @IBOutlet weak var lbUsere: UILabel!
    @IBOutlet weak var textFieldUsere: UITextField!
    
    //Informazioni sul device
    var nameDevice:String = "" //Nome del device dato da Utente/Casa Madre
    var systemNameDevice:String = "" //Systema operativo installato
    var systemVersionDevice:String = "" //Versione OS
    var modelDevice:String = "" //Modello del device
    var identifierForVendorDevice:String = ""
    var releaseVersionNumber:String = ""
    var buildVersionNumber:String = ""
    var linguaDevice:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Titolo della pagina
        self.title = NSLocalizedString("Impostazioni", comment: "")
        
        addSlideMenuButton()
        // Do any additional setup after loading the view.
        
        nameDevice = UIDevice.current.name //Nome del device dato da Utente/Casa Madre
        systemNameDevice = UIDevice.current.systemName //Systema operativo installato
        systemVersionDevice = UIDevice.current.systemVersion //Versione OS
        modelDevice = UIDevice.current.model //Modello del device
        identifierForVendorDevice = UIDevice.current.identifierForVendor!.uuidString
        if let release = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.releaseVersionNumber = release
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.buildVersionNumber = build
        }
        linguaDevice = NSLocale.current.languageCode ?? "" //Lingua del Device
        
        //print("Informazioni sul Telefono")
        //print(nameDevice)
        //print(systemNameDevice)
        //print(systemVersionDevice)
        //print(modelDevice)
        //print(identifierForVendorDevice)
        //print(releaseVersionNumber)
        //print(buildVersionNumber)
        print(linguaDevice)
        //print(NSLocale.current.identifier)
        print("---------------------------")
        
        // Zona Stringa di Connessione
        lbImpStrConn.text = NSLocalizedString("Imposta stringa di connessione", comment: "")
        textFieldDB.placeholder = NSLocalizedString("Inserire stringa", comment: "")
        textFieldDB.text = UserDefaults.standard.string(forKey: "arrayPortali") ?? ""
        
        // Zona Stringa di Usere
        lbUsere.text = NSLocalizedString("Username per il login", comment: "")
        textFieldUsere.placeholder = NSLocalizedString("Inserire stringa", comment: "")
        textFieldUsere.text = UserDefaults.standard.string(forKey: "usere") ?? ""
        
        // Zona Stringa di Password
        lbPassword.text = NSLocalizedString("Password", comment: "")
        textFielsPassword.placeholder = NSLocalizedString("Inserire stringa", comment: "")
        textFielsPassword.text = UserDefaults.standard.string(forKey: "password") ?? ""
        
        //Zona Versione Applicazione
        lbVersioneTesto.text = NSLocalizedString("Versione dell'applicazione", comment: "")
        lbVersioneNumero.text = releaseVersionNumber
        lbVersioneNumero.font = UIFont.boldSystemFont(ofSize: 22.0)
        
        //Zona Immagine + Slider
        lbQualImg.text = NSLocalizedString("Qualità Immagine : ", comment: "")
        lbValore.text = "\(UserDefaults.standard.string(forKey: "slider") ?? "60") %"
        if(UserDefaults.standard.string(forKey: "slider") == nil){
            UserDefaults.standard.set(60, forKey: "slider")
        }
        sliderQualImg.value = UserDefaults.standard.float(forKey: "slider")
        sliderQualImg.minimumTrackTintColor = UIColor.blue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    @IBAction func changeDB(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFieldDB.text, forKey: "arrayPortali")
        
        let arrayPortali = ( UserDefaults.standard.string(forKey: "arrayPortali") ?? "" )
                                                    .replacingOccurrences(of: " ", with: "")
                                                    .components(separatedBy: ",")
        
        //print("NameDB Sistema -> " + (UserDefaults.standard.string(forKey: "nameDB")!))
        //print("ArrayPortali Sistema -> " + (UserDefaults.standard.string(forKey: "arrayPortali")!))
        //print("ArrayPortali Variabile -> " + arrayPortali.joined(separator: ","))
        
        //Se nameDB è vuota o non è contenente in arrayPortali, setto nameDB a arrayPortali[0]
        if( (( UserDefaults.standard.string(forKey: "nameDB") ?? "" ).count == 0) ||
            !arrayPortali.contains(UserDefaults.standard.string(forKey: "nameDB")!)){
            UserDefaults.standard.set(arrayPortali[0], forKey: "nameDB")
            
            //print("if - arrayPortali: " + UserDefaults.standard.string(forKey: "arrayPortali")!)
            //print("if - nameDB: " + UserDefaults.standard.string(forKey: "nameDB")!)
        }
        
    }
    
    @IBAction func changeDBEnd(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFieldDB.text, forKey: "arrayPortali")
        
        let arrayPortali = ( UserDefaults.standard.string(forKey: "arrayPortali") ?? "" )
                                                    .replacingOccurrences(of: " ", with: "")
                                                    .components(separatedBy: ",")
        
        //Se nameDB è vuota o non è contenente in arrayPortali, setto nameDB a arrayPortali[0]
        if( (( UserDefaults.standard.string(forKey: "nameDB") ?? "" ).count == 0) ||
            !arrayPortali.contains(UserDefaults.standard.string(forKey: "nameDB")!)){
            UserDefaults.standard.set(arrayPortali[0], forKey: "nameDB")
            
            //print("if - arrayPortali: " + UserDefaults.standard.string(forKey: "arrayPortali")!)
            //print("if - nameDB: " + UserDefaults.standard.string(forKey: "nameDB")!)
        }
        
        //print("arrayPortali: " + UserDefaults.standard.string(forKey: "arrayPortali")!)
        //print("nameDB: " + UserDefaults.standard.string(forKey: "nameDB")!)
    }
    
    //
    @IBAction func changeUsere(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFieldUsere.text, forKey: "usere")
    }
    
    @IBAction func changeUsereEnd(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFieldUsere.text, forKey: "usere")
    }
    //
    @IBAction func changePassword(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFielsPassword.text, forKey: "password")
    }
        
    @IBAction func changePasswordEnd(_ sender: UITextField) {
        //print(textFieldDB.text)
        UserDefaults.standard.set(textFielsPassword.text, forKey: "password")
    }
    
    @IBAction func changeValue(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        UserDefaults.standard.set(currentValue, forKey: "slider")
        print(currentValue)
        lbValore.text = "\(currentValue) %"
    }
}
