//
//  InvitationRequestsTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 11/12/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class InvitationRequestsTableVC: UITableViewController {

    
    var mUser: User!
    private var mDatabase: Firestore!
    private var mUsers: [User] = []
    private var mSearchList: [User] = []
    private var mInvitationRequestList: [InvitationRequest] = []
    private var mSelectedInvitationRequest: InvitationRequest!
    private var mHud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mDatabase = MyFirebase.sharedInstance.database()
        self.getRequestorsList()
        
        mHud = JGProgressHUD(style: .light)
        mHud.textLabel.textColor = AppColors.colorPrimary
        mHud.indicatorView?.tintColor = AppColors.colorLink
        mHud.textLabel.text = "Enviando..."
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func getRequestorsList() {
        
        self.mInvitationRequestList.removeAll()
        
        mDatabase.collection(MyFirebaseCollections.INVITATION_REQUEST)
            .whereField("leaderId", isEqualTo: mUser.id)
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        print("egvapplog invitationrequests", querySnapshot.documents.count)
                        print("egvapplog invitationrequests", querySnapshot.documents[0].data())
                        if let requestor = InvitationRequest(dictionary: document.data()){
                            print("egvapplog invitationrequests", requestor)
                                requestor.id = document.documentID
                                self.mInvitationRequestList.append(requestor)
                            }
                        }
                        self.mHud.dismiss()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                }
        }
            
    }
    
    private func saveData() {
        
        mHud.show(in: self.view)
        
        let code: Int = Int.random(in: 100000..<999999)

        let invite: [String : Any] = [
            "name_sender" : mUser.name,
            "email_sender" : mUser.email,
            "name_receiver" : mSelectedInvitationRequest.requestorName,
            "email_receiver" : mSelectedInvitationRequest.requestorEmail,
            "embassy_receiver" : mUser.embassy!.toBasicMap(),
            "invite_code" : code,
            "created_at" : FieldValue.serverTimestamp()
        ]

        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .whereField("email_receiver", isEqualTo: mSelectedInvitationRequest.requestorEmail)
            .getDocuments { (querySnapshot, error) in
                if let query = querySnapshot {
                    if query.documents.count > 0 {
                        self.mHud.dismiss()
                        self.makeAlert(message: "Um convite já foi enviado para este e-mail")
                    } else {
                        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                        .document("\(code)")
                        .setData(invite) { (error) in
                                
                                if error == nil {
                                    
                                    self.mHud.dismiss()
                                     let alert = UIAlertController(title: "Convite Enviado!", message: "O convite foi enviado com sucesso!", preferredStyle: UIAlertController.Style.alert)
                                     alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                     self.present(alert, animated: true, completion: nil)
                                    self.deleteInvitationRequest()
                                }
                                
                        }
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
        
        mDatabase.collection(MyFirebaseCollections.INVITATION_REQUEST)
            .document(self.mSelectedInvitationRequest.id!)
            .delete { (error) in
                if error == nil {
                    self.getRequestorsList()
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
        return mInvitationRequestList.count
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mSelectedInvitationRequest = mInvitationRequestList[indexPath.row]
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Aprovar", style: .default , handler:{ (UIAlertAction)in
            self.saveData()
        }))
        alert.addAction(UIAlertAction(title: "Chamar no Whatsapp", style: .default , handler:{ (UIAlertAction)in
            
            var whatsapp = self.mSelectedInvitationRequest.requestorWhatsapp
            whatsapp = whatsapp.replacingOccurrences(of: " ", with: "")
            whatsapp = whatsapp.replacingOccurrences(of: "+", with: "")
            whatsapp = whatsapp.replacingOccurrences(of: "(", with: "")
            whatsapp = whatsapp.replacingOccurrences(of: ")", with: "")
            whatsapp = whatsapp.replacingOccurrences(of: "-", with: "")
            
            if(whatsapp.contains("+")) {
                whatsapp = whatsapp.replacingOccurrences(of: "+", with: "")
                let url = URL(string: "https://wa.me/\(whatsapp)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let url = URL(string: "https://wa.me/55\(whatsapp)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Enviar e-mail", style: .default , handler:{ (UIAlertAction)in
            let url = URL(string: "mailto:\(self.mSelectedInvitationRequest.requestorEmail)")!

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Deletar", style: .destructive , handler:{ (UIAlertAction)in
            self.alertDeleteInvitationRequest()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! BasicUserCell

        let requestor = mInvitationRequestList[indexPath.row]
        
        var userDict: [String:Any] = [:]
        userDict["id"] = requestor.id
        userDict["name"] = requestor.requestorName
        userDict["profile_img"] = nil
        userDict["occupation"] = requestor.requestorEmail
        
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
