//
//  TodoListVC.swift
//  Todoey
//
//  Created by Nick Giglio on 2/24/19.
//  Copyright © 2019 Nick Giglio. All rights reserved.
//

import UIKit
import RealmSwift


class TodoListVC: SwipeTableVC {
    
    let realm = try! Realm()
    
    var itemResults : Results<Item>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//MARK: Tableview Datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemResults?.count == 0 {
            return 1
        } else {
            return itemResults!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if itemResults?.count == 0 {
            cell.textLabel?.text = "No Items Added"
        } else {
            let item = itemResults?[indexPath.row]
            cell.textLabel?.text = item!.title
            cell.accessoryType = item!.done ? .checkmark : .none
        }

        return cell
        
    }
    
    //MARK: Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemResults?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch {
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add New Items
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What happens after Add Item Clicked
            if textField.text == "" {
                textField.text = "Blank Cell Added"
            }

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items \(error)")
                }
            }
            self.tableView.reloadData()
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems(){
        
        itemResults = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(indexPath: IndexPath) {
        if let itemForDeletion = self.itemResults?[indexPath.row]{
            do {
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item \(error)")
            }
        }
    }
    
    

}
extension TodoListVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemResults = itemResults?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else if searchBar.text!.count > 0 {
            itemResults = itemResults?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
        
        
    }
}
