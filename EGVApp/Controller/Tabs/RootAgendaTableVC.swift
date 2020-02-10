//
//  RootAgendaTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RootAgendaTableVC: UITableViewController {

    var mUser: User!
    var mSelectedEvent: Event!
    private var mDatabase: Firestore?
    private var mEventList: [Event] = []
    private var mAdapterPosition: Int = 0
    private var mLastDocument: DocumentSnapshot!
    private var mIsDocumentsOver: Bool = false
    private var mIsLoadingList: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mDatabase = MyFirebase.sharedInstance.database()
        getEventList()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func getEventList() {
        
        let today = Date()
        let timestamp = Timestamp(date: today)
        
         self.mDatabase?.collection(MyFirebaseCollections.EVENTS)
            .whereField("date", isGreaterThan: timestamp)
            .order(by: "date", descending: false)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                     if let query = querySnapshot {
                         if query.documents.count > 0 {
                             
                            self.mLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsDocumentsOver = true
                            }
                            
                             for document in querySnapshot!.documents {
                                 let event = Event(dictionary: document.data())
                                 if(event != nil) {
                                     self.mEventList.append(event!)
                                 }
                             }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                         } else {
                             self.mIsDocumentsOver = true
                         }
                     }
                     
                 }
             })
    }
    
    private func loadMoreEvents() {
        
        self.mIsLoadingList = true
        
        let today = Date()
        let timestamp = Timestamp(date: today)
        
         self.mDatabase?.collection(MyFirebaseCollections.EVENTS)
            //.whereField("date", isGreaterThan: timestamp)
            .order(by: "date", descending: false)
            .start(afterDocument: self.mLastDocument)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                     if let query = querySnapshot {
                         if query.documents.count > 0 {
                             
                            self.mLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsDocumentsOver = true
                            }
                            
                             for document in querySnapshot!.documents {
                                 let event = Event(dictionary: document.data())
                                 if(event != nil) {
                                     self.mEventList.append(event!)
                                 }
                             }
                            
                            DispatchQueue.main.async {
                                self.mIsLoadingList = false
                                self.tableView.reloadData()
                            }
                            
                         } else {
                             self.mIsDocumentsOver = true
                         }
                     }
                     
                 }
             })
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "singleEventSegue") {
            let vc = segue.destination as! SingleEventVC
            vc.mEvent = self.mSelectedEvent
            vc.mUser = self.mUser
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mSelectedEvent = mEventList[indexPath.row]
        performSegue(withIdentifier: "singleEventSegue", sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell

        let event = mEventList[indexPath.row]
        cell.prepare(with: event)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.mEventList.count-5 && !self.mIsLoadingList && !self.mIsDocumentsOver{
            self.loadMoreEvents()
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
