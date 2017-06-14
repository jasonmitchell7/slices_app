import UIKit


class SettingsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var settingsInfo: SliceSettings = SliceSettings()
    let actIndUpdate = ActivityIndicatorWithText(text: "Updating...")
    let actIndGetSettings = ActivityIndicatorWithText(text: "Loading...")
    
    let tableViewSections = [""]
    
    public func reloadTable() {
        tableView.reloadData()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(actIndUpdate)
        actIndUpdate.hide()
        self.view.addSubview(actIndGetSettings)
        actIndGetSettings.hide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        actIndGetSettings.show()
        
        settingsInfo.requestSettingsInfo({(success) -> Void in
            self.reloadTable()
            self.actIndGetSettings.hide()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        actIndUpdate.show()
        
        settingsInfo.updateSettingsInfo({(success) -> Void in
            if (success){
                self.actIndUpdate.hide()
                super.viewWillDisappear(animated)
            }
            else{
                let alert = UIAlertController(title: "Error", message: "Failed to update settings.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: {(action) -> Void in
                        self.actIndUpdate.hide()
                        super.viewWillDisappear(animated)
                    })
                )
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsInfo.getSettingsSectionsList().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return settingsInfo.getPrivacySettingsCount()
        }
        
        return settingsInfo.getNotificationSettingsCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(64.0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsInfo.getSettingsSectionsList()[section]
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "SettingsCell"
        
        var cell: SettingsCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? SettingsCell
        
        if (cell == nil) {
            tableView.register(UINib(nibName: "SettingsCellView", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? SettingsCell
        }
        
        cell?.updateSetting(value: settingsInfo.getSettingsList()[indexPath.section][indexPath.row].0,
                           name: settingsInfo.getSettingsList()[indexPath.section][indexPath.row].1,
                           settingsTableViewController: self)
        
        return cell!
    }
}

class SettingsCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    weak var settingsTableViewController: SettingsTableViewController?
    
    public func updateSetting(value: Bool, name: String, settingsTableViewController: SettingsTableViewController) {
        if (self.settingsTableViewController == nil) {
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: UIControlEvents.valueChanged)
        }
        
        lblName.text = name
        toggle.isOn = value
        
        self.settingsTableViewController = settingsTableViewController
    }
    
    func switchChanged(_ sender: UISwitch!) {
        let name = lblName.text == nil ? "" : lblName.text!
        settingsTableViewController?.settingsInfo.updateValueForSetting(value: sender.isOn, name: name)
        settingsTableViewController?.reloadTable()
    }
}


