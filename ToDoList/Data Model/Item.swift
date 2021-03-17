import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
