//
//  Friend+CoreDataClass.swift
//  messenger
//
//  Created by Octavio Rodriguez Garcia on 13/05/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Friend)
public class Friend: NSManagedObject {
    private var Key: [Int]?
    private var HillCipher: HCImage?;
    
    
    //Establecer objeto HC
    func setHC( hc: HCImage)
    {
        self.HillCipher=hc;
    }
    
    func getHC()->HCImage
    {
        return self.HillCipher!;
    }
    
    //Establecer las llaves
    func setKey(key: [Int] )
    {
        self.Key=key;
    }
    
    func getKey()->[Int]
    {
        return self.Key!;
    }
}
