//
//  MyFiles.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import Alamofire

class MyFiles: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var itemArray = [FileItem]()
    var currentItemArray = [FileItem]()
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var activityViewBottom: UIActivityIndicatorView!
    
    
    @IBOutlet weak var menuBtn: UIButton!
    var did : String?
    
    var fileList = NSMutableArray()
    var selectedFile: FileItem?

    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet weak var filesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.delegate = self
        activityViewBottom.isHidden = true
        
        let tb : TabController = self.parent as! TabController
        
        menuBtn.addTarget(self, action: #selector(tb.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        filesTable.tableFooterView = UIView()
        filesTable.dataSource = self
        filesTable.delegate = self
        
        statusView.isHidden = true
        
        getFiles()
        activityView.startAnimating()

        // Do any additional setup after loading the view.
        
        refreshControl.addTarget(self, action: #selector(refreshWeekData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            
            filesTable.refreshControl = refreshControl
            
        } else {
            
            filesTable.addSubview(refreshControl)
        }
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        search?.inputAccessoryView = keyboardDoneButtonView
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFilesNotification),
            name: NSNotification.Name(rawValue: "refreshFiles"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transcriptionStartedNotification),
            name: NSNotification.Name(rawValue: "transcriptionStarted"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentItemArray = itemArray.filter({ item -> Bool in
            
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return item.filename.lowercased().contains(searchText.lowercased()) || item.status.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        
        filesTable.reloadData()
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
    }
    
    @objc private func refreshWeekData(_ sender: Any) {
        
        refreshFiles()
    }
    
    func refreshFiles() {
        
        itemArray.removeAll()
        getFiles()
    }
    
    @objc func transcriptionStartedNotification (notification: NSNotification) {
        
        let dict = notification.object as! NSDictionary
        
        fileList.add(dict)
        filesTable.reloadData()
        
        //NotificationCenter.default.post(name: Notification.Name("resetTranscription"), object: nil)
        
        startProcessing(dict: dict)
    }
    
    @objc func refreshFilesNotification (notification: NSNotification) {
        
        print("refreshFilesNotification")
        
        refreshFiles()
    }
    
     func startProcessing (dict:NSDictionary) {
        
        print("startProcessing")
        
        activityViewBottom.startAnimating()
        activityViewBottom.isHidden = false
        
        let dataString = "transcribeData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-speech-to-text.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let filename = dict.object(forKey: "filename") as? String
        let did = dict.object(forKey: "did") as? String
        
        let paramString = "uid=\(appDelegate.userid!)&filename=\(filename!)&did=\(did!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("transcribe jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityViewBottom.isHidden = true
                        self.activityViewBottom.stopAnimating()
                        
                        self.showBasicAlert(string: "Transcription unsuccessful")
                        
                        //self.noResultsMain.isHidden = false
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        let status = uploadData.object(forKey: "status") as! String
                        
                        print("status: \(status)")
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityViewBottom.isHidden = true
                            self.activityViewBottom.stopAnimating()
                            
                            if status.contains("transcription completed")
                            {
                                self.refreshFiles()
                                NotificationCenter.default.post(name: Notification.Name("resetTranscription"), object: nil)
                            }
                            else
                            {
                                self.showBasicAlert(string: status)
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            //self.noResultsMain.isHidden = false
                            
                            self.activityViewBottom.isHidden = true
                            self.activityViewBottom.stopAnimating()
                            
                            self.showBasicAlert(string: "Transcription unsuccessful")
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
    
    func getFiles() {
        
        print("getFiles")
        
        let dataString = "filesData"
        
        let urlString = "\(appDelegate.serverDestination!)getFilesJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("files jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                       
                        self.statusView.isHidden = false
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        self.refreshControl.endRefreshing()
                        //self.noResultsMain.isHidden = false
                    })
                }
                else
                {
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if (uploadData.count > 0)
                    {
                        for ob in uploadData {
                            
                            let dict = ob as! NSDictionary
                            
                            self.itemArray.append(FileItem(filename: dict.object(forKey: "filename") as! String, status: dict.object(forKey: "status") as! String, did: dict.object(forKey: "did") as! String, date: dict.object(forKey: "datecreated") as! String))
                        }
                        
                        self.currentItemArray = self.itemArray
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            self.filesTable.reloadData()
                            self.refreshControl.endRefreshing()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.refreshControl.endRefreshing()
                            //self.noResultsMain.isHidden = false
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
    
    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("FileHeaderCell", owner: self, options: nil)?.first as! FileHeaderCell
        
        headerView.headerLbl.text = "MY FILES"
        headerView.headerLbl.textColor = appDelegate.gray51
        
        let font1 = UIFont.init(name: "Avenir-Heavy", size: 16.0)
        
        headerView.headerLbl.font = font1
        
        headerView.leadingWidth.constant = 20
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let dict = fileList[(indexPath as NSIndexPath).row] as! NSDictionary
//
//        did = dict.object(forKey: "did") as! String
        
        selectedFile = currentItemArray[indexPath.row]
        
        did = selectedFile?.did
        
        self.performSegue(withIdentifier: "EditTranscription", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.currentItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! 
        
        if currentItemArray.count > 0
        {
            let dict = currentItemArray[(indexPath as NSIndexPath).row]
            
            cell.selectionStyle = .none
            
            let v0 = cell.viewWithTag(1) as! UILabel
            let v1 = cell.viewWithTag(2) as! UILabel
            let v2 = cell.viewWithTag(3) as! UIButton
            //let v3 = cell.viewWithTag(4) as! UIButton
            let v4 = cell.viewWithTag(5) as! UILabel
            
            v0.text = dict.filename
            v1.text = dict.status
            v4.text = dict.date
            
    //        let transcription = dict.object(forKey: "transcription") as? String
    //        let translations = dict.object(forKey: "translations") as? String
    //
            //v2.setTitle(transcription, for: .normal)
            //v3.setTitle(translations, for: .normal)
            
    //        if translations == "create"
    //        {
    //            v3.addTarget(self, action: #selector(self.createTranslation(_:)), for: UIControlEvents.touchUpInside)
    //        }
    //        else
    //        {
    //            v3.addTarget(self, action: #selector(self.viewTranslations(_:)), for: UIControlEvents.touchUpInside)
    //        }
            
            v2.restorationIdentifier = "\(indexPath.row)"
            //v3.restorationIdentifier = "\(indexPath.row)"
            
        }
        
        return cell
    }
    
    @IBAction func viewTranscription(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let ind = Int(btn.restorationIdentifier!)
        
        selectedFile = currentItemArray[ind!]
        
        did = selectedFile?.did
        
        self.performSegue(withIdentifier: "EditTranscription", sender: self)
    }
    
    @IBAction func createTranslation(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let ind = Int(btn.restorationIdentifier!)
        
        selectedFile = currentItemArray[ind!]
        
        did = selectedFile?.did
        
        self.performSegue(withIdentifier: "CreateTranslation", sender: self)
    }
    
    @IBAction func viewTranslations(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let ind = Int(btn.restorationIdentifier!)
        
        selectedFile = currentItemArray[ind!]
        
        did = selectedFile?.did
        
        self.performSegue(withIdentifier: "ViewTranslations", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditTranscription"
        {
            let destination = segue.destination as! TranscriptionResult
            destination.did = did
        }
        else if segue.identifier == "ViewTranslations"
        {
            let destination = segue.destination as! DocumentTranslations
            destination.did = did
            destination.filename = selectedFile?.filename
        }
    }
}

class FileItem {
    let filename: String
    let status: String
    let did: String
    let date: String
    
    init(filename: String, status: String, did: String, date: String) {
        self.filename = filename
        self.status = status
        self.did = did
        self.date = date
    }
}
