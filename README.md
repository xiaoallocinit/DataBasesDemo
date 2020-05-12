# DataBasesDemo
## 1.引子FMDB
[FMDB详解](https://www.jianshu.com/p/45267dfca32f)
[FMDB的git链接](https://github.com/ccgus/fmdb)

1.1 它基于` SQLite` 封装，对于有` SQLite` 和` ObjC` 基础的开发者来说，简单易懂，可以直接上手；而缺点也正是在此，` FMDB` 只是将` SQLite` 的C接口封装成了` ObjC` 接口，没有做太多别的优化，即所谓的胶水代码(` Glue Code` )。使用过程需要用大量的代码拼接` SQL` 、拼装` Object` ，并不方便。

1.2 不支持` ORM` （模型绑定：` Object-relational Mapping` ），需要每个编码人员写具体的` sql` 语句，没有较多的性能优化，数据库操作相对复杂，关于数据加密、数据库升级等操作需要用户自己实现。


* ##### 本文将` FMDB` 作为引子，来重点介绍一下` RealmSwift` 和` WCDB` 。

----

## 2.初见Realm
### 2.1 什么是Realm
**Realm** 于2014 年7月发布，是一个跨平台的移动数据库引擎，专门为移动应用的数据持久化而生。其目的是要取代 ` Core Data ` 和 ` SQLite` 。

[Realm官网](https://links.jianshu.com/go?to=https%3A%2F%2Frealm.io)
[Realm官方文档](https://links.jianshu.com/go?to=https%3A%2F%2Frealm.io%2Fdocs%2Fobjc%2Flatest%2Fapi%2Findex.html)
[Realm GitHub](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Frealm)

### 2.2 Realm的优缺点

* ##### 优点：

1.**跨平台**（可以在 iOS 和 Android 平台上共同使用），上手比较简单易用，文档比较完善；
2.**可视化**：[Realm](https://links.jianshu.com/go?to=https%3A%2F%2Frealm.io%2Fdocs%2Fswift%2Flatest%2F%23installation) 还提供了一个轻量级的数据库查看工具，在Mac Appstore 可以下载“[Realm Browser](https://links.jianshu.com/go?to=https%3A%2F%2Fstudio-releases.realm.io%2Fv3.6.1%2Fdownload%2Fmac-dmg)”这个工具，开发者可以查看数据库当中的内容，执行简单的插入和删除数据的操作。

* ##### 缺点：

1.基类只能继承自` RLMObject` ，不能自由继承；
2.字符串数组解析不了（` [String]` ，枚举类型定义复杂）；
3.切换分支会崩溃，删掉重装才行；
4.多线程崩溃频发；
5.性能不如` WCDB` 。


* ##### 问题一： 为什么` RealmSwift` 在建模型数据时候，前面要加上` @objc dynamic` ？

因为Realm有一部分是` Objective-C`  编写，一部分是` swift` 编写。` Objective-C ` 的消息发送是完全动态，而` Swift ` 中的函数可以是静态调用，静态调用会更快。` Swift`  跟`  Objective-C`  交互时，` Objective-C ` 动态查找方法地址，就有可能找不到 Swift 中定义的方法。这样就需要在 ` Swift`  中添加一个提示关键字，告诉编译器这个方法是可能被动态调用的，需要将其添加到查找表中。这个就是关键字 ` dynamic ` 的作用。

### 2.3 Realm支持的类型

>Realm支持以下的属性类型：` BOOL、bool、int、NSInteger、long、long long、float、double、NSString、NSDate、NSData` 以及 被特殊类型标记的` NSNumber` ，注意，不支持集合类型和`CGFloat`，只有一个集合`RLMArray`，如果服务器传来的有数组，那么需要我们自己取数据进行转换存储。

### 2.4 Realm数据库配置

```swift
  let schemaVersion: UInt64 = 1
    /// 启动
   func start() {
        /// 数据库地址
        let realmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).last! + "/XZBRealmDataBase/RealmSwift.realm"
        /// 数据迁移
        /*
         为什么要数据迁移？
         假如我们想要更新数据模型，给它添加一个属性，或者更改删除了一个属性。
         在这个时候如果您在数据模型更新之前就已经保存了数据的话，那么` Realm` 就会注意到代码和硬盘上数据不匹配。 每当这时，您必须进行数据迁移，否则当你试图打开这个文件的话` Realm `就会抛出错误。
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
        //使用 Realm Browser 工具可以很方便的对Realm数据库进行读取和编辑（在 App Store 中搜索 Realm Browser 即可下载）。
        print("数据库地址====\(realmPath)")
    }
```
>手动配置数据库地址，`Realm.Configuration`初始化,使用 `Realm Browser `工具可以很方便的对.Realm数据库进行读取和编辑（在 App Store 中搜索 `Realm Browser `即可下载）

###  2.5 Realm数据库迁移
**为什么要数据迁移？**

+ **`代码见2.4`**
  假如我们想要更新数据模型，给它添加一个属性，或者更改删除了一个属性。 在这个时候如果您在数据模型更新之前就已经保存了数据的话，那么 Realm 就会注意到代码和硬盘上数据不匹配。 每当这时，您必须进行数据迁移，否则当你试图打开这个文件的话 Realm 就会抛出错误。

### 2.6 Realm数据库模型

* ##### **2.6.1模型示例代码**
```swift
class BoxModel: Object {
    /// 名称
    @objc dynamic var boxName: String = ""
    /// 数量
    @objc dynamic var num: Int = 0
    /// 作数据库主键，固定值为1
    @objc dynamic var id: String = ""

    /// 添加主键(Primary Keys)
    static override func primaryKey() -> String? {
           return "id"
    }
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
```
* #####  **2.6.2 属性的Setter 和 Getter**
+ Setter 和 Getter：因为` Realm` 在底层数据库中重写了` setters `和 `getters `方法，所以不能在创建的对象上再对其进行重写。

+ 一个简单的替代方法就是：创建一个新的 Realm 忽略属性，该属性的访问起可以被重写， 并且可以调用其他的 getter 和 setter 方法。

* ##### **2.6.3 忽略属性（不会映射到DB）**
```swift
    override static func ignoredProperties() -> [String] {
           return ["num"]
    }
```
+ 重写 `Object.ignoredProperties()` 可以防止 `Realm` 存储数据模型的某个属性。`Realm `将不会干涉这些属性的常规操作，它们将由成员变量(var)提供支持，并且您能够轻易重写它们的 `setter `和 `getter`。
* ##### **2.6.4 添加主键(Primary Keys)**
```swift
/// 添加主键(Primary Keys)
    override static func primaryKey() -> String? {
           return "id"
    }
```
+ 重写 `Object.primaryKey() `可以设置模型的主键。
+ 声明主键之后，对象将被允许查询，更新速度更加高效，并且要求每个对象保持唯一性。
+ 一旦带有主键的对象被添加到 `Realm `之后，该对象的主键将不可修改。



#### 2.7 Realm数据库的增删改查操作

* ##### 2.7.1 增
```swift
let model = BoxModel()
        model.boxName = boxName
        model.num = num
        model.id = id
        let realm = try! Realm()
        try? realm.write {
//            realm.add(model)
         realm.add(model, update: .all)
  }
```
+ 这里需要注意的是`realm.add(model)`和` realm.add(model, update: .all)`的区别，如果主键id相同的话使用`realm.add(model)`会直接导致项目运行崩溃，这一点也是Realm的不足之处，` realm.add(model, update: .all)`直接就更新了主键相同的表。

* ##### 2.7.2 删
```swift
    // MARK: 删（清空本地所有数据）
    @objc private func clearData() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    // MARK: 删（删除指定类型的数据）
    private func clearSingleData(id: String) {
        let realm = try! Realm()
        let tem = realm.objects(BoxModel.self).filter("id == %@", id)
        try! realm.write {
            realm.delete(tem)
        }
    }
```
>一种是删除全部数据库表，一种是根据主键ID删除表。

* #####  2.7.3 改（更新）
* ###### 如果数据模型类中包含了主键，那么 可以使用 `Realm().add(_:update:)`，从而让 `Realm `基于主键来自动更新或者添加对象。
```swift
let model = BoxModel()
        model.boxName = boxName
        model.num = num
        model.id = id
        let realm = try! Realm()
        try? realm.write {
         realm.add(model, update: .all)
  }
```
* ###### 如果这个主键值为 “1” 的 Book 对象已经存在于数据库当中 ，那么该对象只会进行更新。如果不存在的话， 那么一个全新的 Book 对象就会被创建出来，并被添加到数据库当中。
```swift
// 假设主键为 `1` 的 "Book" 对象已经存在
try! realm.write {
    realm.create(BoxModel.self, value: ["id": 1, "boxName": "丰巢"], update: true)
    // BoxModel 对象的 `num ` 属性仍旧保持不变
}
```

* ##### 2.7.4 查
+ 1.简单查询
```swift
// MARK: 查
    private func getData() {
        let realm = try! Realm()
        let results = realm.objects(BoxModel.self)
    }
```
+ 2.主键查询（查询某张表的某条数据，模型必须包含主键，否则会崩溃）
```swift
    // MARK: 主键查询（查询某张表的某条数据，模型必须包含主键，否则会崩溃）
    private func getDataFromPromaykey() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        guard let model = realm.object(ofType: BoxModel.self, forPrimaryKey: "2") else { return }
        self.dataArr.append(model)
        self.tableView.reloadData()
    }
```
+ 3.条件查询: 根据断言字符串 或者` NSPredicate `谓词 查询某张表中的符合条件数据
```swift
    // MARK: 条件查询: 根据断言字符串 或者 NSPredicate 谓词 查询某张表中的符合条件数据
    private func getDataFromPredicate() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "boxName contains %@ and num == ","京东", 68)
        let temps = realm.objects(BoxModel.self).filter(predicate)
        self.dataArr.append(contentsOf: temps)
        self.tableView.reloadData()
    }
```
+ 4.数据排序查询
```swift
    // MARK: 数据排序查询
    @objc private func getDataSorted() {
        self.dataArr.removeAll()
        let realm = try! Realm()
        let temps = realm.objects(BoxModel.self).sorted(byKeyPath: "num", ascending: true)
        self.dataArr.append(contentsOf: temps)
        self.tableView.reloadData()
    }
```

###  2.8 问题和坑（欢迎补充）



----



## 3.WCDB Swfit 基础使用

 [官方文档介绍](https://github.com/Tencent/wcdb/wiki/Swift-%E5%85%B3%E4%BA%8E%20WCDB%20Swift)

###  3.1 关于 WCDB Swift

+ 3.1.1`one line of code` 是 WCDB Swift 设计的基本原则之一。通过更现代的数据库开发模式，减少开发者所需使用的代码量，绝大部分增删查改都只需一行代码即可完成；
+ 3.1.2模型绑定（`Object-relational Mapping`，简称 `ORM`），通过对 `Swift `类或结构进行绑定，形成类或结构 - 表模型、类或结构对象 - 表的映射关系，从而达到通过对象直接操作数据库的目的。
+ 3.1.3语言集成查询。深度结合` Swift` 和 `SQL` 的语法，使得纯字符串的 `SQL` 可以以代码的形式表达出来。结合代码提示及纠错，极大地提高了开发效率。

### 3.2 模型绑定

#### 3.2.1 字段映射
+ ` WCDB Swift ` 的字段映射基于`  Swift 4.0 ` 的 ` Codable ` 协议实现。以下是一个字段映射的示例代码：
```swift
class PersonModel: TableCodable {
    var identifier: Int? = nil
    var title: String? = nil
    var num: Int? = nil
    /// 对应数据库表名
    static var tableName: String { "PersonModel" }

    enum CodingKeys: String, CodingTableKey {
        typealias Root = PersonModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier
        case title
        case num
//        case name
//      case newName = "name"

        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identifier: ColumnConstraintBinding(isPrimary: true)
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
        WCDBDataBaseManager.shared.insertOrReplaceToDb(object: model, table: PersonModel.tableName)
    }
}
```
+ 1.在类内定义 CodingKeys 的枚举类，并遵循 String 和 CodingTableKey。
+ 2.枚举列举每一个需要定义的字段。
+ 3.对于变量名与表的字段名不一样的情况，可以使用别名进行映射，如 case identifier = "id"
+ 4.对于不需要写入数据库的字段，则不需要在 CodingKeys 内定义，如 debugDescription
+ 5.对于变量名与 SQLite 的保留关键字冲突的字段，同样可以使用别名进行映射，如 offset 是 SQLite 的关键字。

#### 3.2.2 字段约束
+ ` ColumnConstraintBinding` 初始化函数的声明如下：
```swift
ColumnConstraintBinding(
    isPrimary: Bool = false, // 该字段是否为主键。字段约束中只能同时存在一个主键
    orderBy term: OrderTerm? = nil, // 当该字段是主键时，存储顺序是升序还是降序
    isAutoIncrement: Bool = false, // 当该字段是主键时，其是否支持自增。只有整型数据可以定义为自增。
    onConflict conflict: Conflict? = nil, // 当该字段是主键时，若产生冲突，应如何处理
    isNotNull: Bool = false, // 该字段是否可以为空
    isUnique: Bool = false, // 该字段是否可以具有唯一性
    defaultTo defaultValue: ColumnDef.DefaultType? = nil // 该字段在数据库内使用什么默认值
)
```

#### 3.2.2 自增属性

+ 定义了 `isPrimary`: 的字段，支持以自增的方式进行插入数据。但仍可以通过非自增的方式插入数据。
+ 当需要进行自增插入时，对象需设置` isAutoIncrement `参数为 `true`，则数据库会使用 已有数据中最大的值+1 作为主键的值。

### 3.3 数据库初始化
+ Database 可以通过文件路径或文件 URL 创建一个数据库。
```swift
/// wcdb数据库
let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,true).last! + "/XZBWCDBDataBase/WCDBSwift.db"
static let defaultDatabase: Database = {
        return Database.init(withFileURL: URL.init(fileURLWithPath: dbPath))
    }()
```

### 3.4 数据库的增删改查

#### 3.4.1  增
+ 插入操作有` "insert" `和` "insertOrReplace" `两个接口。故名思义，前者只是单纯的插入数据，当数据出现冲突时会失败，而后者在主键一致时，新数据会覆盖旧数据。

```swift
let model = PersonModel()
 model.isAutoIncrement = false
 WCDBDataBaseManager.shared.insertOrReplaceToDb(object: model, table: PersonModel.tableName)
```
+ "insert"` 函数的原型为：

```swift
// insert 和 insertOrReplace 函数只有函数名不同，其他参数都一样。
func insert<Object: TableEncodable>(
    objects: [Object], // 需要插入的对象。WCDB Swift 同时实现了可变参数的版本，因此可以传入一个数组，也可以传入一个或多个对象。
    on propertyConvertibleList: [PropertyConvertible]? = nil, // 需要插入的字段
    intoTable table: String // 表名
) throws
```

+ #### 注意：

+ 插入是最常用且比较容易操作卡顿的操作，因此` WCDB Swift` 对其进行了特殊处理。 当插入的对象数大于 1 时，`WCDB Swift` 会自动开启事务，进行批量化地插入，以获得更新的性能。

```swift
/// 执行事务
try dataBase?.run(transaction: {
       try dataBase?.insert(objects: objects, intoTable: table)
})
```

#### 3.4.1  删
+ 删除操作只有一个接口，其函数原型为：
```swift
func delete(fromTable table: String, // 表名
            where condition: Condition? = nil, // 符合删除的条件
            orderBy orderList: [OrderBy]? = nil, // 排序的方式
            limit: Limit? = nil, // 删除的个数
            offset: Offset? = nil // 从第几个开始删除
) throws
```
+ 下面是三种删除情况：
  + 1.删（清空本地所有数据）
  + 2.删（删除指定类型的数据）
  + 3.删除 `PersonModel` 中 按 `identifier` 升序排列后的前 4 行的后 2 行数据
```swift
// MARK: 删（清空本地所有数据）
    @objc private func clearData() {
        WCDBDataBaseManager.shared.deleteFromDb(fromTable: PersonModel.tableName)
    }
    // MARK: 删（删除指定类型的数据）
    private func clearSingleData(identifier: Int) {
        WCDBDataBaseManager.shared.deleteFromDb(fromTable: PersonModel.tableName, where: PersonModel.Properties.identifier == identifier)
    }

   @objc private func clearOtherData() {

        // 删除 PersonModel 中 按 identifier 升序排列后的前 4 行的后 2 行数据
        WCDBDataBaseManager.shared.deleteFromDb(fromTable: PersonModel.tableName, orderBy: [PersonModel.Properties.num.asOrder(by: .ascending)], limit: 2, offset: 4)
    }
```
#### 3.4.1  改（更新）
+ 更新操作有` "update with object" `和 `"update with row" `两个接口。它们的原型分别
``` swift
func update<Object: TableEncodable>(
    table: String,
    on propertyConvertibleList: [PropertyConvertible],
    with object: Object,
    where condition: Condition? = nil,
    orderBy orderList: [OrderBy]? = nil,
    limit: Limit? = nil,
    offset: Offset? = nil) throws

func update(
    table: String,
    on propertyConvertibleList: [PropertyConvertible],
    with row: [ColumnEncodableBase],
    where condition: Condition? = nil,
    orderBy orderList: [OrderBy]? = nil,
    limit: Limit? = nil,
    offset: Offset? = nil) throws
```
+ 更新(通过`"with object"` 接口更新)

``` swift

    @objc private func updateSingleData(_ indexPath: IndexPath, _ identifier: Int) {
        let model = self.dataArr[indexPath.row]
        model.num = 999
        WCDBDataBaseManager.shared.updateToDb(table: PersonModel.tableName, on: PersonModel.Properties.all, with: model, where: PersonModel.Properties.identifier == identifier)
        getData()
    }
```
+ 更新(通过`"with row" `接口更新)

+ `"with row" `接口则是通过` row` 来对数据进行更新。`row` 是遵循 `ColumnEncodable` 协议的类型的数组。

``` swift
    private func updateWithRowData(_ indexPath: IndexPath, _ identifier: Int) {
        do {
            let row = [self.dataArr[indexPath.row].title!] as [ColumnEncodable]
            try WCDBDataBaseManager.defaultDatabase.update(table: PersonModel.tableName, on: PersonModel.Properties.title, with: row, where: PersonModel.Properties.identifier == identifier)
            self.getData()
        } catch  {
            print("查询失败：\(error.localizedDescription)")
        }
    }
```

#### 3.4.1  查
+ ` "getObjects"` 和 `"getObject"` 都是对象查找的接口，他们直接返回已进行模型绑定的对象。它们的函数原型为：

``` swift
func getObjects<Object: TableDecodable>(
    on propertyConvertibleList: [PropertyConvertible],
    fromTable table: String,
    where condition: Condition? = nil,
    orderBy orderList: [OrderBy]? = nil,
    limit: Limit? = nil,
    offset: Offset? = nil) throws -> [Object]

func getObject<Object: TableDecodable>(
    on propertyConvertibleList: [PropertyConvertible],
    fromTable table: String,
    where condition: Condition? = nil,
    orderBy orderList: [OrderBy]? = nil,
    offset: Offset? = nil) throws -> Object?
```
 + 主键查询
``` swift
    private func getDataFromPromaykey() {
        do {
            self.dataArr.removeAll()
            self.dataArr = try WCDBDataBaseManager.defaultDatabase.getObjects(fromTable: PersonModel.tableName,
            where: PersonModel.Properties.identifier < 6 && PersonModel.Properties.identifier > 3)
            self.tableView.reloadData()
        } catch  {
            print("查询失败：\(error.localizedDescription)")
        }

    }
```

### 3.5 数据库语言集成查询

+ 语言集成查询（` WCDB Integrated Language Query` ，简称 ` WINQ` ），是 ` WCDB`  的一项基础特性。它使得开发者能够通过 ` Swift`  的语法特性去完成`  SQL ` 语句。

``` swift
let objects: [Sample] = try database.getObjects(fromTable: PersonModel.tableName, where: PersonModel.Properties.idetifier > 1)
```
>其中 where: 参数后的 ` PersonModel.Properties.idetifier > 1`  就是`语言集成查询`的其中一个写法。其虽然是`  identifier`  和数字 1 的比较，但其结果并不为`  Bool ` 值，而是`  Expression` 。该 ` Expression`  作为 ` SQL`  的 ` where`  参数，用于数据库查询。
>`语言集成查询`基于` SQLite` 的` SQL `语法实现。只要是` SQL `支持的语句，都能使用`语言集成查询`完成。也因此，`语言集成查询`具有和 `SQL `语法一样的复杂性，具体的可以详见[语言集成查询文档](https://github.com/Tencent/wcdb/wiki/Swift-%e8%af%ad%e8%a8%80%e9%9b%86%e6%88%90%e6%9f%a5%e8%af%a2)

### 3.6 单例化
+  `WCDBDataBaseManager`单例化代码，便于调用。

``` swift
class WCDBDataBaseManager: NSObject {

    static let shared = WCDBDataBaseManager()

    static let defaultDatabase: Database = {
        return Database.init(withFileURL: URL.init(fileURLWithPath: dbPath))
    }()

    var dataBase: Database?
    private override init() {
        super.init()
        dataBase = createDb()
    }

    /// 创建db
    private func createDb() -> Database {
        print("wcdb数据库路径==\(dbPath)")
        return Database(withFileURL: URL.init(fileURLWithPath: dbPath))
    }

    /// 创建表
    func createTable<T: TableDecodable>(table: String, of type: T.Type) -> Void {
        do {
            try dataBase?.create(table: table, of: type)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// 插入
    func insertToDb<T: TableEncodable>(objects: [T], table: String) -> Void {
        do {
            /// 如果主键存在的情况下，插入就会失败
            /// 执行事务
            try dataBase?.run(transaction: {
                try dataBase?.insert(objects: objects, intoTable: table)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    /// 插入或更新
    func insertOrReplaceToDb<T: TableEncodable>(object: T, table: String) -> Void {
        do {
            /// 执行事务
            try dataBase?.run(transaction: {
                try dataBase?.insertOrReplace(objects: object, intoTable: table)
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    /// 修改
    func updateToDb<T: TableEncodable>(table: String, on propertys: [PropertyConvertible], with object: T, where condition: Condition? = nil) -> Void {
        do {
            try dataBase?.update(table: table, on: propertys, with: object, where: condition)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// 删除
    func deleteFromDb(fromTable: String, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: WCDBSwift.Offset? = nil) {
        do {
            try dataBase?.run(transaction: {
                try dataBase?.delete(fromTable: fromTable, where: condition, orderBy: orderList, limit: limit, offset: offset)
            })
        } catch {
            print(error.localizedDescription)
        }
    }

    /// 查询
    func qureyObjectsFromDb<T: TableDecodable>(fromTable: String, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) -> [T]? {
        do {
            let allObjects: [T] = try (dataBase?.getObjects(fromTable: fromTable, where: condition, orderBy: orderList, limit: limit, offset: offset))!
            return allObjects
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    /// 查询单条数据
    func qureySingleObjectFromDb<T: TableDecodable>(fromTable: String, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil) -> T? {
        do {
            let object: T? = try (dataBase?.getObject(fromTable: fromTable, where: condition, orderBy: orderList))
            return object
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
```

## 结语：
WCDB是目前性能体验最优的数据库。
