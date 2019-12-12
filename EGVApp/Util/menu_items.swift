//
//  menu_items.swift
//  EGVApp
//
//  Created by Fabricio on 12/11/19.
//  Copyright © 2019 Fabrício Augusto. All rights reserved.
//

import UIKit

class MenuItens {
    
    static let profile: String = "profile"
    static let editProfile : String = "Editar Perfil"
    static let changeProfilePhoto : String = "Alterar Foto de Perfil"
    static let changePassword : String = "Alterar Senha"
    static let editSocialNetwork : String = "Editar Redes Sociais"
    static let myEmbassy : String = "Minha Embaixada"
    static let myEnrolledEvents : String = "Meus Eventos Confirmados"
    static let myFavoriteEvents : String = "Meus Eventos Favoritos"
    static let newEvent : String = "Gerenciar Eventos"
    static let sendInvites : String = "Convidar Membros"
    static let invitationRequests : String = "Aprovar Solicitações de Membros"
    static let sentEmbassyPhotos : String = "Gerenciar Fotos"
    static let editEmbassy : String = "Editar Dados da Embaixada"
    static let affiliatedEmbassies : String = "Embaixadas Afiliadas"
    static let embassyForApproval : String = "Embaixadas para Aprovação"
    static let createBulletin : String = "Gerenciar Informativos"
    static let sendNotifications : String = "Enviar Notificações"
    static let manageSponsors : String = "Gerenciar Padrinhos"
    static let report : String = "Informações"
    static let setPrivacy : String = "Configurações de Privacidade"
    static let policyPrivacy : String = "Políticas de Privacidade"
    static let embassyList : String = "Lista de Embaixadas"
    static let aboutEmbassy : String = "Sobre as Embaixadas"
    static let aboutApp : String = "Sobre o Aplicativo"
    static let suggestFeatures : String = "Sugira uma Funcionalidade"
    static let rateApp : String = "Avalie o Aplicativo"
    static let sendUsMessage : String = "Envie-nos uma Mensagem"
    static let logout : String = "Sair"
    
    func getAccountSection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.editProfile, type: "item", item_icon: UIImage(named: "icon_menu_user")))
        list.append(AppMenuItem(item_name: MenuItens.changeProfilePhoto, type: "item", item_icon: UIImage(named: "icon_menu_change_photo")))
        list.append(AppMenuItem(item_name: MenuItens.changePassword, type: "item", item_icon: UIImage(named: "icon_menu_change_pass")))
        list.append(AppMenuItem(item_name: MenuItens.editSocialNetwork, type: "item", item_icon: UIImage(named: "icon_menu_change_social")))
        list.append(AppMenuItem(item_name: MenuItens.myEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_egv")))

            return list
    }

    func getPrivacySection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.setPrivacy, type: "item", item_icon: UIImage(named: "icon_menu_security")))

            return list
    }

    func getLeaderSection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.newEvent, type: "item", item_icon: UIImage(named: "icon_menu_calendar")))
        list.append(AppMenuItem(item_name: MenuItens.sentEmbassyPhotos, type: "item", item_icon: UIImage(named: "icon_menu_manager_photos")))
        list.append(AppMenuItem(item_name: MenuItens.sendInvites, type: "item", item_icon: UIImage(named: "icon_menu_invite_member")))
        list.append(AppMenuItem(item_name: MenuItens.invitationRequests, type: "item", item_icon: UIImage(named: "icon_menu_approve_user")))
        list.append(AppMenuItem(item_name: MenuItens.editEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_edit_embassy")))

            return list
        }

    func getSponsorSection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.affiliatedEmbassies, type: "item", item_icon: UIImage(named: "icon_menu_sponsor_embassies")))

            return list
    }

    func getManagerSection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.embassyForApproval, type: "item", item_icon: UIImage(named: "icon_menu_approve_embassies")))
        list.append(AppMenuItem(item_name: MenuItens.manageSponsors, type: "item", item_icon: UIImage(named: "icon_menu_manage_sponsors")))
        list.append(AppMenuItem(item_name: MenuItens.createBulletin, type: "item", item_icon: UIImage(named: "icon_menu_manager_bulletin")))
        list.append(AppMenuItem(item_name: MenuItens.sendNotifications, type: "item", item_icon: UIImage(named: "icon_menu_add_notification")))
        list.append(AppMenuItem(item_name: MenuItens.report, type: "item", item_icon: UIImage(named: "icon_menu_report")))

            return list
    }

    func getMoreOptionsSection() -> [AppMenuItem] {

            var list: [AppMenuItem] = []
        list.append(AppMenuItem(item_name: MenuItens.embassyList, type: "item", item_icon: UIImage(named: "icon_menu_embasy_list")))
        list.append(AppMenuItem(item_name: MenuItens.aboutEmbassy, type: "item", item_icon: UIImage(named: "icon_menu_about_embassies")))
        list.append(AppMenuItem(item_name: MenuItens.suggestFeatures, type: "item", item_icon: UIImage(named: "icon_menu_lamp")))
        list.append(AppMenuItem(item_name: MenuItens.rateApp, type: "item", item_icon: UIImage(named: "icon_menu_star")))
        list.append(AppMenuItem(item_name: MenuItens.sendUsMessage, type: "item", item_icon: UIImage(named: "icon_menu_message")))
        list.append(AppMenuItem(item_name: MenuItens.logout, type: "item", item_icon: UIImage(named: "icon_menu_logout")))

            return list
    }

}
