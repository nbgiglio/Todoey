//
//  CategoryVC.swift
//  Todoey
//
//  Created by Nick Giglio on 2/25/19.
//  Copyright © 2019 Nick Giglio. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryVC: SwipeTableVC {
    
    let realm = try! Realm()
    var categoryResults : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

        loadCategories()
    }
    
    //MARK: Data Manipulation Methods
    func loadCategories(){
        
        categoryResults = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func save(category : Category){
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
    }
    
    override func updateModel(indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryResults?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error saving category \(error)")
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func addBtnPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category Name"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if textField.text == "" {
                textField.text = "Blank Category Added"
            }
            
            let newCategory = Category()
            newCategory.name = textField.text!
            
            
            self.save(category: newCategory)
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //Add catch for if no categories yet.  Could try terniary operator.  Nil operator doesn't work.
        if categoryResults?.count == 0 {
            return 1
        } else {
            return categoryResults!.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        cell.textLabel?.text = (categoryResults?.count == 0) ? "No Categories Added Yet" : categoryResults?[indexPath.row].name
        
        cell.backgroundColor = UIColor.randomFlat

        return cell
    }
    

    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (categoryResults?.count != 0) ? performSegue(withIdentifier: "goToItems", sender: self) : tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListVC
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryResults?[indexPath.row]
        }
        
    }

}
