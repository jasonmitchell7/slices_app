//import UIKit
//import Alamofire
//import SwiftyJSON
//
//
//class PotentialChattersViewController: UIViewController{
//    
//    @IBOutlet var tblPotential: UITableView!
//    var filteredPotential = [SliceUser]()
//    var originalPotential = [SliceUser]()
//    var searchBar: UISearchBar!
//    
//    var selectChattersViewController: SelectChattersViewController!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Remove separators below the table view to clean up the look.
//        tblPotential.tableFooterView = UIView(frame: CGRect.zero)
//        
//        // Create the search bar.
//        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tblPotential.frame.width, height: 44))
//        searchBar.placeholder = "Search for a person."
//        searchBar.autocorrectionType = UITextAutocorrectionType.no
//        searchBar.autocapitalizationType = UITextAutocapitalizationType.none
//        tblPotential.tableHeaderView = searchBar
//        tblPotential.bounces = true
//        tblPotential.isScrollEnabled = true
//        searchBar.delegate = self
//
//        var contentOffset = tblPotential.contentOffset
//        contentOffset.y += searchBar.frame.height
//        tblPotential.contentOffset = contentOffset
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
//    func setPotentialArray(_ selected: [SliceUser]){
//        self.originalPotential = selected.sorted(by: {$0.username < $1.username})
//        
//        clearSearch()
//    }
//    
//    func addUserToPotentialChatters(_ newChatter: SliceUser!){
//        self.originalPotential.append(newChatter)
//        self.originalPotential.sort(by: {$0.username < $1.username})
//        
//        clearSearch()
//    }
//    
//    func clearSearch(){
//        self.searchBar.text?.removeAll()
//        self.filteredPotential = originalPotential
//        self.tblPotential.reloadData()
//    }
//    
//}
//
//// TableView Implementation
//extension PotentialChattersViewController: UITableViewDelegate, UITableViewDataSource{
//    
//    // Implement UITableViewDataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return self.filteredPotential.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "PotentialChattersCell",for:indexPath) as! PotentialChattersCell
//        
//        cell.lblName.text = filteredPotential[(indexPath as NSIndexPath).row].username
//        cell.chatter = filteredPotential[(indexPath as NSIndexPath).row]
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
//    // Move user from potential to selected
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        selectChattersViewController.moveToSelected(originalPotential[(indexPath as NSIndexPath).row])
//        originalPotential.remove(at: (indexPath as NSIndexPath).row)
//        
//        clearSearch()
//    }
//}
//
//// Search Bar Implementation
//extension PotentialChattersViewController: UISearchBarDelegate{
//    
//    // The filtering function.
//    func filterUsersForSearchText(_ searchText: String){
//        filteredPotential = originalPotential
//        if searchText != ""{
//            filteredPotential = filteredPotential.filter({ (user: SliceUser) -> Bool in
//                let stringMatch = user.username.lowercased().range(of: searchText.lowercased())
//                return (stringMatch != nil)
//            })
//        }
//        
//        filteredPotential.sort(by: {$0.username < $1.username})
//    }
//    
//    // Call filtering function when searchbar text is changed.
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        filterUsersForSearchText(searchText)
//        
//        tblPotential.reloadData()
//    }
//    
//    // Dismiss keyboard when search button on keyboard is pressed.
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
//        searchBar.resignFirstResponder()
//    }
//    
//}
//
//class PotentialChattersCell: UITableViewCell {
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
