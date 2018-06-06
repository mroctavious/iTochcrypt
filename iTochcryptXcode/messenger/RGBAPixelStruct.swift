//
//  RGBAPixelStruct.swift
//  cameraTest
//
//  Created by Octavio Rodriguez Garcia on 04/04/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//

import UIKit

public struct RGBAPixel
{
    public init( rawPic : UInt32 )
    {
        raw = rawPic
    }
    
    public var raw: UInt32
    public var r: UInt8 {
        get { return UInt8(raw & 0xFF) }
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00) }
    }
    public var g: UInt8 {
        get { return UInt8( (raw & 0xFF00) >> 8 ) }
        set { raw = (UInt32(newValue) << 8) | (raw & 0xFFFF00FF) }
    }
    public var b: UInt8 {
        get { return UInt8( (raw & 0xFF0000) >> 16 ) }
        set { raw = (UInt32(newValue) << 16) | (raw & 0xFF00FFFF) }
    }
    public var a: UInt8 {
        get { return UInt8( (raw & 0xFF000000) >> 24 ) }
        set { raw = (UInt32(newValue) << 24) | (raw & 0x00FFFFFF) }
    }
    
};
