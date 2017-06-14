import UIKit

class SliceTableViewController: SlicesViewControllerWithNav, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var noSlicesViewController: NoSlicesViewController?
    var confirmEmailModal: ConfirmEmailView?
    
    private struct SliceContext {
        var convoID: Int?
        var fromUser: Int?
    }
    
    private var sliceContext = SliceContext(convoID: nil, fromUser: nil)
    
    var slices = [Slice]() {
        didSet {
            reloadSlicesTable()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SliceCellView", bundle: nil), forCellReuseIdentifier: "SliceCell")
        
        // The first SliceTableViewController to load is our root view controller, and sets itself to be such in our menu.
        slicesCircularMainMenu.setRootSlicesTableViewController(to: self)
        
        showLoadedAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.hidesBarsOnSwipe = true
        
        loadSlices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
    }
    
    func setSliceContext(convoID: Int?, fromUser: Int?) {
        sliceContext.convoID = convoID
        sliceContext.fromUser = fromUser
        
        loadSlices()
    }
    
    func clearSliceContext() {
        setSliceContext(convoID: nil, fromUser: nil)
    }
    
    func showConfirmEmailModal() {
        if (confirmEmailModal == nil) {
            confirmEmailModal = ConfirmEmailView()
            confirmEmailModal?.frame = self.view.frame
            confirmEmailModal?.bounds = self.view.bounds
            confirmEmailModal?.setup(blurBackground: true)
            
            UIApplication.shared.keyWindow?.addSubview(confirmEmailModal!)
        }
    }
    
    func showNoSlicesView() {
        logger.message(type: .debug, message: "Showing view for no Slices...")
        
        if (noSlicesViewController == nil){
            noSlicesViewController = NoSlicesViewController(nibName: "NoSlicesView", bundle: nil)
            noSlicesViewController!.didMove(toParentViewController: self)
            noSlicesViewController!.navController = self.navigationController
        }
        self.view.addSubview(noSlicesViewController!.view)
        noSlicesViewController!.didMove(toParentViewController: self)
        noSlicesViewController!.view.frame = self.view.frame
        noSlicesViewController!.view.bounds = self.view.bounds
        
//        navigationController?.hidesBarsOnSwipe = false
        
        tableView.isHidden = true
        tableView.isUserInteractionEnabled = false
    }
    
    func hideNoSlicesView() {
        logger.message(type: .debug, message: "Hiding view for no Slices...")
        
        if (noSlicesViewController != nil) {
            noSlicesViewController?.view.isHidden = true
            noSlicesViewController?.removeFromParentViewController()
            noSlicesViewController = nil
        }
        
//        navigationController?.hidesBarsOnSwipe = true
        
        tableView.isHidden = false
        tableView.isUserInteractionEnabled = true
    }
    
    func reloadSlicesTable() {
        if (slices.isEmpty) {
            showNoSlicesView()
        } else {
            hideNoSlicesView()
        }
        
        tableView.reloadData()
        
        if (currentUser?.emailConfirmed == false) {
            showConfirmEmailModal()
        }
    }
    
    func loadSlices() {
        sessionMgr.checkLoggedIn({(success) -> Void in
            logger.message(type: .debug, message: "Slice Table View checking if User is logged in.")
            if (success == true && currentUser != nil){
                logger.message(type: .debug, message: "Slice Table View requesting Slices.")
                
                currentUser!.requestSlices(self.sliceContext.convoID, fromUser: self.sliceContext.fromUser, count: 5, currentView: self, completion: {(success, slices) -> Void in
                    if (success == true){
                        logger.message(type: .debug, message: "Slice Table View Slice request succeeded, setting Slices.")
                        self.slices = slices!
                    }
                    else
                    {
                        logger.message(type: .error, message: "Slice request failed in Slice Table View with the following params -- convoID: \(self.sliceContext.convoID), fromUser: \(self.sliceContext.fromUser)")
                        self.slices = [Slice]()
                    }
                })
            }
        })

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slices.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        logger.message(type: .debug, message: "Slice Table View getting Slice \(slices[indexPath.row].sliceID!) for row \(indexPath.row).")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SliceCell",
                                                 for: indexPath) as! SliceCellViewController
        
        cell.navController = navigationController
        cell.slice = slices[indexPath.row]
        
        return cell
        
    }

//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        //return slices[indexPath.row].getHeightForDisplay(bounds: tableView.bounds.size)
//        return tableView.bounds.size.height
//    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? SliceCellViewController)?.sliceMediaView.play()
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            (cell as? SliceCellViewController)?.sliceMediaView.pause()
    }
    
}
