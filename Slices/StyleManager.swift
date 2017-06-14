import UIKit
import AVFoundation

var styleMgr: StyleManager = StyleManager()

class StyleManager {
    
    let colorPrimary = UIColor(red: 0 / 255, green: 237 / 255, blue: 161 / 255, alpha: 1.0)
    let colorDark = UIColor(red: 54 / 255, green: 117 / 255, blue: 135 / 255, alpha: 1.0)
    let colorLight = UIColor(red: 19 / 255, green: 148 / 255, blue: 186 / 255, alpha: 1.0)
    let colorYellow = UIColor(red: 237 / 255, green: 253 / 255, blue: 0, alpha: 1.0)
    let colorRed = UIColor(red: 195 / 255, green: 23 / 255, blue: 11 / 255, alpha: 1.0)
    let colorOffWhite = UIColor(red: 236 / 255, green: 240 / 255, blue: 241 / 255, alpha: 1.0)
    let colorGrey = UIColor(red: 44 / 255, green: 62 / 255, blue: 80 / 255, alpha: 1.0)
    let colorLightGrey = UIColor(red: 186 / 255, green: 186 / 255, blue: 186 / 255, alpha: 1.0)
    
    let assetExportQuality = AVAssetExportPresetMediumQuality
    
    var hasShownLoadedAnimation = false
    
    func getButtonStyle() -> (size: borderSize, color: borderColor, radius: cornerRadius) {
        return (size: borderSize.small, color: borderColor.white, radius: cornerRadius.medium)
    }
    
    func getTimelineStyle() -> (size: borderSize, color: borderColor, radius: cornerRadius) {
        return (size: borderSize.small, color: borderColor.white, radius: cornerRadius.small)
    }
    func getUserPhotoStyle() -> (size: borderSize, radius: cornerRadius) {
        return (size: borderSize.medium, radius: cornerRadius.large)
    }
}
