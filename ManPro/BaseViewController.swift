/*
    BaseViewController.swift
    ManPro.net

    Created by Lorenzo Malferrari on 27/03/19.
    Copyright © 2019 Natisoft. All rights reserved.
*/

import UIKit

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("Home",0)
            break
        case 1:
            print("Pannello di controllo\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("Pannello",0)
            break
        case 2:
            print("Impostazioni\n", terminator: "")
            self.openViewControllerBasedOnIdentifier("Impostazioni",0)
            break
        default:
            print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String,_ clickSingolo:Int32){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        // strIdentifier: Pagina alla quale devo andare,
        // clickSingolo == 0 ci sto andando la prima volta o non devo fare il refresh
        // clickSingolo == 1 devo effettuare il refresh (Modifica appliccata per far funzionare il refresh)
        //print("clickSingolo: \(clickSingolo)")
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier! && clickSingolo == 0){ print("Same VC") }
        else { self.navigationController!.pushViewController(destViewController, animated: true) }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
        let btnChooseDB = UIButton(type: UIButton.ButtonType.system)
        
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        btnChooseDB.setImage(UIImage(named:"list"), for: .normal)
        btnChooseDB.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnChooseDB.addTarget(self, action: #selector(chooseDB), for: UIControl.Event.touchUpInside)
        
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        let chooseDB = UIBarButtonItem(customView: btnChooseDB)
        
        self.navigationItem.leftBarButtonItem = customBarItem;
        self.navigationItem.rightBarButtonItem = chooseDB;
    }
    
    //Da Costruire
    @objc func chooseDB(sender: UIButton!) {
        showAlertWithThreeButton()
    }
    
    /**
     Simple Alert with more than 2 buttons
     */
    func showAlertWithThreeButton() {
        let alert = UIAlertController(
                title: NSLocalizedString("Multistringa", comment: ""),
                message: NSLocalizedString("Scegli la Stringa di Connessione", comment: ""),
                preferredStyle: .alert)

        let arrayPortali = ( UserDefaults.standard.string(forKey: "arrayPortali") ?? "" )
                                                        .replacingOccurrences(of: " ", with: "")
                                                        .components(separatedBy: ",")
        
        //Ciclo for per costruire le voci nell'alert
        for portale in arrayPortali {
            alert.addAction(UIAlertAction(title: portale, style: .default, handler: { (_) in
                print("Hai cliccato il Portale: " + portale)
                UserDefaults.standard.set(portale, forKey: "nameDB")
                
                print("arrayPortali: " + UserDefaults.standard.string(forKey: "arrayPortali")!)
                print("nameDB: " + UserDefaults.standard.string(forKey: "nameDB")!)
                
                //Applicare il refresh della webView
                //DA IMPLEMENTARE
                //let home = HomeVC()
                //home.refreshWebView(refresh: UIRefreshControl?)
                self.openViewControllerBasedOnIdentifier("Home",1)
                
            }))
        }
        
        //Bottone per annullare operazione
        alert.addAction(UIAlertAction(title: NSLocalizedString("Annulla", comment: ""), style: .destructive, handler: { (_) in
            print("Hai annullato l'operazione")
            
            print("arrayPortali: " + UserDefaults.standard.string(forKey: "arrayPortali")!)
            print("nameDB: " + UserDefaults.standard.string(forKey: "nameDB")!)
            
        }))
        
        //Applico le voci
        self.present(alert, animated: true, completion: nil)
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()

        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            sender.tag = 0;
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        
        menuVC.view.layoutIfNeeded()
        menuVC.view.frame = CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
