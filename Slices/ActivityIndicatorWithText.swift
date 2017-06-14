import UIKit

class ActivityIndicatorWithText: UIVisualEffectView{
    
    var text: String? {
        didSet{
            label.text = text
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let vibrancyView: UIVisualEffectView
    
//    init(text: String) {
//        self.text = text
//        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
//        super.init(effect:blurEffect)
//        self.setup()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        self.text = ""
//        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
//        super.init(coder: aDecoder)
//        self.setup()
//    }
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect:blurEffect)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndicator)
        vibrancyView.contentView.addSubview(label)
        activityIndicator.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width: CGFloat = superview.frame.size.width / 2
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2, y: superview.frame.height / 2 - height / 2, width: width, height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40.0
            activityIndicator.frame = CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2, width: activityIndicatorSize, height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 15, height: height)
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
            
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide(){
        self.isHidden = true
    }
    
}
