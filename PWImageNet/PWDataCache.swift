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

public class PWDataCache: NSObject {
    
    // 是否加载到内存中，如果选择false，则缓存在磁盘的文件每次都从磁盘加载
    public var cacheType : PWImageNetCacheType = .MemoryAndDisk
    
    private let cache = NSCache()
    
    public class var shareInstance: PWDataCache {
        struct __ {
            static let instance = PWDataCache()
        }
        __.instance.cache.countLimit = 500
        return __.instance
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
    public func clearDisk() -> Bool {
        // TODO: 敬请期待
        return true
    }
}
