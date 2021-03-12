//
//  ViewController.swift
//  FirebaseDBRealTime
//
//  Created by Germán Santos Jaimes on 10/03/21.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var ref: DocumentReference? = nil
    let db = Firestore.firestore()
    
    var name: String = ""
    var quantity: Int = 0
    
    @IBOutlet var table: UITableView!
    
    var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //table.rowHeight = 200
        
        let nib = UINib.init(nibName: "OtherItemTableViewCell", bundle: nil)
        table.register(nib, forCellReuseIdentifier: "otherCeldaItem")
        
        print("Iniciando programa")
        //getItems()
        realTime()
        //let itemTemporal = Item(id: "68aOMiw9ww6oSASeZVfJ", name: "almita", quantity: 20)
        //removeItem(item: "5lEoxXiwNEStXgENxWLH")
        //updateItem(itemID: "68aOMiw9ww6oSASeZVfJ", item: itemTemporal)
    }
    
    func getItems(){
        db.collection("items").getDocuments(){ (querySnapshot, error) in
            if let error = error {
                print("Error al obtener los items \(error)")
            } else {
                self.items.removeAll()
                for document in querySnapshot!.documents{
                    print("\(document.documentID) => \(document.data())")
                    let id = document.documentID as? String ?? "\(UUID())"
                    let data = document.data()
                    let name = data["name"] as? String ?? "Sin nombre"
                    let quantity = data["quantity"] as? Int ?? 0
                    let itemTemp = Item(id: id, name: name, quantity: quantity)
                    self.items.append(itemTemp)
                }
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
        }
    }
    
    func realTime(){
        db.collection("items").order(by: "name").addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error al obtener los items \(error)")
            } else {
                self.items.removeAll()
                for document in querySnapshot!.documents{
                    print("\(document.documentID) => \(document.data())")
                    let id = document.documentID as? String ?? "\(UUID())"
                    let data = document.data()
                    let name = data["name"] as? String ?? "Sin nombre"
                    let quantity = data["quantity"] as? Int ?? 0
                    let itemTemp = Item(id: id, name: name, quantity: quantity)
                    self.items.append(itemTemp)
                }
                DispatchQueue.main.async {
                    print("recargando tabla")
                    self.table.reloadData()
                }
            }
        }
    }
    
    func removeItem(item: String){
        db.collection("items").document(item).delete { (error) in
            if let error = error{
                print("Error al remover el documento \(error.localizedDescription)")
            } else {
                print("Exito al remover el documento")
            }
        }
    }
    
    func updateItem(itemID: String, item:Item){
        let data: [String: Any] = ["name": item.name, "quantity": item.quantity]
        db.collection("items").document(itemID).updateData(data) { (error) in
            if let error = error{
                print("Error al actualizar: \(error.localizedDescription)")
            } else {
                print("Se actualizaron los datos con éxito!!")
            }
        }
    }
    
    @IBAction func addItem(_ sender: UIButton){
        showDialogItem()
    }
    
    func showDialogItem() {
        var nameTF: UITextField!
        var quantityTF: UITextField!
        
        let alertController = UIAlertController(title: "Datos del producto", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Agregar", style: .default) { (action) -> Void in
            if !nameTF.text!.isEmpty{
                self.name = nameTF.text! ?? ""
            }
            
            if !quantityTF.text!.isEmpty{
                self.quantity = Int(quantityTF.text!) ?? 0
            }
            
            self.ref = self.db.collection("items").addDocument(data: [
                "name" : self.name,
                "quantity" : self.quantity
            ]){ error in
                if let error = error{
                    print("error \(error.localizedDescription)")
                } else {
                    print("Documento agregado con ID: \(self.ref?.documentID)")
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Producto"
            nameTF = textField
        }
        
        alertController.addTextField { (textField: UITextField!) in
            textField.placeholder = "Cantidad"
            quantityTF = textField
        }
        
        present(alertController, animated: true, completion: nil)
    }
}

// Add protocols

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "otherCeldaItem", for: indexPath) as! OtherItemTableViewCell
        
        celda.title.text = items[indexPath.row].name
        
        return celda
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            let itemID = items[indexPath.row].id
            removeItem(item: itemID)
            items.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
    }
}

