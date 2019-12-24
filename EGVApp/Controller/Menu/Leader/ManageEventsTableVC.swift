//
//  ManageEventsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class ManageEventsTableVC: UITableViewController, CreateEventDelegate {

    var mEmbassyID: String!
    var mUser: User!
    private var mSelectedEvent: Event!
    private var mDatabase: Firestore!
    private var mLastDocument: DocumentSnapshot?
    private var mLastDocumentRequested: DocumentSnapshot?
    private var mEventList: [Event] = []
    private var isPostsOver: Bool = false
    private var mAdapterPosition: Int = 0
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mDatabase = MyFirebase.sharedInstance.database()
        getEventList()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Excluindo..."
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func getEventList() {
        
        self.mEventList.removeAll()
        
        self.mDatabase.collection(MyFirebaseCollections.EVENTS)
            .whereField("embassy_id", isEqualTo: mEmbassyID ?? "")
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let query = querySnapshot {
                        if query.documents.count > 0 {
                            self.mLastDocument = query.documents[query.count - 1]
                            for document in querySnapshot!.documents {
                                let event = Event(dictionary: document.data())
                                if(event != nil) {
                                    self.mEventList.append(event!)
                                }
                            }
                        } else {
                            self.isPostsOver = true
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.mHud.dismiss()
                        }
                    }
                    
                }
            })
    }
    
    private func alertDeleteEvent() {
        
        let alert = UIAlertController(title: "Excluir Evento", message: "Tem certeza que deseja excluir este evento?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sim, tenho certeza", style: UIAlertAction.Style.destructive, handler: { (alertAction) in
            self.deleteEvent()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteEvent() {
        
        self.mHud.show(in: self.view)
        
        mDatabase.collection(MyFirebaseCollections.EVENTS)
            .document(mSelectedEvent.id)
            .delete { (error) in
                if error == nil {
                    self.getEventList()
                }
        }
    }
    
    func onCreateEvent(vc: CreateEventVC) {
        self.getEventList()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.mSelectedEvent = mEventList[indexPath.row]
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Visualizar", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "singleEventSegue", sender: nil)
        }))
        /*alert.addAction(UIAlertAction(title: "Editar", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
        }))*/
        alert.addAction(UIAlertAction(title: "Deletar", style: .destructive , handler:{ (UIAlertAction)in
            self.alertDeleteEvent()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mEventList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageEventCell", for: indexPath) as! ManageEventCell
        
        let event = mEventList[indexPath.row]
        cell.prepare(with: event)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createEventSegue") {
            let vc = segue.destination as! CreateEventVC
            vc.mUser = self.mUser
            vc.delegate = self
        }
        if(segue.identifier == "singleEventSegue") {
            let vc = segue.destination as! SingleEventVC
            vc.mEvent = self.mSelectedEvent
            vc.mUser = self.mUser
        }
    }
    

}
