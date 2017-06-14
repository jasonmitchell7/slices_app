import UIKit
import Alamofire
import SwiftyJSON

class UserListViewController: UIViewController{

    @IBOutlet var tblUsers: UITableView!
    
    var titleText: String = "Users"
    var singleUserText: String = "user"
    
    var filteredUsers = [SliceUser]()
    var originalUsers = [SliceUser]()
    var searchBar: UISearchBar!
    var selectedUser: SliceUser?
    
    public func setup(titleText: String, singleUserText: String, users: [SliceUser]) {
        self.titleText = titleText
        self.singleUserText = singleUserText
        self.originalUsers = users
        self.filteredUsers = users
        
        sortFilteredUsers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblUsers.dataSource = self
        tblUsers.delegate = self
        
        
        // Remove separators below the table view to clean up the look.
        tblUsers.tableFooterView = UIView(frame: CGRect.zero)
        
        // Create the search bar.
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tblUsers.frame.width, height: 44))
        searchBar.autocorrectionType = UITextAutocorrectionType.no
        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
        tblUsers.tableHeaderView = searchBar
        searchBar.placeholder = "Search for a \(singleUserText)."
        tblUsers.bounces = true
        tblUsers.isScrollEnabled = true
        searchBar.delegate = self
        
        var contentOffset = tblUsers.contentOffset
        contentOffset.y += searchBar.frame.height //+ UIApplication.shared.statusBarFrame.height
        tblUsers.contentOffset = contentOffset
    }
    
    // Returning To View
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        requestAndReloadTable()
    }
    
    func sortFilteredUsers() {
        if (titleText == "Followers") {
            filteredUsers.sort(by: {$0.accepted == $1.accepted ?
                $0.username < $1.username :
                !$0.accepted && $1.accepted})
        } else {
            filteredUsers.sort(by: {$0.username < $1.username})
        }
    }
    
    func requestAndReloadTable() {
        if (titleText == "Following") {
            requestFollowingAndReloadTable()
        } else if (titleText == "Followers") {
            requestFollowersAndReloadTable()
        } else {
            tblUsers.reloadData()
        }
    }
    
    func requestFollowersAndReloadTable() {
        currentUser?.requestFollowers({ () -> Void in
            if currentUser?.followers != nil {
                self.originalUsers = (currentUser?.followers)!
                self.filterUsersForSearchText(self.searchBar.text!)
            }
            else{
                self.originalUsers = [SliceUser]()
                self.filteredUsers = [SliceUser]()
            }

            self.sortFilteredUsers()
            self.tblUsers.reloadData()
            
        })
    }
    
    func requestFollowingAndReloadTable() {
        currentUser?.requestFollowing({ () -> Void in
            if currentUser?.following != nil {
                self.originalUsers = (currentUser?.following)!
                self.filterUsersForSearchText(self.searchBar.text!)
            }
            else{
                self.originalUsers = [SliceUser]()
                self.filteredUsers = [SliceUser]()
            }
            
            self.sortFilteredUsers()
            self.tblUsers.reloadData()
            
        })
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "segueFollowersToOtherUser"){
//            let otherUserVC = segue.destination as! OtherUserViewController
//            
//            otherUserVC.user = selectedUser!
//        }
//    }
}

