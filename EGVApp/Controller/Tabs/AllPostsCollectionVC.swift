//
//  AllPostsCollectionVC.swift
//  EGVApp
//
//  Created by Fabricio on 20/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
import XLPagerTabStrip
import FirebaseFirestore

class AllPostsCollectionVC: UICollectionViewController {
    
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

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        

        // Do any additional setup after loading the view.
        mDatabase = MyFirebase.sharedInstance.database()
        getAllPosts()
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Geral")
    }
    
    private func getAllPosts() {
        
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
                            self.collectionView.reloadData()
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
                            self.getAllPosts()
                        }
                    }
                    
                }
            })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return mPostList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = mPostList[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postPictureCell", for: indexPath) as! PostPictureCollectionCell
        cell.prepare(with: post)
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
