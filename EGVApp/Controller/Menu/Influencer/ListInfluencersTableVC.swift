//
//  ListInfluencersTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 18/01/20.
//  Copyright © 2020 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class ListInfluencersTableVC: UITableViewController {

    var mUser: User!
    private var mDatabase: Firestore!
    private var mInfluencers: [User] = []
    private var mSelectedInfluencer: User!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mDatabase = MyFirebase.sharedInstance.database()
        self.getInfluencersList()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando..."

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func getInfluencersList() {
        
        self.mInfluencers.removeAll()
        
        mDatabase.collection(MyFirebaseCollections.USERS)
            .whereField("influencer", isEqualTo: true)
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        if let influencer = User(dictionary: document.data()){
                                self.mInfluencers.append(influencer)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                }
        }
            
    }
    
    private func alertDeleteInvitationRequest() {
        
        let alert = UIAlertController(title: "Excluir solicitante", message: "Tem certeza que deseja excluir esta pessoa?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Sim, tenho certeza", style: UIAlertAction.Style.destructive, handler: { (alertAction) in
            self.deleteInvitationRequest()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteInvitationRequest() {
        
        mDatabase.collection(MyFirebaseCollections.USERS)
            .document(self.mSelectedInfluencer.id)
            .delete { (error) in
                if error == nil {
                    self.getInfluencersList()
                }
        }
    }
    
    private func makeAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mInfluencers.count
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mSelectedInfluencer = mInfluencers[indexPath.row]
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "influencerCell", for: indexPath) as! BasicUserCell

        let influencer = mInfluencers[indexPath.row]
        
        var userDict: [String:Any] = [:]
        userDict["id"] = influencer.id
        userDict["name"] = influencer.name
        userDict["profile_img"] = influencer.profile_img
        userDict["occupation"] = influencer.occupation
        
        if let basicUser = BasicUser(dictionary: userDict) {
            cell.prepare(with: basicUser)
        }
        
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
