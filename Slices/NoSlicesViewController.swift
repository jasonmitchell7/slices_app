import UIKit

class NoSlicesViewController: SlicesViewControllerWithNav {
    
    public var navController: UINavigationController?
    
    @IBOutlet weak var findFriends: UIButton!
    
    @IBAction func didPressFindFriends(_ sender: UIButton) {
        let findFriendsViewController = FindFriendsViewController(nibName: "FindFriendsView", bundle: nil)
        navController?.pushViewController(findFriendsViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        findFriends.addBorderForButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slicesCircularMainMenu.sliceTableViewController?.loadSlices()
    }
    
}
