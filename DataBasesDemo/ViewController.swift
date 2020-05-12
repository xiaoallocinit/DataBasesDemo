//
//  ViewController.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/6.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.bounds, style: .plain)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    var dataArr = ["RealmSwift", "WCDBSwift"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "DatabaseDemo"
        self.view.addSubview(tableView)
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = dataArr[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(RealmSwiftViewController(), animated: true)
        }
        if indexPath.row == 1 {
            self.navigationController?.pushViewController(WCDBSwiftViewController(), animated: true)
        }
    }
}

