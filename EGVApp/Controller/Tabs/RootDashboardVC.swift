//
//  RootDashboardViewController.swift
//  EGVApp
//
//  Created by Fabricio on 10/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class RootDashboardVC: UIViewController {

    @IBOutlet weak var mBtMembers: UIButton!
    @IBOutlet weak var mBtEvents: UIButton!
    @IBOutlet weak var mBtPhotos: UIButton!
    @IBOutlet weak var mBtCloud: UIButton!
    @IBOutlet var viewsToSet: [CenteredButton]!
    @IBOutlet var viewsToFormat: [UIView]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        
        // Do any additional setup after loading the view.
    }
    
    func setLayout() {
        
        for button in viewsToSet {
            button.layer.cornerRadius = 5
            button.layer.borderColor = AppColors.colorBorderGrey.cgColor
            button.layer.borderWidth = 1
        }
        
        for view in viewsToFormat {
            view.layer.cornerRadius = 5
            view.layer.borderColor = AppColors.colorBorderGrey.cgColor
            view.layer.borderWidth = 1
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

class CenteredButton: UIButton
{
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.titleRect(forContentRect: contentRect)
        let imageRect = super.imageRect(forContentRect: contentRect)
        
        return CGRect(x: 0, y: imageRect.maxY,
                      width: contentRect.width, height: rect.height)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let rect = super.imageRect(forContentRect: contentRect)
        let titleRect = self.titleRect(forContentRect: contentRect)
        
        return CGRect(x: contentRect.width/2.0 - rect.width/2.0,
                      y: (contentRect.height - titleRect.height)/2.0 - rect.height/2.0,
                      width: rect.width, height: rect.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        centerTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        centerTitleLabel()
    }
    
    private func centerTitleLabel() {
        self.titleLabel?.textAlignment = .center
    }
}
