//
//  CardsList.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//


import Foundation
import Cocoa

class CardsListVC: NSViewController {

    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var lColorPicker: NSColorWell!
    @IBOutlet weak var rColorPicker: NSColorWell!
    
    @IBOutlet weak var colorBtn: NSButton!
    @IBOutlet weak var gredientColorBtn: NSButton!
    @IBOutlet weak var colorView: NSView!
    @IBOutlet weak var gredientView: NSView!
    @IBOutlet weak var angleSlider: NSSlider!
    
    var isGradientSelected:Bool = false{
        didSet{
            if isGradientSelected == true{
                colorBtn.bgColor = NSColor.init(hex: "ffffff")
                gredientColorBtn.bgColor = NSColor.init(hex: "A80C62")
                if #available(OSX 10.14, *) {
                    colorBtn.contentTintColor = NSColor.init(hex: "A80C62")
                    gredientColorBtn.contentTintColor = NSColor.init(hex: "ffffff")
                } else {
                    // Fallback on earlier versions
                }
            }else{
                colorBtn.bgColor = NSColor.init(hex: "A80C62")
                gredientColorBtn.bgColor = NSColor.init(hex: "ffffff")
                if #available(OSX 10.14, *) {
                    colorBtn.contentTintColor = NSColor.init(hex: "ffffff")
                    gredientColorBtn.contentTintColor = NSColor.init(hex: "A80C62")
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        isGradientSelected = false
        
        NOTIFICATION_CENTER.addObserver(self, selector: #selector(selectionChanged(_:)), name: NSNotification.Name(rawValue: NotificationKey.cardSideSeleceted.rawValue),object: nil)
    }
    
    @objc func selectionChanged(_ notification:Notification) -> Void {
        if let dict = notification.object as? [String:Any] {
            if let lcolor = dict["leftColor"] as? NSColor {
                lColorPicker.color = lcolor
            }
            if let rcolor = dict["rightColor"] as? NSColor {
                rColorPicker.color = rcolor
            }
            if let angle = dict["angle"] as? Float {
                angleSlider.floatValue = angle
            }
            if let color = dict["color"] as? NSColor {
                colorPicker.color = color
            }
        }
    }
    @IBAction func importBtnClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.importBackgroundSticker.rawValue), object: nil, userInfo: nil)
    }
    @IBAction func colorBtnClicked(_ sender: Any) {
        colorView.isHidden = false
        gredientView.isHidden = true
        isGradientSelected = false
        
    }
    @IBAction func gredienttBtnClicked(_ sender: Any) {
        colorView.isHidden = true
        gredientView.isHidden = false
        isGradientSelected = true
        
        
        
        
    }
    
    @IBAction func colorDidChanged(_ sender: NSColorWell) {
        var dict:[String:Any] = [String:Any]()
        dict["color"] = sender.color
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.bgColorChanged.rawValue), object: dict, userInfo: nil)
    }
    @IBAction func lColorDidChanged(_ sender: NSColorWell) {
        var dict:[String:Any] = [String:Any]()
        dict["angle"] = angleSlider.floatValue
        dict["leftColor"] = sender.color
        dict["rightColor"] = rColorPicker.color
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.bgColorChanged.rawValue), object: dict, userInfo: nil)
    }
    @IBAction func rColorDidChanged(_ sender: NSColorWell) {
        var dict:[String:Any] = [String:Any]()
        dict["angle"] = angleSlider.floatValue
        dict["leftColor"] = lColorPicker.color
        dict["rightColor"] = sender.color
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.bgColorChanged.rawValue), object: dict, userInfo: nil)
    }
    @IBAction func angleSliderDidChanged(_ sender: NSSlider) {
        var dict:[String:Any] = [String:Any]()
        dict["angle"] = sender.floatValue
        dict["leftColor"] = lColorPicker.color
        dict["rightColor"] = rColorPicker.color
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.bgColorChanged.rawValue), object: dict, userInfo: nil)
    }
    
}
extension CardsListVC:NSCollectionViewDelegate,NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 62
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell =   collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CardListCell"), for: indexPath) as? CardListCell else {
            fatalError("The dequeued cell is not an instance of DetailCell.")
        }
        
        if let img = loadImageNamed(name: "postsBg" + String(indexPath.item)) {
            cell.quoteImg.image = img
        }
        cell.quoteImg.imageScaling = .NSScaleToFit
        
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

       // return NSSize(width:115, height:60)
        
        return NSSize(width:230, height:230)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {return}
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.BusinessCardSelected.rawValue), object: nil, userInfo: ["index":indexPath.item])
        
        
        collectionView.deselectItems(at: indexPaths)
    }
}
