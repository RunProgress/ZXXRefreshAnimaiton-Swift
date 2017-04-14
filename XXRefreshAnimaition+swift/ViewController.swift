//
//  ViewController.swift
//  XXRefreshAnimaition+swift
//
//  Created by zhang on 2017/4/12.
//  Copyright © 2017年 zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var  tableView: UITableView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView = UITableView.init(frame: CGRect(x: 0, y: 20, width:self.view.bounds.size.width, height:self.view.bounds.size.height - 20));
        tableView?.delegate = self;
        tableView?.dataSource = self;
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell");
        self.view.addSubview(tableView!);
        tableView!.addHeaderRefresh {
            NSLog("start pull refresh");
        }
        
    }
    
    // tableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell");
        cell?.textLabel?.text = String(indexPath.row);
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.header .endRefresh();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

