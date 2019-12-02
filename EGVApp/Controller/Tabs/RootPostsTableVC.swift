//
//  RootPostsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 21/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FaveButton

class RootPostsTableVC: UITableViewController {

    var mUser: User!
    private var mAuth: Auth!
    private var mSelectedPost: Post!
    private var mDatabase: Firestore!
    private var mLastDocument: DocumentSnapshot?
    private var mLastDocumentRequested: DocumentSnapshot?
    private var mPostList: [Post] = []
    private var mHighlightPostList: [Post] = []
    private var mEmbassyPostList: [Post] = []
    private var mAllPostList: [Post] = []
    private var mListLikes: [PostLike] = []
    private var isPostsOver: Bool = false
    private var mAdapterPosition: Int = 0
    private var mUserID: String!
    private var mLikeIsProcessing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("evgapplog root", mUser.id)
        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        
        if let authUser = mAuth.currentUser {
            mUserID = authUser.uid
            self.getPostLikes()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // delegate and data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func onClickCreatePost(_ sender: UIBarButtonItem) {
        self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
    }
    
    
    @IBAction func onChangePostCategory(_ sender: UISegmentedControl) {
        
        let indexSelected = sender.selectedSegmentIndex
        
        if(indexSelected == 0) {
            if(mHighlightPostList.count == 0) {
                self.getHighlightListPosts()
            } else {
                self.mPostList.removeAll()
                self.mPostList = self.mHighlightPostList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if(indexSelected == 1) {
            if(mEmbassyPostList.count == 0) {
                self.getEmbassyPosts()
            } else {
                self.mPostList.removeAll()
                self.mPostList = self.mEmbassyPostList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if(indexSelected == 2) {
            if(mAllPostList.count == 0) {
                self.getAllPosts()
            } else {
                self.mPostList.removeAll()
                self.mPostList = self.mAllPostList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    // MARK: - Table view data source

    private func getHighlightListPosts() {
        
        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: true)
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("egvapplog", "deu erro")
                    print("Error getting documents: \(err)")
                } else {
                    print("egvapplog", "deu certo ")
                    if let query = querySnapshot {
                        print("egvapplog", "achou a query")
                        if query.documents.count > 0 {
                            self.mLastDocument = query.documents[query.count - 1]
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    self.mHighlightPostList.append(post!)
                                }
                            }
                            self.mPostList = self.mHighlightPostList
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
    
    private func getEmbassyPosts() {
        
        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("embassy_id", isEqualTo: mUser.embassy_id ?? "")
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
                                    self.mEmbassyPostList.append(post!)
                                }
                            }
                            self.mPostList = self.mEmbassyPostList
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
    
    private func getAllPosts() {

        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: false)
            .order(by: "date", descending: true)
            .limit(to: 30)
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
                                    self.mAllPostList.append(post!)
                                }
                            }
                            self.mPostList = self.mAllPostList
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
        print("egvapplog", "postlikes vai ser chamado")
        isPostsOver = false
        mListLikes.removeAll()
        
        self.mDatabase?.collection(MyFirebaseCollections.POST_LIKES)
            .whereField("user_id", isEqualTo: self.mUserID ?? "")
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    print("egvapplog", "postlikes não deu erro")
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            print("egvapplog", "postlikes deu certo")
                            self.mLastDocument = query.documents[query.count - 1]
                            
                            for document in querySnapshot!.documents {
                                let postLike = PostLike(dictionary: document.data())
                                if(postLike != nil) {
                                    self.mListLikes.append(postLike!)
                                }
                            }
                        }
                        self.getHighlightListPosts()
                    }
                    
                }
            })
    }
    
    private func setNotification(type: String, likeID: String, post: Post) {
    
        let notification: [String:Any] =
            ["type": type,
             "post_id": post.id,
             "title": "<b>${mUser.name}</b> curtiu a sua publicação",
             "picture": mUser.profile_img,
             "receiver_id": post.user_id,
             "like_id": likeID]
    
        self.mDatabase?.collection(MyFirebaseCollections.NOTIFICATIONS)
            .addDocument(data: notification, completion: { (error) in
                if error == nil {
                    
                }
            })
    }
    
    func setLikePost(post: Post, completion: @escaping (Bool) -> Void) {
       
        if !self.mListLikes.contains(where: { postLike in postLike.post_id == post.id }) {
            
            var postLike: [String: Any] = ["post_id" : post.id, "user_id" : mUserID!, "user" : mUser!.toBasicMap()]
            
            mLikeIsProcessing = true
            
            //mTxtAdPostLikes.text = numLikes
            var ref: DocumentReference? = nil
            ref = mDatabase?.collection(MyFirebaseCollections.POST_LIKES).addDocument(data: postLike, completion: { (error) in
                if error == nil {
                    self.mPostList.filter {$0.id == post.id}.first?.post_likes = post.post_likes
                    postLike["id"] = ref!.documentID
                    let like: PostLike? = PostLike(dictionary: postLike)
                    self.mListLikes.append(like!)
                    ref!.updateData(["id" :ref!.documentID], completion: { (error) in
                        
                        if error == nil {
                            print("egvapplog", "atualizou o id")
                            self.setNotification(type: "post_like", likeID: ref!.documentID, post: post)
                            self.mDatabase?.collection(MyFirebaseCollections.POSTS).document(post.id).updateData(["post_likes": post.post_likes], completion: { (error) in
                                if error == nil {
                                    completion(true)
                                }
                            })
                            self.mLikeIsProcessing = false
                        }
                        
                    })
                }
            })
        }
    }
    
    func setUnlikePost(post: Post, completion: @escaping (Bool) -> Void) {
        if self.mListLikes.contains(where: { postLike in postLike.post_id == post.id }) {
            
            mLikeIsProcessing = true
            
            let list = mListLikes.filter( { return $0.post_id == post.id } )
            self.mListLikes = mListLikes.filter( { return $0.post_id != post.id } )
            
            if(list.count > 0) {
                mDatabase?.collection(MyFirebaseCollections.POST_LIKES).document(list[0].id).delete(completion: { (error) in
                    if error == nil {
                        self.mPostList.filter {$0.id == post.id}.first?.post_likes = post.post_likes
                        self.mDatabase.collection(MyFirebaseCollections.POSTS).document(post.id).updateData(["post_likes": post.post_likes], completion: { (error) in
                            if error == nil {
                                completion(true)
                            }
                        })
                    }
                })
            }
            
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "singlePostSegue") {
            let vc = segue.destination as! SinglePostVC
            vc.mPost = self.mSelectedPost
            vc.mUser = self.mUser
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(mPostList.count > 0) {
            print("egvapplog", "last item \(indexPath.row + 1)")
            if indexPath.row + 1 == mPostList.count {
                print("egvapplog", "last item \(indexPath.row + 1)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mSelectedPost = mPostList[indexPath.row]
        performSegue(withIdentifier: "singlePostSegue", sender: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mPostList.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = mPostList[indexPath.row]
        print("egvapplog", "prepare cell")
        
        if(post.type == "post") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postPictureCell", for: indexPath) as! PostCell
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        } else if(post.type == "thought") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! ThoughtCell
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        }
        
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Em breve!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
