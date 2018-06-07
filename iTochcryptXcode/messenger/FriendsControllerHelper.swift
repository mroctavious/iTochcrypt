//
//  FriendsControllerHelper.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 13/05/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController
{
    func clearData()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate;
        if let context = delegate?.persistentContainer.viewContext
        {
            do
            {
                let entities = ["Friend", "Message"];
                for entity in entities
                {
                    let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity )
                    if let objects = try( context.fetch(request) as? [NSManagedObject] )
                    {
                        for i in objects
                        {
                            context.delete(i);
                        }
                    }
                    try(context.save())
                }
                
            }
            catch let err
            {
                print(err);
            }
        }
    }
    func setupData()
    {
        clearData();
        let delegate = UIApplication.shared.delegate as? AppDelegate;
        
        if let context = delegate?.persistentContainer.viewContext
        {
            //Amiga Shantotto
            let shantotto = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            shantotto.name="Shantotto"
            shantotto.setKey(key: [ 17, 17, 5, 21, 18, 21, 2, 2, 19 ]);
            shantotto.profileImageName="Shantotto";
            
            //Amigo Noctis
            let noctis = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            noctis.name="Noctis Lucis Caelum";
            noctis.setKey(key: [ 17, 17, 5, 21, 18, 21, 2, 2, 19 ]);
            noctis.profileImageName="Noctis";
            
            //Amigo Edward
            let ed = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            ed.name="Radical Edward";
            ed.setKey(key: [ 17, 17, 5, 21, 18, 21, 2, 2, 19 ]);
            ed.profileImageName="Edward";
            
            //Amigo Faye Valentine
            let faye = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            faye.name="Faye Valentine";
            faye.setKey(key: [ 18, 231, 65, 32, 34, 76, 43, 213, 123 ]);
            faye.profileImageName="Faye";
            
            //Amigo Janis Joplin
            let janis = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            janis.name="Janis Joplin";
            janis.setKey(key: [ 18, 231, 65, 32, 34, 76, 43, 213, 123 ]);
            janis.profileImageName="Janis";
            
            //Amigo Aristegui
            let aristegui = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context ) as! Friend;
            aristegui.name="Carmen Aristegui";
            aristegui.setKey(key: [ 18, 231, 65, 32, 34, 76, 43, 213, 123 ]);
            aristegui.profileImageName="Aristegui";
            
            
            //Mensajes Noctis
            FriendsController.createMessageWithText(text: "Didn't...mean to do that", friend: noctis, minutesAgo: 4, context: context);
            FriendsController.createMessageWithText(text: "Yes, you did!", friend: noctis, minutesAgo: 3, context: context);
            FriendsController.createMessageWithText(text: "Ok, i'll talk to you later man!", friend: noctis, minutesAgo: 2, context: context);
            
            //Mensajes Shantotto
            FriendsController.createMessageWithText(text: "Hohohoho como te atreveis, perra!", friend: shantotto, minutesAgo: 1, context: context);
            //Respuesta
            FriendsController.createMessageWithText(text: "Disculpa?", friend: shantotto, minutesAgo: 1, context: context, isSender: true);
 
            //Mensajes de Edward
            FriendsController.createMessageWithText(text: "I think I know. I don't think I know. I don't think I think I know. I don't think I think.", friend: ed, minutesAgo: 10, context: context)

            //Mensajes Noctis
            FriendsController.createMessageWithText(text: "If Alice was still alive she’d be over 200 years old.", friend: faye, minutesAgo: 1440*2, context: context);
            FriendsController.createMessageWithText(text: " We’re Romanies. For eons we’ve wandered the stars looking for love. It’s our way.", friend: faye, minutesAgo: 1440*3, context: context);
            FriendsController.createMessageWithText(text: "The wilds are calling me! You can’t keep me locked up!", friend: faye, minutesAgo: 1440*4, context: context);
            
            //Mensajes de Janis
            FriendsController.createMessageWithText(text: "The more you live, the less you die.", friend: janis, minutesAgo: 1440*34, context: context);
            FriendsController.createMessageWithText(text: "If you've got a today, don't wear it tomorrow. Tomorrow never happens. It's all the same day.", friend: janis, minutesAgo: 1440*35, context: context);
            FriendsController.createMessageWithText(text: "Freedom is just another word for when you have NOTHING left to lose.", friend: janis, minutesAgo: 1440*36, context: context);
            FriendsController.createMessageWithText(text: "Singing, it's like it's like loving somebody, it's a supreme emotional and physical experience.", friend: janis, minutesAgo: 1440*37, context: context);
            
            
            //Mensajes de Aristegui
            FriendsController.createMessageWithText(text: "Hay un conjunto de concesiones en juego, y la resolución final sobre lo que pase con ellas se encuentra en el cajón del Presidente.", friend: aristegui, minutesAgo: 60*24*30, context: context);
            FriendsController.createMessageWithText(text: "Los poderes dominantes en las telecomunicaciones impiden la entrada de nuevos competidores, y a los que existen les hace la vida verdaderamente imposible.", friend: aristegui, minutesAgo: 60*24*35, context: context);
            FriendsController.createMessageWithText(text: "¿Por qué en México los empresarios de los medios pueden ser sometidos a presiones para que silencien a los comunicadores?", friend: aristegui, minutesAgo: 60*24*40, context: context);
            FriendsController.createMessageWithText(text: "¿Qué clase de país es éste, que por un comentario editorial, se le corta la cabeza a quien lo comentó?", friend: aristegui, minutesAgo: 60*24*45, context: context);
            
            
            do
            {
                try(context.save())
            }
            catch let err
            {
                print(err);
            }
        }
        
        loadData();
    }
    static func createMessageWithText( text: String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false )
    {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context ) as! Message;
        message.text = text;
        message.friend = friend;
        message.date = NSDate().addingTimeInterval(-minutesAgo * 60);
        message.isSender = NSNumber(booleanLiteral: isSender ) as! Bool;
    }
    func loadData()
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate;
        if let context = delegate?.persistentContainer.viewContext
        {
            //Cargar todos los amigos
            if let friends = fetchFriends()
            {
                messages = [Message]();
                for friend in friends
                {
                    print(friend.name!)
                    
                    //Agarra los mensajes guardados en el core data
                    let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Message");
                    
                    //Ordena los datos adquiridos, la ordenacion va a ser por el campo date
                    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)];
                    
                    //Conseguir el ultimo mensaje, primero filtra por el nombre, despues limitamos resultados a 1, este conseguira el mas nuevo
                    request.predicate = NSPredicate(format: "friend.name = %@", friend.name! );
                    request.fetchLimit = 1;
                    
                    do
                    {
                        let fetchedMessage = try(context.fetch(request)) as? [Message];
                        messages?.append(contentsOf: fetchedMessage!)
                    }
                    catch let err
                    {
                        print(err);
                    }
                }
                
                //Ordena los mensajes, colocando el mas reciente al principio de la lista
                messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedDescending})
            }

        }
    }
    
    //Funcion que cargara desde core data los amigos
    private func fetchFriends()->[Friend]?
    {
        let delegate = UIApplication.shared.delegate as? AppDelegate;
        if let context = delegate?.persistentContainer.viewContext
        {
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend");
            do
            {
                return try context.fetch(request) as? [Friend];
            }
            catch let err
            {
                print(err);
            }
        }
        return nil;
    }
}