// TableView Implementation
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Implement UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let identifier = "UserListCell"
        
        var cell: UserListCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? UserListCell
        
        if (cell == nil) {
            tableView.register(UINib(nibName: "UserListCellView", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? UserListCell
        }
        
        cell?.tableViewController = self
        
        cell?.lblName.text = filteredUsers[(indexPath as NSIndexPath).row].username
        cell?.user = filteredUsers[(indexPath as NSIndexPath).row]
        cell?.updateUserPhoto()
        
        cell?.setColorsForIndex((indexPath as NSIndexPath).row)
        cell?.setButtonsHidden(filteredUsers[(indexPath as NSIndexPath).row].accepted)
        
        if (cell == nil) {
            logger.message(type: .error, message: "Null cell in user list.")
        }
        
        return cell!
        
    }
    
    // Implement UITableViewDelegate
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        if ((titleText == "Followers" && filteredUsers[(indexPath as NSIndexPath).row].accepted) || titleText == "Following")  {
            return UITableViewCellEditingStyle.delete
        }
        else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            if (currentUser != nil) {
                let user: SliceUser = (titleText == "Followers") ? currentUser! : filteredUsers[(indexPath as NSIndexPath).row]
                let userFollowing: SliceUser = (titleText == "Followers") ? filteredUsers[(indexPath as NSIndexPath).row] : currentUser!
                currentUser!.requestUnfollowUser(user, userFollowing: userFollowing, completion: {(success, errorMessage) -> Void in
                    if (success == true) {
                        let alert = UIAlertController(title: "Success", message: "\(self.filteredUsers[(indexPath as NSIndexPath).row].username) has been successfuly removed from \(self.singleUserText)s.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        self.filteredUsers.remove(at: (indexPath as NSIndexPath).row)
                        self.requestAndReloadTable()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = filteredUsers[(indexPath as NSIndexPath).row]
//        self.performSegue(withIdentifier: "segueFollowersToOtherUser", sender: self)
    }
}

// Search Bar Implementation
extension UserListViewController: UISearchBarDelegate{
    
    // The filtering function.
    func filterUsersForSearchText(_ searchText: String){
        filteredUsers = originalUsers
        if searchText != ""{
            filteredUsers = filteredUsers.filter({ (user: SliceUser) -> Bool in
                let stringMatch = user.username.lowercased().range(of: searchText.lowercased())
                return (stringMatch != nil)
            })
        }
        filteredUsers.sort(by: {$0.username < $1.username})
    }
    
    // Call filtering function when searchbar text is changed.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsersForSearchText(searchText)
        
        tblUsers.reloadData()
    }
    
    // Dismiss keyboard when search button on keyboard is pressed.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
}

class UserListCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSliceCount: UILabel!
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    
    var user: SliceUser!
    var tableViewController: UserListViewController!
    
    @IBAction func didPressDecline(_ sender: UIButton) {
        currentUser!.sendDeclineFollow(user.userId, completion: {(success) -> Void in
            if (success == true) {
                self.tableViewController.requestAndReloadTable()
            }
        })
    }
    
    @IBAction func didPressAccept(_ sender: UIButton) {
        currentUser!.sendAcceptFollow(user.userId, completion: {(success) -> Void in
            if (success == true) {
                self.tableViewController.requestAndReloadTable()
            }
        })
    }
    
    
    func updateUserPhoto() {
        user.requestUserPhoto({ () -> Void in
            if let newImage = self.user.photoImg {
                
                if newImage.size.width > self.imgUserPhoto.image!.size.width{
                    let scaledImage = RBSquareImageTo(newImage, size: self.imgUserPhoto.image!.size)
                    self.imgUserPhoto.image = scaledImage
                }
                else{
                    self.imgUserPhoto.image = newImage
                }
            }
        })
    }
    
    func setColorsForIndex(_ index: Int){
        
        
        if (index % 2 != 0){
            self.backgroundColor = styleMgr.colorDark
            btnAccept.layer.borderColor = styleMgr.colorOffWhite.cgColor
            btnAccept.setTitleColor(styleMgr.colorOffWhite, for: UIControlState())
            btnDecline.layer.borderColor = styleMgr.colorOffWhite.cgColor
            btnDecline.setTitleColor(styleMgr.colorOffWhite, for: UIControlState())
            lblName.textColor = styleMgr.colorOffWhite
            lblSliceCount.textColor = styleMgr.colorOffWhite
            self.imgUserPhoto.addBorderForUserPhoto(color: .white)
        }
        else{
            self.backgroundColor = UIColor.white
            btnAccept.layer.borderColor = styleMgr.colorLight.cgColor
            btnAccept.setTitleColor(styleMgr.colorLight, for: UIControlState())
            btnDecline.layer.borderColor = styleMgr.colorLight.cgColor
            btnDecline.setTitleColor(styleMgr.colorLight, for: UIControlState())
            lblName.textColor = styleMgr.colorDark
            lblSliceCount.textColor = styleMgr.colorDark
            self.imgUserPhoto.addBorderForUserPhoto(color: .dark)
        }
    }
    
    func setButtonsHidden(_ hidden: Bool){
        btnAccept.isHidden = hidden
        btnDecline.isHidden = hidden
    }
    
}

