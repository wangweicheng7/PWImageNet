//
//  PWDataDownloader.swift
//  PWImageNet
//
//  Created by 王炜程 on 16/7/4.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import Foundation

class PWDataDownloader: NSObject, NSURLSessionDataDelegate {
    
    private var completionHandler : PWDataDownloadCompletionClosure?
    private var progressClosure : PWDataDownloadProgressClosure?
    private var imageData : NSMutableData?
    private var session : NSURLSession!
    private var url : NSURL?
    private var expectedTotalSize : Int64 = 0
    private var downloadTotalSize : Int64 = 0
    private var timeout : Int?
    
    /**
     一个下载的实例，session 也不是单例
     
     - author: wangweicheng
     
     - returns: 下载实例
     */
    class func downloadInstance() -> PWDataDownloader {
        
        let downloader = PWDataDownloader()
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 120
        NSURLSession.sharedSession()
        let session = NSURLSession(configuration: sessionConfig,delegate: downloader, delegateQueue: NSOperationQueue.mainQueue())
        downloader.session = session
        
        
        return downloader
    }
    
    
    func downloadImageData(url : NSURL, completionHandler : PWDataDownloadCompletionClosure) {
        imageData(url, progressClosure: nil, completionHandler: completionHandler)
    
    }
    
    func imageData(url: NSURL, progressClosure: PWDataDownloadProgressClosure?, completionHandler: PWDataDownloadCompletionClosure?) {
        
        self.completionHandler = completionHandler
        self.url = url
        self.progressClosure    = progressClosure
        
        // request data from url
        let dataTask = session.dataTaskWithURL(url)
        dataTask.resume()
    }

    // MARK: NSURLSessionDataDelegate
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        expectedTotalSize = response.expectedContentLength

        if response.expectedContentLength <= 0 {
            completionHandler(.Cancel)
            return
        }
        imageData = NSMutableData(capacity: Int(response.expectedContentLength))
        completionHandler(.Allow)
    }
    
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        guard let imageData = imageData else{
            print(ERROR_DATA_MSG)
            return
        }
        
        downloadTotalSize += data.length
        
        if let progressClosure = progressClosure {
            progressClosure(receivedSize: downloadTotalSize, expectedSize: expectedTotalSize)
        }
        print(downloadTotalSize, expectedTotalSize)
        
        imageData.appendData(data)
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        session.invalidateAndCancel()
        
        guard let completionHandler = completionHandler else {
            return
        }
        completionHandler(data: imageData, error: error, url: url!, source: .Net)
        
        guard let imageData = imageData else {
            return
        }
        // 缓存到磁盘
        PWDataCache.shareInstance.cacheOnMemoryAndDisk(imageData, key: url!.absoluteString)

    }
}
