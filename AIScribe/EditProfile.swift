//
//  EditProfile.swift
//  AIScribe
//
//  Created by Randall Ridley on 11/6/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit
import AWSS3

class EditProfile: BaseViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate

     let prefs = UserDefaults.standard
     
     @IBOutlet weak var activityView: UIActivityIndicatorView!

     @IBOutlet weak var submitBtn: UIButton!
     @IBOutlet weak var backBtn: UIButton!

     @IBOutlet weak var instructionsLbl: UILabel!

     @IBOutlet weak var usernameLbl: UILabel!
     @IBOutlet weak var usernameTxt: UITextField!
    
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var firstnameLbl: UILabel!
    @IBOutlet weak var lastnameLbl: UILabel!
    
    @IBOutlet weak var firstnameTxt: UITextField!
    @IBOutlet weak var lastnameTxt: UITextField!

    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
     
     @IBOutlet weak var dobTxtTopPadding: NSLayoutConstraint!
     @IBOutlet weak var fullnameTxtTopPadding: NSLayoutConstraint!

    @IBOutlet weak var lastnameTopPadding: NSLayoutConstraint!
    @IBOutlet weak var firstnameTopPadding: NSLayoutConstraint!
    
     @IBOutlet weak var imageIV : UIImageView!

     var selectedDate : String?

     var imagePicker : UIImagePickerController!
     var selectedImage : UIImage?

     var statusImageCache = [String:UIImage]()

     var inviteList : String?
     var uploadImageName : String?

    @IBOutlet weak var profileBtn: UIButton!
     
     var validateFields : [UITextField]?
    
    @IBOutlet weak var contentSV: UIScrollView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
  
        dobTxtTopPadding.constant = 0
     
          validateFields = [firstnameTxt,lastnameTxt, emailTxt, passwordTxt,usernameTxt]

//          if appDelegate.userImage != nil
//          {
//               profileBtn.setBackgroundImage(appDelegate.userImage, for: .normal)
//          }
//          else if appDelegate.profileImg != ""
//          {
//               downloadImage(imagename: appDelegate.profileImg!)
//          }
     
          creditsLbl.text = "$\(self.appDelegate.credits!)"

          getProfileInfo()
     
        //years in days * seconds in a day
        
        //let d = Date(timeInterval: -6570*86400, since: NSDate() as Date)
        
        //dobPicker.setDate(NSDate() as Date, animated: false)
     
     
     usernameLbl.isHidden = false
     
        firstnameLbl.isHidden = true
        lastnameLbl.isHidden = true
        emailLbl.isHidden = true
        passwordLbl.isHidden = true
     
     usernameTxt.isUserInteractionEnabled = false
     
//          let v = UIView.init(frame: CGRect.init(x: 0, y: profileBtn.frame.height-25, width: 300, height: 50))
//          v.backgroundColor = .white
//          v.isUserInteractionEnabled = false
//
//          profileBtn.addSubview(v)
     
