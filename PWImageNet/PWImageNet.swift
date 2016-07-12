//
//  PWImageNet.swift
//  PWImageNet
//
//  Created by 王炜程 on 16/7/4.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit

public class PWImageNet: NSObject {
    

    /**
     从网络拉取图片
     
     - author: wangweicheng
     
     - parameter url:               图片地址
     - parameter placeholder:       占位图片
     - parameter progress:          进度回调
     - parameter completionHandler: 拉取成功的回调
     */
    public class func fetchImage(url : NSURL, placeholder : UIImage?, completionHandler : PWImageFetchCompletionClosure) {
        fetchImage(url, placeholder: placeholder, progress: nil, completionHandler: completionHandler)
    }
    
    public class func fetchImage(url : NSURL, placeholder : UIImage?,progress: PWDataDownloadProgressClosure?, completionHandler : PWImageFetchCompletionClosure) {
        
        if let imageData = PWDataCache.shareInstance.dataFromCache(url.absoluteString) {
            dispatch_async(dispatch_get_main_queue(), {
                
                    completionHandler(image: UIImage.imageFormat(imageData), error: nil, url: url, source: .Cache)
            })
            return
        }
        

        let downloader = PWDataDownloader(url: url)
        downloader.startDownload(progress: progress) { (data, error, url, source) in
            
                // data is not nil
                if let data = data {
                    let image = UIImage.imageFormat(data)
                    // image load success
                    if image != nil {
                        completionHandler(image: image,error: error, url: url, source: .Net)
                        return
                    }
                }
                
                var aError : NSError
                if let error = error {
                    let domain = "图片加载失败: " + error.domain
                    aError = NSError(domain: domain, code: error.code, userInfo: error.userInfo)
                }else{
                    aError = NSError(domain: "图片加载失败", code: -1, userInfo: nil)
                }
                completionHandler(image: placeholder, error: aError, url: url, source: .Net)
        }
        
        if let _ = placeholder {
            completionHandler(image: placeholder, error: nil, url: nil, source: .None)
        }
        
    }
    
}
