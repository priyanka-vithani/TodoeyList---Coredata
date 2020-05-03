//
//  CategoryVC.swift
//  Todoey
//
//  Created by Apple on 13/04/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

import ChameleonFramework
import CoreData

class CategoryVC: SwipeTableVC {
    
    
    var arrCatrgory = [Category]()
    var index : Int?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //MARK: - viewcontroller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let navbar = navigationController?.navigationBar else{
                       fatalError("navbar not extst")
                   }
        navbar.backgroundColor = UIColor(hexString: "0984FF")
    }
    //MARK: - add new categories
    @IBAction func btnAdd_clk(_ sender: UIBarButtonItem) {
        CreateAlert(flag: "New Item")
    }
    private func CreateAlert(flag : String){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            
            
            if textField.text != ""{
                
               let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                newCategory.colour = UIColor.randomFlat().hexValue()
                self.arrCatrgory.append(newCategory)
                
                self.saveCategories()
                
            }
            
        }
        alert.addAction(action)
        alert.addTextField { (alertTxtFld) in
            alertTxtFld.placeholder = "Add new category"
            textField = alertTxtFld
        }
        
        present(alert, animated: true, completion: nil)
        
    }

    
    //MARK: - data manipulation
    
 func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            arrCatrgory = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
       
        tableView.reloadData()
        
    }
   
       
    func deleteCategory(_ category : Category, at index : Int){
          context.delete(arrCatrgory[index])
          arrCatrgory.remove(at: index)
       }
       
       override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
       
            self.deleteCategory(self.arrCatrgory[indexPath.row], at: indexPath.row)
    }
     
    
}
//MARK: - TABLEVIEW DATADOURCE METHODS
extension CategoryVC{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCatrgory.count 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
            cell.textLabel?.text = arrCatrgory[indexPath.row].name
           
        
        
        if let categoryColor = arrCatrgory[indexPath.row].colour{
            cell.backgroundColor = UIColor(hexString: categoryColor)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryColor)!, returnFlat: true)
        }
             
        
        
        return cell
    }
    
}


//MARK: - tableview delegate methods
extension CategoryVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListVC
        
        if let indexpath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = arrCatrgory[indexpath.row]
        }
    }
}








