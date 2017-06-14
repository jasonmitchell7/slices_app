import UIKit
import Alamofire
import SwiftyJSON

class UserViewController: SlicesViewControllerWithNav, LongTextEntryDelegate {
    
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblSlicesCount: UILabel!
    @IBOutlet weak var btnUserDescription: UIButton!
    @IBOutlet weak var btnFindFriends: UIButton!
    
    // User Description Modal Variables
    var userDescriptionModal: LongTextEntryView?
    let maxUserDescriptionCount = 530
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        
        if (currentUser != nil){
            logger.message(type: .information, message: "Updating labels on user screen.")
            updateLabels()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBordersToButtons()
        
        // Setup tap gesture for the user photo.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserViewController.tappedUserPhoto(_:)))
        imgUserPhoto.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func didPressFollowers(_ sender: UIButton) {
        if (currentUser?.followers != nil) {
            if (currentUser!.followers!.count < 1) {
                return
            }
        }
        
        currentUser?.requestFollowers({() -> Void in
            let userListViewController = UserListViewController(nibName: "UserListView", bundle: nil)
            userListViewController.setup(titleText: "Followers", singleUserText: "follower", users: currentUser!.followers!)
            self.navigationController?.pushViewController(userListViewController, animated: true)
        })
    }
    
    @IBAction func didPressFollowing(_ sender: UIButton) {
        if (currentUser?.following != nil) {
            if (currentUser!.following!.count < 1) {
                return
            }
        }
        
        currentUser?.requestFollowing({() -> Void in
            let userListViewController = UserListViewController(nibName: "UserListView", bundle: nil)
            userListViewController.setup(titleText: "Following", singleUserText: "following", users: currentUser!.following!)
            self.navigationController?.pushViewController(userListViewController, animated: true)
        })
    }
    
    
    @IBAction func didPressSlices(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "userToSliceScrollView", sender: self)
        print("TODO: Implement pressed slices...")
    }
    
    @IBAction func didPressFindFriends(_ sender: UIButton) {
        let viewController = FindFriendsViewController(nibName: "FindFriendsView", bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didPressUserDescription(_ sender: UIButton) {
        showUserDescriptionModal()
    }
    
    @IBAction func didPressLogout(_ sender: UIButton) {
        sessionMgr.doLogout({() -> Void in
            self.tabBarController?.selectedIndex = 0
            sessionMgr.loadLoginStoryboard()
        })
    }
    
    @IBAction func didPressSettings(_ sender: UIButton) {
        let viewController = SettingsTableViewController(nibName: "SettingsView", bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func addBordersToButtons() {
        btnFindFriends.addBorderForButton()
        btnUserDescription.addBorderForButton()
    }
    
    func tappedUserPhoto(_ gestureRecognizer: UITapGestureRecognizer){
        self.selectPhotoForUpload()
    }
    
    func updateLabels(){
        lblSlicesCount.text = "\(currentUser!.sliceCount)"
            
        currentUser?.requestFollowers({ () -> Void in
            if let user = currentUser {
                if (user.potentialFollowerCount == 0) {
                    self.lblFollowersCount.text = user.getFollowersCountString()
                } else {
                    self.lblFollowersCount.text = "\(user.getPotentialFollowersCountString()) / \(user.getAllFollowersCountString())"
                }
            }
        })
            
        currentUser?.requestFollowing({ () -> Void in
            if let user = currentUser {
                self.lblFollowingCount.text = user.getFollowingCountString()
            }
        })
            
        currentUser?.requestUserPhoto({ () -> Void in
            if let user = currentUser {
                if let userPhoto = user.photoImg {
                    self.updateUserPhoto(userPhoto)
                }
            }
        })
    }
    
    func showUserDescriptionModal() {
        if (currentUser == nil) {
            logger.message(type: .error, message: "Null current user when loading User Description Modal.")
            return
        }
        
        userDescriptionModal = LongTextEntryView()
        userDescriptionModal?.frame = self.view.frame
        userDescriptionModal?.bounds = self.view.bounds
        userDescriptionModal?.delegate = self
        userDescriptionModal?.setup(title: "User Description",
                                    cancelText: "Cancel",
                                    okayText: "Update Description",
                                    initialText: currentUser!.userDescription,
                                    characterLimit: maxUserDescriptionCount,
                                    blurBackground: true)
        
        UIApplication.shared.keyWindow?.addSubview(userDescriptionModal!)
    }
    
    func hideUserDescriptionModal() {
        userDescriptionModal?.removeFromSuperview()
        userDescriptionModal = nil
    }
    
    func longTextEntryCancelSelected(text: String?) {
        hideUserDescriptionModal()
    }
    
    func longTextEntryOkaySelected(text: String) {
        if (text != currentUser?.userDescription) {
            currentUser!.updateUserDescription(text, completion: {(success) -> Void in
                if (success == true) {
                    self.hideUserDescriptionModal()
                }
                else {
                    // Display Modal Alert
                    let alert = UIAlertController(title: "Error", message: "Couldn't update description. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            self.hideUserDescriptionModal()
        }
    }
    
}


// UIImagePickerController Delegate
// Used for selecting profile picture to upload.
extension UserViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func selectPhotoForUpload(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        // Dismiss Image Picker
        self.dismiss(animated: true, completion: nil)
        
        let selImage: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Change to this later for higher resolution images.
        //var squareImage = RBSquareImageLargest(newImage)
        //uploadUserPhoto(squareImage)
        let scaledImage = RBSquareImageTo(selImage, size: self.imgUserPhoto.image!.size)
        uploadUserPhoto(scaledImage)
        
        updateUserPhoto(selImage)
        
    }

    func updateUserPhoto( _ newImage: UIImage! ){
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
    
    func uploadUserPhoto( _ image: UIImage! ){
        
        // Show activity indicator.
        let actInd = ActivityIndicatorWithText(text: "Uploading...")
        self.view.addSubview(actInd)
        actInd.show()
        
        // Create the upload request
        let imgData: Data = UIImagePNGRepresentation(image.cropImageToSquare())!
        let httpRequest = httpHelper.uploadMediaRequest("upload_media", data: imgData, type: "photo_user", sliceID: nil)
        
        // Send the HTTP request
        httpHelper.sendRequest(httpRequest as URLRequest, completion: {(data: Data?, error: Error?) -> Void in
            if error != nil{
                // Display Modal Alert
                let errorMessage = httpHelper.getErrorMessage(error!)
                let alert = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            // Hide Activity Indicator
            actInd.hide()

        })
    }

}
