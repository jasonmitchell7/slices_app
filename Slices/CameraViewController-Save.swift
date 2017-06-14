import UIKit

extension CameraViewController {
    func saveImage(image: UIImage?) {
        if let img = image {
            albumMgr.saveImage(img, completion: {(success) -> Void in
                if (success == true) {
                    let alert = UIAlertController(title: "Saved", message: "Saved successfully!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Could Not Save", message: "Make sure Slices has access to your Photos.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Back", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            print("Error while saving image: No image found.")
        }
    }
}
