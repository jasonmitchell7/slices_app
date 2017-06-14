//import UIKit
//import Alamofire
//import SwiftyJSON
//
//
//class SelectChattersViewController: UIViewController{
//    var privateTableViewController: PrivateTableViewController!
//    var selectedChattersViewController: SelectedChattersViewController!
//    var potentialChattersViewController: PotentialChattersViewController!
//    var gotFollowers: Bool = false
//    var potentialViewRequiresInitalArray: Bool = false
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        gotFollowers = false
//        currentUser?.requestFollowers({() -> Void in
//            if (self.potentialViewRequiresInitalArray){
//                self.potentialChattersViewController.setPotentialArray(currentUser!.followers!)
//            }
//            else{
//                self.gotFollowers = true
//            }
//        })
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "chattersToSelectedChatters"){
//            print("segued to selected chatters")
//            selectedChattersViewController = segue.destination as! SelectedChattersViewController
//            selectedChattersViewController.selectChattersViewController = self
//        
//        }
//        
//        if (segue.identifier == "chattersToPotentialChatters"){
//            print("segued to potential chatters")
//            potentialChattersViewController = segue.destination as! PotentialChattersViewController
//            potentialChattersViewController.selectChattersViewController = self
//            if (gotFollowers){
//                potentialChattersViewController.setPotentialArray(currentUser!.followers!)
//            }
//            else{
//                potentialViewRequiresInitalArray = true
//            }
//        }
//    }
//    
//    func moveToPotential(_ user: SliceUser!){
//        potentialChattersViewController.addUserToPotentialChatters(user)
//    }
//    
//    func moveToSelected(_ user: SliceUser!){
//        selectedChattersViewController.addUserToSelectedChatters(user)
//    }
//    
//    @IBAction func didPressCreateConvo(_ sender: UIBarButtonItem) {
//        privateTableViewController.requestCreateConversation(selectedChattersViewController.getSelectedChatterIDs())
//        
//        dismiss(animated: true, completion: nil)
//    }
//}
