//
//  RealmSwiftViewController.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/5.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit
import RealmSwift

class RealmSwiftViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.bounds, style: .plain)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    private lazy var addBut: UIButton = {
        let btn = UIButton()
        btn.setTitle("插入数据", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(addData), for: .touchUpInside)
        return btn
    }()
    private lazy var clearBut: UIButton = {
        let btn = UIButton()
        btn.setTitle("清除所有数据库", for: .normal)
        btn.frame = CGRect(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width/2, height: 100)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(clearData), for: .touchUpInside)
        return btn
    }()
    private lazy var sortBut: UIButton = {
        let btn = UIButton()
        btn.setTitle("排序", for: .normal)
        btn.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width/2, height: 100)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(getDataSorted), for: .touchUpInside)
        return btn
    }()
    /// 保存从数据库中查询出来的结果集
    var dataArr = [BoxModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RealmSwift"
        self.view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: addBut)
        self.view.addSubview(tableView)
        self.view.addSubview(clearBut)
        self.view.addSubview(sortBut)
        createData()
        getData()
    }

    /// 新建数据
    private func createData() {
        //使用默认的数据库`
        let realm = try! Realm()
        //查询所有的消费记录
        let items = realm.objects(BoxModel.self)
        //已经有记录的话就不插入了
        if items.count > 0 {
            return
        }
        BoxModel.save(boxName: "顺丰", num: 5, id: "1")
        BoxModel.save(boxName: "中通", num: 55, id: "2")
        BoxModel.save(boxName: "速递易", num: 88, id: "3")
        BoxModel.save(boxName: "阿里巴巴", num: 35, id: "4")
        BoxModel.save(boxName: "京东", num: 68, id: "5")
    }
    // MARK: 查
    private func getData() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        let results = realm.objects(BoxModel.self)
        if results.count == 0 {
            return
        }
        results.forEach { (model) in
            self.dataArr.append(model)
        }
        self.tableView.reloadData()
    }
    // MARK: 主键查询（查询某张表的某条数据，模型必须包含主键，否则会崩溃）
    private func getDataFromPromaykey() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        guard let model = realm.object(ofType: BoxModel.self, forPrimaryKey: "2") else { return }
        self.dataArr.append(model)
        self.tableView.reloadData()
    }
    // MARK: 条件查询: 根据断言字符串 或者 NSPredicate 谓词 查询某张表中的符合条件数据
    private func getDataFromPredicate() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "boxName contains %@ and num == ","京东", 68)
        let temps = realm.objects(BoxModel.self).filter(predicate)
        self.dataArr.append(contentsOf: temps)
        self.tableView.reloadData()
    }
    // MARK: 数据排序查询
    @objc private func getDataSorted() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        let temps = realm.objects(BoxModel.self).sorted(byKeyPath: "num", ascending: true)
        self.dataArr.append(contentsOf: temps)
        self.tableView.reloadData()
    }
    // MARK: 增
    @objc private func addData() {
        let id = self.dataArr.last?.id ?? "1"
        let addID = (Int(id)!+3)
        BoxModel.save(boxName: "丰巢\(addID)", num: Int(arc4random_uniform(100)), id: String(addID))
        getData()
    }
    // MARK: 删（清空本地所有数据）
    @objc private func clearData() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        self.dataArr.removeAll()
        self.tableView.reloadData()
    }
    // MARK: 删（删除指定类型的数据）
    private func clearSingleData(id: String) {
        let realm = try! Realm()
        let tem = realm.objects(BoxModel.self).filter("id == %@", id)
        try! realm.write {
            realm.delete(tem)
            getData()
        }
    }

}

extension RealmSwiftViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = dataArr[indexPath.row].boxName
        cell.detailTextLabel?.text = "第\(dataArr[indexPath.row].num)个"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let modification = UITableViewRowAction.init(style: .normal, title: "修改名称") { (action, indexPath) in
            self.modificationAction(indexPath)

            tableView.setEditing(false, animated: true)
        }
        modification.backgroundColor = .red

        // MARK: 删
        let delete = UITableViewRowAction.init(style: .normal, title: "删除") { (action, indexPath) in
            self.clearSingleData(id: self.dataArr[indexPath.row].id)
            tableView.setEditing(false, animated: true)
        }
        delete.backgroundColor = .systemBlue
        return [modification, delete]
    }
}
extension RealmSwiftViewController {
    // MARK: 改
    private func modificationAction(_ indexPath: IndexPath){
      let alertController = UIAlertController(title: "修改",message: "输入名称", preferredStyle: .alert)
      alertController.addTextField {
          (textField: UITextField!) -> Void in
          textField.placeholder = "请输入名称"
      }
      let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
      let okAction = UIAlertAction(title: "确认", style: .default, handler: {
          action in
            let realm = try! Realm()
            try! realm.write {
                // 通过 id 主键 更新model
                let model = self.dataArr[indexPath.row]
                model.boxName = alertController.textFields!.first!.text!
                realm.add(model, update: .all)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }

      })
      alertController.addAction(cancelAction)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
}
