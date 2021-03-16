import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        // The button you are going to press once you are done
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // What will happen once the user clicks the Add Item button on our UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.isDone = false
            
            
            self.itemArray.append(newItem)
            self.saveItems()
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField                      // Storing the same reference to a local variable accessible
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func saveItems() {
        
        do {
            try context.save()
    
        } catch {
            print("Error saving context \(error)")
        }

        self.tableView.reloadData()
    }
    
    func loadItems() {

        // going to fetch results in the form of Items that we created in the Data Model (entity)
        // you have to specify the data type
        // fetchRequest() requests everything back from the Persistent Container
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    

}

extension TodoListViewController {
    
    //MARK: - UITableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isDone ? .checkmark : .none

        return cell
    }
    
    //MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        saveItems()
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
    
        tableView.deselectRow(at: indexPath, animated: true)    // cell 을 누르자마자 deselect 되는 애니메이션이 나올 수 있도록
        
    }

    
}
