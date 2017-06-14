import UIKit

extension CameraViewController {
    
    func registerGestureRecognizers() {
        let tapPreviewRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(capturePhotoTap(gestureRecognizer:)))
        viewPreview.addGestureRecognizer(tapPreviewRecognizer)
        
        let tapMainRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(resetCamera(gestureRecognizer:)))
        imgMain.addGestureRecognizer(tapMainRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self,
                                                           action: #selector(swipeSide(gestureRecognizer:)))
        swipeLeftRecognizer.direction = .left
        viewPreview.addGestureRecognizer(swipeLeftRecognizer)
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self,
                                                            action: #selector(swipeSide(gestureRecognizer:)))
        swipeRightRecognizer.direction = .right
        viewPreview.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self,
                                                         action: #selector(swipeUpOrDown(gestureRecognizer:)))
        swipeUpRecognizer.direction = .up
        viewPreview.addGestureRecognizer(swipeUpRecognizer)
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self,
                                                           action: #selector(swipeUpOrDown(gestureRecognizer:)))
        swipeDownRecognizer.direction = .down
        viewPreview.addGestureRecognizer(swipeDownRecognizer)
    }
    
    func swipeSide(gestureRecognizer: UISwipeGestureRecognizer) {
        logger.message(type: .information, message: "Swiped camera, changing selected camera position.")
        currentCameraPosition = currentCameraPosition == .front ? .back : .front
        changeCameraPosition()
    }
    
    func swipeUpOrDown(gestureRecognizer: UISwipeGestureRecognizer) {
        logger.message(type: .information, message: "Swiped camera, changing flash mode.")
        changeFlashMode()
    }
    
    func resetCamera(gestureRecognizer: UITapGestureRecognizer) {
        logger.message(type: .information, message: "Resetting the camera.")
        sliceTimeline?.selectedTimelineBlockIndex = nil
    }
    
}
