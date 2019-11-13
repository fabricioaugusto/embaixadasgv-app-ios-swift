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

    private var mUser: User?
    private var mAuth: Auth?
    private var mDatabase: Firestore?
    private var mMenuList: [MenuItem] = []
    private var mSectionList: [String] = []
    private var mNumSections: Int = 0
    private var mMenuDict: [Int: [MenuItem]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        mMenuDict[mNumSections] = [MenuItem(item_name: "Perfil", type: "profile", item_icon: nil)]
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return mSectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mMenuDict[section]!.count
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
