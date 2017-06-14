var helpMgr: HelpManager = HelpManager()

class HelpManager: NSObject {
    enum helpSettingType {
        case general
        case camera
    }
    
    var helpEnabled = true
    var helpSettings = [helpSettingType : Bool]()
    
    func setHelpSetting(setting: helpSettingType, turnOn: Bool) {
        helpSettings.updateValue(turnOn, forKey: setting)
    }
    
    func getHelpSetting(setting: helpSettingType) -> Bool {
        if let value = helpSettings[setting] {
            return value
        }
        else {
            return true
        }
    }
    
    func shouldShowHelp(forSetting: helpSettingType) -> Bool {
        if helpEnabled == true {
            return getHelpSetting(setting: forSetting)
        }
        
        return false
    }
}
