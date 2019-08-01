//
//  InviteFriends.swift
//  AIScribe
//
//  Created by Randall Ridley on 8/24/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit
import Contacts
import FBSDKLoginKit
import FBSDKCoreKit
import Social
import MessageUI

class InviteFriends: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKLoginButtonDelegate, MFMessageComposeViewControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var inviteList = [NSDictionary]()
    var facebookList = [NSDictionary]()
    
    var selectedPhoneList = [String]()
    var selectedEmailList = [String]()
    
    //var contactsList = [NSDictionary]()
    var contactsList = [CNContact]()
    
    var selectedInviteList = [NSDictionary]()
    var selectedFacebookList = [NSDictionary]()
    //var selectedContactsList = [NSDictionary]()
    var selectedContactsList = [CNContact]()
    
    var inviteMode : Int?
    var item : NSDictionary?
    var item1 : CNContact?
    @IBOutlet weak var requestsTable: UITableView!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var nameTxt: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var instructionLbl: UILabel!
    
    @IBOutlet weak var micBtn: UIButton!
    @IBOutlet weak var instructionHeight: NSLayoutConstraint!
    
    var dict2 : [String : AnyObject]?
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var emailsStr : String?
    var phonesStr : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        inviteMode = 0
        
        requestsTable.dataSource = self
        requestsTable.delegate = self
        requestsTable.tableFooterView = UIView()
        
        instructionHeight.constant = 0
        separatorView.isHidden = true
        micBtn.isHidden = false
        emailLbl.isHidden = true
        
        activityView.isHidden = true
        
        sendBtn.backgroundColor = appDelegate.crWarmGray
        sendBtn.isEnabled = false
        
//        if FBSDKAccessToken.current() != nil {
//
//            print("has logged into FB")
//
//            getFBFriends()
//        }
        
        //debug()
        
        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            btnItem]
        
        numberToolbar.sizeToFit()
        
        nameTxt.inputAccessoryView = numberToolbar
        
        getContacts()
        //getFBFriends()
        
//        if FBSDKAccessToken.current() != nil {
//
//            print("has logged into FB")
//
//            self.logUserData()
//        }

        // Do any additional setup after loading the view.
    }
    
