//import UIKit
//import Alamofire
//import SwiftyJSON
//
//
//class PrivateTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
//    
//    @IBOutlet weak var tblConvos: UITableView!
//    var convosJSON = [JSON]()
//    var convos = [Conversation]()
//    var newConvoTitle: String!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Remove separators below the table view to clean up the look.
//        tblConvos.tableFooterView = UIView(frame: CGRect.zero)
//        
//    }
//    
//    func reloadTable(){
//        tblConvos.reloadData()
//    }
//    
//    
//    @IBAction func newConvoPressed(_ sender: UIBarButtonItem) {
//        let newConvoAlert = UIAlertController(title: "New Conversation", message: "Name your new conversation:", preferredStyle: .alert)
//        
//        let createAction = UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) -> Void in
//            self.newConvoTitle = newConvoAlert.textFields!.first!.text!
//    
//            self.performSegue(withIdentifier: "privateShowSelectChatters", sender: self)
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) -> Void in })
//        
//        newConvoAlert.addTextField(configurationHandler: { (textField: UITextField) -> Void in })
//        
//        newConvoAlert.addAction(cancelAction)
//        newConvoAlert.addAction(createAction)
//        
//        present(newConvoAlert, animated: true, completion: nil)
//    }
//    
//    func chattersArrayToString(_ chatters: [Int]) -> String{
//        var chattersStr = "["
//        
//        //for (var i = 0; i < (chatters.count-1); i += 1) {
//        for i in 0 ..< (chatters.count-1){
//            chattersStr = chattersStr + "\(chatters[i]),"
//        }
//        
//        chattersStr = chattersStr + "\(chatters[chatters.count-1])]"
//        
//        return chattersStr
//    }
//    
//    func requestCreateConversation(_ chatters: [Int]){
//        let url = ApiHelper.BASE_URL + "/create_convo"
//        
//        let chattersStr = chattersArrayToString(chatters)
//        
//        let params: [String : String]? = ["title": newConvoTitle, "chatters": chattersStr]
//        
//        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
//            switch response.result{
//            case .success(let data):
//                let json = JSON(data)
//                
//                print("\(data)")
//                
//                let errorMessage = json["message"].string
//                let status = json["status"].int
//                
//                if (errorMessage != nil && status != 200)
//                {
//                    // Display Modal Alert
//                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    
//                    return
//                }
//                else{
//                    let newConvo = Conversation()
//                    newConvo.title = self.newConvoTitle
//                    for id in chatters{
//                        let newUser = SliceUser()
//                        newUser.userId = id
//                        newUser.requestUserInfo(id, isRequestingSelf: false, completion: {(success) -> Void in
//                            if (success){
//                                newUser.requestUserPhoto({() -> Void in
//                                    newConvo.users.append(newUser)
//                                    if (newConvo.users.count == chatters.count){
//                                        self.convos.append(newConvo)
//                                        self.reloadTable()
//                                    }
//                                })
//                                
//                            }
//                            else
//                            {
//                                print("User info request failed in conversation creation for user: \(id)")
//                            }
//                        })
//                        
//                    }
//                }
//                
//            case .failure(let error):
//                print("Create conversation request failed with error: \(error)")
//            }
//        }
//    }
//    
//    // Returning To View
//    override func viewWillAppear(_ animated: Bool) {
//        getConversationData({(success) -> Void in
//        })
//    }
//    
//    func getConversationData(_ completion: @escaping (_ success: Bool) -> Void){
//        convos.removeAll()
//        
//        let url = ApiHelper.BASE_URL + "/get_convos"
//        
//        Alamofire.request(url, method: .get, parameters: nil, headers: apiHelper.authTokenHeader()).responseJSON { response in
//            switch response.result{
//            case .success(let data):
//                let json = JSON(data)
//                
//                if (json == nil ){
//                    print("Recieved null json object when requesting recipes.")
//                    
//                    completion(false)
//                    return
//                }
//                
//                self.convosJSON = json.array!
//                
//                self.loadIndividiualConvos(0)
//                
//                completion(true)
//                
//            case .failure(let error):
//                print("Request failed with error: \(error)")
//                
//                completion(false)
//            }
//        }
//
//    }
//    
//    func loadIndividiualConvos(_ index: Int){
//        if (index == self.convosJSON.count){
//            return
//        }
//        let newConvo = Conversation()
//        newConvo.createConversationFromJSON(convosJSON[index].dictionary!, completion:{ () -> Void in
//            newConvo.loadStatus = Conversation.ConvoLoadStatus.loaded
//            self.convos.append(newConvo)
//            self.reloadTable()
//            self.loadIndividiualConvos(index + 1)
//        })
//    }
//    
//    // Implement UITableViewDataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return convos.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ConvoCell",for:indexPath) as! PrivateTableViewCell
//        
//        if ((indexPath as NSIndexPath).row % 2 == 0){
//            cell.backgroundColor = styleMgr.colorLight
//            cell.viewParticipants.backgroundColor = styleMgr.colorLight
//        }
//        else{
//            cell.backgroundColor = UIColor.white
//            cell.viewParticipants.backgroundColor = UIColor.white
//        }
//        
//        cell.lblTitle.text = convos[(indexPath as NSIndexPath).row].title
//        cell.loadParticipants(convos[(indexPath as NSIndexPath).row].users)
//        
//        return cell
//        
//    }
//    
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        case .delete:
//            self.convos[(indexPath as NSIndexPath).row].requestLeaveConversation({(success) -> Void in
//                if (success){
//                    self.convos.remove(at: (indexPath as NSIndexPath).row)
//                    self.reloadTable()
//                }
//                else{
//                    print("Error when requesting to leave conversation from private table view.")
//                }
//            })
//            
//        default:
//            return
//        }
//    }
//    
//    // Select and push to slice scroll view.
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        self.performSegue(withIdentifier: "privateToSliceScrollView", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "privateToSliceScrollView" {
//            let slicesScrollView = segue.destination as! SliceScrollViewController
//            
//            slicesScrollView.setSliceContext(self.convos[(tblConvos.indexPathForSelectedRow! as NSIndexPath).row].id,
//                                           fromUser: nil)
//        }
//        
//        if segue.identifier == "privateShowSelectChatters" {
//            let chatterSelectVC = segue.destination as! SelectChattersViewController
//            
//            chatterSelectVC.privateTableViewController = self
//        }
//    }
//    
//}
//
//class PrivateTableViewCell: UITableViewCell{
//    
//    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var viewParticipants: UIView!
//    @IBOutlet weak var lblAndMore: UILabel!
//    
//    var participants = [SliceUser]()
//    var participantImageViews = [UIImageView]()
//    let participantViewPadding = CGFloat(3)
//    
//    func loadParticipants(_ userArray: [SliceUser]){
//        var currentPosition = participantViewPadding
//        var userIndex = 0
//        
//        removeParticipantImageViews()
//        
//        lblAndMore.isHidden = true
//        
//        participants = userArray.sorted(by: {$0.convoContributions > $1.convoContributions})
//        
//        print("User array count: \(userArray.count)")
//        print("Participant count: \(participants.count)")
//        
//        while(userIndex < participants.count){
//            print("user index: \(userIndex)")
//            if( currentPosition > viewParticipants.frame.width - participantViewPadding){
//                lblAndMore.isHidden = false
//                break
//            }
//            
//            if (participants[userIndex].userId != currentUser!.userId){
//                let participantImageView = UIImageView(frame: CGRect(x: currentPosition, y: 0, width: viewParticipants.frame.height, height: viewParticipants.frame.height))
//                participants[userIndex].requestUserPhoto({() -> Void in
//                    
//                    participantImageView.image = self.participants[userIndex].photoImg
//                    if (self.participants[userIndex].photoId != nil){
//                        participantImageView.layer.borderWidth = 2.0
//                        participantImageView.layer.borderColor = styleMgr.colorOffWhite.cgColor
//                        participantImageView.layer.cornerRadius = 8.0
//                        participantImageView.layer.masksToBounds = true
//                        self.participantImageViews.append(participantImageView)
//                    }
//                    
//                    self.viewParticipants.addSubview(participantImageView)
//                })
//                currentPosition = currentPosition + self.viewParticipants.frame.height + self.participantViewPadding
//            }
//            
//            userIndex = userIndex + 1
//        }
//    }
//    
//    func removeParticipantImageViews(){
//        for imageView in participantImageViews{
//            imageView.delete(self)
//        }
//    }
//}
