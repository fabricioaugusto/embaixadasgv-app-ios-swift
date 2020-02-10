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
import STPopup
import Sheeeeeeeeet

class RootPostsTableVC: UITableViewController, CreatePostDelegate, SinglePostDelegate {

    var mUser: User!
    private var mAuth: Auth!
    private var mSelectedPost: Post!
    private var mSelectedPostUserID: String!
    private var mSelectedIndexPath: IndexPath!
    private var mDatabase: Firestore!
    private var mPostList: [Post] = []
    private var mHighlightPostList: [Post] = []
    private var mEmbassyPostList: [Post] = []
    private var mAllPostList: [Post] = []
    private var mListLikes: [PostLike] = []
    private var mHighlightLastDocument: DocumentSnapshot!
    private var mEmbassyLastDocument: DocumentSnapshot!
    private var mAllLastDocument: DocumentSnapshot!
    private var mIsHighlightDocumentsOver: Bool = false
    private var mIsEmbassyDocumentsOver: Bool = false
    private var mIsAllDocumentsOver: Bool = false
    private var mIsLoadingList: Bool = false
    private var mAdapterPosition: Int = 0
    private var mUserID: String!
    private var mLikeIsProcessing: Bool = false
    private var mCreatePostType: String!
    @IBOutlet weak var mSegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("evgapplog root", mUser.id)
        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        
        if(mUser.influencer || mUser.counselor) {
            self.mSegmentControl.removeSegment(at: 1, animated: false)
        }
        
        
        if #available(iOS 13, *) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for i in 0...(self.mSegmentControl.numberOfSegments-1)  {
                    let backgroundSegmentView = self.mSegmentControl.subviews[i]
                    //it is not enogh changing the background color. It has some kind of shadow layer
                    backgroundSegmentView.isHidden = true
                }
            }
            
            mSegmentControl.layer.borderColor = AppColors.colorPrimary.cgColor
            mSegmentControl.layer.borderWidth = 1.0
            mSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorPrimary], for: .normal)
            mSegmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppColors.colorWhite], for: .selected)
        }
        
        
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
        
        self.tabBarController?.tabBar.isHidden = false
        
        // delegate and data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func onClickCreatePost(_ sender: UIBarButtonItem) {
        
        self.mCreatePostType = "photo"
        self.startCreatePostVC()
        
        //self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "createPostMenuVC") as! CreatePostMenuVC
        viewController.mRootPostsTableVC = self
        let popupController = STPopupController(rootViewController: viewController)
        popupController.present(in: self)
        
        
        let item1 = MenuItem(title: "Foto", subtitle: nil, value: "photo", image: UIImage(named: "icon_picture"), isEnabled: true, tapBehavior: .dismiss)
        let item2 = MenuItem(title: "Pensamento", subtitle: nil, value: "thought", image: UIImage(named: "icon_bubble"), isEnabled: true, tapBehavior: .dismiss)
        let item3 = MenuItem(title: "Nota", subtitle: nil, value: "note", image: UIImage(named: "icon_create_note"), isEnabled: true, tapBehavior: .dismiss)
        let items = [item1, item2, item3]
        let menu = Menu(title: "O que você gostaria de compartilhar?", items: items)
        
        let sheet = menu.toActionSheet(presenter: ActionSheet.defaultPresenter) { sheet, item in
            if let value = item.value as? String {
                if value == "photo" {
                    self.mCreatePostType = "photo"
                    self.startCreatePostVC()
                }
                if value == "thought" {
                    self.mCreatePostType = "thought"
                    self.startCreatePostVC()
                }
                if value == "note" {
                    self.mCreatePostType = "note"
                    self.startCreatePostVC()
                }
            }
        }
        
        sheet.present(in: self, from: self.view)*/
        
        
        /*let sheet = ActionSheet(items: items) { sheet, item in
            if let value = item.value as? Int { print("You selected an int: \(value)") }
            if let value = item.value as? String { print("You selected a string: \(value)") }
            if let value = item.value as? Car { print("You selected a car") }
            if item.isOkButton { print("You tapped the OK button") }
        }*/
    }
    
    
    @IBAction func onChangePostCategory(_ sender: UISegmentedControl) {
        if(mUser.influencer || mUser.counselor) {
            changePostCategoryInfluencer(sender: sender)
        } else {
            changePostCategory(sender: sender)
        }
    }
    
    private func changePostCategory(sender: UISegmentedControl) {
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
    
    private func changePostCategoryInfluencer(sender: UISegmentedControl) {
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
                    print("Error getting documents: \(err)")
                } else {
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mHighlightLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsHighlightDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mHighlightPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mHighlightPostList
                        } else {
                            self.mIsHighlightDocumentsOver = true
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            })
    }
    
    private func loadMoreHighlightListPosts() {
        
        self.mIsLoadingList = true
        
        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: true)
            .order(by: "date", descending: true)
            .start(afterDocument: self.mHighlightLastDocument)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mHighlightLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsHighlightDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mHighlightPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mHighlightPostList
                        } else {
                            self.mIsHighlightDocumentsOver = true
                        }
                        
                        DispatchQueue.main.async {
                            self.mIsLoadingList = false
                            self.tableView.reloadData()
                        }
                    }
                    
                }
            })
    }
    
    private func getEmbassyPosts() {
        
        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("embassy_id", isEqualTo: mUser.embassy_id)
            .whereField("user_verified", isEqualTo: false)
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mEmbassyLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsEmbassyDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mEmbassyPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mEmbassyPostList
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            self.mIsEmbassyDocumentsOver = true
                        }
                    }
                    
                }
            })
    }
    
    private func loadMoreEmbassyPosts() {
        
        self.mIsLoadingList = true
        
        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("embassy_id", isEqualTo: mUser.embassy_id)
            .whereField("user_verified", isEqualTo: false)
            .order(by: "date", descending: true)
            .start(afterDocument: self.mEmbassyLastDocument)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mEmbassyLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsEmbassyDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mEmbassyPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mEmbassyPostList
                            
                            DispatchQueue.main.async {
                                self.mIsLoadingList = false
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            self.mIsEmbassyDocumentsOver = true
                        }
                        
                        
                    }
                    
                }
            })
    }
    
    private func getAllPosts() {
        
        self.mIsLoadingList = true

        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: false)
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mAllLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsAllDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mAllPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mAllPostList
                            
                            DispatchQueue.main.async {
                                self.mIsLoadingList = false
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            self.mIsAllDocumentsOver = true
                        }
                        
                    }
                    
                }
            })
    }
    
    private func loadMoreAllPosts() {

        self.mDatabase?.collection(MyFirebaseCollections.POSTS)
            .whereField("user_verified", isEqualTo: false)
            .order(by: "date", descending: true)
            .start(afterDocument: self.mAllLastDocument)
            .limit(to: 30)
            .getDocuments(completion: { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let query = querySnapshot {
                        
                        if query.documents.count > 0 {
                            
                            self.mAllLastDocument = query.documents[query.documents.count - 1]
                            
                            if query.documents.count < 10 {
                                self.mIsAllDocumentsOver = true
                            }
                            
                            for document in querySnapshot!.documents {
                                let post = Post(dictionary: document.data())
                                if(post != nil) {
                                    if(post!.type != "video") {
                                        self.mAllPostList.append(post!)
                                    }
                                }
                            }
                            self.mPostList = self.mAllPostList
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        } else {
                            self.mIsAllDocumentsOver = true
                        }
                        
                    }
                    
                }
            })
    }
    

    
    private func getPostLikes() {
        
        mIsHighlightDocumentsOver = false
        mIsEmbassyDocumentsOver = false
        mIsAllDocumentsOver = false
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
    
    func postWasPublished(vc: CreatePostVC, highlightPost: Bool) {
        mHighlightPostList.removeAll()
        mAllPostList.removeAll()
        mEmbassyPostList.removeAll()
        
        if(highlightPost) {
            mSegmentControl.selectedSegmentIndex = 0
            self.getHighlightListPosts()
        } else {
            mSegmentControl.selectedSegmentIndex = 1
            self.getEmbassyPosts()
        }
        
        
    }
    
    func postWasCommented(post: Post, vc: SinglePostVC) {
        
        if let allPostsOffset = mAllPostList.firstIndex(where: {$0.id == post.id}) {
            mAllPostList[allPostsOffset] = post
        }
        
        if let embassyPostsOffset = mEmbassyPostList.firstIndex(where: {$0.id == post.id}) {
            mEmbassyPostList[embassyPostsOffset] = post
        }
        
        if let highlightOffset = mHighlightPostList.firstIndex(where: {$0.id == post.id}) {
            mHighlightPostList[highlightOffset] = post
        }
        
        mPostList[mSelectedIndexPath.row] = post
        self.tableView.reloadRows(at: [mSelectedIndexPath], with: .none)
    }
    
    func deletePost(post: Post, index: Int) {
        mDatabase.collection(MyFirebaseCollections.POSTS)
            .document(post.id)
            .delete { (error) in
                if error == nil {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.mPostList.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    if let allPostsOffset = self.mAllPostList.firstIndex(where: {$0.id == post.id}) {
                        self.mAllPostList.remove(at: allPostsOffset)
                    }
                    
                    if let embassyPostsOffset = self.mEmbassyPostList.firstIndex(where: {$0.id == post.id}) {
                        self.mEmbassyPostList.remove(at: embassyPostsOffset)
                    }
                    
                    if let highlightOffset = self.mHighlightPostList.firstIndex(where: {$0.id == post.id}) {
                        self.mHighlightPostList.remove(at: highlightOffset)
                    }
                }
        }
    }
    
    func startSingleUserVC(userId: String) {
        self.mSelectedPostUserID = userId
        performSegue(withIdentifier: "userSingleSegue", sender: nil)
    }
    
    func startCreatePostVC() {
        performSegue(withIdentifier: "createPostVC", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "userSingleSegue") {
            let vc = segue.destination as! SingleUserVC
            vc.mUserID = self.mSelectedPostUserID
        }
        
        if(segue.identifier == "singlePostSegue") {
            let vc = segue.destination as! SinglePostVC
            vc.mPost = self.mSelectedPost
            vc.mUser = self.mUser
            vc.delegate = self
        }
        
        if(segue.identifier == "createPostVC") {
            let vc = segue.destination as! CreatePostVC
            vc.mUser = self.mUser
            vc.mPostType = mCreatePostType
            vc.delegate = self
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.mSelectedIndexPath = indexPath
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
            cell.mIndex = indexPath.row
            cell.mUser = mUser
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        } else if(post.type == "thought") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! ThoughtCell
            cell.mIndex = indexPath.row
            cell.mUser = mUser
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell
            cell.mIndex = indexPath.row
            cell.mUser = mUser
            cell.rootVC = self
            cell.post = post
            cell.prepare(with: post, postLikes: mListLikes)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let indexSelected = self.mSegmentControl.selectedSegmentIndex
        
        
        if(mUser.influencer || mUser.counselor) {
            
            if(indexSelected == 0) {
                if indexPath.row == self.mHighlightPostList.count-5 && !self.mIsLoadingList && !self.mIsHighlightDocumentsOver{
                    self.loadMoreHighlightListPosts()
                }
            }
            
            if(indexSelected == 1) {
                if indexPath.row == self.mAllPostList.count-5 && !self.mIsLoadingList && !self.mIsAllDocumentsOver{
                    self.loadMoreAllPosts()            }
            }
            
        } else {
            if(indexSelected == 0) {
                if indexPath.row == self.mHighlightPostList.count-5 && !self.mIsLoadingList && !self.mIsHighlightDocumentsOver{
                    self.loadMoreHighlightListPosts()
                }
            }
            
            if(indexSelected == 1) {
                if indexPath.row == self.mEmbassyPostList.count-5 && !self.mIsLoadingList && !self.mIsEmbassyDocumentsOver{
                    self.loadMoreEmbassyPosts()
                }
            }
            
            if(indexSelected == 2) {
                if indexPath.row == self.mAllPostList.count-5 && !self.mIsLoadingList && !self.mIsAllDocumentsOver{
                    self.loadMoreAllPosts()            }
            }
        
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

/*extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            
            
            
            let tintColorImage = UIImage(color: tintColor)
            // Must set the background image for normal to something (even clear) else the rest won't work
            setBackgroundImage(UIImage(color: backgroundColor ?? .clear), for: .normal, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            setBackgroundImage(UIImage(color: tintColor.withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            setTitleTextAttributes([.foregroundColor: tintColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular)], for: .normal)
            setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            layer.borderWidth = 1
            layer.borderColor = tintColor.cgColor
        }
    }
}*/
