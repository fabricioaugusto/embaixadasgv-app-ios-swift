//
//  menu_items.swift
//  EGVApp
//
//  Created by Fabricio on 12/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class MenuItens {
    
    private let profile: String = "profile"
    private let editProfile : String = "Editar Perfil"
    private let changeProfilePhoto : String = "Alterar Foto de Perfil"
    private let changePassword : String = "Alterar Senha"
    private let editSocialNetwork : String = "Editar Redes Sociais"
    private let myEmbassy : String = "Minha Embaixada"
    private let myEnrolledEvents : String = "Meus Eventos Confirmados"
    private let myFavoriteEvents : String = "Meus Eventos Favoritos"
    private let newEvent : String = "Gerenciar Eventos"
    private let sendInvites : String = "Convidar Membros"
    private let invitationRequests : String = "Aprovar Solicitações de Membros"
    private let sentEmbassyPhotos : String = "Gerenciar Fotos"
    private let editEmbassy : String = "Editar Dados da Embaixada"
    private let affiliatedEmbassies : String = "Embaixadas Afiliadas"
    private let embassyForApproval : String = "Embaixadas para Aprovação"
    private let createBulletin : String = "Gerenciar Informativos"
    private let sendNotifications : String = "Enviar Notificações"
    private let manageSponsors : String = "Gerenciar Padrinhos"
    private let report : String = "Informações"
    private let setPrivacy : String = "Configurações de Privacidade"
    private let policyPrivacy : String = "Políticas de Privacidade"
    private let embassyList : String = "Lista de Embaixadas"
    private let aboutEmbassy : String = "Sobre as Embaixadas"
    private let aboutApp : String = "Sobre o Aplicativo"
    private let suggestFeatures : String = "Sugira uma Funcionalidade"
    private let rateApp : String = "Avalie o Aplicativo"
    private let sendUsMessage : String = "Envie-nos uma Mensagem"
    private let logout : String = "Sair"
    
    func getAccountSection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: editProfile, type: "item", item_icon: UIImage(named: "icon_menu_user")))
            list.append(MenuItem(item_name: changeProfilePhoto, type: "item", item_icon: UIImage(named: "icon_menu_change_photo")))
            list.append(MenuItem(item_name: changePassword, type: "item", item_icon: UIImage(named: "icon_menu_change_pass")))
            list.append(MenuItem(item_name: editSocialNetwork, type: "item", item_icon: UIImage(named: "icon_menu_change_social")))
            list.append(MenuItem(item_name: myEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_egv")))

            return list
    }

    func getPrivacySection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: setPrivacy, type: "item", item_icon: UIImage(named: "icon_menu_security")))

            return list
    }

    func getLeaderSection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: newEvent, type: "item", item_icon: UIImage(named: "icon_menu_calendar")))
            list.append(MenuItem(item_name: sentEmbassyPhotos, type: "item", item_icon: UIImage(named: "icon_menu_manager_photos")))
            list.append(MenuItem(item_name: sendInvites, type: "item", item_icon: UIImage(named: "icon_menu_invite_member")))
            list.append(MenuItem(item_name: invitationRequests, type: "item", item_icon: UIImage(named: "icon_menu_approve_user")))
            list.append(MenuItem(item_name: editEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_edit_embassy")))

            return list
        }

    func getSponsorSection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: affiliatedEmbassies, type: "item", item_icon: UIImage(named: "icon_menu_sponsor_embassies")))

            return list
    }

    func getManagerSection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: embassyForApproval, type: "item", item_icon: UIImage(named: "icon_menu_approve_embassies")))
            list.append(MenuItem(item_name: manageSponsors, type: "item", item_icon: UIImage(named: "icon_menu_manage_sponsors")))
            list.append(MenuItem(item_name: createBulletin, type: "item", item_icon: UIImage(named: "icon_menu_manager_bulletin")))
            list.append(MenuItem(item_name: sendNotifications, type: "item", item_icon: UIImage(named: "icon_menu_add_notification")))
            list.append(MenuItem(item_name: report, type: "item", item_icon: UIImage(named: "icon_menu_report")))

            return list
    }

    func getMoreOptionsSection() -> [MenuItem] {

            var list: [MenuItem] = []
            list.append(MenuItem(item_name: embassyList, type: "item", item_icon: UIImage(named: "icon_menu_embasy_list")))
            list.append(MenuItem(item_name: aboutEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_about_embassies")))
            list.append(MenuItem(item_name: suggestFeatures, type: "item", item_icon: UIImage(named: "icon_menu_lamp")))
            list.append(MenuItem(item_name: rateApp, type: "item", item_icon: UIImage(named: "icon_menu_star")))
            list.append(MenuItem(item_name: sendUsMessage, type: "item", item_icon: UIImage(named: "icon_menu_message")))
            list.append(MenuItem(item_name: logout, type: "item", item_icon: UIImage(named: "icon_menu_logout")))

            return list
    }

}
