//import UIKit
//import Alamofire
//import SwiftyJSON
//
//
//class SelectedChattersViewController: UIViewController{
//    
//    @IBOutlet var tblSelected: UITableView!
//    var filteredSelected = [SliceUser]()
//    var originalSelected = [SliceUser]()
//    var searchBar: UISearchBar!
//    
//    var selectChattersViewController: SelectChattersViewController!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Remove separators below the table view to clean up the look.
//        tblSelected.tableFooterView = UIView(frame: CGRect.zero)
//        
//        // Create the search bar.
//        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tblSelected.frame.width, height: 44))
//        searchBar.placeholder = "Search for a person."
//        searchBar.autocorrectionType = UITextAutocorrectionType.no
//        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
//        tblSelected.tableHeaderView = searchBar
//        tblSelected.bounces = true
//        tblSelected.isScrollEnabled = true
//        searchBar.delegate = self
//        
//        var contentOffset = tblSelected.contentOffset
//        contentOffset.y += searchBar.frame.height
//        tblSelected.contentOffset = contentOffset
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // Returning To View
//    override func viewWillAppear(_ animated: Bool) {
//    }
//    
//    func setSelectedArray(_ selected: [SliceUser]){
//        self.originalSelected = selected.sorted(by: {$0.username < $1.username})
//    
//        clearSearch()
//    }
//    
//    func addUserToSelectedChatters(_ newChatter: SliceUser!){
//        self.originalSelected.append(newChatter)
//        self.originalSelected.sort(by: {$0.username < $1.username})
//    
//        clearSearch()
//    }
//    
//    func clearSearch(){
//        self.searchBar.text?.removeAll()
//        self.filteredSelected = originalSelected
//        self.tblSelected.reloadData()
//    }
//   
//    func getSelectedChatterIDs() -> [Int]{
//        var chatterIDs = [Int]()
//        
//        for chatter in originalSelected{
//            chatterIDs.append(chatter.userId)
//        }
//        
//        return chatterIDs
//    }
//}
//
//// TableView Implementation
//extension SelectedChattersViewController: UITableViewDelegate, UITableViewDataSource{
//    
//    // Implement UITableViewDataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return self.filteredSelected.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedChattersCell",for:indexPath) as! SelectedChattersCell
//        
//        cell.lblName.text = filteredSelected[(indexPath as NSIndexPath).row].username
//        cell.chatter = filteredSelected[(indexPath as NSIndexPath).row]
//        cell.updateUserPhoto()
//        
//        if ((indexPath as NSIndexPath).row % 2 == 0){
//            cell.backgroundColor = styleMgr.colorLight
//        }
//        else{
//            cell.backgroundColor = UIColor.white
//        }
//        
//        return cell
//    }
//    
//    // Move user from selected to potential
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        selectChattersViewController.moveToPotential(originalSelected[(indexPath as NSIndexPath).row])
//        originalSelected.remove(at: (indexPath as NSIndexPath).row)
//        
//        clearSearch()
//    }
//}
//
//// Search Bar Implementation
//extension SelectedChattersViewController: UISearchBarDelegate{
//    
//    // The filtering function.
//    func filterUsersForSearchText(_ searchText: String){
//        filteredSelected = originalSelected
//        if searchText != ""{
//            filteredSelected = filteredSelected.filter({ (user: SliceUser) -> Bool in
//                let stringMatch = user.username.lowercased().range(of: searchText.lowercased())
//                return (stringMatch != nil)
//            })
//        }
//        
//        filteredSelected.sort(by: {$0.username < $1.username})
//    }
//    
//    // Call filtering function when searchbar text is changed.
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filterUsersForSearchText(searchText)
//        
//        tblSelected.reloadData()
//    }
//    
//    // Dismiss keyboard when search button on keyboard is pressed.
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
//        searchBar.resignFirstResponder()
//    }
//    
//}
//
//class SelectedChattersCell: UITableViewCell {
//    
//    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var lblSliceCount: UILabel!
//    @IBOutlet weak var imgUserPhoto: UIImageView!
//    var chatter: SliceUser!
//    
//    func updateUserPhoto(){
//        
//        
//        chatter.requestUserPhoto({ () -> Void in
//            if let newImage = self.chatter.photoImg{
//                
//                if newImage.size.width > self.imgUserPhoto.image!.size.width{
//                    let scaledImage = RBSquareImageTo(newImage, size: self.imgUserPhoto.image!.size)
//                    self.imgUserPhoto.image = scaledImage
//                    
//                    self.imgUserPhoto.layer.borderWidth = 2.0
//                    self.imgUserPhoto.layer.borderColor = styleMgr.colorOffWhite.cgColor
//                    self.imgUserPhoto.layer.cornerRadius = 8.0
//                    self.imgUserPhoto.layer.masksToBounds = true
//                }
//                else{
//                    self.imgUserPhoto.image = newImage
//                    
//                    self.imgUserPhoto.layer.borderWidth = 0.0
//                }
//            }
//        })
//        
//    }
//    
//}
//
