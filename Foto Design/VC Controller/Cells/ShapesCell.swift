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
        
        
    }
    
}
class ListItem: NSCollectionViewItem {

    static let itemIdentifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ListItem")
    
    @IBOutlet weak var tempImg: NSImageView!
    @IBOutlet weak var createLbl: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
    }
    
}
class JLStickerTextView: NSCollectionViewItem {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
    }
    
}

