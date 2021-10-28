//
//  ShapesCollectionViewCell.swift
//  Quote Maker - Asif Nadeem
//
//  Created by Asif Nadeem on 12/31/18.
//  Copyright © 2018 Asif Nadeem. All rights reserved.
//

import Cocoa

class ShapesCell: NSCollectionViewItem {


    @IBOutlet weak var quoteImg: NSImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        DispatchQueue.main.async {
//            let ta = NSTrackingArea(rect: self.view.bounds,
//                                     options: [.mouseEnteredAndExited, .mouseMoved, .activeWhenFirstResponder, .activeInKeyWindow],
//                                     owner: self,
//                                     userInfo: nil)
//            self.view.addTrackingArea(ta)
//        }
        
        
//        self.view.wantsLayer = true
//        self.view.layer?.borderWidth = 1
//        self.view.layer?.borderColor = NSColor(hex: "EBEBEB").cgColor
//        self.view.layer?.cornerRadius = 10
        
        
    }

    
//    override func mouseEntered(with event: NSEvent) {
//        NSCursor.pointingHand.set()
//    }
//    override func mouseExited(with event: NSEvent) {
//        NSCursor.arrow.set()
//    }
    
}
