//
//  PersonModel.swift
//  DataBasesDemo
//
//  Created by 🍎上的豌豆 on 2020/5/11.
//  Copyright © 2020 xiao. All rights reserved.
//

import UIKit
import WCDBSwift

class PersonModel: TableCodable {
    var identifier: Int? = nil
    var title: String? = nil
    var num: Int? = nil
    var newName: String? = nil
    /// 对应数据库表名
    static var tableName: String { "PersonModel" }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = PersonModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier
        case title
        case num
//        case name
        case newName = "name"
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identifier: ColumnConstraintBinding(isPrimary: true)
            ]
        }
        static var indexBindings: [IndexBinding.Subfix: IndexBinding]? {
            return [
                "_index": IndexBinding(indexesBy: title)
            ]
        }
    }
    var isAutoIncrement: Bool = true // 用于定义是否使用自增的方式插入
    var lastInsertedRowID: Int64 = 0 // 用于获取自增插入后的主键值

    // MARK: model保存
    static func save(title: String, num: Int) {
        let model = PersonModel()
        model.title = title
        model.num = num
        model.newName = "jack"
        WCDBDataBaseManager.shared.insertOrReplaceToDb(object: model, table: PersonModel.tableName)
    }
}
/*
 ColumnConstraintBinding(
     isPrimary: Bool = false, // 该字段是否为主键。字段约束中只能同时存在一个主键
     orderBy term: OrderTerm? = nil, // 当该字段是主键时，存储顺序是升序还是降序
     isAutoIncrement: Bool = false, // 当该字段是主键时，其是否支持自增。只有整型数据可以定义为自增。
     onConflict conflict: Conflict? = nil, // 当该字段是主键时，若产生冲突，应如何处理
     isNotNull: Bool = false, // 该字段是否可以为空
     isUnique: Bool = false, // 该字段是否可以具有唯一性
     defaultTo defaultValue: ColumnDef.DefaultType? = nil // 该字段在数据库内使用什么默认值
 )
*/
