//
//  SelectUserModeratorTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 14/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import InstantSearchClient


protocol SelectUserModeratorDelegate: class {
    func onUserSelected(user: User, vc: SelectUserModeratorTableVC)
}

class SelectUserModeratorTableVC: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var mUser: User!
    private var mUsers: [User] = []
    private var mSearchList: [User] = []
    private var mSelectedUser: User!
    private var mDatabase: Firestore?
    private var mClient: Client!
    private var mIndex: Index!
    private var count_users: Int!
    private var mWorkItem: DispatchWorkItem!
    private var isSearching: Bool = false
    
    weak var delegate: ManageModeratorsTableVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mClient = Client(appID: "2IGM62FIAI", apiKey: "fc7745fc8140b2f1851132bfb5948b51")
        self.mIndex = mClient.index(withName: "users")
            
        mDatabase = MyFirebase.sharedInstance.database()
        listUsers()
        searchBar.delegate = self
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false

            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
        
    private func listUsers() {
        mDatabase?.collection(MyFirebaseCollections.USERS)
            .whereField("status", isEqualTo: "active")
            .getDocuments(completion: { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                       let user = User(dictionary: document.data())
                        if(user != nil) {
                            self.mUsers.append(user!)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BasicUserCell

        var list: [User] = []
        
        if(self.isSearching) {
            list = self.mSearchList
        } else {
            list = self.mUsers
        }
        
        let user = list[indexPath.row]
        if let basicUser = BasicUser(dictionary: user.toMap()) {
            cell.prepare(with: basicUser)
        }

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
        self.delegate.onUserSelected(user: mSelectedUser, vc: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SingleUserVC
        vc.mUserID = mSelectedUser.id
    }

}

extension SelectUserModeratorTableVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let customRanking = ["name", "city", "state", "occupation"]
        let settings = ["searchableAttributes": customRanking]
        mIndex.setSettings(settings, completionHandler: { (content, error) -> Void in
            if error != nil {
                print("Error when applying settings: \(error!)")
            }
        })
        
        self.mSearchList.removeAll()
        
        if searchText.isEmpty {
            self.isSearching = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            self.isSearching = true
        
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
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
