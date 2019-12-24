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
    private var mEmbassyList: [Embassy] = []
    private var mSearchList: [Embassy] = []
    private var mEmbassySelected: Embassy!
    private var isSearching: Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
        var list: [Embassy] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mEmbassyList
        }
        
        self.mEmbassySelected = list[indexPath.row]
        performSegue(withIdentifier: "singleEmbassySegue", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        var list: [Embassy] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mEmbassyList
        }
        
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "embassyCell", for: indexPath) as! EmbassyCell
        
        var list: [Embassy] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mEmbassyList
        }
        
        let embassy = list[indexPath.row]
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

extension ListEmbassyTableVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.isSearching = false
            mSearchList.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            self.isSearching = true
            mSearchList.removeAll()
            mSearchList = mEmbassyList.filter{ $0.name.lowercased().contains(searchText.lowercased()) }
            let cityList = mEmbassyList.filter{ $0.city.lowercased().contains(searchText.lowercased()) }
            let stateList = mEmbassyList.filter{ $0.state.lowercased().contains(searchText.lowercased()) }
            mSearchList.append(contentsOf: cityList)
            mSearchList.append(contentsOf: stateList)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        /*if mWorkItem != nil {
            mWorkItem.cancel()
        }
        
        self.mWorkItem = DispatchWorkItem {
            UserService.searchUsers(query: searchText) { (users) in
                self.users = users
                self.count_users = users.count
             
 
        }
        
        //DispatchQueue.main.asyncAfter(deadline: .now(), execute: self.mWorkItem!)}*/
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
