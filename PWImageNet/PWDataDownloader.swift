//
//  PWDataDownloader.swift
//  PWImageNetDemo
//
//  Created by 王炜程 on 16/7/12.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit

class PWDataDownloader: NSObject,NSURLSessionDataDelegate {
    
    var completionHandler : PWDataDownloadCompletionClosure?
    var progressClosure : PWDataDownloadProgressClosure?
        
    private var imageData : NSMutableData?
    private var session : NSURLSession!
    
    private var expectedTotalSize : Int64 = 0
    private var downloadTotalSize : Int64 = 0
    private var timeout : Int?
    
    var url : NSURL?
    //    var dataTask : NSURLSessionDataTask?
    
    init(url : NSURL) {
        super.init()

        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForRequest = 120
        self.session = NSURLSession(configuration: sessionConfig,delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        self.url = url
    }
    
    override init() {
        super.init()
        fatalError("请使用 init(url : NSURL) 初始化")
    }
    
    /*
    func startWork(url: NSURL, progressClosure: PWDataDownloadProgressClosure?, completionHandler: PWDataDownloadCompletionClosure?) {
        
        self.completionHandler = completionHandler
        self.url = url
        self.progressClosure    = progressClosure
        
        // request data from url
        let dataTask = session.dataTaskWithURL(url)
        dataTask.resume()
    }
 */
    
    func startDownload(progress progressClosure: PWDataDownloadProgressClosure?, completion completionHandler: PWDataDownloadCompletionClosure?) {
        
        self.completionHandler = completionHandler
        self.progressClosure    = progressClosure
        
        PWTransferManager.addDownloader(self)
        
        // 如果任务在进行中，中断
        if PWTransferManager.isDownloading(self) {
            return
        }
        
        guard let url = url else {
            print("没有可用的url")
            return
        }
        
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
        
        let downloaders = PWTransferManager.downloadersForURL(url!)
        if downloaders != nil {
            
            for downloader in downloaders! {
                if downloader.progressClosure != nil {
                    downloader.progressClosure!(receivedSize: downloadTotalSize, expectedSize: expectedTotalSize)
                }
            }
        }
        
        print(downloadTotalSize, expectedTotalSize)
        
        imageData.appendData(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        session.invalidateAndCancel()
        
        let downloaders = PWTransferManager.downloadersForURL(url!)
        if downloaders != nil {
            
            for downloader in downloaders! {
                if downloader.completionHandler != nil {
                    downloader.completionHandler!(data: imageData, error: error, url: url!, source: .Net)
                }
            }
            PWTransferManager.removeDownloadForURL(url!)
        }
        
        guard let imageData = imageData else {
            return
        }
        // 缓存到磁盘
        PWDataCache.shareInstance.cacheOnMemoryAndDisk(imageData, key: url!.absoluteString)
        
    }
    
}
