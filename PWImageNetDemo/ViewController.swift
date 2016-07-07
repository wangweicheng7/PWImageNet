//
//  ViewController.swift
//  PWImageNetDemo
//
//  Created by 王炜程 on 16/7/6.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit
import PWImageNet

class ViewController: UIViewController {

    var imageView : UIImageView?
    var progressView : UIProgressView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let width = UIScreen.mainScreen().bounds.width
        let height = UIScreen.mainScreen().bounds.height
        
        
        imageView = UIImageView(frame: CGRectMake(0, 0, width, height - 64))
        view.addSubview(imageView!)
        
        PWDataCache.shareInstance.cacheType = .MemoryAndDisk
        
        progressView = UIProgressView(frame: CGRectMake(0, 64, width, 0))
        progressView?.tintColor = UIColor.orangeColor()
        progressView?.trackTintColor = UIColor.lightGrayColor()
        view.addSubview(progressView!)
        
        let url = NSURL(string: "http://image5.tuku.cn/wallpaper/Landscape%20Wallpapers/9104_2560x1600.jpg")
        
        PWImageNet.fetchImage(url!, placeholder: UIImage(named: "img_head_cs"), progress: { (receivedSize, expectedSize) in
            let progress = Float(receivedSize)/Float(expectedSize)
            self.progressView?.setProgress(progress, animated: true)
            }) { (image, error, url, source) in
                self.imageView!.image = image
        }
        
        let btn = UIButton(type : .Custom)
        btn.frame = CGRectMake(0, height - 40, width, 40)
        btn.backgroundColor = UIColor.redColor()
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(ViewController.reloadImage), forControlEvents: .TouchUpInside)
        
        
    }
    
    func reloadImage() {
        
//        let url = NSURL(string: "https://s-media-cache-ak0.pinimg.com/564x/5d/cd/54/5dcd54555e9a58dd7aedbc9d73d084cd.jpg")
        let url = NSURL(string: "https://s-media-cache-ak0.pinimg.com/originals/ad/6d/ba/ad6dbabe9d08d67ffe465134c43eedc2.gif")
        
        //        PWImageNetCacheType
        
        PWImageNet.fetchImage(url!, placeholder: UIImage(named: "img_head_cs"), progress: { (receivedSize, expectedSize) in
            
            let progress = Float(receivedSize)/Float(expectedSize)
            print(progress)
            self.progressView?.setProgress(progress, animated: true)
        }) { (image, error, url, source) in
            self.imageView!.image = image
        }
        
        //        PWImageNet.fetchImage(url!, placeholder: UIImage(named: "img_head_cs")) { (image, error, url, source) in
        //            self.imageView!.image = image
        //            print(url?.absoluteString)
        //            print("\n")
        //            print(error?.domain)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

