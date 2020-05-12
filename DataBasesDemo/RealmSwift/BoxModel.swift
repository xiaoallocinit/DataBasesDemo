//
//  BoxModel.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/9.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit
import RealmSwift

class BoxModel: Object {
    /// 名称
    @objc dynamic var boxName: String = ""
    /// 数量
    @objc dynamic var num: Int = 0
    /// 作数据库主键，固定值为1
    @objc dynamic var id: String = ""

    /// 添加主键(Primary Keys)
    override static func primaryKey() -> String? {
           return "id"
    }
    /*
     重写 Object.ignoredProperties() 可以防止 Realm 存储数据模型的某个属性。Realm 将不会干涉这些属性的常规操作，它们将由成员变量(var)提供支持，并且您能够轻易重写它们的 setter 和 getter。忽略属性（不会映射到DB）
     */
//    override static func ignoredProperties() -> [String] {
//           return ["num"]
//    }
//    /// 重写 Object.indexedProperties() 方法可以为数据模型中需要添加索引的属性建立索引
//    override static func indexedProperties() -> [String] {
//        return ["num"]
//    }

    // MARK: model保存
    static func save(boxName: String, num: Int, id: String) {
        let model = BoxModel()
        model.boxName = boxName
        model.num = num
        model.id = id
        let realm = try! Realm()
        try? realm.write {
//            realm.add(model)
            realm.add(model, update: .all)
        }
    }
}
