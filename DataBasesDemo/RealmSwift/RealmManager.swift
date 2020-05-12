//
//  RealmManager.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/9.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit
import RealmSwift

///使用泛型增删改查的语法去使用是最简练的
class RealmManager: NSObject {
    static let shared = RealmManager()
    /// 线程可能会变，此处使用计算属性可以随时更改realm所处线程
    var realm: Realm {
         return try! Realm()
     }

    let schemaVersion: UInt64 = 1

    /// 启动
    func start() {
        /// 数据库地址
        let realmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).last! + "/XZBRealmSwift.realm"
        /// 数据迁移
        /*
         为什么要数据迁移？
         假如我们想要更新数据模型，给它添加一个属性，或者更改删除了一个属性。
         在这个时候如果您在数据模型更新之前就已经保存了数据的话，那么 Realm 就会注意到代码和硬盘上数据不匹配。 每当这时，您必须进行数据迁移，否则当你试图打开这个文件的话 Realm 就会抛出错误。
         */
        let config = Realm.Configuration(
            fileURL: URL.init(fileURLWithPath: realmPath),
            // 设置新的架构版本。这个版本号必须高于之前所用的版本号
               // （如果您之前从未设置过架构版本，那么这个版本号设置为 0）
            schemaVersion: schemaVersion,
            // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
            migrationBlock: { (migration, oldSchemaVersion) in
                 // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
                guard oldSchemaVersion == self.schemaVersion else {
                     // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
                    return
                }
                // 手动迁移
                // ...
        })
        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
        Realm.Configuration.defaultConfiguration = config
        // 触发配置
        //打印出数据库地址
        //使用 Realm Browser 工具可以很方便的对.realm数据库进行读取和编辑（在 App Store 中搜索 Realm Browser 即可下载）。
        print("数据库地址====\(realmPath)")
    }

    /// 增
    func addModel<T>(model: T) {
        do {
            try realm.write {
                realm.add(model as! Object)
                print("model:插入成功")
            }
        } catch {
            print("插入model失败:\(error)")
        }
    }

    func addModels<T>(models:[T]) {
        do {
            try realm.write {
                realm.add(models as! [Object], update: .all)
            }
        } catch {
            print("插入models失败:\(error)")
        }
    }
    /// 删
    func deleteModel<T>(model: T) {
        do {
            try realm.write {
                realm.delete(model as! Object)
            }
        } catch {
            print("删除models失败:\(error)")
        }
    }
    /// 删除某张表
    func deleteModelList<T>(model: T) {
        do {
            try realm.write {
                realm.delete(realm.objects((T.self as! Object.Type).self))
            }
        } catch {
            print("删除models失败:\(error)")
        }
    }
    /// 改 根据主键(urlString)修改：调用此方法的模型必须具有主键
    func updateModel<T>(model: T) {
        do {
            try realm.write {
                realm.add(model as! Object, update: .all)
            }
        } catch {
            print("更新models失败:\(error)")
        }
    }
    func updateModels<T>(models: [T]) {
        do {
            try realm.write {
                realm.add(models as! [Object], update: .all)
            }
        } catch {
            print("批量更新失败")
        }
    }

    /// 查
    func queryModel<T>(model: T, filter: String? = nil) -> [T] {
        var results: Results<Object>
        if filter != nil {
            results = realm.objects((T.self as! Object.Type).self).filter(filter!)
        } else {
            results = realm.objects((T.self as! Object.Type).self)
        }
        guard results.count > 0 else { return [] }
        var modelArray = [T]()
        for model in results {
            modelArray.append(model as! T)
        }
        return modelArray
    }
}
