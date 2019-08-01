//
//  TabController.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/21/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class TabController: UITabBarController, SlideMenuDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        print("tag: \(item.tag)")
        
        if item.tag != 1
        {
            NotificationCenter.default.post(name: Notification.Name("hideTranscribePicker"), object: nil)
        }
        
        if item.tag != 2
        {
            NotificationCenter.default.post(name: Notification.Name("hideTranslatePicker"), object: nil)
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = appDelegate.crLightBlue
        self.tabBar.unselectedItemTintColor = UIColor.init(red: 51.00/255.0, green: 51.00/255.0, blue: 51.00/255.0, alpha: 1.0)

        UITabBar.appearance().barTintColor = UIColor.white
        
        // Do any additional setup after loading the view.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        
        let _ : UIViewController = self.navigationController!.topViewController!
        
        //print("View Controller is : \(topViewController) \n", terminator: "")
        
        switch(index){
            
        case 0:
            
            print("Home3")
            
            self.openViewControllerBasedOnIdentifier("tab controller")
            
            break
            
        case 1:
            
            print("edit profile")
            
            self.openViewControllerBasedOnIdentifier("My Account")
            
            break
            
        case 2:
            
            print("manage friends")
            
            self.openViewControllerBasedOnIdentifier("My Friends")
            
            break
            
        case 3:
            
            print("manage groups")
            
            self.openViewControllerBasedOnIdentifier("My Groups")
            
            break
            
        case 4:
            
            print("manage family")
            
            self.openViewControllerBasedOnIdentifier("Manage Family")
            
            break
            
        case 5:
            
            print("logout")
            
            NotificationCenter.default.post(name: Notification.Name("Logout"), object: nil)
            
            break
            
        default:
            print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            
            //print("Same VC")
            
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
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
    
    func showMenu(sender : UIButton) {
        
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
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            
        }, completion:nil)
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
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            
        }, completion:nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
