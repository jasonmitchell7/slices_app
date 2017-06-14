import UIKit

enum borderSize {
    case large
    case medium
    case small
    case none
}

enum cornerRadius {
    case large
    case medium
    case small
    case none
}

enum borderColor {
    case black
    case dark
    case light
    case white
    case primary
    case none
}

extension UIView {
    
    func addBorder(size: borderSize, color: borderColor, radius: cornerRadius) {
        if (size != .none) {
            self.layer.borderWidth = getBorderWidth(size: size)
        }
        self.layer.borderColor = getBorderColor(color: color)
        if (radius != .none) {
            self.layer.cornerRadius = getCornerRadius(radius: radius)
        }
        self.layer.masksToBounds = true
    }
    
    func addBorder(size: borderSize, color: borderColor, radius: CGFloat) {
        if (size != .none) {
            self.layer.borderWidth = getBorderWidth(size: size)
        }
        self.layer.borderColor = getBorderColor(color: color)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func addBorderForButton() {
        let style = styleMgr.getButtonStyle()
        addBorder(size: style.size, color: style.color, radius: style.radius)
    }
    
    func addBorderForTimeline() {
        let style = styleMgr.getTimelineStyle()
        addBorder(size: style.size, color: style.color, radius: style.radius)
    }
    
    func addBorderForUserPhoto(color: borderColor) {
        let style = styleMgr.getUserPhotoStyle()
        addBorder(size: style.size, color: color, radius: style.radius)
    }
    
    private func getBorderWidth(size: borderSize) -> CGFloat {
        switch (size) {
        case .large:
            return 3.0
        case .medium:
            return 2.0
        case .small:
            return 1.0
        case .none:
            return 0.0
        }
    }
    
    private func getBorderColor(color: borderColor) -> CGColor {
        switch (color) {
        case .black:
            return UIColor.black.cgColor
        case .dark:
            return styleMgr.colorDark.cgColor
        case .light:
            return styleMgr.colorLight.cgColor
        case .white:
            return UIColor.white.cgColor
        case .primary:
            return styleMgr.colorPrimary.cgColor
        case .none:
            return UIColor(white: 1.0, alpha: 0.0).cgColor
        }
    }
    
    private func getCornerRadius(radius: cornerRadius) -> CGFloat {
        switch (radius) {
        case .large:
            return 8.0
        case .medium:
            return 4.0
        case .small:
            return 2.0
        case .none:
            return 0.0
        }
    }
}