//        let attributedString = NSMutableAttributedString(string: "* You can change this from your Account Settings", attributes: [
//            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
//            .foregroundColor: appDelegate.crWarmGray
//            ])
//        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Heavy", size: 12.0)!, range: NSRange(location: 32, length: 16))
     
        //instructionsLbl.attributedText = attributedString
        
        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            btnItem]
        
        numberToolbar.sizeToFit()
        
        emailTxt.inputAccessoryView = numberToolbar
        passwordTxt.inputAccessoryView = numberToolbar
        usernameTxt.inputAccessoryView = numberToolbar
        firstnameTxt.inputAccessoryView = numberToolbar
        lastnameTxt.inputAccessoryView = numberToolbar
     
     NotificationCenter.default.addObserver(
          self,
          selector: #selector(updateCreditsNotification),
          name: NSNotification.Name(rawValue: "updateCredits"),
          object: nil)
     }
     
     @objc func updateCreditsNotification (notification: NSNotification) {
          
          let credits = notification.object as! String
          
          creditsLbl.text = "$\(credits)"

          contentSV.scrollRectToVisible(CGRect.init(x: 0, y: lastnameTxt.frame.origin.y, width: contentSV.frame.width, height: contentSV.frame.height), animated: false)
     }
     
     override func viewDidLayoutSubviews() {
          
          contentSV.contentSize = CGSize.init(width: contentSV.frame.width, height: 1000)
     }

     @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
     }
     
     // MARK: Actions

     @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
     }

     @IBAction func saveInfo(_ sender: Any) {
          
          for field in validateFields!
          {
               if field.text == ""
               {
                    self.showBasicAlert(string: "Please enter \(field.restorationIdentifier)")
                    return
               }
          }
        
        self.uploadUserData()
     }

     func showBasicAlert(string:String)
     {
        let alert = UIAlertController(title: nil, message: string, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
               
            case .default:
                print("default")
               
            case .cancel:
                print("cancel")
               
            case .destructive:
                print("destructive")
            }
        }))
     }

     @IBAction func selectPhoto(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: "Change your profile picture", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Open Photo Library", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
                self.choosePhoto()
               
            case .cancel:
                print("cancel")
               
            case .destructive:
                print("destructive")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
                self.takePhoto()
               
            case .cancel:
                print("cancel")
               
            case .destructive:
                print("destructive")
            }
        }))
        
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

     // MARK: Image Picker

     func takePhoto () {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
          
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
          
            self.present(imagePicker, animated: true, completion: nil)
        }
     }

     func choosePhoto () {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
          
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
          
            self.present(imagePicker, animated: true, completion: nil)
        }
     }

     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("cancel")
     }

     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("did pick")
        
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        imageIV.image = selectedImage
        
        self.dismiss(animated: true, completion: {
          
          self.uploadS3()
          
            //self.uploadToServer(name:"registration-\(self.appDelegate.userid!)")
        });
     }
     
     // MARK: Web service

     func uploadS3 () {
        
        if appDelegate.profileImg == ""
        {
            uploadImageName = "\(appDelegate.randomString(length: 10)).jpeg"
        }
        else
        {
            uploadImageName = appDelegate.profileImg
        }
        
        let image = selectedImage!
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(uploadImageName!)
        let imageData = UIImageJPEGRepresentation(image, 0)
        fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        let fileUrl = NSURL(fileURLWithPath: path)
        
        print("upload")
        
        let transferManager = AWSS3TransferManager.default()
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = "shotgraph1224/aiscribe"
        uploadRequest!.key = uploadImageName
        uploadRequest?.body = fileUrl as URL
        uploadRequest?.contentType = "image/jpeg"
        
        uploadRequest?.acl = AWSS3ObjectCannedACL.publicReadWrite;
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
          
            if let error = task.error as NSError? {
               
                if error.domain == AWSS3TransferManagerErrorDomain,
                    
                    let code = AWSS3TransferManagerErrorType(rawValue: error.code)
                {
                    switch code
                    {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading 1: \(uploadRequest?.key!) Error: \(error)")
                    }
                }
                else
                {
                    print("Error uploading: \(uploadRequest?.key!) Code: \(error.code) Error: \(error)")
                }
               
                return nil
            }
          
            //let uploadOutput = task.result
          
            print("Upload complete for: \(uploadRequest!.key!)")
          
            //self.updateUserImage()
          
            return nil
        })
     }
     
     func getProfileInfo () {
          
          print("getProfileInfo")
          
          let urlString = "\(appDelegate.serverDestination!)getProfileInfo.php"
          
          print("urlString: \(urlString)")
          
          let url = URL(string: urlString)
          
          var request = URLRequest(url: url!)
          
          request.httpMethod = "POST"
          
          let paramString = "uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true&devStatus=\(appDelegate.devStage!)"
          
          print("paramString: \(paramString)")
          
          request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
          
          let session = URLSession.shared
          
          session.dataTask(with: request) {data, response, err in
               
               do {
                    
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    
                    print("profile jsonResult: \(jsonResult)")
                    
                    let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                    
                    if dataDict["profileData"]! is NSNull
                    {
                         print("no user")
                    }
                    else
                    {
                         let uploadData : NSDictionary = dataDict["profileData"] as! NSDictionary
                        
                         let firstname = uploadData.object(forKey: "firstname") as? String
                         let lastname = uploadData.object(forKey: "lastname") as? String
                         let email = uploadData.object(forKey: "email") as? String
                         let password = uploadData.object(forKey: "password") as? String
                         let username = uploadData.object(forKey: "username") as? String
                         //let credits = uploadData.object(forKey: "credits") as? String
                      
                         DispatchQueue.main.sync(execute: {
                              
                              self.firstnameLbl.isHidden = false
                              self.lastnameLbl.isHidden = false
                              self.emailLbl.isHidden = false
                              self.passwordLbl.isHidden = false
                              
                              self.firstnameTxt.text = "\(firstname!)"
                              self.lastnameTxt.text = "\(lastname!)"
                              self.emailTxt.text = "\(email!)"
                              self.passwordTxt.text = "\(password!)"
                              self.usernameTxt.text = "\(username!)"
                              //self.creditsLbl.text = "$\(self.appDelegate.credits!)"
                              self.emailTxt.text = uploadData.object(forKey: "email") as? String
                         })
                    }
               }
               catch let err as NSError
               {
                    print("error: \(err.description)")
               }
               
          }.resume()
     }

     func updateUserImage () {
        
        print("updateUserImage")
        
        let urlString = "\(appDelegate.serverDestination!)updateProfileImage.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&userimage=\(uploadImageName!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
          
            do {
               
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
               
                print("image jsonResult: \(jsonResult)")
               
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
               
                if dataDict["userImageData"]! is NSNull
                {
                    print("no user")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["userImageData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "profile image saved")
                    {
                        
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                         
                            self.showBasicAlert(string: "Profile image not saved. Please check your internet connection.")
                        })
                    }
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
          
          }.resume()
     }

     func uploadUserData() {
        
          submitBtn.isEnabled = false

          activityView.isHidden = false
          activityView.startAnimating()

          print("uploadUserData")

          let urlString = "\(appDelegate.serverDestination!)updateProfile.php"

          print("urlString: \(urlString)")

          let url = URL(string: urlString)

          var request = URLRequest(url: url!)

          request.httpMethod = "POST"

        var paramString = "firstname=\(firstnameTxt.text!)&lastname=\(lastnameTxt.text!)&email=\(emailTxt.text!)&password=\(passwordTxt.text!)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"

          if self.isEditing == true
          {
               paramString = "\(paramString)&updating=true"
          }
          else
          {
               paramString = "\(paramString)&basicprofile=true"
          }

          //paramString = "\(paramString)&basicprofile=true"

          print("paramString: \(paramString)")

          request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

          let session = URLSession.shared

          session.dataTask(with: request) {data, response, err in

            do {
               
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
               
                print("add user jsonResult: \(jsonResult)")
               
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
               
                if dataDict["userData"]! is NSNull
                {
                    print("no user")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["userData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "profile updated")
                    {
                         DispatchQueue.main.sync(execute: {
                              
                              self.activityView.isHidden = true
                              self.activityView.stopAnimating()
                              
                              self.appDelegate.firstname = self.firstnameTxt.text!
                              self.appDelegate.lastname = self.lastnameTxt.text!
                              self.appDelegate.email = self.emailTxt.text!
                              self.appDelegate.password = self.passwordTxt.text!
                              
                              if self.appDelegate.firstname != nil {
                                   self.prefs.setValue(self.appDelegate.firstname , forKey: "firstname")
                              }
                              if self.appDelegate.lastname != nil {
                                   self.prefs.setValue(self.appDelegate.lastname , forKey: "lastname")
                              }
                              
                              if self.appDelegate.email != nil {
                                   self.prefs.setValue(self.appDelegate.email , forKey: "email")
                              }
                              
                              if self.appDelegate.password != nil {
                                   self.prefs.setValue(self.appDelegate.password , forKey: "password")
                              }
                              
                              self.prefs.synchronize()
                              
                              self.showBasicAlert(string: "Profile updated")
                         })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                         
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                         
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                         
                            self.showBasicAlert(string: status)
                        })
                    }
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }

          }.resume()
     }
     
     // MARK: Textfield Delegate
     
     func textFieldDidEndEditing(_ textField: UITextField) {
          
          if textField.restorationIdentifier == "firstname" && textField.text != ""
          {
               firstnameLbl.isHidden = false
          }
          else if textField.restorationIdentifier == "lastname" && textField.text != ""
          {
               lastnameLbl.isHidden = false
               dobTxtTopPadding.constant = 5
          }
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
                              
                              self.imageIV.image = image
                              self.appDelegate.userImage = image
                         }
                         
                         //println("test")
                    })
                    return nil
               }))
          }
          else
          {
               self.imageIV.image = UIImage.init(named: "profile-icon")
          }
     }

     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
     }
     
     // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     
     self.view.endEditing(true)
        
    }
}

extension String {
     func sqlToDate(withFormat format: String = "yyyy-MM-dd 00:00:00") -> Date {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = format
          guard let date = dateFormatter.date(from: self) else {
               preconditionFailure("Take a look to your format")
          }
          return date
     }
}
