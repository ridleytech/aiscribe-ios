//
//  MyCorpora.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/8/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class MyCorpora: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var itemArray = [CorpusItem]()
    var currentItemArray = [CorpusItem]()
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var statusView: UIView!
    
    var did : String?
    var modelList = NSMutableArray()
    var selectedCorpus: CorpusItem?
    
    @IBOutlet weak var modelsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBtn.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        self.statusView.isHidden = true
        modelsTable.tableFooterView = UIView()
        modelsTable.dataSource = self
        modelsTable.delegate = self
        
        search.delegate = self
        
        refreshControl.addTarget(self, action: #selector(manualRefresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            
            modelsTable.refreshControl = refreshControl
            
        } else {
            
            modelsTable.addSubview(refreshControl)
        }
        
        getCorpora()
        activityView.startAnimating()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        search?.inputAccessoryView = keyboardDoneButtonView
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshCorporaNotification),
            name: NSNotification.Name(rawValue: "refreshCorpora"),
            object: nil)
    }
    
    @objc private func manualRefresh(_ sender: Any) {
        
        refreshCorporaControl()
    }
    
    func refreshCorporaControl() {
        
        itemArray.removeAll()
        getCorpora()
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
    }
    
    @objc func refreshCorporaNotification (notification: NSNotification) {
        
        print("refreshCorporaNotification")
        
        itemArray.removeAll()
        
        getCorpora()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        currentItemArray = itemArray.filter({ item -> Bool in
            
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return item.filename.lowercased().contains(searchText.lowercased()) || item.modelname.lowercased().contains(searchText.lowercased()) || item.content.lowercased().contains(searchText.lowercased()) || item.status.lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        
        modelsTable.reloadData()
    }
    
    func getCorpora() {
        
        print("getCorpora")
        
        let dataString = "corporaData"
        
        let urlString = "\(appDelegate.serverDestination!)getCorpusJSON.php"
        
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
                            
                            //self.modelList.add(dict)
                            self.itemArray.append(CorpusItem(filename: dict.object(forKey: "filename") as! String, cpid: dict.object(forKey: "cpid") as! String, mid: dict.object(forKey: "mid") as! String, cid: dict.object(forKey: "cid") as! String, modelname: dict.object(forKey: "modelname") as! String, content: dict.object(forKey: "content") as! String, status: dict.object(forKey: "status") as! String))
                        }
                        
                        self.currentItemArray = self.itemArray
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.statusView.isHidden = true
                            self.activityView.stopAnimating()
                            self.modelsTable.reloadData()
                            self.refreshControl.endRefreshing()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            self.statusView.isHidden = false
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
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
        
        headerView.headerLbl.text = "MY CORPORA"
        headerView.headerLbl.textColor = appDelegate.gray51
        
        let font1 = UIFont.init(name: "Avenir-Heavy", size: 16.0)
        
        headerView.headerLbl.font = font1
        headerView.leadingWidth.constant = 20
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCorpus = currentItemArray[indexPath.row]
        
        //did = selectedCorpus!.cpid
        
        self.performSegue(withIdentifier: "EditCorpus", sender: self)
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
        //let v3 = cell.viewWithTag(4) as! UIButton
        let v4 = cell.viewWithTag(5) as! UILabel
        
        let first30 = String(dict.content.prefix(30))
        
        v0.text = "\(dict.filename).txt"
        v1.text = "Content: \(first30)..."
        v3.text = "Model: \(dict.modelname)"
        v4.text = "Status: \(dict.status)"
        
        v2.restorationIdentifier = "\(indexPath.row)"
        //v3.restorationIdentifier = "\(indexPath.row)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditCorpus"
        {
            let destination = segue.destination as! EditCorpus
            destination.selectedCorpus = selectedCorpus
        }
    }
}

class CorpusItem {
    
    let filename: String
    let cpid: String
    let mid: String
    let cid: String
    let modelname: String
    let content: String
    let status: String
    
    init(filename: String, cpid: String, mid: String, cid: String, modelname: String, content: String, status: String) {
        self.filename = filename
        self.cpid = cpid
        self.mid = mid
        self.cid = cid
        self.modelname = modelname
        self.content = content
        self.status = status
    }
}
