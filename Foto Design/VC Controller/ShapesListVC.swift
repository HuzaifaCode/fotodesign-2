//
//  ShapesListVC.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//

import Cocoa

class ShapesListVC: NSViewController {

    @IBOutlet weak var stickerCollectionView: NSCollectionView!
    @IBOutlet weak var colorPicker: NSColorWell!
    
    @IBOutlet weak var logoBtn: NSButton!
    @IBOutlet weak var iconBtn: NSButton!
    @IBOutlet weak var shapesBtn: NSButton!
    
    var editorType:DesignViewType = .none
    
    
    var stickerSelection: StickerSelection = .logo {
        didSet{
            
            self.stickerCollectionView.reloadData()
            if stickerSelection == .logo{
                
            }else if stickerSelection == .icons{
                
            }else if stickerSelection == .shappes{
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self,selector: #selector(loadStickers(_:)),name: NSNotification.Name(rawValue: NotificationKey.DesignTypeSelected.rawValue),
                                                      object: nil)
    }
    @objc func loadStickers(_ notification:NSNotification) -> Void {
        if let type = notification.object as? DesignViewType {
            self.editorType = type
            self.stickerCollectionView.reloadData()
            
        }else {
           // self.currentTextView =  nil
        }
    }
    @IBAction func logoIconClicked(_ sender: Any) {
        self.stickerSelection = .logo
    }
    @IBAction func iconsClicked(_ sender: Any) {
        self.stickerSelection = .icons
    }
    @IBAction func shapesClicked(_ sender: Any) {
        self.stickerSelection = .shappes
    }
    @IBAction func importBtnClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.importImageSticker.rawValue), object: nil, userInfo: nil)
    }
    
    @IBAction func chnageColor(_ sender: NSColorWell) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.StickerColorChanged.rawValue), object: sender.color, userInfo: nil)
    }
    
}

extension ShapesListVC:NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if stickerSelection == .logo {
            return 210
        }else if stickerSelection == .icons {
            return 154
        }else if stickerSelection == .shappes {
            return 135
        }
        return 154
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell =   collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShapesCell"), for: indexPath) as? ShapesCell else {
            fatalError("The dequeued cell is not an instance of DetailCell.")
        }
        if stickerSelection == .logo {
            if let img = loadImageNamed(name: "logo_icon" + String(indexPath.item)){
                cell.quoteImg.image = img
            }
        }else if stickerSelection == .icons {
            if let img = loadImageNamed(name: "social_icon" + String(indexPath.item)){
                cell.quoteImg.image = img
            }
        }else if stickerSelection == .shappes {
            if let img = loadImageNamed(name: "shape_icon" + String(indexPath.item)){
                cell.quoteImg.image = img
            }
        }else{
            if let img = loadImageNamed(name: "social_icon" + String(indexPath.item)){
                cell.quoteImg.image = img
            }
        }
        cell.quoteImg.imageScaling = .scaleProportionallyUpOrDown
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = (collectionView.frame.size.width / 3 ) - 5
       // return NSSize(width:115, height:60)
        
        return NSSize(width:width, height:width)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {return}
        
        var iconName = "logo_icon" + String(indexPath.item)
        if stickerSelection == .logo {
            iconName = "logo_icon" + String(indexPath.item)
        }else if stickerSelection == .icons {
            iconName = "social_icon" + String(indexPath.item)
        }else if stickerSelection == .shappes {
            iconName = "shape_icon" + String(indexPath.item)
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.shapeSelected.rawValue), object: nil, userInfo: ["index":iconName])
        
        
        collectionView.deselectItems(at: indexPaths)
    }
}
