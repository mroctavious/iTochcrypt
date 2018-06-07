//
//  ViewController.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 09/05/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//

import UIKit

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Este tendra el id de los usuarios, es private
    //para mantenerla a salvo de otras clases
    private let cellId="Coatlicue";
    
    //Creamos arreglo de mensajes
    var messages: [Message]?;
    //Esta funcion hace que la barra aparesca en la patalla de inicio
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Recent";
        collectionView?.backgroundColor = UIColor.black;
        collectionView?.register( MessageCell.self, forCellWithReuseIdentifier: cellId);
        
        //Para que se cree el efecto de jalar y que no haya mas elementos
        collectionView?.alwaysBounceVertical=true;
        setupData();
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count
        {
            return count;
        }
        return 0; //3 Rows
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath ) as!  MessageCell
        if let message = messages?[indexPath.item]
        {
            cell.message = message;
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height/9 ) //view.frame.height/8
    }
    //override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath )
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let layout = UICollectionViewFlowLayout();
        let controller = ChatLogController( collectionViewLayout: layout );
        controller.friend = messages?[ indexPath.item ].friend;
        navigationController?.pushViewController(controller, animated: true)
    }

}

//Meter una medicion de prioridad y que vaya
//cambiando de color conforme va la prioridad


//Heredamos la celda base, y personalizamos para vista amigo
class MessageCell: BaseCell
{
    override var isHighlighted: Bool
    {
        didSet
        {
            //En caso de que se active isHighligted que ocurre
            backgroundColor = isHighlighted ? UIColor(red:202.0/255.0, green:228.0/255.0, blue:230.0/255.0, alpha:1.0) : UIColor.black;
            nameLabel.textColor = isHighlighted ? UIColor(red:0.0/255.0, green:228.0/255.0, blue:30.0/255.0, alpha:1.0) : UIColor.white;
            messageLabel.textColor = isHighlighted ? UIColor(red:0.0/255.0, green:0.0/255.0, blue:0.0/255.0, alpha:0.8) : UIColor.lightGray;
        }
    };

    var message: Message?
    {
        //Aqui se pondra la informacion de la celda del mensaje, como imagen, nombre y fecha
        didSet
        {
            nameLabel.text = message?.friend?.name;
            
            if let profileImageName = message?.friend?.profileImageName
            {
                //Hacemos objeto Hill Cipher, controlara la encriptacion del mensaje
                let hc = HCImage( image: UIImage(named: profileImageName)!, key: ( message?.friend?.getKey())! );
                message?.friend?.setHC(hc: hc);
                message?.friend?.getHC().applyKey();
                message?.friend?.getHC().encrypt();
                
                //Asignacion de imagenes a las vistas
                profileImageView.image=message?.friend?.getHC().currentImage;
                hasReadImageView.image=message?.friend?.getHC().image;
                
                //profileImageView.image=hc.encryptUsingHillCipher();
                //profileImageView.image=hc.encryptedImage;
                //hasReadImageView.image=hc.encryptedImage;
            }
            
            messageLabel.text = message?.text;
            
            if let date = message?.date
            {
                //Objeto que da formato a la fecha
                let dateFormat = DateFormatter();
                dateFormat.dateFormat="h:mm a"
                
                //Conseguimos tiempo en segundos
                let elapsedTimeSeconds = Date().timeIntervalSince(date as Date)
                let secondsInDays: TimeInterval = 60*60*24;
                
                //Formato para mensajes que pasan de una semana de viejos
                if elapsedTimeSeconds > secondsInDays*7
                {
                    dateFormat.dateFormat="dd/MM/yy";
                }
                //Ver si hay mensajes viejos, mas de 1 dia
                else if elapsedTimeSeconds > secondsInDays
                {
                    dateFormat.dateFormat="EEE";
                }
                
                timeLabel.text = dateFormat.string(from: date as Date )
            }
            
        }
    }
    //Imagen de perfil
    let profileImageView: UIImageView =
    {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill;
        imageView.layer.cornerRadius = 35;
        imageView.layer.masksToBounds = true;
        return imageView;
    }();
    
    //Linea divisora de chats
    let dividerLineView: UIView =
    {
        let view = UIView();
        view.backgroundColor = UIColor( white: 0.9, alpha: 0.6)
        return view;
    }();
    
    //Etiqueta que dice el nombre del amigo
    let nameLabel: UILabel =
    {
        let label = UILabel();
        label.text = "Friend Name";
        label.font = UIFont.systemFont(ofSize: 18);
        label.textColor = UIColor.white;
        return label;
    }();
    
    
    //Etiqueta del ultimo mensaje
    let messageLabel: UILabel =
    {
        let label = UILabel();
        label.text = "PKOOOOOO";
        label.textColor = UIColor.lightGray;
        label.font = UIFont.systemFont(ofSize: 13);

        return label;
    }();
    
