//
//  MembersCodesTableVC.swift
//  EGVApp
//
//  Created by Fabricio on 20/01/20.
//  Copyright © 2020 Fabrício Augusto. All rights reserved.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class MembersCodesTableVC: UITableViewController {

    var mUser: User!
    private var mDatabase: Firestore!
    private var mUsers: [User] = []
    private var mSearchList: [User] = []
    private var mInvitationList: [Invite] = []
    private var mSelectedInvitationRequest: Invite!
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
        
        self.mInvitationList.removeAll()
        
        mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .whereField("email_sender", isEqualTo: mUser.email)
            .getDocuments { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        if let requestor = Invite(dictionary: document.data()){
                            requestor.id = document.documentID
                            
                            self.mInvitationList.append(requestor)
                        }
                    }
                    
                    self.mHud.dismiss()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
        }
            
    }
    
    private func sendInvitationByWhatsapp() {
        
        let name = mSelectedInvitationRequest.name_receiver
        let text = "Olá *\(name)*, este é um convite para você ter acesso ao aplicativo das Embaixadas GV. Bastar baixar o *EGV App* na Google Play (para Android) ou na AppStore (para iOS), clicar em *CADASTRE-SE* e utilizar o seguinte código de acesso: *\(mSelectedInvitationRequest.invite_code)*. Vamos lá? https://embaixadasgv.app"
                
        let escapedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        print(escapedString!)
        
        //print(message)
        
        let url = URL(string: "https://wa.me/?text=\(escapedString!)")
        
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func sendInvitationByEmail() {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enviar por e-mail", message: "Digite o e-mail no campo abaixo para enviar o convite", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: { [weak alert] (_) in
            
            self.mHud.show(in: self.view)
            
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
           
            self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                .document("\(self.mSelectedInvitationRequest.invite_code)")
                .updateData(["email_receiver":textField!.text ?? "", "email_resent": true]) { (error) in
                    self.mHud.dismiss()
                    let alert = UIAlertController(title: "E-mail enviado!", message: "E-mail enviado com sucesso!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    private func copyInvitation() {
        
        let name = mSelectedInvitationRequest.name_receiver
        let text = "Olá \(name), este é um convite para você ter acesso ao aplicativo das Embaixadas GV. Bastar baixar o EGV App na Google Play (para Android) ou na AppStore (para iOS), clicar em CADASTRE-SE e utilizar o seguinte código de acesso: \(mSelectedInvitationRequest.invite_code). Vamos lá? https://embaixadasgv.app"
        
        UIPasteboard.general.string = text
        
        let alert = UIAlertController(title: "Texto do convite copiado!", message: "Agora você pode colar no Mensager do Facebook, Direct do Instagram, Telegram ou onde preferir", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func saveData() {
        
        mHud.show(in: self.view)
        
        let code: Int = Int.random(in: 100000..<999999)

        let invite: [String : Any] = [
            "name_sender" : mUser.name,
            "email_sender" : mUser.email,
            "name_receiver" : mSelectedInvitationRequest.name_receiver,
            "email_receiver" : mSelectedInvitationRequest.email_receiver,
            "embassy_receiver" : mUser.embassy!.toBasicMap(),
            "invite_code" : code,
            "created_at" : FieldValue.serverTimestamp()
        ]

        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
            .whereField("email_receiver", isEqualTo: mSelectedInvitationRequest.email_receiver)
            .getDocuments { (querySnapshot, error) in
                if let query = querySnapshot {
                    if query.documents.count > 0 {
                        self.mHud.dismiss()
                        self.makeAlert(message: "Um convite já foi enviado para este e-mail")
                    } else {
                        self.mDatabase.collection(MyFirebaseCollections.APP_INVITATIONS)
                            .addDocument(data: invite) { (error) in
                                
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
            .document("\(self.mSelectedInvitationRequest.invite_code)")
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
        return mInvitationList.count
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mSelectedInvitationRequest = mInvitationList[indexPath.row]
        
        let alert = UIAlertController(title: "Seleciona uma opção", message: "O que você deseja fazer?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Enviar por Whatsapp", style: .default , handler:{ (UIAlertAction)in
            self.sendInvitationByWhatsapp()
        }))
        alert.addAction(UIAlertAction(title: "Enviar por E-mail", style: .default , handler:{ (UIAlertAction)in
            self.sendInvitationByEmail()
        }))
        alert.addAction(UIAlertAction(title: "Copiar", style: .default , handler:{ (UIAlertAction)in
            self.copyInvitation()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "membersCell", for: indexPath) as! BasicUserCell

        let requestor = mInvitationList[indexPath.row]
        
        var userDict: [String:Any] = [:]
        userDict["id"] = requestor.id
        userDict["name"] = requestor.name_receiver
        userDict["profile_img"] = nil
        userDict["occupation"] = "\(requestor.invite_code)"
        
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
