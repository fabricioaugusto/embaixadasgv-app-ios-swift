//
//  SinglePostVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import NextGrowingTextView


protocol SinglePostDelegate: class {
    func postWasCommented(post: Post, vc: SinglePostVC)
}

class SinglePostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContraintCommentView: NSLayoutConstraint!
    @IBOutlet weak var mCommentContainerView: UIView!
    @IBOutlet weak var mTextViewComment: NextGrowingTextView!
    
    weak var delegate: RootPostsTableVC!
    
    var mUser: User!
    var mPost: Post!
    var mPostID: String!
    private var mCurrentKeyboardHeight: CGFloat = 0.0
    private var mkeyboardWillShowObserver: NSObjectProtocol!
    private var mkeyboardWillHideObserver: NSObjectProtocol!
    private var mDatabase: Firestore!
    private var mTabBarHeight: CGFloat = 0
    private var mPostCommentList: [PostComment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mTabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        
        AppLayout.addLineToView(view: mCommentContainerView, position: .LINE_POSITION_TOP, color: AppColors.colorBorderGrey, width: 1)
        
        let font = UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: AppColors.colorSubText
        ]
        
        mTextViewComment.textView.textColor = AppColors.colorText
        mTextViewComment.textView.font = UIFont.systemFont(ofSize: 15)
        
        mTextViewComment.placeholderAttributedText = NSAttributedString(string: "Deixe um comentário aqui...", attributes: attributes)
        
        // Do any additional setup after loading the view.
        mDatabase = MyFirebase.sharedInstance.database()
        getPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let center = NotificationCenter.default
        
        self.mkeyboardWillShowObserver = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let height = value.cgRectValue.height
            
            print(self.view.frame.origin.y)
        
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= height - self.mTabBarHeight
            } else if self.view.frame.origin.y == (0 - (self.mCurrentKeyboardHeight - self.mTabBarHeight)) {
                self.view.frame.origin.y = 0 - (height - self.mTabBarHeight)
            }
            
            self.mCurrentKeyboardHeight = height
            // use the height of the keyboard to layout your UI so the prt currently in
            // foxus remains visible
        }
        
        self.mkeyboardWillHideObserver = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func onClickBtSaveComment(_ sender: Any) {
        self.saveComment()
    }
    
    private func getPost() {
        
        if mPostID == nil {
            mPostID = mPost.id
        }
        
        mDatabase.collection(MyFirebaseCollections.POSTS)
        .document(mPostID)
            .getDocument { (documentoSnapshot, error) in
                if let error = error {
                    
                } else {
                    if let post = documentoSnapshot.flatMap({$0.data().flatMap({ (data) in
                       return Post(dictionary: data)
                    })}) {
                        self.mPost = post
                        self.getComments()
                    }
                }
        }
    }
    
    private func getComments() {
    
        self.mDatabase.collection(MyFirebaseCollections.POST_COMMENTS)
            .whereField("post_id", isEqualTo: mPost.id)
            .order(by: "date", descending: false)
            .getDocuments(completion: { (querySnapshot, error) in
                
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let comment = PostComment(dictionary: document.data())
                        if let comment = comment {
                            self.mPostCommentList.append(comment)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            })
    }
    
    private func saveComment() {
        let comment = mTextViewComment.textView.text ?? ""

        if(comment.isEmpty){
            return
        }

        mTextViewComment.textView.text = ""

        var postComment: [String: Any] = [:]
        postComment["post_id"] = mPost.id
        postComment["user_id"] = mUser.id
        postComment["text"] = comment
        postComment["user"] = mUser.toBasicMap()
        postComment["date"] = FieldValue.serverTimestamp()
        
        var ref: DocumentReference? = nil
        
        ref = mDatabase.collection(MyFirebaseCollections.POST_COMMENTS)
            .addDocument(data: postComment) { (error) in
                if error == nil {
                    ref!.updateData(["id": ref!.documentID])
                    postComment["id"] = ref!.documentID
                    let comment = PostComment(dictionary: postComment)
                    self.mPost.post_comments += 1
                    self.delegate.postWasCommented(post: self.mPost, vc: self)
                    if let comment = comment {
                       self.mPostCommentList.append(comment)
                    }
                    self.view.endEditing(true)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: self.mPostCommentList.count, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    
                    self.mDatabase.collection(MyFirebaseCollections.POSTS)
                        .document(self.mPost.id).getDocument { (documentSnapshot, error) in
                            
                            if let error = error {
                                
                            } else {
                                if let post = documentSnapshot.flatMap({
                                    $0.data().flatMap({ (data) in
                                        return Post(dictionary: data)
                                    })
                                }) {
                                    let post_comments = post.post_comments + 1
                                    documentSnapshot?.reference.updateData(["post_comments": post_comments])
                                    
                                } else {
                                    print("Document not exists")
                                }
                            }
                            
                    }
                }
        }

                //setNotification("post_comment", postComment.id)
            
    }
    
    func startSingleUserVC() {
        performSegue(withIdentifier: "userSingleSegue", sender: nil)
    }
    
    func startListLikesVC() {
        performSegue(withIdentifier: "likeUsersSegue", sender: nil)
    }
    
    private func setKeyboardObservers() {
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                print(keyboardSize.size.height)
                self.view.frame.origin.y -= keyboardSize.size.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mPost != nil ? mPostCommentList.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = mPost!
        print("egvapplog", "prepare cell")

        if(indexPath.row == 0) {
            if(post.type == "post") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postPictureCell", for: indexPath) as! SinglePostCell
                cell.rootVC = self
                cell.post = post
                cell.prepare(with: post)
                return cell
            } else if(post.type == "thought") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! SingleThoughtCell
                cell.rootVC = self
                cell.post = post
                cell.prepare(with: post)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! SingleArticleCell
                cell.rootVC = self
                cell.post = post
                cell.prepare(with: post)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCommentCell", for: indexPath) as! PostCommentCell
            let comment = mPostCommentList[indexPath.row - 1]
            cell.prepare(with: comment)
            return cell
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "userSingleSegue") {
            let vc = segue.destination as! SingleUserVC
            vc.mUserID = self.mPost.user_id
        }
        
        if segue.identifier == "likeUsersSegue" {
            let vc = segue.destination as! ListUsersTableVC
            vc.mType = "likeUsers"
            vc.mPostID = mPost.id
            vc.mUser = mUser
        }
    }
    

}

extension SinglePostVC: UITextViewDelegate {
    
}
