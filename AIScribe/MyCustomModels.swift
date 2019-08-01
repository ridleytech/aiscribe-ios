//
//  MyCustomModels.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class MyCustomModels: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var itemArray = [ModelItem]()
    var currentItemArray = [ModelItem]()
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    var did : String?
    
    var modelList = NSMutableArray()
    var selectedModel: ModelItem?
    
    @IBOutlet weak var modelsTable: UITableView!
    var initLoaded : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tb : TabController = self.parent as! TabController
        
        menuBtn.addTarget(self, action: #selector(tb.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        self.statusView.isHidden = true
        modelsTable.tableFooterView = UIView()
        modelsTable.dataSource = self
        modelsTable.delegate = self
        
        search.delegate = self
        
        getModels()
        activityView.startAnimating()
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            
            modelsTable.refreshControl = refreshControl
            
        } else {
            
            modelsTable.addSubview(refreshControl)
        }
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        search?.inputAccessoryView = keyboardDoneButtonView
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshModelsNotification),
            name: NSNotification.Name(rawValue: "refreshCustomModels"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if initLoaded == true
        {
            print("viewWillAppear initLoaded")
            refreshFiles()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        refreshFiles()
    }
    
    func refreshFiles() {
        
        itemArray.removeAll()
        getModels()
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentItemArray = itemArray.filter({ item -> Bool in
            
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return item.modelname.lowercased().contains(searchText.lowercased()) || item.modeldescription.lowercased().contains(searchText.lowercased()) || item.basename1.lowercased().contains(searchText.lowercased()) || item.status.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        
        modelsTable.reloadData()
    }
    
    @objc func refreshModelsNotification (notification: NSNotification) {
        
        print("refreshModelsNotification")
        
        refreshFiles()
    }
    
    func getModels() {
        
        print("getModels")
        
        let dataString = "modelsData"
        
        let urlString = "\(appDelegate.serverDestination!)getModelsJSON.php"
        
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
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if (uploadData.count > 0)
                    {
                        //let list = uploadData as! NSMutableArray
                        
                        for ob in uploadData {
                            
                            let dict = ob as! NSDictionary
                            
                            self.itemArray.append(ModelItem(modelname: dict.object(forKey: "modelname") as! String, modeldescription: dict.object(forKey: "modeldescription") as! String, basename1: dict.object(forKey: "basename1") as! String, mid: dict.object(forKey: "mid") as! String, cid: dict.object(forKey: "cid") as! String, status:  dict.object(forKey: "status") as! String))
                        }
                        
                        self.currentItemArray = self.itemArray
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.statusView.isHidden = true
                            self.activityView.stopAnimating()
                            self.modelsTable.reloadData()
                            self.refreshControl.endRefreshing()
                            
                            self.initLoaded = true
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            self.statusView.isHidden = false
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
        
        headerView.headerLbl.text = "MY MODELS"
        headerView.headerLbl.textColor = appDelegate.gray51
        
        let font1 = UIFont.init(name: "Avenir-Heavy", size: 16.0)
        
        headerView.headerLbl.font = font1
        headerView.leadingWidth.constant = 20
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedModel = currentItemArray[indexPath.row]
        
        self.performSegue(withIdentifier: "EditModel", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 140
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.currentItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let dict = currentItemArray[(indexPath as NSIndexPath).row] 
        
        cell.selectionStyle = .none
        
        let v0 = cell.viewWithTag(1) as! UILabel
        let v1 = cell.viewWithTag(2) as! UILabel
        let v2 = cell.viewWithTag(3) as! UIButton
        let v3 = cell.viewWithTag(4) as! UILabel
        let v4 = cell.viewWithTag(5) as! UILabel
        //let v3 = cell.viewWithTag(4) as! UIButton
        //let v4 = cell.viewWithTag(5) as! UILabel
        
        v0.text = dict.modelname
        v1.text = "Description: \(dict.modeldescription)"
        v3.text = "Language: \(dict.basename1)"
        v4.text = "Status: \(dict.status)"
        
        v2.restorationIdentifier = "\(indexPath.row)"
        //v3.restorationIdentifier = "\(indexPath.row)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditModel"
        {
            let destination = segue.destination as! EditCustomModel
            destination.selectedModel = selectedModel
        }
    }
}


class ModelItem {
    
    let modelname: String
    let modeldescription: String
    let basename1: String
    let mid: String
    let cid: String
    let status: String
    
    init(modelname: String, modeldescription: String, basename1: String, mid: String, cid: String, status: String) {
        self.modelname = modelname
        self.modeldescription = modeldescription
        self.basename1 = basename1
        self.mid = mid
        self.cid = cid
        self.status = status
    }
}
