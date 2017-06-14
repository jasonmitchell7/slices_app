import UIKit
import Alamofire
import SwiftyJSON


class FindFriendsViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var lblFindUsername: UILabel!
    @IBOutlet weak var txtFindUserField: UITextField!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var imgFollowUserPhoto: UIImageView!
    
    @IBOutlet weak var searchWithFacebook: UIButton!
    @IBOutlet weak var searchWithGoogle: UIButton!
    @IBOutlet weak var searchWithContacts: UIButton!
    
    var currentFoundUser: SliceUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBordersToButtons()
        
        // Setup text field for finding users.
        txtFindUserField.delegate = self
        
        changeDisplayOfFoundUserItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
    }
    
    @IBAction func didPressFollow(_ sender: UIButton) {
        // Check if they haven't returned on text withing the find user field.
        if txtFindUserField.text != lblFindUsername.text {
            searchForUser()
        }
        
        // If no user has been found, don't send the request.
        if currentFoundUser == nil{
            let alert = UIAlertController(title: "Error", message: "You need to find a user before you can follow them." as String, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if (currentUser != nil && currentFoundUser != nil) {
            currentUser!.requestFollowUser(currentFoundUser!, completion: ({(success, errorMessage) -> Void in
                if (success == true) {
                    let alert = UIAlertController(title: "Success", message: "You have successfully followed \(self.lblFindUsername.text!)." as String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.currentFoundUser = nil
                    self.changeDisplayOfFoundUserItems()
                    self.lblFindUsername.text = ""
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        searchForUser()
        
        return true
    }
    
    func addBordersToButtons() {
        btnFollow.addBorderForButton()
        searchWithFacebook.addBorderForButton()
        searchWithGoogle.addBorderForButton()
        searchWithContacts.addBorderForButton()
    }
    
    func changeDisplayOfFoundUserItems(){
        if currentFoundUser == nil {
            btnFollow.isHidden = true
            imgFollowUserPhoto.isHidden = true
        }
        else{
            btnFollow.isHidden = false
            imgFollowUserPhoto.isHidden = false
        }
    }
    
    func searchForUser(){
        
        let url = ApiHelper.BASE_URL + "/find_user"
        
        let params = [
            "search_field": txtFindUserField.text!
        ]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response  in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                let errorMessage = json["message"].string
                
                if (errorMessage != nil)
                {
                    self.lblFindUsername.text = "Could not find user."
                    self.currentFoundUser = nil
                    
                    self.changeDisplayOfFoundUserItems()
                    
                    return
                }
                else{
                    self.currentFoundUser = SliceUser()
                    
                    self.currentFoundUser!.userId = json["id"].int!
                    self.currentFoundUser!.photoId = json["photo_id"].string
                    self.currentFoundUser!.username = json["username"].string!
                    
                    self.lblFindUsername.text = json["username"].string!
                    self.btnFollow.isHidden = false
                    
                    self.currentFoundUser!.requestUserPhoto({ () -> Void in
                        self.updateFollowUserPhoto(newPhoto: self.currentFoundUser!.photoImg)
                    })
                    
                }
                
            case .failure(let error):
                print("Request failed with error: \(error)")
                
            }
        }
        
    }

    func updateFollowUserPhoto(newPhoto: UIImage! ){
        
        if newPhoto.size.width > self.imgFollowUserPhoto.image!.size.width{
            let scaledImage = RBSquareImageTo(newPhoto, size: self.imgFollowUserPhoto.image!.size)
            self.imgFollowUserPhoto.image = scaledImage
            
            self.imgFollowUserPhoto.layer.borderWidth = 2.0
            self.imgFollowUserPhoto.layer.borderColor = styleMgr.colorOffWhite.cgColor
            self.imgFollowUserPhoto.layer.cornerRadius = 8.0
            self.imgFollowUserPhoto.layer.masksToBounds = true
        }
        else{
            self.imgFollowUserPhoto.image = newPhoto
            
            self.imgFollowUserPhoto.layer.borderWidth = 0.0
        }
        
        changeDisplayOfFoundUserItems()
    }
    
}

