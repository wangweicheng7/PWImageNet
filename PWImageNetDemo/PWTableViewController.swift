//
//  PWTableViewController.swift
//  PWImageNetDemo
//
//  Created by 王炜程 on 16/7/12.
//  Copyright © 2016年 weicheng wang. All rights reserved.
//

import UIKit
import PWImageNet

let imageUrls = ["https://s-media-cache-ak0.pinimg.com/564x/5d/cd/54/5dcd54555e9a58dd7aedbc9d73d084cd.jpg","https://s-media-cache-ak0.pinimg.com/originals/ad/6d/ba/ad6dbabe9d08d67ffe465134c43eedc2.gif","https://s-media-cache-ak0.pinimg.com/originals/99/4c/60/994c6054b1fc2f9b7ff7647650b5f265.gif","http://image5.tuku.cn/wallpaper/Landscape%20Wallpapers/9104_2560x1600.jpg","https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3975843072,3519565029&fm=11&gp=0.jpg","https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4210209192,3681860907&fm=11&gp=0.jpg","https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3897556425,1839832790&fm=21&gp=0.jpg","https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=4061993391,571779673&fm=21&gp=0.jpg","https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=906256754,1518923381&fm=21&gp=0.jpg","https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=209219387,1483212337&fm=21&gp=0.jpg","https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3196062159,2569243402&fm=21&gp=0.jpg","https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=740949607,2629076995&fm=21&gp=0.jpg","https://s-media-cache-ak0.pinimg.com/564x/5d/cd/54/5dcd54555e9a58dd7aedbc9d73d084cd.jpg","https://s-media-cache-ak0.pinimg.com/originals/ad/6d/ba/ad6dbabe9d08d67ffe465134c43eedc2.gif","https://s-media-cache-ak0.pinimg.com/originals/99/4c/60/994c6054b1fc2f9b7ff7647650b5f265.gif","http://image5.tuku.cn/wallpaper/Landscape%20Wallpapers/9104_2560x1600.jpg","https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3975843072,3519565029&fm=11&gp=0.jpg","https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4210209192,3681860907&fm=11&gp=0.jpg","https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3897556425,1839832790&fm=21&gp=0.jpg","https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=4061993391,571779673&fm=21&gp=0.jpg","https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=906256754,1518923381&fm=21&gp=0.jpg","https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=209219387,1483212337&fm=21&gp=0.jpg","https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3196062159,2569243402&fm=21&gp=0.jpg","https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=740949607,2629076995&fm=21&gp=0.jpg"]


class PWTableViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.registerNib(UINib(nibName: "PWTableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // WARNING: Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! PWTableViewCell

        PWImageNet.fetchImage(NSURL(string: imageUrls[indexPath.row])!, placeholder: UIImage(named: "img_head_cs"), progress: { (receivedSize, expectedSize) in
            let progress = Float(receivedSize)/Float(expectedSize)
            cell.loadProgressView.setProgress(progress, animated: true)
            }) { (image, error, url, source) in
                cell.mainImageView.image = image
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
}
