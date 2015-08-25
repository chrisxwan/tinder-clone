//
//  SwipingViewController.swift
//  ParseStarterProject
//
//  Created by Christopher Wan on 8/25/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SwipingViewController: UIViewController {

    @IBOutlet var userImage: UIImageView!
    @IBOutlet var infoLabel: UILabel!
    
    var displayedUserId = ""
    
    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        let label = gesture.view!
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 500)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        label.transform = stretch
        if(gesture.state == UIGestureRecognizerState.Ended) {
            var acceptedOrRejected = ""
            if(label.center.x < 100) {
                print("not chosen")
                acceptedOrRejected = "rejected"
            } else {
                print("chosen")
                acceptedOrRejected = "accepted"
            }
            if(acceptedOrRejected != "") {
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: acceptedOrRejected)
                PFUser.currentUser()?.save()
            }
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            label.transform = stretch
            label.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            updateImage()
        }
    }
    
    func updateImage() {
        var query = PFUser.query()!
        var genderInterestedIn = "male"
        if(PFUser.currentUser()!["interestedIn"]! as! Bool) {
            genderInterestedIn = "female"
        }
        var isFemale = true
        if(PFUser.currentUser()!["gender"] as! String == "male") {
            isFemale = false
        }
        query.whereKey("gender", equalTo: genderInterestedIn)
        query.whereKey("interestedIn", equalTo:isFemale)
        
        if let latitude = PFUser.currentUser()?["location"]!.latitude {
            if let longitude = PFUser.currentUser()?["location"]!.longitude {
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude:latitude-1, longitude: longitude-1), toNortheast: PFGeoPoint(latitude:latitude+1, longitude:longitude+1))
            }
        }

        
        var alreadySeen = [""]
        if let acceptedArray = PFUser.currentUser()?["accepted"] {
            alreadySeen += acceptedArray as! Array
        }
        if let rejectedArray = PFUser.currentUser()?["rejected"] {
            alreadySeen += rejectedArray as! Array
        }
        query.whereKey("objectId", notContainedIn: alreadySeen)
        query.limit = 1
        query.findObjectsInBackgroundWithBlock{( objects, error) -> Void in
            if error != nil {
                print(error)
            } else {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.displayedUserId = object.objectId!
                        let imageFile = object["image"] as! PFFile
                        imageFile.getDataInBackgroundWithBlock{(imageData, error) -> Void in
                            if(error != nil) {
                                print(error)
                            } else {
                                if let data = imageData {
                                    self.userImage.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateImage()
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
            if let geoPoint = geoPoint {
                PFUser.currentUser()?["location"] = geoPoint
                PFUser.currentUser()?.save()
            }
        }
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        userImage.addGestureRecognizer(gesture)
        userImage.userInteractionEnabled = true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "logout") {
            PFUser.logOut()
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
