//
//  ShapesListVC.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//

import Cocoa

class ShapesListVC: NSViewController {

    
    @IBOutlet weak var colorPicker: NSColorWell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
        return 110
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell =   collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShapesCell"), for: indexPath) as? ShapesCell else {
            fatalError("The dequeued cell is not an instance of DetailCell.")
        }
        
        if let img = loadImageNamed(name: "typo" + String(indexPath.item)){
            cell.quoteImg.image = img
        }
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = (collectionView.frame.size.width / 3 ) - 5
       // return NSSize(width:115, height:60)
        
        return NSSize(width:width, height:width)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {return}
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.shapeSelected.rawValue), object: nil, userInfo: ["index":indexPath.item])
        
        
        collectionView.deselectItems(at: indexPaths)
    }
}
