import UIKit
import Alamofire
import SwiftyJSON

class NotificationsTableViewController: UITableViewController{

    @IBOutlet var tblNotifications: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove separators below the table view to clean up the look.
        tblNotifications.tableFooterView = UIView(frame: CGRect.zero)
    }

    // Returning To View
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// TableView Implementation
extension NotificationsTableViewController{
    
    // Implement UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell",for:indexPath) as! NotificationTableViewCell
        
        if ((indexPath as NSIndexPath).row % 2 == 0){
            cell.backgroundColor = styleMgr.colorLight
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
}

class NotificationTableViewCell: UITableViewCell {
    
    
}

