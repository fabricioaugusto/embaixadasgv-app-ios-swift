//
//  ManageModeratorsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 14/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol SelectModeratorDelegate: class {
    func onModeratorSelected(moderator: Moderator, vc: ManageModeratorsTableVC)
}

class ManageModeratorsTableVC: UITableViewController, SelectUserModeratorDelegate, RegisterModeratorDelegate {
    
    var mUser: User!
    private var mDatabase: Firestore!
    private var mModeratorList: [Moderator] = []
    
    weak var delegate: CreateEventVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        mDatabase = MyFirebase.sharedInstance.database()
        listModerators()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func onClickBtAddModerator(_ sender: UIBarButtonItem) {
        self.presentActionSheet()
    }
    
    func presentActionSheet() {
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Selecionar cadastrado", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "searchModeratorSegue", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cadastrar manualmente", style: .default , handler:{ (UIAlertAction)in
            self.performSegue(withIdentifier: "registerModeratorSegue", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func listModerators() {
        
        self.mModeratorList.removeAll()
        
        mDatabase.collection(MyFirebaseCollections.MODERATORS)
            .getDocuments { (querySnapshot, error) in
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        if let moderator = Moderator(dictionary: document.data()){
                            self.mModeratorList.append(moderator)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
        }
            
        
    }
    
    func onUserSelected(user: User, vc: SelectUserModeratorTableVC) {
        
        var moderator: [String: Any] = [:]
        moderator["name"] = user.name
        moderator["profile_img"] = user.profile_img
        moderator["embassy_id"] = user.embassy_id
        moderator["occupation"] = user.occupation
        moderator["description"] = user.description
        moderator["username"] = user.username
        moderator["user_id"] = user.id

        mDatabase.collection(MyFirebaseCollections.MODERATORS)
            .addDocument(data: moderator) { (error) in
                if error == nil {
                    self.listModerators()
                }
        }
    }
    
    func onRegisterModerator(vc: RegisterModeratorVC) {
        self.listModerators()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mModeratorList.count
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.onModeratorSelected(moderator: mModeratorList[indexPath.row], vc: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BasicUserCell

        let moderator = mModeratorList[indexPath.row]
        
        var userDict: [String:Any] = [:]
        userDict["id"] = moderator.id
        userDict["name"] = moderator.name
        userDict["profile_img"] = moderator.profile_img
        userDict["occupation"] = moderator.occupation
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "searchModeratorSegue") {
            let vc = segue.destination as! SelectUserModeratorTableVC
            vc.delegate = self
        }
        
        if (segue.identifier == "registerModeratorSegue") {
            let vc = segue.destination as! RegisterModeratorVC
            vc.mUser = self.mUser
            vc.delegate = self
        }
    }
    

}
