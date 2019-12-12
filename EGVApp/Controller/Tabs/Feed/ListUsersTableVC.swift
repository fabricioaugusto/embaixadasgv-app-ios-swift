//
//  ListUsersTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 10/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ListUsersTableVC: UITableViewController {

    var mType: String!
    var mEventID: String!
    var mPostID: String!
    var mUser: User!
    private var mUsers: [BasicUser] = []
    private var mSelectedUser: BasicUser!
    private var mDatabase: Firestore?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        mDatabase = MyFirebase.sharedInstance.database()
        
        if(mType == "likeUsers") {
            self.title = "Curtidas"
            self.listLikeUsers()
        }
        
        if(mType == "enrollUsers") {
            self.title = "Inscritos"
            self.listEnrollUsers()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    private func listLikeUsers() {
        mDatabase?.collection(MyFirebaseCollections.POST_LIKES)
            .whereField("post_id", isEqualTo: self.mPostID)
            .getDocuments(completion: { (querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let postLike = PostLike(dictionary: document.data()) {
                            let user = postLike.user
                            self.mUsers.append(user)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            })
    }

    private func listEnrollUsers() {
        mDatabase?.collection(MyFirebaseCollections.ENROLLMENTS)
        .whereField("event_id", isEqualTo: self.mEventID)
        .getDocuments(completion: { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let enrollment = Enrollment(dictionary: document.data()) {
                        let user = enrollment.user
                        self.mUsers.append(user)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.mUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BasicUserCell
        
        let user = self.mUsers[indexPath.row]
        cell.prepare(with: user)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        mSelectedUser = self.mUsers[indexPath.row]
        performSegue(withIdentifier: "singleUser", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SingleUserVC
        vc.mUserID = mSelectedUser.id
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
