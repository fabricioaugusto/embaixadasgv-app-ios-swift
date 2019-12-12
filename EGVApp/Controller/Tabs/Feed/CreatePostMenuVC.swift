//
//  CreatePostMenuVC.swift
//  EGVApp
//
//  Created by Fabricio on 05/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import STPopup

class CreatePostMenuVC: UIViewController {

    weak var mRootPostsTableVC: RootPostsTableVC!
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //title = "View Controller"
        navigationController?.setNavigationBarHidden(true, animated: false)
       //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBtnDidTap))
       // It's required to set content size of popup.
        
        
       contentSizeInPopup = CGSize(width: 300, height: 180)
       landscapeContentSizeInPopup = CGSize(width: 400, height: 200)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onClickCreatePostPicture(_ sender: UIButton) {
        self.mRootPostsTableVC.startCreatePostVC()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onClickCreatePostThought(_ sender: UIButton) {
        self.mRootPostsTableVC.startCreatePostVC()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onClickCreatePostNote(_ sender: UIButton) {
        self.mRootPostsTableVC.startCreatePostVC()
        self.dismiss(animated: true, completion: nil)
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
