import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""

    let items = List<Item>()
}

// Inside each category, "items" is going to point to a list of Item objects.
