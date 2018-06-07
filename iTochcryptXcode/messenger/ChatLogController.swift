//
//  ChatLogController.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 13/05/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//

import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    private let cellId = "cellId"
    //Los log de mensajes
    
    
    var friend: Friend?
    {
        didSet
        {
            //Cambiar el titulo de la ventana, al nombre del amigo
            navigationItem.title = friend?.name;
            
            messages = friend?.message?.allObjects as? [Message]
            
            //Ordena los mensajes, colocando el mas reciente al principio de la lista
            messages = messages?.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending })
            
            
            
        }
    }
    var messages: [Message]?;
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    } ()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        return textField
        
    }()
    
    let sendButtom: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0,green: 137/255,blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
        
    }()
    @objc func handleSend (){
        //print(inputTextField.text)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        
    }
    //Va a sobrescribir la vista, para poder ver los mensajes
    var bottomConstraint: NSLayoutConstraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        //oculta la barra en la pestaña de mensajes
        tabBarController?.tabBar.isHidden = true
        
        //Color de fondo del chat, donde estaran las burbujas de texto
        collectionView?.backgroundColor = UIColor(red:159.0/255.0, green:238.0/255.0, blue:243.0/255.0, alpha:8.0);
        
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId )
        
        //mandamos llamar a la funcion y le damos tamaño a la barra de enviar mensajes
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponets()
        
        NotificationCenter.default.addObserver(self, selector: #selector (handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector (handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        if let userInfo = notification.userInfo {
            let keyboardFrame = ((userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue)
            print("Mario", keyboardFrame!)
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            UIView.animate(withDuration: 0, delay: 0, options:UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(completed) in
                
            })
        }
        
    }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAtPath indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
        
    
    private func setupInputComponets(){

        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButtom)
        
        
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField,sendButtom)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButtom)
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count
        {
            return count;
        }
        return 0;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath ) as! ChatLogMessageCell
        
        cell.messageTextView.text = messages?[indexPath.item].text;
        
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = messages?[indexPath.item].friend?.getHC().currentImage
        {
            cell.profileImageView.image = profileImageName;
            let size = CGSize(width: 250, height: 1000);
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            //Calcular el tamano de la ventana
            let estimado = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 19.0)], context: nil);
            
            //Para saber si el mensaje es del receptor o del emisor
            if !message.isSender
            {
                //Retornar tamano calculado
                cell.messageTextView.frame = CGRect(x: 47 + 8, y: 0, width: estimado.width, height: estimado.height + 15 );
                cell.textBubbleView.frame = CGRect(x: 47 - 7, y: 0, width: estimado.width + 10 - 5, height: estimado.height + 15 + 5 );

                //Ocultar imagen que esta colocada a la izquierda, en caso de que sea el emisor del mensaje, poner en true
                cell.profileImageView.isHidden = false;
                
                //Cambiar vector de la imagen, como emisor
                cell.bubbleImageView.image = ChatLogMessageCell.chatBubbleReceptorImage;
                
                //Color de la burbuja de mensaje
                //cell.textBubbleView.backgroundColor = UIColor(red: 130, green: 80/256, blue: 100/256, alpha: 0.6);
                cell.bubbleImageView.tintColor = UIColor(red: 255, green: 255/256, blue: 255/256, alpha: 0.6);
                //Color del texto
                cell.messageTextView.textColor = UIColor.black;
            }
            else
            {
                //////////////////////
                //MENSAJES DE SALIDA//
                //////////////////////
                
                //Retornar tamano calculado
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimado.width - 15 - 4, y: 0, width: estimado.width, height: estimado.height + 15 );
                cell.textBubbleView.frame = CGRect(x:  view.frame.width - estimado.width - 15 - 10, y: 0, width: estimado.width + 10, height: estimado.height + 15 );
                
                //Ocultar imagen que esta colocada a la izquierda
                cell.profileImageView.isHidden = true;
                
                //Cambiar vector de la imagen, como emisor
                cell.bubbleImageView.image = ChatLogMessageCell.chatBubbleEmisorImage;
                
                //Color de la burbuja de mensaje
                cell.bubbleImageView.tintColor = UIColor(red: 0,green: 137/255,blue: 249/255, alpha: 1);
                //Color del texto
                cell.messageTextView.textColor = UIColor.white;
            }
            
        }
        
        return cell
    }
    
    //Esta son el tamano de las cajas de mensajes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let messageText = messages?[indexPath.item].text
        {
            let size = CGSize(width: 250, height: 1000);
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            //Calcular el tamano de la ventana
            let estimado = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 19.0)], context: nil);

            //Retornar tamano calculado
            return CGSize(width: view.frame.width, height: estimado.height + 15 )
        }
        return CGSize( width: view.frame.width, height: 100 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0);
    }
    
}

class ChatLogMessageCell: BaseCell
{
    //MeesageTextView es el texto que se va a desplegar dentro de la burbuja
    let messageTextView: UITextView =
    {
        let textView =  UITextView();
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample message"
        textView.backgroundColor = UIColor.clear;
        return textView;
    }();
    
    //Forma que va a tener la burbuja de mensaje
    let textBubbleView: UIView =
    {
        let view = UIView();
        //view.backgroundColor = UIColor(red:202.0/255.0, green:228.0/255.0, blue:230.0/255.0, alpha:0.8);
        
        //Para el efecto de curva en los mensajes de texto
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true;
        
        return view;
    }();
    
    let profileImageView: UIImageView =
    {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill;
        imageView.layer.cornerRadius = 15;
        imageView.layer.masksToBounds = true;
        return imageView;
    }();
    
    //Vectores del chat burbuja
    static let chatBubbleReceptorImage = UIImage(named: "chatBubbleReceptor" )!.resizableImage(withCapInsets: UIEdgeInsetsMake(18, 58, 5, 58)).withRenderingMode(.alwaysTemplate);
    
    static let chatBubbleEmisorImage = UIImage(named: "chatBubbleEmisor" )!.resizableImage(withCapInsets: UIEdgeInsetsMake(18, 18, 5, 18)).withRenderingMode(.alwaysTemplate);
    
    
    //Para usar vector del chat burbuja como fondo
    let bubbleImageView: UIImageView =
    {
        let imageView = UIImageView();
        //Esta parte esta bien perra, hay que ajustar el tamano del vector de la burbuja de chat TOP, LEFT, BOTTOM, RIGHT
        imageView.image = chatBubbleReceptorImage;
        
        //imageView.tintColor = UIColor(red: 130, green: 80/256, blue: 100/256, alpha: 0.6);
        imageView.tintColor = UIColor.clear;
        return imageView;
    }();
    
    override func setupViews() {
        super.setupViews()
        
        //Vista del texto
        addSubview(textBubbleView);
        
        //Vista de la burbuja
        addSubview(messageTextView);
        
        //Vista de la imagen de perfil
        addSubview(profileImageView);
        //Reglas de posicion de la image, aqui se mueve la pequeña imagen que sale en cada burbuja de texto
        addConstraintsWithFormat(format: "H:|-10-[v0(30)]", views: profileImageView);
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView);
        
        textBubbleView.addSubview(bubbleImageView);
        addConstraintsWithFormat(format: "H:|-7-[v0]|", views: bubbleImageView );
        addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView );
        
        
        profileImageView.backgroundColor = UIColor.clear;

    }
    
}
