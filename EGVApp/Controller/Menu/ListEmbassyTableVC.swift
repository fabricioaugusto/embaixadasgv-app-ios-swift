//
//  ListEmbassyTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 26/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ListEmbassyTableVC: UITableViewController {

    var mUser: User!
    var mDatabase: Firestore!
    var mEmbassyList: [Embassy] = []
    var mEmbassySelected: Embassy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        listEmbassy()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func listEmbassy() {
        mDatabase.collection(MyFirebaseCollections.EMBASSY)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    
                } else {
                    
                    if let query = querySnapshot {
                        for document in query.documents {
                            if let embassy = Embassy(dictionary: document.data()) {
                                self.mEmbassyList.append(embassy)
                            }
                        }
                        
                        self.mDatabase.collection(MyFirebaseCollections.EMBASSY)
                            .whereField("status", isEqualTo: "approved")
                            .getDocuments { (querySnapshot, error) in
                                if let error = error {
                                    
                                } else {
                                    
                                    if let query = querySnapshot {
                                        for document in query.documents {
                                            if let embassy = Embassy(dictionary: document.data()) {
                                                self.mEmbassyList.append(embassy)
                                            }
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                        }
                        
                    }
                }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singleEmbassySegue" {
            let vc = segue.destination as! SingleEmbassyVC
            vc.mUser = self.mUser
            vc.mEmbassyID = mEmbassySelected.id
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mEmbassySelected = mEmbassyList[indexPath.row]
        performSegue(withIdentifier: "singleEmbassySegue", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mEmbassyList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "embassyCell", for: indexPath) as! EmbassyCell
        let embassy = mEmbassyList[indexPath.row]
        cell.prepare(with: embassy)
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

    /*
    // MARK: - Navigation

    
    */

}
