//
//  TermsConditions.swift
//  AIScribe
//
//  Created by Randall Ridley on 3/9/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class TermsConditions: UIViewController {

    @IBOutlet weak var textTV: UITextView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //textTV.text = "AIScribe is your on-the-go resource for all things healthy eating. No matter what your family's dietary restrictions, or how busy life gets, our mobile meal and menu app facilitates nutritious food choices so you can feel good about what you serve at your table."
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        textTV.setContentOffset(.zero, animated: false)
    }
    
    @IBAction func cancel() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
