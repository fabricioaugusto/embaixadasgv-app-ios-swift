//
//  NotificationsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 27/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class NotificationsTableVC: UITableViewController {

    
    var mUser: User!
    weak var mRoodDashboardVC: RootDashboardVC!
    
    private var mSelectedNotification: Notification!
    private var mDatabase: Firestore!
    private var mLastDocument: DocumentSnapshot!
    private var mLastDocumentRequested: DocumentSnapshot!
    private var mListNotifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mDatabase = MyFirebase.sharedInstance.database()
        getUserLastReadNotification()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func getUserLastReadNotification() {
        mDatabase.collection(MyFirebaseCollections.USERS)
            .document(mUser.id)
            .getDocument(completion: { (documentSnapshot, error) in
                if let document = documentSnapshot {
                    let lastNotificationRead: Timestamp? = document.get("last_read_notification") as? Timestamp
                    if(lastNotificationRead != nil) {
                        self.getListNotifications(timestamp: lastNotificationRead!)
                    }
                    document.reference.updateData(["last_read_notification" : FieldValue.serverTimestamp()])
                    self.mRoodDashboardVC.clearCountNotificationBarButton()
                }
            })
    }
    
    private func getListNotifications(timestamp: Timestamp) {

        //isPostsOver = false

        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("receiver_id", isEqualTo: mUser.id)
            .order(by: "created_at", descending: true)
            .limit(to: 30)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                
                                notification.id = document.documentID
                                
                                let date = timestamp.dateValue()
                                let created_at = notification.created_at!.dateValue()
                                
                                if created_at > date {
                                    notification.read = false
                                }
                                
                                self.mListNotifications.append(notification)
                            }
                        }

                        self.getManagerNotifications(timestamp: timestamp)
                    }
                }
        }
    }
    
    private func getManagerNotifications(timestamp: Timestamp) {
        
        
        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("type", isEqualTo: "manager_notification")
            .whereField("only_leaders", isEqualTo: false)
            .order(by: "created_at", descending: true)
            .limit(to: 30)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                
                                notification.id = document.documentID
                                
                                let date = timestamp.dateValue()
                                let created_at = notification.created_at!.dateValue()
                                
                                if created_at > date {
                                    notification.read = false
                                }
                                
                                self.mListNotifications.append(notification)
                            }
                        }
                        
                        if(self.mUser.leader) {
                            self.getLeaderNotifications(timestamp: timestamp)
                        } else {
                            
                            self.mListNotifications = self.mListNotifications.sorted(by: {
                                
                                let created_at_0 = $0.created_at!.dateValue()
                                let created_at_1 = $1.created_at!.dateValue()
                                
                                return created_at_0 > created_at_1
                            })
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        }
            
                    }
                }
        }
    }
    
    private func getLeaderNotifications(timestamp: Timestamp) {


        mDatabase.collection(MyFirebaseCollections.NOTIFICATIONS)
            .whereField("type", isEqualTo: "manager_notification")
            .whereField("only_leaders", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .limit(to: 30)
            .getDocuments { (querySnapshot, error) in
                if error == nil {
                    if let documents = querySnapshot?.documents {
                        
                        print(documents.count)
                        for document in documents {
                            if let notification = Notification(dictionary: document.data()) {
                                
                                notification.id = document.documentID
                                
                                let date = timestamp.dateValue()
                                let created_at = notification.created_at!.dateValue()
                                
                                if created_at > date {
                                    notification.read = false
                                }
                                
                                self.mListNotifications.append(notification)
                            }
                        }
                        
                        self.mListNotifications = self.mListNotifications.sorted(by: {
                            
                            let created_at_0 = $0.created_at!.dateValue()
                            let created_at_1 = $1.created_at!.dateValue()
                            
                            return created_at_0 > created_at_1
                        })
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }

                    }
                }
        }

    }

    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mSelectedNotification = mListNotifications[indexPath.row]
        if mSelectedNotification.type == "post_like" || mSelectedNotification.type == "post_comment" {
            performSegue(withIdentifier: "singlePostSegue", sender: nil)
        }
        
        if mSelectedNotification.type == "manager_notification" {
            performSegue(withIdentifier: "singleNotificationSegue", sender: nil)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mListNotifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        
        let notification = self.mListNotifications[indexPath.row]
        cell.prepare(with: notification)

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
        if segue.identifier == "singlePostSegue" {
            let vc = segue.destination as! SinglePostVC
            vc.mPostID = self.mSelectedNotification.post_id
        }
        
        if segue.identifier == "singleNotificationSegue" {
            let vc = segue.destination as! SingleNotificationVC
            vc.mNotificationID = self.mSelectedNotification.id
        }
    }

}
