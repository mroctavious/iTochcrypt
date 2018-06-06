//
//  hcImage.swift
//  cameraTest
//  Clase Hill Cipher imagen que ayudara a la encriptacion de imagenes tomadas desde la camara
//  Created by Octavio Rodriguez Garcia on 04/04/18.
//  Copyright © 2018 Octavio Rodriguez Garcia. All rights reserved.
//
import UIKit

extension UIImage {
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

open class HCImage {
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
    let height: Int;
    let width: Int;
    let image : UIImage;
    var imageAppliedKey : UIImage?;
    var currentImage: UIImage?;
    
    let key: [Int];
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    let bitsPerComponent = 8
    let bytesPerRow: Int
    
    public init( width: Int, height: Int, key: [Int] ) {
        self.height = height
        self.width = width
        
        //4 bytes, 4 canales, RGBA
        bytesPerRow = 4 * width
        
        //Se obtiene los datos en crudo
        let rawdata = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        
        //Guarda la imagen en la estructura, los datos los transforma a RGBA
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawdata, count: width * height)
        self.image=UIImage();
        self.key=key;
    }
    
    public init( image: UIImage, key: [Int]  ) {
        
        //Comprimimos imagen
        //let pic = image.resizeWithPercent(percentage: 0.5)
        self.image=UIImage(data: UIImagePNGRepresentation( image.resizeWithPercent(percentage: 0.5)! )!)!;
        self.key=key;
        
        height = Int(self.image.size.height);
        width = Int(self.image.size.width);
        
        //4 bytes, 4 canales, RGBA
        bytesPerRow = 4 * width
        
        //Se obtiene los datos en crudo
        let rawdata = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        
        //se crea la imagen?
        let imageContext = CGContext(data: rawdata, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        //Se dibuja la imagen
        imageContext?.draw( (self.image.cgImage!), in: CGRect(origin: CGPoint.zero, size: (self.image.size) ));
        
        //Guarda la imagen en la estructura, los datos los transforma a RGBA
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawdata, count: width * height)
        
    }
    
    //Funcion que encripta un pixel usando Hill Cipher
    func hillCipher(p:RGBAPixel )-> RGBAPixel
    {
        
        //let key = [ 17, 17, 5, 21, 18, 21, 2, 2, 19 ];
        var p2=p
        var tmp: Int;
        let red: Int = Int(p2.r);
        let green: Int = Int(p2.g);
        let blue: Int = Int(p2.b);
        
        //Alteramos primer canal
        tmp =  ( red * self.key[0] )  + ( green * self.key[1] )  + ( blue * self.key[2] ) ;
        p2.r=UInt8( tmp % 256 );
        
        //2do Canal
        tmp = ( red * self.key[3] ) + ( green * self.key[4] ) + ( blue * self.key[5] ) ;
        p2.g=UInt8( tmp % 256 );
        
        //3er Canal
        tmp = ( red * self.key[6] ) + ( green * self.key[7] ) + ( blue * self.key[8] ) ;
        p2.b=UInt8( tmp % 256 );
        
        return p2;
    }
    
    func getPixel( _ x: Int, y: Int ) -> RGBAPixel {
        return pixels[x+y*width];
    }
    
    func setPixel( _ value: RGBAPixel, x: Int, y: Int )  {
        pixels[x+y*width] = value;
    }
    
    func toUIImage() -> UIImage {
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        return UIImage(cgImage: outContext!.makeImage()!)
    }
    
    open func transformPixels( _ tranformFunc: (RGBAPixel)->RGBAPixel ) -> UIImage {
        //let newImage = HCImage(width: self.width, height: self.height)
        for y in 0 ..< self.height {
            for x in 0 ..< self.width {
                //Source pixel :D
                let p1 = self.getPixel(x, y: y)
                let p2 = tranformFunc(p1)
                setPixel(p2, x: x, y: y)
            }
        }
        return toUIImage();
    }
    
    open func applyKey()
    {
        self.imageAppliedKey=transformPixels(hillCipher);
    }
    open func decrypt()
    {
        self.currentImage=self.image;
    }
    open func encrypt()
    {
        //Creamos objeto imagen encriptada HC
        self.currentImage=self.imageAppliedKey;
        
    }
    
    
}
