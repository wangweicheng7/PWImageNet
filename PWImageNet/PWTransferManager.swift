//
//  PWTransferManager.swift
//  PWImageNet
//
//  Created by 王炜程 on 16/7/4.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import Foundation

class PWSessionAction {
    var completionHandler : PWDataDownloadCompletionClosure?
    var progressClosure : PWDataDownloadProgressClosure?
}

class PWTransferManager: NSObject, NSURLSessionDataDelegate {
    
//    private var completionHandler : PWDataDownloadCompletionClosure?
//    private var progressClosure : PWDataDownloadProgressClosure?
//    private var imageData : NSMutableData?
//    private var session : NSURLSession!
    private var url : NSURL?
//    private var expectedTotalSize : Int64 = 0
//    private var downloadTotalSize : Int64 = 0
//    private var timeout : Int?

    private var downloaders = [String : [PWDataDownloader]]()
    
    static let shareInstance = PWTransferManager()
    
    class func startDownload(url: NSURL, progressClosure: PWDataDownloadProgressClosure?, completionHandler: PWDataDownloadCompletionClosure?) {
        
        let downloader = PWDataDownloader(url: url)
        
        PWTransferManager.addDownloader(downloader)
        
        let count = PWTransferManager.countOfDownloader(downloader)
        
        if count != nil && count > 1 {
            downloader.completionHandler = completionHandler
            downloader.progressClosure = progressClosure
            return
        }
        
//        let sessionWorks = PWTransferManager.sessionWorksForURL(sessionWork.url!)
        
//         回调要调给所有的任务


        //        sessionWork.startWork(<#T##progressClosure: PWDataDownloadProgressClosure?##PWDataDownloadProgressClosure?##(receivedSize: Int64, expectedSize: Int64) -> Void#>, completionHandler: <#T##PWDataDownloadCompletionClosure?##PWDataDownloadCompletionClosure?##(data: NSData?, error: NSError?, url: NSURL, source: PWImageSourceType) -> Void#>)
        
        
//        downloader.startWork({ (receivedSize, expectedSize) in
//                for aSessionWork in sessionWorks {
//                    if aSessionWork == sessionWork {
//                        progressClosure!(receivedSize: receivedSize, expectedSize: expectedSize)
//                    }
//                    aSessionWork.progressClosure!(receivedSize: receivedSize, expectedSize: expectedSize)
//                }
//            }) { (data, error, url, source) in
//                    for aSessionWork in sessionWorks {
//                        aSessionWork.completionHandler!(data: data, error: error, url: url, source: source)
//                    }
//                // 一个url请求完成是，要任务列表中删除任务
//                PWTransferManager.removeSessionWorkForURL(sessionWork.url!)
//        }
    }
    
    class func startDownload(url : NSURL, completionHandler : PWDataDownloadCompletionClosure) {
        
//        PWSessionWorking.instance().imageData(url, progressClosure: nil, completionHandler: completionHandler)
    
    }

}

extension PWTransferManager {
    
    /**
     是否有任务在下载
     
     - author: wangweicheng
     */
    class func isDownloading(downloader : PWDataDownloader) -> Bool {
        
        let count = PWTransferManager.countOfDownloader(downloader)
        
        return (count != nil && count > 1)

    }
    
    class func addDownloader(downloader : PWDataDownloader) {
        
        let key = downloader.url!.absoluteString.md5
        
        var downloaders = PWTransferManager.shareInstance.downloaders[key]
        if downloaders != nil {
            downloaders!.append(downloader)
            PWTransferManager.shareInstance.downloaders[key] = downloaders!
            return
        }
        PWTransferManager.shareInstance.downloaders[key] = [downloader]

    }
    
    
    class func removeDownloadForURL(URL : NSURL) {

        let key = URL.absoluteString.md5
        PWTransferManager.shareInstance.downloaders.removeValueForKey(key)
        
    }
    
    class func countOfDownloader(downloader : PWDataDownloader) -> Int? {
        let key = downloader.url!.absoluteString.md5
        let downloaders = PWTransferManager.shareInstance.downloaders[key]
        return downloaders?.count
        
    }
    
    class func downloadersForURL(URL : NSURL) -> [PWDataDownloader]? {
        
        let key = URL.absoluteString.md5
        let downloaders = PWTransferManager.shareInstance.downloaders[key]
        
        return downloaders
    }
    
//    class func sessionWorksForURL(URL : NSURL) -> [PWDataDownloader] {
//        
//        let key = URL.absoluteString.md5
//        let sessionWorks = PWTransferManager.shareInstance.sessionWorks[key]
//        guard let _ = sessionWorks else {
//            return [PWSessionWork]()
//        }
//        return sessionWorks!
//        
//    }
}

