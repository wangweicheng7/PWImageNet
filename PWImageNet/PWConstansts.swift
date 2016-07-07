//
//  PWConstansts.swift
//  PWImageNet
//
//  Created by 王炜程 on 16/7/4.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import Foundation
import UIKit.UIImage

public enum PWImageSourceType : Int {
    
    case None = 0 , Net, Cache
}

public enum PWImageNetCacheType : Int {
    
    case None = 0, OnlyMemory, OnlyDisk, MemoryAndDisk

}

public typealias PWImageFetchCompletionClosure = (image: UIImage?, error: NSError?, url: NSURL?, source: PWImageSourceType) -> Void

public typealias PWDataDownloadCompletionClosure  = (data : NSData?, error: NSError?, url : NSURL, source : PWImageSourceType) -> Void

public typealias PWDataDownloadProgressClosure     = (receivedSize : Int64, expectedSize : Int64) -> Void

let DISK_CACHE_PATH = NSHomeDirectory().stringByAppendingString("/Documents/ImageCaches/")

let ERROR_DATA_MSG  = "ERROR: 初始化 data 失败"

let ERROR_REMOVE_MSG = "remove file failed"






