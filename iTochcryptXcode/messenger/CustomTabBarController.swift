//
//  CustomTabBarController.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 16/05/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//

import UIKit
class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout: layout);

        //Mensajes recientes
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController);
        recentMessagesNavController.tabBarItem.title = "Recent";
        recentMessagesNavController.tabBarItem.image = UIImage(named: "Recent")
       
        
        //Setup our custom view controller
        viewControllers = [recentMessagesNavController, createDummyNavControllerWithTitle(title: "Community", imageName: "Community"), createDummyNavControllerWithTitle(title: "Notas", imageName: "Notes"), createDummyNavControllerWithTitle(title: "Settings", imageName: "Settings")];
    }
    //Funcion que crea controlador para cada posicion de la barra de opciones de abajo
    private func createDummyNavControllerWithTitle( title: String, imageName: String ) -> UINavigationController
    {
        let viewController = UIViewController();
        let navController = UINavigationController(rootViewController: viewController );
        navController.tabBarItem.title = title;
        navController.tabBarItem.image = UIImage(named: imageName);
        return navController;
    }
}
