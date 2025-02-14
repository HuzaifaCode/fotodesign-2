//
//  CardsList.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//


import Foundation
import Cocoa
import SDWebImage


class CardsListVC: NSViewController {

    @IBOutlet weak var bgCollectionView: NSCollectionView!
    
    
    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var lColorPicker: NSColorWell!
    @IBOutlet weak var rColorPicker: NSColorWell!
    
    @IBOutlet weak var colorBtn: NSButton!
    @IBOutlet weak var gredientColorBtn: NSButton!
    @IBOutlet weak var colorView: NSView!
    @IBOutlet weak var gredientView: NSView!
    @IBOutlet weak var angleSlider: NSSlider!
    
    var editorType:DesignViewType = .none
    
    var backgroundsArray:[PhotoObject]?
    
    var isGradientSelected:Bool = false{
        didSet{
            if isGradientSelected == true{
                colorBtn.bgColor = NSColor.init(hex: "ffffff")
                gredientColorBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
                if #available(OSX 10.14, *) {
                    colorBtn.contentTintColor = NSColor.init(hex: MAIN_COLOR)
                    gredientColorBtn.contentTintColor = NSColor.init(hex: "ffffff")
                } else {
                    // Fallback on earlier versions
                }
            }else{
                colorBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
                gredientColorBtn.bgColor = NSColor.init(hex: "ffffff")
                if #available(OSX 10.14, *) {
                    colorBtn.contentTintColor = NSColor.init(hex: "ffffff")
                    gredientColorBtn.contentTintColor = NSColor.init(hex: MAIN_COLOR)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    lazy var sheetViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "SubscriptionVC")
        as! NSViewController
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        isGradientSelected = false
        
        NOTIFICATION_CENTER.addObserver(self, selector: #selector(selectionChanged(_:)), name: NSNotification.Name(rawValue: NotificationKey.cardSideSeleceted.rawValue),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(loadBackgrounds(_:)),name: NSNotification.Name(rawValue: NotificationKey.DesignTypeSelected.rawValue),
                                                      object: nil)
        
        NOTIFICATION_CENTER.addObserver(self,
                  selector: #selector(refreshData),
                  name:NSNotification.Name( NotificationKey.Refresh_Data.rawValue),object: nil)
        
       // loadData()
    }
    
    @objc func refreshData(){
        self.bgCollectionView.reloadData()
    }
    
    
    @objc func loadBackgrounds(_ notification:NSNotification) -> Void {
        if let type = notification.object as? DesignViewType {
            //self.currentTextView = zdView
            //self.currentSelectedFontFamily = dView.txtView.familyName
            self.editorType = type
            if type == .flyer || type == .invitation {
                loadData(search: "invitation&orientation=vertical")
            }else if type == .poster{
                loadData(search: "poster&orientation=horizontal")
            }else if type == .logo{
                loadData(search: "background+texture&orientation=horizontal")
            }else if type == .ytThumbnail{
                loadData(search: "video&orientation=horizontal")
            }else{
                loadData(search: "wallpaper&orientation=horizontal")
            }
        }else {
           // self.currentTextView =  nil
        }
    }
    
    
    func loadData(search:String){
        ApiManager.getImages(type: search, completion: {[weak self](result,abc) in
             guard let self = self else {return}
            
            if let imgArray = result?.hits{
                print(imgArray)
                self.backgroundsArray = imgArray
                self.bgCollectionView.reloadData()
            }
           
            
            
        }, progress: {[weak self](progress) in
            guard let self = self else {return}
           print(progress)
        })
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
        if let count = backgroundsArray?.count {
            return count
        }
        return 0
    }
    func resetCell(cell:CardListCell){
        cell.proImg.isHidden = true
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell =   collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CardListCell"), for: indexPath) as? CardListCell else {
            fatalError("The dequeued cell is not an instance of DetailCell.")
        }
        
        self.resetCell(cell: cell)
        if let bg = backgroundsArray?[indexPath.item]{
            
            cell.quoteImg.sd_setImage(with: URL.init(string:bg.previewURL),placeholderImage: NSImage(named: "postsBg0"), options: .highPriority, progress: nil, completed: { (image, error, type, url) in
            })
        }else{
            if let img = loadImageNamed(name: "postsBg" + String(indexPath.item)) {
                cell.quoteImg.image = img
            }
        }
        
        cell.quoteImg.imageScaling = .scaleAxesIndependently
        
        
        
        if indexPath.item >= 5  && !isProUser(){
            cell.proImg.isHidden = false
        }
        
        
        return cell
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

       // return NSSize(width:115, height:60)
        let width = (collectionView.frame.size.width / 2) - 5
        
        if editorType == .poster || editorType == .invitation || editorType == .flyer{
            return NSSize(width:width, height:width * 1.414)
        }
        
        return NSSize(width:width, height:width)
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {return}
        
        
        if indexPath.item >= 5 && !isProUser(){
            self.presentAsSheet(sheetViewController)
            return
        }
        
        
        if let bg = backgroundsArray?[indexPath.item].largeImageURL{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.BusinessCardSelected.rawValue), object: nil, userInfo: ["url":bg])
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.BusinessCardSelected.rawValue), object: nil, userInfo: ["index":indexPath.item])
        }
        
        
        
        
        collectionView.deselectItems(at: indexPaths)
    }
}
