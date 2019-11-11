//
//  RootPostsVC.swift
//  EGVApp
//
//  Created by Fabricio on 10/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RootPostsVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    public var buttonBarHeight: CGFloat?
    
    override func viewDidLoad() {
        self.loadDesign()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        navigationController?.navigationBar.isHidden = true // for navigation bar hide
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let hightLightPosts = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HighlightsPosts")
        let embassyPosts = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmbassyPosts")
        let allPosts = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllPosts")
        
        return [hightLightPosts, embassyPosts, allPosts]
    }
    
    func loadDesign() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = AppColors.colorLink
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = AppColors.colorText
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
