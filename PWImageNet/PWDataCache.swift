//
//  PWDataCache.swift
//  PWImageNet
//
//  Created by 王炜程 on 16/7/4.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit
//import CommonCrypto
//import CommonCrypto
let cacheQueue = dispatch_queue_create("com.putao.imageCache.queue", DISPATCH_QUEUE_SERIAL)

public class PWDataCache: NSObject {
    
    // 是否加载到内存中，如果选择false，则缓存在磁盘的文件每次都从磁盘加载
    public var cacheType : PWImageNetCacheType = .MemoryAndDisk
    /// 磁盘缓存大小，默认100MB
    public var maxDiskCacheSize : Int = 2
    
    private let cache = NSCache()
    
    public class var shareInstance: PWDataCache {
        struct __ {
            static let instance = PWDataCache()
        }
//        __.instance.cache.countLimit = 500
        return __.instance
    }
    
    override init() {
        super.init()
        // 进入后台后，检查一次缓存
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PWDataCache.clearExpiredCacheFromDisk), name: UIApplicationDidEnterBackgroundNotification, object: nil)


    }
    
    /**
     将数据根据缓存策略缓存下来
     
     - author: wangweicheng
     
     - parameter data: 数据
     - parameter key:  标识
     */
    func cacheOnMemoryAndDisk(data: NSData, key: String) {
        if cacheType == PWImageNetCacheType.None {
            return
        }
        cacheOnMemory(data, key: key)
        cacheOnDisk(data, key: key)
    }
    
    /**
     把数据缓存到内存中
     
     - author: wangweicheng
     
     - parameter data: 数据
     - parameter key:  标识
     */
    func cacheOnMemory(data: NSData, key: String) {
        
        if cacheType == PWImageNetCacheType.OnlyMemory ||
            cacheType == PWImageNetCacheType.MemoryAndDisk {
            cache.setObject(data, forKey: key)    // 缓存到内存中
        }
    }
    /**
     把数据流存储到磁盘，当缓存类型为 OnlyMemory 的时候
     
     - author: wangweicheng
     
     - parameter data: 数据流
     - parameter key:  文件标识
     */
    func cacheOnDisk(data : NSData, key : String) {
        
        if cacheType == PWImageNetCacheType.OnlyDisk ||
            cacheType == PWImageNetCacheType.MemoryAndDisk {
            
            let path = DISK_CACHE_PATH.stringByAppendingString(key.md5)
            print("path >>" + path)
            
            let fileManager = NSFileManager.defaultManager()
            if fileManager.isExecutableFileAtPath(path) {
                
                do {
                    try fileManager.removeItemAtPath(path)
                }catch {
                    print(ERROR_REMOVE_MSG)
                }
                
                return
            }
            if !fileManager.fileExistsAtPath(DISK_CACHE_PATH) {
                do {
                    try fileManager.createDirectoryAtPath(DISK_CACHE_PATH, withIntermediateDirectories: true, attributes: nil)
                    
                }catch {
                    print("create directory failed at path: \(DISK_CACHE_PATH)")
                }
            }
            
            if !fileManager.createFileAtPath(path, contents: data, attributes: nil) {
                print("create file failed at path: \(path)")
            }
        }
        
    }
    
    /**
     从缓存中获取数据
     
     - author: wangweicheng
     
     - parameter url:        url
     - parameter completion: 回调
     - return   是否成功获取到数据
     */
    func dataFromCache(key : String) -> NSData? {
        
        if cacheType == .None {
            return nil
        }
        
        if cacheType == .OnlyDisk {
            return dataFromDisk(key)
        }
        
        if cacheType == .OnlyMemory {
            return dataFromMemory(key)
        }
        
        if cacheType == .MemoryAndDisk {
            
            if let data = dataFromMemory(key) {
                return data
            }else{
                return dataFromDisk(key, toMemory: true)
            }
        }
        
        return nil
    }
    
    /**
     从内存中取数据，当缓存类型为 OnlyMemory 或者 MemoryAndDisk 的时候才会从内存中读取数据
     
     - author: wangweicheng
     
     - parameter key: 文件标识
     
     - returns: 内存中的数据
     */
    func dataFromMemory(key: String) -> NSData? {

        if cacheType == PWImageNetCacheType.OnlyMemory ||
           cacheType == PWImageNetCacheType.MemoryAndDisk {
            
            return cache.objectForKey(key) as? NSData
        }
       return nil
    }
    
    /**
     从磁盘上去取数据，缓存类型为 OnlyDisk 或者 MemoryAndDisk 的时候才会从磁盘上读取缓存，缓存类型是 MemoryAndDisk 的时候，从磁盘中读取的数据同时会加载到内存中
     
     - author: wangweicheng
     
     - parameter key: 文件标识
     
     - returns: 磁盘上的数据
     */
    func dataFromDisk(key: String) -> NSData? {
        //
        return dataFromDisk(key, toMemory: (cacheType == PWImageNetCacheType.MemoryAndDisk))
    }
    
    func dataFromDisk(key: String, toMemory: Bool) -> NSData? {
        
        if cacheType == PWImageNetCacheType.OnlyDisk ||
           cacheType == PWImageNetCacheType.MemoryAndDisk {
            
            let path = DISK_CACHE_PATH.stringByAppendingString(key.md5)
            
            if let data = NSData(contentsOfFile: path) {
                if toMemory {
                    cache.setObject(data, forKey: key)
                }
                return data
            }
        }
        return nil
    }
    
    /****************** clean cache ******************/
    
    public func clearExpiredCacheFromDisk() {
        let fileManager = NSFileManager.defaultManager()
        
        let filePaths = fileManager.subpathsAtPath(DISK_CACHE_PATH)
        
        dispatch_async(cacheQueue) {
            
            
            var diskCacheSize = self.diskCacheSize()
            
            if self.maxDiskCacheSize > 0 && (self.maxDiskCacheSize * 1024 * 1024) < diskCacheSize {
                
                // 文件按日期升序排序
                let sortPaths = filePaths?.sort({ (firstPath, secondPath) -> Bool in
                    let first = DISK_CACHE_PATH.stringByAppendingString(firstPath)
                    let second = DISK_CACHE_PATH.stringByAppendingString(secondPath)
                    do {
                        let firstFileInfo = try fileManager.attributesOfItemAtPath(first)
                        let secondFileInfo = try fileManager.attributesOfItemAtPath(second)
                        
                        if let firstDate = firstFileInfo[NSFileModificationDate] as? NSDate,
                            secondDate = secondFileInfo[NSFileModificationDate] as? NSDate {
                            return firstDate.compare(secondDate) == .OrderedAscending
                        }
                        return true
                        
                    } catch _ {
                        print("获取文件信息失败")
                        return false
                    }
                })
                
                for filePath in sortPaths! {
                    
                    let fileSize = self.diskCacheSize(DISK_CACHE_PATH + filePath)
                    do {
                        try fileManager.removeItemAtPath(DISK_CACHE_PATH + filePath)
                        diskCacheSize -= fileSize
                    } catch _ {
                        
                    }
                    if diskCacheSize <= ((self.maxDiskCacheSize * 1024 * 1024)/2) {
                        return
                    }
                }
                
            }
            
        }
        
    }
    
    public func clearAllCacheFromDisk() {
        
        dispatch_async(cacheQueue) { 
            let path = DISK_CACHE_PATH
            let fileManager = NSFileManager.defaultManager()
            if fileManager.isExecutableFileAtPath(path) {
                
            }
            do {
                let fileNames = try fileManager.contentsOfDirectoryAtPath(path)
                print(fileNames)
                for file in fileNames {
                    try fileManager.removeItemAtPath(DISK_CACHE_PATH.stringByAppendingString(file))
                }
                
            }catch _ {
                print(ERROR_REMOVE_MSG)
            }
        }
    }

}

extension PWDataCache {
    
    func diskCacheSize(path: String) -> Int {
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(DISK_CACHE_PATH) {
            return 0
        }
        
        var fileSize = 0
        
        do {
            let fileAttrDic = try fileManager.attributesOfItemAtPath(path)
            fileSize = fileAttrDic[NSFileSize] as! Int
            
        } catch _ {
            
        }
        return fileSize
    }
    
    public func diskCacheSize() -> Int {
        
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(DISK_CACHE_PATH) {
            return 0
        }
        
        var diskCacheSize = 0
        
        let fileNames : [String]? = fileManager.subpathsAtPath(DISK_CACHE_PATH)
        
        if let _fileNames = fileNames {
        
            for ( _, fileName) in _fileNames.enumerate() {
                do {
                    let fileAttrDic = try fileManager.attributesOfItemAtPath(DISK_CACHE_PATH + fileName)
                    let fileSize = fileAttrDic[NSFileSize] as! Int
                    
                    diskCacheSize += fileSize
                    
                } catch _ {
                    
                }
            }

        } else {
            print("获取文件名失败")
            return 0
        }
        
        return diskCacheSize
        
    }
    
}
