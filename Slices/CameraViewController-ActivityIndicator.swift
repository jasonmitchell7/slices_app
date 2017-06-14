extension CameraViewController {
        func showActivityIndicatorWithText(text: String) {
            actInd = ActivityIndicatorWithText(text: text)
            self.view.addSubview(actInd)
            actInd.show()
        }
    
        func hideActivityIndicator() {
            actInd.hide()
            actInd.removeFromSuperview()
        }
}
