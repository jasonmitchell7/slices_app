import UIKit
import AVFoundation

@IBDesignable class UserMediaView: UIImageView {
    var user: SliceUser! {
        didSet{
            loadUser()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
        setupView()
    }
    
    private func setupView() {
        self.contentMode = .scaleAspectFit
        //self.isHidden = true
        self.addBorder(size: .medium, color: .primary, radius: .none)
        self.layer.cornerRadius = self.frame.height / 2.0
    }
    
    private func loadUser() {
        if (user != nil) {
            user.requestUserPhoto({ () -> Void in
                logger.message(type: .debug, message: "Got photo for user \(self.user.userId!).")
                self.isHidden = false
                self.image = self.user.photoImg!
            })
        }
        else {
            self.image = nil
            //self.isHidden = true
        }
    }
}
