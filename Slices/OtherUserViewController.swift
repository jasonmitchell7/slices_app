import UIKit
import Alamofire
import SwiftyJSON

class OtherUserViewController: UIViewController {
    var user: SliceUser!
    var alreadyFollowing: Bool = false
    
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblSlicesCount: UILabel!
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var lblUserDescription: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCountsAndDescription()
        updateUserPhoto()
        checkAlreadyFollowing()
    }
    
    func updateCountsAndDescription() {
        lblFollowersCount.text = "\(user.followerCount)"
        lblFollowingCount.text = "\(user.followingCount)"
        lblSlicesCount.text = "\(user.sliceCount)"
        lblUserDescription.text = "\(user.userDescription)"
    }

    func checkAlreadyFollowing() {
        if (currentUser != nil) {
            alreadyFollowing = currentUser!.isFollowingUserWithID(user.userId)
        }
        
        if (alreadyFollowing) {
            btnFollow.setTitle("Unfollow", for: UIControlState())
        }
        else {
            btnFollow.setTitle("Follow", for: UIControlState())
        }
        
        btnFollow.layer.borderWidth = 1.0
        btnFollow.layer.borderColor = styleMgr.colorOffWhite.cgColor
        btnFollow.layer.cornerRadius = 2.0
        btnFollow.layer.masksToBounds = true
    }
    
    func updateUserPhoto() {
        user.requestUserPhoto({ () -> Void in
            if let newImage = self.user.photoImg{
                
                if newImage.size.width > self.imgUserPhoto.image!.size.width{
                    let scaledImage = RBSquareImageTo(newImage, size: self.imgUserPhoto.image!.size)
                    self.imgUserPhoto.image = scaledImage
                    
                    self.imgUserPhoto.layer.borderWidth = 2.0
                    self.imgUserPhoto.layer.borderColor = styleMgr.colorOffWhite.cgColor
                    self.imgUserPhoto.layer.cornerRadius = 8.0
                    self.imgUserPhoto.layer.masksToBounds = true
                }
                else{
                    self.imgUserPhoto.image = newImage
                    
                    self.imgUserPhoto.layer.borderWidth = 0.0
                }
            }
        })
    }
    
    @IBAction func didPressBlockUser(_ sender: UIButton) {
    }
    
    @IBAction func didPressReportUser(_ sender: UIButton) {
    }
    
    @IBAction func didPressFollowers(_ sender: UIButton) {
    }
    
    @IBAction func didPressFollowing(_ sender: UIButton) {
    }
    
    @IBAction func didPressSlices(_ sender: UIButton) {
    }
    
    @IBAction func didPressFollow(_ sender: UIButton) {
        if (alreadyFollowing == false){
            if (currentUser != nil) {
                currentUser!.requestFollowUser(user, completion: ({(success, errorMessage) -> Void in
                    if (success == true) {
                        let alert = UIAlertController(title: "Success", message: "You have succesfully followed \(self.user.username)." as String, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        self.btnFollow.setTitle("Unfollow", for: UIControlState())
                        self.alreadyFollowing = true
                    }
                    else {
                        // Display Modal Alert
                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }))
            }
        }
        else {
            if (currentUser != nil) {
                currentUser!.requestUnfollowUser(currentUser!, userFollowing: user, completion: {(success, errorMessage) -> Void in
                    if (success == true) {
                        let alert = UIAlertController(title: "Success", message: "You are no longer following \(self.user.username).", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        self.btnFollow.setTitle("Follow", for: UIControlState())
                        self.alreadyFollowing = true
                    }
                    else {
                        // Display Modal Alert
                        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
}
