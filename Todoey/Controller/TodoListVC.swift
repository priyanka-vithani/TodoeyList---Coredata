//
//  ViewController.swift
//  Todoey
//
//  Created by Apple on 06/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ChameleonFramework
import  CoreData

class TodoListVC: SwipeTableVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    //MARK: - Constants
   
    var arrItem = [Item]()
    var index: Int?
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      
    //MARK: - View controller life cycles
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.colour{
            title = selectedCategory!.name
            guard let navbar = navigationController?.navigationBar else{
                fatalError("navbar not extst")
            }
            if let navbarColor = UIColor(hexString: colorHex){
                 
                navbar.backgroundColor = navbarColor
                navbar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
                navbar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navbarColor, returnFlat: true)]
                searchBar.barTintColor = navbarColor
               
        
            }
            
            
            
            
        }
        
    }
    //MARK: - Add new items
    
    @IBAction func btnAdd_clk(_ sender: UIBarButtonItem) {
        CreateAlert(flag: "New Item")
    }
    
    private func CreateAlert(flag : String){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory{
                
                if flag == "New Item"{
                    let newItem = Item(context: self.context)
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory
                    self.arrItem.append(newItem)
                    self.saveItems()
                }else{
                    if let ind = self.index {
                        
                        self.updateItems(in: self.arrItem[ind], with: textField.text!)
                        
                        
                    }
                    
                }
                
                
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTxtFld) in
            alertTxtFld.placeholder = "Create new item"
            textField = alertTxtFld
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    //MARK - Model Manupulation Methods
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            arrItem = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    func updateItems(in item : Item, with text : String){
        
        
    }
    func deleteItem(_ item: Item, at index : Int){
       context.delete(arrItem[index])
       arrItem.remove(at: index)
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        self.deleteItem(self.arrItem[indexPath.row], at: indexPath.row)
            
            
        
    }
    
    
    
    
}

//MARK: - tableview datasource methods

extension TodoListVC{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItem.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        cell.textLabel?.text = arrItem[indexPath.row].title
        
        if let col = selectedCategory!.colour, let colour = UIColor(hexString: col)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(arrItem.count)){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        
        
            
            
        cell.accessoryType = arrItem[indexPath.row].done ? .checkmark : .none
       
        
        return cell
    }
}

//MARK: - Tableview Delegate Methods

extension TodoListVC{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //update data using realm
       
            
            
            
             arrItem[indexPath.row].done = !arrItem[indexPath.row].done

                   saveItems()
                   
                   tableView.deselectRow(at: indexPath, animated: true)
            
       
        
        
    }
    //    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //
    //        index = indexPath.row
    //
    //        // action one
    //        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
    //
    //            self.index = indexPath.row
    //
    //                do{
    //                    try self.realm.write{
    //                        self.CreateAlert(flag: "Edit")
    //
    //                    }
    //                }catch{
    //
    //                }
    //
    //            tableView.reloadData()
    //
    //
    //        })
    //        editAction.backgroundColor = UIColor.blue
    //
    //        // action two
    //        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
    //
    //            if let item = self.arrItem?[indexPath.row]{
    //
    //                self.deleteItem(item)
    //
    //
    //            }
    //            tableView.reloadData()
    //
    //
    //
    //        })
    //        deleteAction.backgroundColor = UIColor.red
    //
    //        return [deleteAction, editAction]
    //    }
}


//MARK: - UISearchbarDelegare

extension TodoListVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
          
              let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
              
              request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
              
              loadItems(with: request, predicate: predicate)
        
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
