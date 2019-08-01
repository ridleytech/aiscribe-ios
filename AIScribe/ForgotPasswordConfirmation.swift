//
//  ForgotPasswordConfirmation.swift
//  ChewsRite
//
//  Created by Randall Ridley on 5/18/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class ForgotPasswordConfirmation: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var instructionsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "Instructions to reset your password have been sent to your email stellachandler@email.com. Please check your inbox to continue.", attributes: [
            .font: UIFont(name: "Avenir-Light", size: 14.0)!,
            .foregroundColor: appDelegate.crGray
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Medium", size: 14.0)!, range: NSRange(location: 65, length: 25))
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Book", size: 14.0)!, range: NSRange(location: 91, length: 36))
        
        instructionsLbl.attributedText = attributedString
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
