import UIKit

extension UIImage {
    
    public func fixImageFromCamera() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.draw(in: CGRect(x: 0,
                             y: 0,
                             width: self.size.width,
                             height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func cropImageToSquare() -> UIImage {

        let contextImage: UIImage = UIImage(cgImage: self.cgImage!)
        
        let contextSize = contextImage.size
        
        let newSize = contextSize.width
        
        let posX: CGFloat = 0
        let posY: CGFloat = ((contextSize.height - contextSize.width) / 2)
        let width: CGFloat = newSize
        let height: CGFloat = newSize
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        let squareImage: UIImage = UIImage(cgImage: imageRef)
        
        return squareImage
    }
    
    
    func resizeImage(toTargetSize: Int) -> UIImage? {
        let targetSize = CGSize(width: toTargetSize, height: toTargetSize)
        
        let image = self
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

//
//  RBResizer.swift
//  Locker
//
//  Created by Hampton Catlin on 6/20/14.
//  Copyright (c) 2014 rarebit. All rights reserved.
//


func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage? {
    return RBResizeImage(RBSquareImage(image), targetSize: size)
}

func RBSquareImageLargest(_ image:UIImage) -> UIImage? {
    
    let smallerSize = ((image.size.width < image.size.height) ? image.size.width : image.size.height)
    
    let newSize = CGSize(width: smallerSize, height: smallerSize)
    
    return RBResizeImage(RBSquareImage(image), targetSize: newSize)
}

func RBSquareImage(_ image: UIImage) -> UIImage? {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height
    
    var edge: CGFloat
    if originalWidth > originalHeight {
        edge = originalHeight
    } else {
        edge = originalWidth
    }
    
    let posX = (originalWidth  - edge) / 2.0
    let posY = (originalHeight - edge) / 2.0
    
    let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
    
    let imageRef = image.cgImage?.cropping(to: cropSquare);
    return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
}

func RBResizeImage(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
    if let image = image {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    } else {
        return nil
    }
}