    //Etiqueta para el tiempo
    let timeLabel : UILabel =
    {
        let label = UILabel();
        label.text = "21:05 PM";
        label.textColor = UIColor.lightGray;
        label.font = UIFont.systemFont(ofSize: 14);
        label.textAlignment = .right;
        return label;
    }();
    let hasReadImageView : UIImageView =
    {
        let imageView = UIImageView();
        imageView.contentMode = .scaleAspectFill;
        imageView.layer.cornerRadius = 10;
        imageView.layer.masksToBounds = true;
        return imageView;
    }();
    //Configuracion de la vista
    override func setupViews()
    {
        //Añadiendo vistas al renglon, que representa una conversacion
        addSubview(profileImageView);
        addSubview(dividerLineView);  //Linea divisora
        addSubview(timeLabel);  //Tiempo de ultimo mensaje

        //Configuracion del contenedor, este contenedor contendra los datos de una conversacion con un amigo
        setupContainerView();
        
        //Para la foto de perfil
        //Probando encriptacion con llave
        let key = [ 17, 17, 5, 21, 18, 21, 2, 2, 19 ];
        let hc=HCImage( image: UIImage(named: "Shantotto")!, key: key );
        hc.encrypt();
        profileImageView.image = hc.imageAppliedKey;
        hasReadImageView.image=hc.image;
        
        //Crear reglas para la vista de la imagen de chat
        profileImageView.translatesAutoresizingMaskIntoConstraints = false;

        //Crear reglas para la vista de la linea separadora
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false;
        
        //Reglas para la posicion de la linea divisora
        addConstraintsWithFormat(format: "H:|-100-[v0]-20-|", views: dividerLineView);
        addConstraintsWithFormat(format: "V:[v0(1)]|", views: dividerLineView);
        
        //Reglas para la posicion de la imagen de perfil cirular, eje horizontal y vertical
        addConstraintsWithFormat(format: "H:|-13-[v0(75)]", views: profileImageView);
        addConstraintsWithFormat(format: "V:|-5-[v0(68)]|", views: profileImageView);
        
        
        addConstraint(NSLayoutConstraint(item: profileImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        

        
    }
    //Contenedor del amigo, este sera cada chat que tiene el usuario
    private func setupContainerView()
    {
        
        let containerView = UIView();
        addSubview(containerView);

        addConstraintsWithFormat(format: "H:|-100-[v0]|", views: containerView );
        addConstraintsWithFormat(format: "V:[v0(50)]", views: containerView );
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        //Nombre del amigo, etiqueta
        containerView.addSubview(nameLabel);
        //Etiqueta para el tiempo
        containerView.addSubview(timeLabel);
        
        //Etiqueta del ultimo mensaje recivido
        containerView.addSubview(messageLabel);

        //Subvista de la imagen de visto, dejado en R
        containerView.addSubview(hasReadImageView);
        
        //Ajustes del contenedor nombre de amigo
        containerView.addConstraintsWithFormat(format: "H:|[v0][v1(80)]-10-|", views: nameLabel, timeLabel );
        containerView.addConstraintsWithFormat(format: "V:|[v0][v1(24)]|", views: nameLabel, messageLabel );

        //Ajustes del contenedor ultimo mensaje y Ajuste de la imagen de visto R
        containerView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(20)]-12-|", views: messageLabel, hasReadImageView );

        //Ajuste vertical del tiempo y mensaje de visto
        containerView.addConstraintsWithFormat(format: "V:|[v0(20)]", views: timeLabel );
        containerView.addConstraintsWithFormat(format: "V:[v0(20)]|", views: hasReadImageView );
    }
    
    
}

extension UIView
{
    func addConstraintsWithFormat( format: String, views: UIView... )
    {
        //Declaramos diccionario de vistas, empieza de v0, v1, v2, ... vN-1.
        var viewsDictionary = [ String : UIView ]();
        
        //Recorrer todas las vistas
        for( index, view ) in views.enumerated()
        {
            //Damos formato a la llave
            let key = "v\(index)"
            
            //Agregamos vista al diccionario
            viewsDictionary[key] = view;
            
            //Crear reglas para la vista
            view.translatesAutoresizingMaskIntoConstraints = false;
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary ))
    }
}

class BaseCell: UICollectionViewCell
{
    /*Aqui es donde entro la sobrecarga,
     cambia su atributo frame cambia a
     la forma de un rectangulo*/
    override init( frame: CGRect )
    {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()
    {
        backgroundColor=UIColor.clear;
    }
}


