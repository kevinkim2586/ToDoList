import Foundation
import RealmSwift


// Object is a super class that we're going to use to enable us to persist
// our Data class
class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
    
}


// dynamic keyword is a declaration modifier that allows the property name
// to be monitored for change at "runtime".
// ex. While your app is running, if "name" changes, it allows Realm to dynamically
// update those changes in the database.
