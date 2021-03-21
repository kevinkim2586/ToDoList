import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        
        didSet {
            loadItems()
        }
    }
    
    var colorScheme: UIColor = FlatWhite()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.delegate = self
        

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist")
        }
   
        navBar.backgroundColor = colorScheme
        navBar.tintColor = ContrastColorOf(colorScheme, returnFlat: true)
        
        // Large Title 속성으로 되어 있는 경우 largeTitleTextAttributes
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(colorScheme, returnFlat: true)]

        searchBar.barTintColor = colorScheme
       

        let navBarColor = UINavigationBarAppearance()
        navBarColor.backgroundColor = colorScheme
        navBar.scrollEdgeAppearance = navBarColor
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New To Do Item", message: "", preferredStyle: .alert)
        
        // The button you are going to press once you are done
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        
                        let newItem = Item()
                        
                        newItem.title = textField.text!
                        newItem.isDone = false
                        newItem.dateCreated = Date()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField                      // Storing the same reference to a local variable accessible
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func markComplete(at indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error in didSelectRowAt : \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)    // cell 을 누르자마자 deselect 되는 애니메이션이 나올 수 있도록
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        
        if let taskToDelete = self.todoItems?[indexPath.row] {
            
            do {
                
                try self.realm.write {
                    self.realm.delete(taskToDelete)
                }
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }
}

extension TodoListViewController {
    
    //MARK: - UITableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
    
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
        
            let percentage = CGFloat(indexPath.row) / CGFloat(todoItems!.count)
            let color = self.colorScheme.darken(byPercentage: percentage)
            
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color!, returnFlat: true)
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
    
        return cell
    }
    
}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
