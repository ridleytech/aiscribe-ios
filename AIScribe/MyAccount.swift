//
//  MyAccount.swift
//  AIScribe
//
//  Created by DTO MacBook11 on 11/15/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit
import AWSS3

class MyAccount: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var prefsList = [NSDictionary]()//["Diet", "Nutrition Goals", "Notifications"]
    var moreList  = [NSDictionary]()//["About Us", "Recommend App", "Feedback", "Legal Information"]
    
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        accountTable.delegate = self
        accountTable.dataSource = self
        accountTable.tableFooterView = UIView()
        accountTable.separatorStyle = .none
        
        menuBtn.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
//        let tb : TabController = self.parent as! TabController
//
//        menuBtn.addTarget(self, action: #selector(tb.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
//        prefsList.append(["title":"Diet", "icon":"diet"])
//        prefsList.append(["title":"Nutrition Goals", "icon":"nutrition-goals"])
//        prefsList.append(["title":"Notifications", "icon":"notifications"])
        
        //moreList.append(["title":"About Us", "icon":"about-us"])
        //moreList.append(["title":"Recommend App", "icon":"recommend-app"])
        moreList.append(["title":"Feedback", "icon":"feedback"])
        //moreList.append(["title":"Legal Information", "icon":"legal"])
        
        accountTable.reloadData()
    }
    
    // MARK: Tableview Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 || section == 2
        {
            return 44
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 || section == 2
        {
            let headerView = Bundle.main.loadNibNamed("MemberHeaderCell", owner: self, options: nil)?.first as! MemberHeaderCell
            
            if section == 1
            {
                headerView.headerLbl.text = "MORE"
            }
//            else
//            {
//                headerView.headerLbl.text = "MORE"
//            }
            
            headerView.headerLbl.textColor = appDelegate.gray51
            
            let font1 = UIFont.init(name: "Avenir-Heavy", size: 16.0)
            
            headerView.headerLbl.font = font1
            
            headerView.leadingWidth.constant = 20
            
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && indexPath.section == 0
        {
            return 88
        }
        else
        {
            return 62
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell?
       
        //print("indexPath.row: \(indexPath.row) indexPath.section: \(indexPath.section)")
        
        if indexPath.section == 0
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")!
            
            let lblTitle = cell?.contentView.viewWithTag(1) as! UILabel
            
            //lblTitle.text = "\(appDelegate.firstname!) \(appDelegate.lastname!)"
            lblTitle.text = "\(appDelegate.username!)"
            
//            if indexPath.row == 0
//            {
//                cell = tableView.dequeueReusableCell(withIdentifier: "cell1")!
//
//                let lblTitle = cell?.contentView.viewWithTag(1) as! UILabel
//
//                //lblTitle.text = "\(appDelegate.firstname!) \(appDelegate.lastname!)"
//                lblTitle.text = "\(appDelegate.username!)"
//
////                let imgIcon = cell?.contentView.viewWithTag(0) as! UIImageView
////                imgIcon.image = appDelegate.userImage
//            }
//            else
//            {
//                cell = tableView.dequeueReusableCell(withIdentifier: "cell2")!
//            }
        }
//        else if indexPath.section == 1 {
//
//            cell = tableView.dequeueReusableCell(withIdentifier: "cell3")!
//
//            let lblTitle = cell?.contentView.viewWithTag(1) as! UILabel
//            let imgIcon = cell?.contentView.viewWithTag(0) as! UIImageView
//            let separator = cell?.contentView.viewWithTag(3) as! UIView
//
//            lblTitle.text = prefsList[indexPath.row].object(forKey: "title") as? String
//            imgIcon.image = UIImage.init(named: prefsList[indexPath.row].object(forKey: "icon") as! String)
//
//            if indexPath.row == 2
//            {
//                separator.isHidden = true
//            }
//        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell3")!
            
            let lblTitle = cell?.contentView.viewWithTag(1) as! UILabel
            let imgIcon = cell?.contentView.viewWithTag(0) as! UIImageView
            let separator = cell?.contentView.viewWithTag(3) as! UIView
            
            lblTitle.text = moreList[indexPath.row].object(forKey: "title") as? String
            imgIcon.image = UIImage.init(named: moreList[indexPath.row].object(forKey: "icon") as! String)
            
            if indexPath.row == 3
            {
                separator.isHidden = true
            }
        }
        
        cell?.selectionStyle = UITableViewCellSelectionStyle.none

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && indexPath.section == 0
        {
            self.performSegue(withIdentifier: "EditProfile", sender: nil)
        }
//        else if indexPath.row == 0 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "EditDiet", sender: nil)
//        }
//        else if indexPath.row == 1 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "NutritionGoals", sender: nil)
//        }
//        else if indexPath.row == 2 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "Notifications", sender: nil)
//        }
//        else if indexPath.row == 0 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "AboutUs", sender: nil)
//        }
//        else if indexPath.row == 0 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "RecommendApp", sender: nil)
//        }
        else if indexPath.row == 0 && indexPath.section == 1
        {
            self.performSegue(withIdentifier: "Feedback", sender: nil)
        }
//        else if indexPath.row == 3 && indexPath.section == 1
//        {
//            self.performSegue(withIdentifier: "Terms", sender: nil)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
            //return 2
            return 1
        }
//        else if section == 1
//        {
//            return prefsList.count
//        }
        else
        {
            return moreList.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2;
    }
    
    func downloadImage (imagename : String, iv: UIImageView) {
        
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
                    
                    iv.image = image
                }
                
                //println("test")
            })
            return nil
        }))
            
        }
            else
            {
                iv.image = UIImage.init(named: "profile-icon")
            }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EditProfile"
        {
            let destination = segue.destination as! EditProfile
            //destination.newFamilyMemberID = newFamilyMemberID
            destination.isEditing = true
        }
    }
}
