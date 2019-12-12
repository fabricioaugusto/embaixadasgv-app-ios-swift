//
//  RootMenuTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 09/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RootMenuTableVC: UITableViewController {

    var mUser: User!
    private var mAuth: Auth!
    private var mDatabase: Firestore?
    private var mMenuList: [AppMenuItem] = []
    private var mSectionList: [String] = []
    private var mNumSections: Int = 0
    private var mMenuDict: [Int: [AppMenuItem]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("evgapplog root", mUser.id)
        mAuth = MyFirebase.sharedInstance.auth()
        mDatabase = MyFirebase.sharedInstance.database()
        
        if let currentUser = mAuth?.currentUser {
            getCurrentUser(uid: currentUser.uid)
        }
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func getCurrentUser(uid: String) {
        mDatabase?.collection(MyFirebaseCollections.USERS).document(uid).getDocument(completion:
            { (documentSnapshot, error) in
                
                if let user = documentSnapshot.flatMap({
                    $0.data().flatMap({ (data) in
                        return User(dictionary: data)
                    })
                }) {
                    self.mUser = user
                    self.setMenu()
                } else {
                    print("Document does not exist")
                }
        })
    }
    
    private func setMenu() {
        
        mSectionList.append("")
        mMenuDict[mNumSections] = [AppMenuItem(item_name: "Perfil", type: "profile", item_icon: nil)]
        self.mNumSections += 1
        
        self.mMenuDict[mNumSections] = MenuItens().getAccountSection()
        mSectionList.append("Configurações de Conta")
        self.mNumSections += 1
        
        mMenuList.append(contentsOf: MenuItens().getAccountSection())
        if(mUser!.leader) {
            self.mMenuDict[mNumSections] = MenuItens().getLeaderSection()
            mSectionList.append("Líderes")
            self.mNumSections += 1
        }
        if(mUser!.sponsor) {
            self.mMenuDict[mNumSections] = MenuItens().getSponsorSection()
            mSectionList.append("Padrinhos")
            self.mNumSections += 1
        }
        if(mUser!.manager) {
            self.mMenuDict[mNumSections] = MenuItens().getManagerSection()
            mSectionList.append("Gestores")
            self.mNumSections += 1
        }
        self.mMenuDict[mNumSections] = MenuItens().getPrivacySection()
        mSectionList.append("Privacidade")
        self.mNumSections += 1
        self.mMenuDict[mNumSections] = MenuItens().getMoreOptionsSection()
        mSectionList.append("Mais Opções")
        self.mNumSections += 1
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setItemsActions(item_name: String) {
        
        if(item_name == MenuItens.editProfile) {
            performSegue(withIdentifier: "editProfileSegue", sender: nil)
        }
        
        if(item_name == MenuItens.changeProfilePhoto) {
            performSegue(withIdentifier: "changeProfilePhotoSegue", sender: nil)
        }
        
        if(item_name == MenuItens.changePassword) {
            performSegue(withIdentifier: "changePasswordSegue", sender: nil)
        }
        
        if(item_name == MenuItens.editSocialNetwork) {
            performSegue(withIdentifier: "editSocialNetworkSegue", sender: nil)
        }
        
        if(item_name == MenuItens.myEmbassy) {
            performSegue(withIdentifier: "myEmbassySegue", sender: nil)
        }
        
        if(item_name == MenuItens.setPrivacy) {
            performSegue(withIdentifier: "setPrivacySegue", sender: nil)
        }
        
        if(item_name == MenuItens.newEvent) {
            performSegue(withIdentifier: "manageEventsSegue", sender: nil)
        }
        
        if(item_name == MenuItens.sentEmbassyPhotos) {
            performSegue(withIdentifier: "managePhotosSegue", sender: nil)
        }
        
        if(item_name == MenuItens.sendInvites) {
            performSegue(withIdentifier: "sendInvitationsSegue", sender: nil)
        }
        
        if(item_name == MenuItens.invitationRequests) {
            performSegue(withIdentifier: "invitationRequestsSegue", sender: nil)
        }
        
        if(item_name == MenuItens.editEmbassy) {
            performSegue(withIdentifier: "editEmbassySegue", sender: nil)
        }
        
        if(item_name == MenuItens.embassyList) {
            performSegue(withIdentifier: "embassyListSegue", sender: nil)
        }
        
        if(item_name == MenuItens.aboutEmbassy) {
            performSegue(withIdentifier: "aboutEmbassySegue", sender: nil)
        }
        
        if(item_name == MenuItens.suggestFeatures) {
            performSegue(withIdentifier: "suggestFeaturesSegue", sender: nil)
        }
        
        if(item_name == MenuItens.sendUsMessage) {
            performSegue(withIdentifier: "sendUsMessageSegue", sender: nil)
        }
        
        if(item_name == MenuItens.rateApp) {
            self.makeAlert(message: "Este recurso estará disponível nas próximas atualizações!")
        }
        
        
        if(item_name == MenuItens.logout) {
            
            do {
                try self.mAuth.signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckAuthVC") as! CheckAuthVC
                UIApplication.shared.keyWindow?.rootViewController = vc
                return
            } catch {
                print("Não foi possível fazer o logoff")
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "userSingleSegue" {
            let vc = segue.destination as! SingleUserVC
            vc.mUserID = self.mUser.id
        }
        
        if segue.identifier == "editProfileSegue" {
            let vc = segue.destination as! EditProfileVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "changeProfilePhotoSegue" {
            let vc = segue.destination as! ChangeProfilePhotoVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "changePasswordSegue" {
            let vc = segue.destination as! ChangePasswordVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "editSocialNetworkSegue" {
            let vc = segue.destination as! EditSocialNetworkingVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "myEmbassySegue" {
            let vc = segue.destination as! SingleEmbassyVC
            vc.mUser = self.mUser
            vc.mEmbassyID = self.mUser.embassy_id!
        }
        
        if segue.identifier == "setPrivacySegue" {
            let vc = segue.destination as! SetPrivacyVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "manageEventsSegue" {
            let vc = segue.destination as! ManageEventsTableVC
            //vc.mUser = self.mUser
        }
        
        if segue.identifier == "managePhotosSegue" {
            let vc = segue.destination as! ManagePhotosCollectionVC
            //vc.mUser = self.mUser
        }
        
        if segue.identifier == "sendInvitationsSegue" {
            let vc = segue.destination as! SendInvitationsVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "invitationRequestsSegue" {
            let vc = segue.destination as! InvitationRequestsTableVC
            //vc.mUser = self.mUser
        }
        
        if segue.identifier == "editEmbassySegue" {
            let vc = segue.destination as! EditEmbassyVC
            //vc.mUser = self.mUser
        }
        
        if segue.identifier == "embassyListSegue" {
            let vc = segue.destination as! ListEmbassyTableVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "aboutEmbassySegue" {
            let vc = segue.destination as! AboutEmbassiesVC
            vc.mUser = self.mUser
        }
        
        if segue.identifier == "suggestFeaturesSegue" {
            let vc = segue.destination as! SuggestFeaturesVC
            vc.mUser = self.mUser
        }
        if segue.identifier == "sendUsMessageSegue" {
            let vc = segue.destination as! SendMessageVC
            vc.mUser = self.mUser
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return mSectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mMenuDict[section]!.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0 && indexPath.row == 0) {
            performSegue(withIdentifier: "userSingleSegue", sender: nil)
            return
        }
        
        if let item_name = mMenuDict[indexPath.section]?[indexPath.row].item_name {
            self.setItemsActions(item_name: item_name)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileCell", for: indexPath) as! UserProfileCell
            cell.prepare(with: mUser!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        // Configure the cell...
        let sectionList = mMenuDict[indexPath.section]!
        cell.prepare(with: sectionList[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mSectionList[section]
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
