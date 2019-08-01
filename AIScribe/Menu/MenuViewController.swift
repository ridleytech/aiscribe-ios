//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import AWSS3

protocol SlideMenuDelegate {
    
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userIV: UIImageView!
    @IBOutlet weak var premiumBtn: UIButton!
    
    var lastId : String?
    
    
    
    @IBAction func closeMenu(_ sender: Any) {
        
    }
    
    @IBAction func goPremium(_ sender: Any) {
        
        self.openViewControllerBasedOnIdentifier("Premium")
        
        delegate?.slideMenuItemSelectedAtIndex(6)
    }
    
    /**
    *  Array to display menu options
    */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
    *  Array containing menu options
    */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    
    var delegate : SlideMenuDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        lastId = "tab controller"
        
        tblMenuOptions.separatorColor = .clear
                
        tblMenuOptions.tableFooterView = UIView()
        
        if appDelegate.userImage != nil
        {
            userIV.image = appDelegate.userImage
        }
        else if appDelegate.profileImg != nil && appDelegate.profileImg != ""
        {
            downloadImage(imagename: appDelegate.profileImg!)
        }
        else
        {
            appDelegate.userImage = UIImage(named: "profile-icon")
            userIV.image = appDelegate.userImage
        }
        
        if appDelegate.firstname != nil && appDelegate.lastname != nil
        {
            nameLbl.text = "\(appDelegate.firstname!) \(appDelegate.lastname!)"
        }
        else
        {
            nameLbl.text = ""
        }
        
        if appDelegate.fullVersion == true
        {
            premiumBtn.isHidden = true
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appUpgradeNotification),
            name: NSNotification.Name(rawValue: "appUpgraded"),
            object: nil)
    }
    
    @objc func appUpgradeNotification (notification: NSNotification) {
        
        print("upgrade app UI")
        
        premiumBtn.isHidden = true
        tblMenuOptions.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        
        arrayMenuOptions.append(["title":"My Files","subtitle":"View your transcribed files.", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"My Corpora","subtitle":"Creating a corpus allows you to expand the vocabulary of your transcription service.", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"My Account","subtitle":"Edit your profile, password, preferences and more.", "icon":"PlayIcon"])
        arrayMenuOptions.append(["title":"Logout", "subtitle":"", "icon":"PlayIcon"])
        
        tblMenuOptions.reloadData()
    }
    
    @IBAction func onCloseMenuClick(_ button:UIButton!){
        
        //self.tabBarController?.tabBar.isHidden = true
        
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            
            var index = Int32(button.tag)
            
            if(button == self.btnCloseMenuOverlay)
            {
                index = -1
            }
            
            if appDelegate.fullVersion == false
            {
                if index == 3 || index == 4
                {
                    return
                }
            }
            
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
                
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // old slider logic
        
        let btn = UIButton(type: UIButtonType.custom)
        btn.tag = indexPath.row
        self.onCloseMenuClick(btn)
        
        //NotificationCenter.default.post(name: Notification.Name("closeNav"), object: indexPath.row)
        
        //new slider logic
        
        //newLogic(indexPath.row)
    }
    
    func newLogic (index : Int) {
        
        switch(index){
            
        case 0:
            
            print("Home1")
            
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

        if (lastId == destViewController.restorationIdentifier!){

            print("Same VC")

        } else {
            
            lastId = strIdentifier
            
            self.navigationController!.pushViewController(destViewController, animated: true)
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")! as! MenuTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        //cell.backgroundColor = UIColor.clear
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let lblTitle2 : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let lockIV : UIImageView = cell.contentView.viewWithTag(103) as! UIImageView
        //let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        //imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        lblTitle2.text = arrayMenuOptions[indexPath.row]["subtitle"]!
        
        if indexPath.row == 5
        {
            //cell.subheaderBottomPadding.constant = 0
            cell.subheaderHeight.constant = 5
        }
        
        if appDelegate.fullVersion == false
        {
            if indexPath.row == 3 || indexPath.row == 4
            {
                lockIV.isHidden = false
            }
            else
            {
                lockIV.isHidden = true
            }
        }
        else
        {
            lockIV.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayMenuOptions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1;
    }
    
    func downloadImage (imagename : String) {
        
        if appDelegate.downloadImages == true
        {
            let s3BucketName = "shotgraph1224/aiscribe"
            
            let downloadFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(imagename)
            let downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imagename)
            
            // Set the logging to verbose so we can see in the debug console what is happening
            //AWSLogger.default().logLevel = .none
            
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest?.bucket = s3BucketName
            downloadRequest?.key = imagename
            downloadRequest?.downloadingFileURL = downloadingFileURL
            
            let transferManager = AWSS3TransferManager.default()
            
            //[[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
            
            transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: ({
                (task: AWSTask!) -> AWSTask<AnyObject>? in
                
                DispatchQueue.main.async(execute: {
                    
                    if task.error != nil
                    {
                        print("AWS Error downloading image")
                        
                        print(task.error.debugDescription)
                    }
                    else
                    {
                        //print("AWS download successful")
                        
                        var downloadOutput = AWSS3TransferManagerDownloadOutput()
                        
                        downloadOutput = task.result! as? AWSS3TransferManagerDownloadOutput
                        
                        print("downloadOutput photo: \(downloadOutput)");
                        print("downloadFilePath photo: \(downloadFilePath)");
                        
                        let image = UIImage(contentsOfFile: downloadFilePath)
                        
                        self.userIV.image = image
                        self.appDelegate.userImage = image
                    }
                    
                    //println("test")
                })
                return nil
            }))
        }
        else
        {
            self.userIV.image = UIImage.init(named: "profile-icon")
        }
    }
        
}
