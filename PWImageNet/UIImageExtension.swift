//
//  UIImageExtension.swift
//  PWImageNetDemo
//
//  Created by 王炜程 on 16/7/7.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit
import ImageIO

enum PWImageType {
    case Unknwon
    case JPEG
    case PNG
    case GIF
    case TIFF
}

extension UIImage {
    
    class func imageFormat(data: NSData) -> UIImage? {
        if UIImage.contentType(data) == PWImageType.GIF {
            return UIImage.animatedImage(data: data)
        }else{
            return UIImage(data: data)
        }
    }
    
    class func contentType(url: NSURL) -> PWImageType {
        
        if let type = url.pathExtension {
            switch type.lowercaseString {
            case "jpg", "jpeg":
                return .JPEG
            case "png":
                return .PNG
            case "gif":
                return .GIF
            case "tiff":
                return .TIFF
            default:
                return .Unknwon
            }
        }
        return .Unknwon
    }
    
    class func contentType(imageData: NSData) -> PWImageType {
        var c = [UInt8](count: 1, repeatedValue: 0)
        imageData.getBytes(&c, length: 1)
        
        switch c[0] {
        case 0xFF:
            return .JPEG
        case 0x89:
            return .PNG
        case 0x47:
            return .GIF
        case 0x49, 0x4D:
            return .TIFF
        default:
            return .Unknwon
        }
    }
    
    class func animatedImage(data data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            return nil
        }
        return UIImage.animatedImage(source: source)
    }
    
    class func animatedImage(source source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var animatedImages = [CGImageRef]()
        var delays = [Int]()
        
        for i in 0..<count {
            
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                animatedImages.append(image)
            }
            
            let delay = UIImage.delayForImageAtIndex(i, source: source)
            delays.append(Int(delay * 1000.0)) // 转成毫秒存下来
            
        }
        
        // 计算总时长
        let duration: Int = {
            var sum = 0
            for val: Int in delays {
                sum += val
            }
            return sum
        }()
        
        // Get frames
        let gcd = UIImage.gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(CGImage: animatedImages[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
    
        let animation = UIImage.animatedImageWithImages(frames,
                                                        duration: Double(duration) / 1000.0)
        return animation
        
    }
    
    /**
     获取 gif 图片的每一帧的时间数组
     
     - author: wangweicheng
     
     - parameter index:  索引
     - parameter source: 图片源
     
     - returns: 帧数组
     */
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionaryRef = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                unsafeAddressOf(kCGImagePropertyGIFDictionary)),
            CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)),
            AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    
    
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
}
