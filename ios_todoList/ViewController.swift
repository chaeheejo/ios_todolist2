//
//  ViewController.swift
//  ios_todoList
//
//  Created by chaehee on 2023/02/02.
//

import UIKit
import RealmSwift

class ToDoListItem: Object {
    @objc dynamic var text: String = ""
    @objc dynamic var date: Date = Date()
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    
    private var data = [ToDoListItem]()
    private let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = realm.objects(ToDoListItem.self).map({$0})
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "entry")
        table.delegate = self
        table.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = tableView.dequeueReusableCell(withIdentifier: "entry", for: indexPath)
        entry.textLabel?.text = data[indexPath.row].text
        return entry
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "detail") as? DetailViewController else{
            return
        }
        
        vc.item = item
        
        vc.deletionHandler = { [weak self] in
            self?.refresh()
        }
        
        vc.modificationHandler = { [weak self] in
            self?.refresh()
        }
        
        vc.title = item.text
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let deleteItem = data[indexPath.row]
            
            realm.beginWrite()
            realm.delete(deleteItem)
            try! realm.commitWrite()
            
            refresh()
        }
    }
    
    @IBAction func didTapAddButton(){
        guard let vc = storyboard?.instantiateViewController(identifier: "entry") as? EntryViewController else{
            return
        }
        
        vc.additionHandler = { [weak self] in
            self?.refresh()
        }
        
        vc.title = "New Item"
        vc.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refresh(){
        data = realm.objects(ToDoListItem.self).map({$0})
        table.reloadData()
    }

}

