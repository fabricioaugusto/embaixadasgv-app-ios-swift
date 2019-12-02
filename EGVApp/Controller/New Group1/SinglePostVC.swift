//
//  SinglePostVC.swift
//  EGVApp
//
//  Created by Fabricio on 13/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SinglePostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomContraintCommentView: NSLayoutConstraint!
    @IBOutlet weak var mCommentContainerView: UIView!
    
    var mUser: User!
    var mPost: Post!
    private var mDatabase: Firestore!
    private var mTabBarHeight: CGFloat = 0
    private var mPostCommentList: [PostComment] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        mTabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        AppLayout.addLineToView(view: mCommentContainerView, position: .LINE_POSITION_TOP, color: AppColors.colorBorderGrey, width: 1)
        
        // Do any additional setup after loading the view.
        mDatabase = MyFirebase.sharedInstance.database()
        getPost()
    }
    
    
    private func getPost() {
        
        mDatabase.collection(MyFirebaseCollections.POSTS)
        .document(mPost.id)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - mTabBarHeight
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
        return mPostCommentList.count + 1
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
                cell.post = post
                cell.prepare(with: post)
                return cell
            } else if(post.type == "thought") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! SingleThoughtCell
                cell.post = post
                cell.prepare(with: post)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! SingleArticleCell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
