//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by Christopher Wan on 8/24/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var interestedIn: UISwitch!
    @IBAction func signUp(sender: AnyObject) {
        PFUser.currentUser()?["interestedIn"] = interestedIn.on
        PFUser.currentUser()?.save()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if(error != nil) {
                print(error)
            } else if let result = result {
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?.save()
                let userId = result["id"] as! String
                let profilePicture = "https://graph.facebook.com/" + userId + "/picture?type=large"
                if let profPic = NSURL(string: profilePicture) {
                    if let data = NSData(contentsOfURL: profPic) {
                        self.userImage.image = UIImage(data: data)
                        let imageFile: PFFile = PFFile(data: data)
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.save()
                    }
                }
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
