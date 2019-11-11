//
//  HighlightsPostsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 10/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore

class HighlightsPostsTableVC: UITableViewController, IndicatorInfoProvider {

    
    private var mDatabase: Firestore?
    private var mLastDocument: DocumentSnapshot?
    private var mLastDocumentRequested: DocumentSnapshot?
    private var mPostList: [Post] = []
    private var mListLikes: [PostLike] = []
    private var isPostsOver: Bool = false
    private var mAdapterPosition: Int = 0
    private var mUser: User?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Destaques")
    }
    // MARK: - Table view data source
    
    
    private func getHighlightListPosts() {

        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: true)
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
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    self.mPostList.append(post!)
                                }
                            }
                        } else {
                            self.isPostsOver = true
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            })
        
        
       }

       private func loadMore() {

            
       }

       private func getPostLikes() {

            isPostsOver = false
            mListLikes.removeAll()
        
            self.mDatabase?.collection(MyFirebaseCollections.POSTS)
                .whereField("user_id", isEqualTo: mUser?.id ?? "")
                .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            self.mLastDocument = query.documents[query.count - 1]
                            
                            for document in querySnapshot!.documents {
                                let postLike = PostLike(dictionary: document.data())
                                if(postLike != nil) {
                                    self.mListLikes.append(postLike!)
                                }
                            }
                            self.getHighlightListPosts()
                        }
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
        return mPostList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highlightPostsCell", for: indexPath) as! PostCell

        let post = mPostList[indexPath.row]
        cell.prepare(with: post)

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
