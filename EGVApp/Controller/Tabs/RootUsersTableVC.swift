//
//  SearchTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import InstantSearchClient

class RootUsersTableVC: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var mUser: User!
    private var mCountUsers: Int = 0
    private var mUsers: [User] = []
    private var mSearchList: [User] = []
    private var mSelectedUser: User!
    private var mDatabase: Firestore!
    private var mClient: Client!
    private var mIndex: Index!
    private var mLastDocument: DocumentSnapshot!
    private var mIsDocumentsOver: Bool = false
    private var mIsLoadingList: Bool = false
    private var count_users: Int!
    private var mWorkItem: DispatchWorkItem!
    private var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mClient = Client(appID: "2IGM62FIAI", apiKey: "fc7745fc8140b2f1851132bfb5948b51")
        self.mIndex = mClient.index(withName: "users")
        
        mDatabase = MyFirebase.sharedInstance.database()
        listUsers()
        countUsers()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func onClickBarBtInfo(_ sender: Any) {
        let alert = UIAlertController(title: "\(mCountUsers)", message: "GV's cadastrados", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func listUsers() {
        mDatabase?.collection(MyFirebaseCollections.USERS)
            .whereField("status", isEqualTo: "active")
            .limit(to: 50)
            .getDocuments(completion: { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let querySnapshot = querySnapshot {
                        
                        if querySnapshot.documents.count > 0 {
                            
                            self.mLastDocument = querySnapshot.documents[querySnapshot.documents.count - 1]
                            
                            if querySnapshot.documents.count < 50 {
                                self.mIsDocumentsOver = true
                            }
                            
                            for document in querySnapshot.documents {
                               let user = User(dictionary: document.data())
                                if(user != nil) {
                                    self.mUsers.append(user!)
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
    
    private func loadMoreUsers() {
        
        self.mIsLoadingList = true
        
        mDatabase?.collection(MyFirebaseCollections.USERS)
            .whereField("status", isEqualTo: "active")
            .start(afterDocument: self.mLastDocument)
            .limit(to: 50)
            .getDocuments(completion: { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let querySnapshot = querySnapshot {
                        
                        if querySnapshot.documents.count > 0 {
                            self.mLastDocument = querySnapshot.documents[querySnapshot.documents.count - 1]
                               
                               if querySnapshot.documents.count < 50 {
                                   self.mIsDocumentsOver = true
                               }
                            
                               for document in querySnapshot.documents {
                                  let user = User(dictionary: document.data())
                                   if(user != nil) {
                                       self.mUsers.append(user!)
                                   }
                               }
                               
                               DispatchQueue.main.async {
                                   self.mIsLoadingList = false
                                   self.tableView.reloadData()
                               }
                        }  else {
                            self.mIsDocumentsOver = true
                        }
                    }
                    
                }
            })
    }
    
    private func countUsers() {
        mDatabase.collection(MyFirebaseCollections.APP_SERVER)
            .document("users_count")
            .getDocument { (documentSnapshot, error) in
                
                if error == nil {
                    if let document = documentSnapshot {
                        let data = document.data()
                        if let data = data {
                            self.mCountUsers = data["value"] as? Int ?? 0
                            print(self.mCountUsers)
                        }
                    }
                }
            }
            
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        var list: [User] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mUsers
        }
        
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell

        var list: [User] = []
        
        if(self.isSearching) {
            list = self.mSearchList
            cell.identifierView.isHidden = true
        } else {
            list = self.mUsers
            cell.identifierView.isHidden = false
        }
        
        let user = list[indexPath.row]
        cell.prepare(with: user)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var list: [User] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mUsers
        }
        
        mSelectedUser = list[indexPath.row]
        performSegue(withIdentifier: "singleUser", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.mUsers.count-10 && !self.mIsLoadingList && !self.mIsDocumentsOver{
            self.loadMoreUsers()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SingleUserVC
        vc.mUserID = mSelectedUser.id
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

extension RootUsersTableVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let customRanking = ["name", "city", "state", "occupation"]
        let settings = ["searchableAttributes": customRanking]
        mIndex.setSettings(settings, completionHandler: { (content, error) -> Void in
            if error != nil {
                print("Error when applying settings: \(error!)")
            }
        })
        
        
        
        if searchText.isEmpty {
            self.isSearching = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            self.isSearching = true
            self.mSearchList.removeAll()
            
            self.mIndex.search(Query(query: searchText), completionHandler: { (content, error) -> Void in
                if error == nil {
                    if let content = content {
                        if let hits = content["hits"] as? [NSObject] {
                            
                            for hit in hits {
                                var user: [String: Any] = [:]
                                user["id"] = hit.value(forKey: "id")
                                user["name"] = hit.value(forKey: "name")
                                user["email"] = hit.value(forKey: "email")
                                if(hit.value(forKey: "profile_img") != nil) {
                                    user["profile_img"] = hit.value(forKey: "profile_img")
                                    user["occupation"] = hit.value(forKey: "occupation")
                                    let searchUser = User(dictionary: user)
                                    if let searchUser = searchUser {
                                        self.mSearchList.append(searchUser)
                                    }
                                }
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            })
            
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