//    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//
//        print("logged in")
//    }
//
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//
//        print("logged out")
//    }
    
    // MARK: Actions
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("logged in")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("logged out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        print("result: \(result)")
        
        if let error = error
        {
            print(error.localizedDescription)
            return
        }
        
        //self.logUserData()
    }
    
    @IBAction func loginFB(_ sender: Any) {
        
        //http://www.oodlestechnologies.com/blogs/How-To-Integrate-Facebook-iOS-Application-In-swift-4
        
//        FacebookSignInManager.basicInfoWithCompletionHandler(self) { (dataDictionary:Dictionary<String, AnyObject>?, error:NSError?) -> Void in
//
//            print("dataDictionary: \(dataDictionary!)")
//
//            self.appDelegate.firstname = dataDictionary!["first_name"] as! String
//            self.appDelegate.lastname = dataDictionary!["last_name"] as! String
//            self.appDelegate.email = dataDictionary!["email"] as! String
//            self.appDelegate.fbID = dataDictionary!["id"] as? String
//            let pic =  dataDictionary!["picture"] as! NSDictionary
//            let data =  pic["data"] as! NSDictionary
////
////            self.appDelegate.profileImg = data["url"] as? String
//        }
        
        
        
        
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//
//        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//
//            if (error == nil){
//
//                let fbloginresult : FBSDKLoginManagerLoginResult = result!
//                if fbloginresult.grantedPermissions != nil {
//                    if(fbloginresult.grantedPermissions.contains("email")) {
//
//                        if((FBSDKAccessToken.current()) != nil){
//
//                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
//                                if (error == nil){
//                                    self.dict2 = result as! [String : AnyObject]
//
//                                    //print(result!)
//                                    print("dict: \(self.dict2)")
//
//                                    self.getFBFriends()
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        }
    }
    
    var inviteVals : [String:String]?
    
    @IBAction func sendInvites(_ sender: Any) {
        
        emailsStr = (selectedEmailList.map{String($0)}).joined(separator: ",")
        phonesStr = (selectedPhoneList.map{String($0)}).joined(separator: ",")
        
        print("emailsStr: \(emailsStr!)")
        print("phonesStr: \(phonesStr!)")
        
        inviteVals  = ["emailsStr" : emailsStr!, "phonesStr" : phonesStr!, "inviteMode" : "2"]
                
        //NotificationCenter.default.post(name: Notification.Name("invitesSentNotification"), object: dict)
        
        if selectedPhoneList.count > 0
        {
            sendSMS()
        }
        else
        {
           sendInvites()
        }
    }
    
    func sendEmailInvites() {
        
        //emailsStr = ""
        
        print("sendEmailInvites")
        
        let dataString = "emailInvitesData"
        
        let urlString = "\(appDelegate.serverDestination!)sendEmailInvites.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&emailsStr=\(emailsStr!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("friend requests jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.recipeStatusTV.isHidden = false
                    })
                }
                else
                {
                    let uploadData : NSDictionary = dataDict[dataString]! as! NSDictionary
                    
                    print("uploadData: \(uploadData)")
                    
                    let status = uploadData.object(forKey: "status") as! String
                    
                    var isSaved = false
                    
                    //to do
                    
                    if status == "email invites sent"
                    {
                        isSaved = true
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
        }.resume()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectItem(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        manageButton(btn: btn)
    }
    
    @IBAction func changeInviteMode(_ sender: Any) {
        
        let btn = sender as? UIButton
        
        inviteMode = Int((btn?.restorationIdentifier!)!)
        
        if inviteMode != 2
        {
            instructionHeight.constant = 0
            separatorView.isHidden = true
            micBtn.isHidden = false
            emailLbl.isHidden = true
            nameTxt.borderStyle = .roundedRect
            nameTxt.placeholder = "Search in Friends"
        }
        else
        {
            separatorView.isHidden = false
            instructionHeight.constant = 58
            micBtn.isHidden = true
            emailLbl.isHidden = false
            nameTxt.borderStyle = .none
            nameTxt.placeholder = "enter email (eg. name@email.com)"
        }
        
        requestsTable.reloadData()
    }
    
    func cellUpdateBtn (btn: UIButton) {
        
        let ind = Int(btn.restorationIdentifier!)
        
        if inviteMode == 0
        {
            item = facebookList[ind!]
            
            if selectedFacebookList.contains(item!)
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
            }
            else
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal)
            }
        }
        else if inviteMode == 1
        {
            item1 = contactsList[ind!]
            
//            if selectedContactsList.contains(item1!)
//            {
//                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
//            }
//            else
//            {
//                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal)
//            }
            
            
            
            var ind = 0
            var hasPhone = false
            
            for phone in selectedPhoneList
            {
                if let phone1 = item1?.phoneNumbers[0]
                {
                    if phone1.value.stringValue == phone
                    {
                        hasPhone = true
                    }
                }
                
                ind += 1
            }
            
            ind = 0
            
            var hasEmail = false
            
            for email in selectedEmailList
            {
                if let email1 = item1?.emailAddresses[0]
                {
                    if email1.value as String == email
                    {
                        hasEmail = true
                    }
                }
                
                ind += 1
            }
            
            if hasPhone == false && hasEmail == false
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "light"), for: .normal)
            }
            else
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal)
            }
        }
        else
        {
            item = inviteList[ind!]
            
            if selectedInviteList.contains(item!)
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
            }
            else
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal)
            }
        }
    }
    
    func manageButton (btn: UIButton) {
        
        let ind = Int(btn.restorationIdentifier!)
        
        if inviteMode == 0
        {
            item = facebookList[ind!]
            
            if selectedFacebookList.contains(item!)
            {
                let ind2 = selectedFacebookList.index(of: item!)
                
                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal) //replace with check
                selectedFacebookList.remove(at: ind2!)
                
                self.disableSendBtn()
            }
            else
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
                selectedFacebookList.append(item!)
            }
        }
        else if inviteMode == 1
        {
            item1 = contactsList[ind!]
            
            //disable button and remove selected contact
            
            if selectedContactsList.contains(item1!)
            {
                let ind2 = selectedContactsList.index(of: item1!)
                
                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal) //replace with check
                selectedContactsList.remove(at: ind2!)
                
                self.disableSendBtn()
                
                //remove selected phone number
                
                if (item1?.phoneNumbers.count)! > 0 {
                    
                    var ind = 0
                    
                    for phone in selectedPhoneList
                    {
                        if let phone1 = self.item1?.phoneNumbers[0]
                        {
                            if phone1.value.stringValue == phone
                            {
                                self.selectedPhoneList.remove(at: ind)
                                
                                print("remove phone")
                            }
                        }
                        
                        ind += 1
                    }
                }
                
                //remove selected email
                
                if (item1?.emailAddresses.count)! > 0 {
                    
                    var ind = 0
                    
                    for email in selectedEmailList
                    {
                        if let email1 = self.item1?.emailAddresses[0]
                        {
                            if email1.value as String == email
                            {
                                self.selectedEmailList.remove(at: ind)
                                
                                print("remove email")
                            }
                        }
                        
                        ind += 1
                    }
                }
            }
            else
            {
                
                //add contact
                
                //                if contact.phoneNumbers.count > 0 {
                //                    self.txtP1.text = (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as? String
                //                } else {
                //                    self.txtP1.text = ""
                //                }
                
                let alert = UIAlertController(title: "Share Contact", message: "Please select", preferredStyle: UIAlertControllerStyle.alert)
                
                self.present(alert, animated: true, completion: nil)
                
                if (item1?.phoneNumbers.count)! > 0 {
                    
                    alert.addAction(UIAlertAction(title: "Phone", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                            btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
                            self.selectedContactsList.append(self.item1!)
                            
                            if let phone = self.item1?.phoneNumbers[0]
                            {
                                print("phone: \(phone.value.stringValue)")
                                self.selectedPhoneList.append(phone.value.stringValue as String)
                                
                                self.enableSendBtn()
                            }
                            else
                            {
                                print("na phone")
                            }
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                        }
                    }))
                }
                
                if (item1?.emailAddresses.count)! > 0 {
                    
                    alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                            btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
                            self.selectedContactsList.append(self.item1!)
                            
                            if let email = self.item1?.emailAddresses[0]
                            {
                                print("email: \(email.value)")
                                
                                self.selectedEmailList.append(email.value as String)
                                
                                self.enableSendBtn()
                            }
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                        }
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
            }
            
            print("selectedContactsList: \(selectedContactsList.count)")
        }
        else
        {
            item = inviteList[ind!]
            
            if selectedInviteList.contains(item!)
            {
                let ind2 = selectedInviteList.index(of: item!)
                
                btn.setBackgroundImage(#imageLiteral(resourceName: "plus-normal"), for: .normal) //replace with check
                selectedInviteList.remove(at: ind2!)
                
                self.disableSendBtn()
            }
            else
            {
                btn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal) //replace with check
                selectedInviteList.append(item!)
            }
        }
    }
    
    func sendSMS () {
        
        if (MFMessageComposeViewController.canSendText()) {
            
            let controller = MFMessageComposeViewController()
            controller.body = "Download Chewsrite at http://aiscribelink.com and use my signup code: \(self.appDelegate.referralCode!)..."
            //controller.recipients = [phoneNumber.text]
            controller.messageComposeDelegate = self
            controller.recipients = selectedPhoneList
            self.present(controller, animated: true, completion: nil)
            
        } else {
            
            // show failure alert
            
            selectedPhoneList.removeAll()
            requestsTable.reloadData()
            
            
            
            let alert = UIAlertController(title: nil, message: "Texting is not allowed on this device.", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                    if self.selectedEmailList.count > 0
                    {
                        self.sendInvites()
                    }
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                }
            }))
        }
    }
    
    // MARK: Text Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        print("message UI dismiss with error")
        
        controller.dismiss(animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        print("message UI dismiss")
        
        controller.dismiss(animated: true)
        
        if selectedEmailList.count > 0
        {
            sendInvites()
        }
    }
    
    func enableSendBtn () {
        
        sendBtn.backgroundColor = appDelegate.crLightBlue
        sendBtn.isEnabled = true
    }
    
    func disableSendBtn () {
        
        if selectedFacebookList.count == 0 && selectedContactsList.count == 0 && selectedEmailList.count == 0
        {
            sendBtn.backgroundColor = appDelegate.crWarmGray
            sendBtn.isEnabled = false
        }
    }
    
    // MARK: Query
    
    func getFBFriends () {
        
        let params = ["fields": "id, first_name, last_name, name, email, picture"]
        
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            
            if error == nil {
                
                if let userData = result as? [String:Any] {
                    print("friends: \(userData)")
                }
                
            } else {
                print("Error Getting Friends \(error)");
            }
            
        })
        
        connection.start()
    }
    
    func getContacts () {
        
        let contactStore = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactPhoneNumbersKey,
                           CNContactEmailAddressesKey] as [Any]
        
        // The container means
        // that the source the contacts from, such as Exchange and iCloud
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        //var contacts: [CNContact] = []
        
        // Loop the containers
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                // Put them into "contacts"
                self.contactsList.append(contentsOf: containerResults)
                
                //print("containerResults: \(containerResults)\n")
                
            } catch {
                print("Error fetching results for container")
            }
        }
        
        for contact in contactsList
        {
            //print("contact: \(contact.givenName) \(contact.familyName)")
        }        
    }
    
    @objc func dismissKeyboard () {
        
        var dict : NSMutableDictionary?
        
        if inviteMode == 2
        {
            if nameTxt.text != ""
            {
                dict  = ["friendname" : nameTxt.text!,"serving" : "2 oz", "active" : true]
                inviteList.append(dict!)
                selectedInviteList.append(dict!)
                selectedEmailList.append(nameTxt.text!)
                
                nameTxt.text = ""
                
                self.enableSendBtn()
            }
        }
        else
        {
            //self.selectedEmailList.append(email as String)
        }
        
        requestsTable.reloadData()
        
        self.view.endEditing(true)
    }
    
    func sendInvites() {
        
        print("sendInvites")
        
        let dataString = "inviteData"
        
        let urlString = "\(appDelegate.serverDestination!)sendInvites.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&emails=\(emailsStr!)&phones=\(phonesStr!)&inviteMode=\(inviteMode!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print("recipes jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //                        self.activityView.stopAnimating()
                        //                        self.activityView.isHidden = true
                    })
                    
                }
                else
                {
                    let uploadData : NSDictionary = dataDict[dataString]! as! NSDictionary
                    
                    print("uploadData: \(uploadData)")
                    
                    let status = uploadData.object(forKey: "status") as! String
                    
                    var isSaved = false
                    
                    if status == "invites sent"
                    {
                        isSaved = true
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        
                        if isSaved == true
                        {
                            //let dict  = ["emailsStr" : self.emailsStr!, "phonesStr" : self.phonesStr!]
                            
                            self.handleSave()
                        }
                        else
                        {
                            print("save error")
                            
                            let alert = UIAlertController(title: nil, message: "Save Error", preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                }
                            }))
                        }
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
        }.resume()
    }
    
    func handleSave() {
        
        NotificationCenter.default.post(name: Notification.Name("invitesSentNotification"), object: inviteVals)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func debug () {
        
        var dict : NSMutableDictionary = ["friendname" : "Joe Blow","serving" : "1 oz", "active" : false]
        facebookList.append(dict)
        
        dict  = ["friendname" : "Kim Slut","serving" : "2 oz", "active" : false]
        facebookList.append(dict)
        
//        dict  = ["friendname" : "Jane Ho","serving" : "2 oz", "active" : false]
//        contactsList.append(dict)
//
//        dict  = ["friendname" : "Lisa Tramp","serving" : "2 oz", "active" : false]
//        contactsList.append(dict)
        
        dict  = ["friendname" : "ra_rid@yahoo.com","serving" : "2 oz", "active" : false]
        inviteList.append(dict)
        
        dict  = ["friendname" : "ridley@yahoo.com","serving" : "2 oz", "active" : false]
        inviteList.append(dict)
        
        requestsTable.reloadData()
    }
    
    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inviteMode == 0
        {
            return self.facebookList.count
        }
        else if inviteMode == 1
        {
            return self.contactsList.count
        }
        else
        {
            return self.inviteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! FriendRequestCell
        
        var dict : NSDictionary?
        var dict1 : CNContact?
        
        var friendname = ""
        
        if inviteMode == 0
        {
            dict = self.facebookList[(indexPath as NSIndexPath).row] as NSDictionary
            friendname = dict?.object(forKey: "friendname") as! String
        }
        else if inviteMode == 1
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")! as! FriendRequestCell
            
            dict1 = self.contactsList[(indexPath as NSIndexPath).row] as CNContact
            
//            var ind = 0
//            var hasPhone = false
//
//            for phone in selectedPhoneList
//            {
//                if let phone1 = dict1?.phoneNumbers[0]
//                {
//                    if phone1.value.stringValue == phone
//                    {
//                        hasPhone = true
//                    }
//                }
//
//                ind += 1
//            }
//
//            ind = 0
//
//            var hasEmail = false
//
//            for email in selectedEmailList
//            {
//                if let email1 = self.item1?.emailAddresses[0]
//                {
//                    if email1.value as String == email
//                    {
//                        hasEmail = true
//                    }
//                }
//
//                ind += 1
//            }
//
//            if hasPhone == false && hasEmail == false
//            {
//                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "light"), for: .normal)
//            }
//            else
//            {
//                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal)
//            }

            

            
//            var hasEmail = false
//
//            if let a = dict1?.emailAddresses[0].value {
//
//                hasEmail = true
//            }
//
//            var hasPhone = false
//
//            if let b = dict1?.phoneNumbers[0].value.stringValue {
//
//                hasPhone = true
//            }
            
//            if !selectedEmailList.contains(dict1?.emailAddresses[0].value as String) && !selectedPhoneList.contains(dict1?.phoneNumbers[0].value.stringValue as String)
//            {
//                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "light"), for: .normal)
//            }
//            else
//            {
//                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal)
//            }
            
            //cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "light"), for: .normal)
            
            let fn = dict1?.givenName
            let ln = dict1?.familyName
            
//            if let phone = dict1?.phoneNumbers[0]
//            {
//                print("phone: \(phone.value.stringValue)")
//            }
//            else
//            {
//                print("na phone")
//            }
            
//            if let email = dict1?.emailAddresses[0]
//            {
//                print("email: \(email.value)")
//            }
//            else
//            {
//                print("na email")
//            }
            
            friendname = "\(fn!) \(ln!)"
        }
        else
        {
            dict = self.inviteList[(indexPath as NSIndexPath).row] as NSDictionary
            friendname = dict?.object(forKey: "friendname") as! String
        }
        
        if inviteMode == 0
        {
            cell.friendIV.image = UIImage.init(named: (dict?.object(forKey: "friendname") as? String)!)
            cell.friendIV.image = #imageLiteral(resourceName: "risotto")
        }
        else if inviteMode == 2
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")! as! FriendRequestCell
            
            if dict?.object(forKey: "active") as! Bool == true
            {
                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "checkGreen"), for: .normal)
            }
            else
            {
                cell.requestBtn.setBackgroundImage(#imageLiteral(resourceName: "light"), for: .normal)
            }
            //cell.friendIV.image = nil
        }
        
        cell.selectionStyle = .none
        
        cell.nameLbl.text = friendname
        
        cell.requestBtn.restorationIdentifier = "\(indexPath.row)"
        cell.requestBtn.addTarget(self, action: #selector(self.selectItem(_:)), for: UIControlEvents.touchUpInside)
        
        cellUpdateBtn(btn: cell.requestBtn)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
