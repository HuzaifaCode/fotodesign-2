//
//  ViewController.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 13/07/2021.
//



import Cocoa
import StoreKit
import SDWebImage
import FirebaseStorage
import Firebase

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class ViewController: NSViewController {

    @IBOutlet weak var importBgView: NSView!
    @IBOutlet weak var TextView: NSView!
    @IBOutlet weak var bgImageView: NSImageView!

    @IBOutlet weak var socialView: NSView!
    @IBOutlet weak var fbImageView: NSImageView!
    @IBOutlet weak var instaImageView: NSImageView!
    
    
    @IBOutlet weak var cardslistView: NSView!
    @IBOutlet weak var shapeslistView: NSView!
    @IBOutlet weak var hudView: NSView!
    
    @IBOutlet weak var designView: DesignView!
    @IBOutlet weak var importBgBtn: NSButton!
    @IBOutlet weak var shapesBtn: NSButton!
    @IBOutlet weak var backgroundBtn: NSButton!
    @IBOutlet weak var templatesBtn: NSButton!
    
    
    @IBOutlet weak var designViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var designViewAspectConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgViewWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var cardSelectionView: NSView!
    
    @IBOutlet weak var updateView: NSView!
    
    @IBOutlet weak var editingView: NSView!
    
    public var mainPopover: NSPopover?
    var selectedExt = "png"
    var hud:MBProgressHUD?
    var isSavePanelOpen:Bool = false
    var stickerLayers:[NSView] = [NSView]()
    
    var mainSelectionViiew:MainSelectionType = .none {
        didSet{
            
            self.editingView.isHidden = true
            self.cardSelectionView.isHidden = true
            if mainSelectionViiew == .layoutSelection {
                self.cardSelectionView.isHidden = false
            }else if mainSelectionViiew == .editing {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.DesignTypeSelected.rawValue), object: self.editorType)
                self.editingView.isHidden = false
            }
        }
    }
    var editorType:DesignViewType = .none {
        didSet{
            
            designViewHeightConstraint.constant = 500
            self.mainSelectionViiew = .editing
            if editorType == .poster {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Poster"])
                designViewHeightConstraint.constant = 500
                setDesignViewSize(aspectRatio: (0.7072/1))
            }else if editorType == .flyer {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Flyer"])
                setDesignViewSize(aspectRatio: (0.7072/1))
            }else if editorType == .invitation {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Inviation"])
                setDesignViewSize(aspectRatio: (0.7072/1))
            }else if editorType == .logo {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Logo"])
                setDesignViewSize(aspectRatio: (1/1))
            }else if editorType == .ytChannelArt {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Channel Art"])
                designViewHeightConstraint.constant = 350
                setDesignViewSize(aspectRatio: (1.7777/1))
            }else if editorType == .fbCover {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Cover"])
                designViewHeightConstraint.constant = 200
                setDesignViewSize(aspectRatio: (2.701/1))
            }else if editorType == .ytThumbnail {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "YT Thumbnail"])
                designViewHeightConstraint.constant = 350
                setDesignViewSize(aspectRatio: (1.7777/1))
            }else if editorType == .googleCover {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Google Cover"])
                designViewHeightConstraint.constant = 360
                setDesignViewSize(aspectRatio: (1.7714/1))
            }else if editorType == .fbPost {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Post"])
                designViewHeightConstraint.constant = 450
                setDesignViewSize(aspectRatio: (1.1928/1))
            }else if editorType == .instaPost {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Insta Post"])
                designViewHeightConstraint.constant = 500
                setDesignViewSize(aspectRatio: (1/1))
            }else if editorType == .pintrastGraphic {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Pintrast"])
                designViewHeightConstraint.constant = 500
                setDesignViewSize(aspectRatio: (0.6669/1))
            }else if editorType == .fbAd {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Add"])
                designViewHeightConstraint.constant = 300
                setDesignViewSize(aspectRatio: (1.9108/1))
            }
        }
    }
    var currentEditOption: EditOption = .importBg {
        didSet {
            
            self.hideViews()
            shapesBtn.bgColor = NSColor.init(hex: "ffffff")
            backgroundBtn.bgColor = NSColor.init(hex: "ffffff")
            templatesBtn.bgColor = NSColor.init(hex: "ffffff")
           // self.bgViewWidthConstraint.constant = 0
            if #available(OSX 10.14, *) {
                shapesBtn.contentTintColor = NSColor.init(hex: MAIN_COLOR)
                backgroundBtn.contentTintColor = NSColor.init(hex: MAIN_COLOR)
                templatesBtn.contentTintColor = NSColor.init(hex: MAIN_COLOR)
            }
            
            
            if currentEditOption == .shape {
                if #available(OSX 10.14, *) {
                    shapesBtn.contentTintColor = NSColor.init(hex: "ffffff")
                }
//                NSAnimationContext.runAnimationGroup { context in
//                    context.duration = 1
//                    self.cardslistView.animator().alphaValue = 0.3
//                } completionHandler: {
                    self.shapeslistView.isHidden = false
//                    self.cardslistView.alphaValue = 1
//                }
                //manageSideMenu()
               // isInvitaion = true
                setDesignViewSize()
                shapesBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
            }else if currentEditOption == .backgrounds {
                if #available(OSX 10.14, *) {
                    backgroundBtn.contentTintColor = NSColor.init(hex: "ffffff")
                }
                manageSideMenu()
               
                backgroundBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
                
                
            }else if currentEditOption == .text {
                if #available(OSX 10.14, *) {
                    templatesBtn.contentTintColor = NSColor.init(hex: "ffffff")
                }
                TextView.isHidden = false
                templatesBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
            }
        }
    }
    
   
    
    var currentSelectedShape:ZDStickerView? = nil {
        didSet {
            //removeAllHighlights()
            for sticker in stickerLayers {
                if let zdSticker = sticker as? ZDStickerView {
                    zdSticker.hideEditingHandles()
                    if let textView = zdSticker.contentView as? ZdContentView {
                        DispatchQueue.main.async {
                            textView.txtView?.resignFirstResponder()
                            textView.txtView?.window?.makeFirstResponder(nil)
                            let align =   textView.txtView.textAlign
                            textView.txtView.textAlign = align
                        }
                        zdSticker.translucencySticker = false
                    }
                }
            }
            NSColorPanel.shared.orderOut(nil)
            currentSelectedShape?.hideEditingHandles()
            //currentSelectedShape.translucencySticker = false
            if currentSelectedShape != nil {
                currentSelectedShape?.window?.makeFirstResponder(self.view.window?.contentView)
                currentSelectedShape?.showEditingHandles()
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.ImageStickerViewDidChanged.rawValue), object: nil, userInfo: ["isEnable":false])
                if currentSelectedShape?.type() == .text {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue), object: self.currentSelectedShape?.contentView)
                    
                    self.currentEditOption = .text
                    // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.currentTextSelectionChanged.rawValue), object: self.currentSelectedShape?.contentView)
                }else if currentSelectedShape?.type() == .image {
                    self.currentEditOption = .shape
                    // self.editOptions = .element
                    // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.ImageStickerViewDidChanged.rawValue), object: nil, userInfo: ["isEnable":true])
                }
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue), object: nil)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.editingView.isHidden = true
        self.updateView.isHidden = true
        
        FirebaseApp.configure()
        
        
        self.mainSelectionViiew = .layoutSelection
        currentEditOption = .backgrounds
        // Do any additional setup after loading the view.
       
        addObservers()
        hudView.isHidden = true
        
        UserDefaults.standard.setValue(true, forKey: IS_FREE_USERS)
        
     
        
        
       
        
        let fbTap = NSGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        //let instaTap = NSGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        socialView.addGestureRecognizer(fbTap)
        //instaImageView.addGestureRecognizer(instaTap)
        
        
        AppCenter.start(withAppSecret: "c50f3691-08ce-4c40-92ca-5d3d1e151fc4", services: [
            Analytics.self,
            Crashes.self
        ])
        
    }

    override func viewDidAppear() {
        
        setDesignViewSize()
        self.downImageFromFirebase()
    }
    
    func downImageFromFirebase(){
        
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a storage reference from our app
        // Create a reference to the file you want to download
        let islandRef = storageRef.child("fotoDesign.json")

        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }

        
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                if let version = json?["version"] as? String{
                    if appVersion <= version {
                        self.updateView.isHidden = false
                    }
                }
            }catch{
                
            }
          }
        }
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        
    }
    @IBAction func layoutBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = false
        editingView.isHidden = true
        
        self.stickerLayers.removeAll()
        self.bgImageView.image = nil
        self.currentEditOption = .backgrounds
        self.designView.bgColor = NSColor.clear
        for sticker in designView.subviews{
            if sticker is ZDStickerView{
                sticker.removeFromSuperview()
            }
        }
        bgImageView.image = nil
        for  sublayer in self.designView.layer!.sublayers! {
            if sublayer is CAGradientLayer{
                sublayer.removeFromSuperlayer()
            }
        }
        
        
    }
    @IBAction func socialPostClicked(_ sender: Any) {
        if let button = sender as? NSButton{
            if button.tag == 0 {
                editorType = .fbPost
                
            }else if button.tag == 1 {
                editorType = .instaPost
            }else if button.tag == 2 {
                editorType = .pintrastGraphic
            }else if button.tag == 3 {
                editorType = .fbAd
            }
        }
    }
    
    
    
    
    @IBAction func socialHeaderClicked(_ sender: Any) {
        if let button = sender as? NSButton{
            if button.tag == 0 {
                editorType = .ytChannelArt
            }else if button.tag == 1 {
                editorType = .fbCover
            }else if button.tag == 2 {
                editorType = .ytThumbnail
            }else if button.tag == 3 {
                editorType = .googleCover
            }
        }
    }
    @IBAction func marketingClicked(_ sender: Any) {
        if let button = sender as? NSButton{
            if button.tag == 0 {
                editorType = .poster
            }else if button.tag == 1 {
                editorType = .flyer
            }else if button.tag == 2 {
                editorType = .invitation
            }else if button.tag == 3 {
                editorType = .logo
            }else if button.tag == 4 {
                
            }
        }
    }
    @IBAction func fbBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = true
        editingView.isHidden = false
        setDesignViewSize()
    }
    @IBAction func instaBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = true
        editingView.isHidden = false
        setDesignViewSize()
    }
    @IBAction func invitaitonBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = true
        editingView.isHidden = false
        setDesignViewSize()
    }
    @IBAction func posterBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = true
        editingView.isHidden = false
        setDesignViewSize()
    }
    @objc func handleTap(_ sender: NSGestureRecognizer? = nil) {
        // handling code.
        cardSelectionView.isHidden = true
    }
    
    
    func setDesignViewSize(aspectRatio:CGFloat? = nil){
        if let ratio = aspectRatio {
            let multiplier:CGFloat = ratio//isInvitaion ? (0.7072/1) : (1/1)
            NSLayoutConstraint.setMultiplier(multiplier, of: &designViewAspectConstraint)
            view.layoutSubtreeIfNeeded()
        }else{
//            let multiplier:CGFloat = isInvitaion ? (0.7072/1) : (1/1)
//            NSLayoutConstraint.setMultiplier(multiplier, of: &designViewAspectConstraint)
//            view.layoutSubtreeIfNeeded()
        }
        
    }
    func addObservers(){
        let notificationCenter = NotificationCenter.default
        NotificationCenter.default.addObserver(self, selector: #selector(cardSelected), name: NSNotification.Name(rawValue: NotificationKey.BusinessCardSelected.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shapeSelected), name: NSNotification.Name(rawValue: NotificationKey.shapeSelected.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: NSNotification.Name(rawValue: NotificationKey.TextChanged.rawValue), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(addText(_:)),name: NSNotification.Name(rawValue: NotificationKey.AddText.rawValue),object: nil)
        notificationCenter.addObserver(self,selector: #selector(textBorderDidChanged(notification:)),name: NSNotification.Name(rawValue:NotificationKey.TextBorderDidChanged.rawValue),object: nil)
        notificationCenter.addObserver(self, selector: #selector(colorChanged(_:)), name: NSNotification.Name(rawValue: NotificationKey.ColorChanged.rawValue),object: nil)
        notificationCenter.addObserver(self, selector: #selector(stickerColorChanged(_:)), name: NSNotification.Name(rawValue: NotificationKey.StickerColorChanged.rawValue),object: nil)
        notificationCenter.addObserver(self,selector: #selector(opacityChanged(_:)),name: NSNotification.Name(rawValue: NotificationKey.OpacitySliderChanged.rawValue),object: nil)
        notificationCenter.addObserver(self,selector: #selector(stickerHeightChanged(_:)),name: NSNotification.Name(rawValue: NotificationKey.stickerHeightChanged.rawValue),object: nil)
        notificationCenter.addObserver(self,selector: #selector(stickerWidthChanged(_:)),name: NSNotification.Name(rawValue: NotificationKey.stickerWidthChanged.rawValue),object: nil)
        notificationCenter.addObserver(self, selector: #selector(fontChanged(_:)),name: NSNotification.Name(rawValue: NotificationKey.FontChanged.rawValue),object: nil)
        
        notificationCenter.addObserver(self,selector: #selector(alignmentChanged(_:)),name: NSNotification.Name(rawValue: NotificationKey.textAlignmentChanged.rawValue),
                                       object: nil)
        notificationCenter.addObserver(self,selector: #selector(importSticker(_:)),name: NSNotification.Name(rawValue: NotificationKey.importImageSticker.rawValue),
                                       object: nil)
        notificationCenter.addObserver(self,selector: #selector(importBackground(_:)),name: NSNotification.Name(rawValue: NotificationKey.importBackgroundSticker.rawValue),
                                       object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(bgColorChanged(_:)), name: NSNotification.Name(rawValue: NotificationKey.bgColorChanged.rawValue),object: nil)
        
        
        
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func manageSideMenu(){
        let initialValue = self.bgViewWidthConstraint.constant
        NSView.animate(duration: 1.55, delay: 0, timingFunction: CAMediaTimingFunction.easeIn, animations: {[weak self] in
            guard let self = self else {return}
            self.bgViewWidthConstraint.constant = initialValue == 330 ? 0 : 330
            self.cardslistView.isHidden = false
//            self.scrollviewSideMenu.isHidden = !self.scrollviewSideMenu.isHidden
//            self.tableView.isHidden = !self.tableView.isHidden
//            self.tableView2.reloadData()
//            self.tableView.reloadData()
            self.view.layoutSubtreeIfNeeded()
        }, completion: nil)
    }
    
    @objc func cardSelected(_ notification: Notification){
        if let userInfo = notification.userInfo{
            if let index = userInfo["index"] as? Int{
                if(self.designView.layer?.sublayers?.count ?? 0 > 0) {
                    for  sublayer in self.designView.layer!.sublayers! {
                        if sublayer is CAGradientLayer{
                            sublayer.removeFromSuperlayer()
                        }
                    }
                }
                
                bgImageView.bgColor = NSColor.clear
                designView.bgColor = NSColor.clear
                    if let img = loadImageNamed(name: "postsBg" + String(index)) {
                        
                        DispatchQueue.main.async {[weak self] in
                            guard let self = self else {return}
                            self.bgImageView.image = img
                           // self.bgImageView.imageScaling = .scaleNone
                           
                        }
                            
                    }
                
                
                importBgView.isHidden = true
            }
            if let bgUrl = userInfo["url"] as? String{
                self.showHudbuyProd(){[weak self](isSaved) in
                    guard let self = self else{ return }
                    ApiManager.downloadFile(url: bgUrl, completion: {[weak self](url,error) in
                      guard let self = self else {return}
                        if error != nil {
                            print("error")
                        }else{
                           //
                            let img = NSImage.init(contentsOfFile: (url?.path)!)
                            if img != nil {
                                self.hideHud()
                                let resizeImg = img?.resizeMaintainingAspectRatio(withSize: self.bgImageView.frame.size)
                                self.bgImageView.imageScaling = .scaleNone
                                
                                    self.bgImageView.image = resizeImg
                            }
                        }
                    }, progress: {[weak self](progress) in
                        guard let self = self else {return}
                        print(progress)
                    })
                }
            }
        }
    }
    @objc func alignmentChanged(_ notification:Notification) -> Void {
        if let sticker = self.currentSelectedShape , let alignment = notification.object as? NSTextAlignment {
            self.alignText(alignment, sticker: sticker)
        }
    }
    @objc func importSticker(_ notification:Notification) -> Void {
        self.openPanel()
    }
    @objc func importBackground(_ notification:Notification) -> Void {
        self.openPanel(isBg: true)
    }
    @objc func fontChanged(_ notification:Notification) -> Void {
        if let sticker = self.currentSelectedShape , let dict = notification.object as? [String:Any] {
            
            if let fontSize = dict["fontSize"] as? CGFloat {
                self.updateFontSize(newFontSize:fontSize,sticker: sticker)
            }
            
            if let fontName = dict["fontName"] as? String,
                let fontStyle = dict["fontStyle"] as? String{
                self.updateFontName(newFontName:fontName, style: fontStyle,sticker: sticker)
                //self.changeFont(fontName, newFontSize: CGFloat(fontSize),style:fontStyle,familyName:family,sticker: sticker)
            }else{
                if let size = dict["fontSize"] as? CGFloat{
                    let fontName = (sticker.contentView as? ZdContentView)?.txtView.font?.fontName ?? ""
                    let style = (sticker.contentView as? ZdContentView)?.txtView.fontStyle ?? ""
                    let familyName = (sticker.contentView as? ZdContentView)?.txtView.familyName ?? ""
                    
                    self.changeFont(fontName, newFontSize: CGFloat(size),style:style,familyName:familyName,sticker: sticker)
                    
                }
            }
        }
    }
    
    func applyColor(color:NSColor){
        if let sticker = currentSelectedShape{
            if sticker.type() == .image{
            if let imgView = (sticker.contentView as? DraggingImageView) {
                let img  = imgView.image
                let newImg = img?.tintedImageWithColor(color)
                (sticker.contentView as? DraggingImageView)?.image = newImg
            }
            }
        }
    }
    
    func alignText(_ alignment: NSTextAlignment,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? ZdContentView else {
            return
        }
        textView.txtView.textAlign = alignment
    }
    
    
    func updateFontSize(newFontSize:CGFloat?,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? ZdContentView else {
            return
        }
        if let fontSize = newFontSize{
            let font = NSFont.init(name: textView.txtView.fontName, size: fontSize)
            textView.txtView.font = font
            textView.txtView.textAlign = textView.txtView.textAlign
            textView.txtView.setNeedsDisplay()
        }
    }
    func updateFontName(newFontName:String?,style:String ,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? ZdContentView else {
            return
        }
        if let fontName = newFontName{
            let font = NSFont.init(name: fontName, size: (textView.txtView.font?.pointSize ?? 13))
            textView.txtView.font = font
            textView.txtView.fontName = fontName
            textView.txtView.fontStyle = style
            textView.txtView.textAlign = textView.txtView.textAlign
            textView.txtView.setNeedsDisplay()
        }
    }
    
    func changeFont(_ newFontName: String,newFontSize:CGFloat,style:String,familyName:String ,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? ZdContentView else {
            return
        }
        
        if let nFont = NSFont.init(name: newFontName, size: newFontSize) {
            textView.txtView.font = nFont
            textView.txtView.textAlign = textView.txtView.textAlign
            textView.txtView.fontName = newFontName
            textView.txtView.fontStyle = style
            textView.txtView.familyName = familyName
            textView.txtView.setNeedsDisplay()
        }
    }
    func addImageSticker(image:NSImage){
        let scale = image.size.width / image.size.height
        let imageView = DraggingImageView(frame: CGRect(x: 0, y: 0, width: 150*scale, height:150 ))
        imageView.image = image
        //imageView.imageName = "shape1"
        imageView.orignalImage = image
        self.addStickerToView(imageView: imageView)
    }
    @objc func shapeSelected(_ notification: Notification){
        if let userInfo = notification.userInfo{
            if let name = userInfo["index"] as? String{
                
                
               // if editorType == .logo {
                    if let img = loadImageNamed(name: name) {
                       // let scale = img.size.width / img.size.height
                        if let imgae = img.resizeMaintainingAspectRatio(withSize: NSSize(width: 500, height: 500)){
                            self.addImageSticker(image: imgae)
                        }
                        
                    }
//                }else{
//                    if let img = loadImageNamed(name: "social_icon" + String(index)) {
//                        let imgae = img.resizeImage()
//                        self.addImageSticker(image: imgae)
//
//                    }
//                }
                
            }
        }
    }
    @objc func textChanged(_ notification: Notification){
        if let userInfo = notification.userInfo{
            if let txt = userInfo["text"] as? String{
                if let zdContentView = self.currentSelectedShape?.contentView as? ZdContentView{
                    zdContentView.txtView.stringValue = txt
                }
            }
        }
    }
    @objc func textBorderDidChanged(notification:Notification) {
        
        if let sticker = self.currentSelectedShape , let dict = notification.object as? [String:Any] {
            if let width = dict["borderWidth"] as? CGFloat,
                let color = dict["borderColor"] as? NSColor {
                
                self.addBorder(width, borderColor: color, sticker: sticker)
            }
        }
        
    }
    
    
    func hideViews(){
        self.TextView.isHidden = true
        self.cardslistView.isHidden = true
        self.shapeslistView.isHidden = true
    }
    @IBAction func shapesBtnClicked(_ sender: Any) {
        currentEditOption = .shape
    }
    @IBAction func backgroundsBtnClicked(_ sender: Any) {
        
        currentEditOption = .backgrounds
    }
    @IBAction func addTextBtnClicked(_ sender: Any) {
        
        currentEditOption = .text
    }
    @IBAction func printBtnClicked(_ sender: Any) {
        self.showHudbuyProd(){[weak self](isSaved) in
            guard let self = self else {return}
            self.designView.isHidden = false
            self.printBtnClicked()
        }
    }
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        self.showSavePopup(view: sender as! NSButton)
    }
    @IBAction func resetBtnClicked(_ sender: Any) {
        
        
        var str = "Do you really want to reset?"
        
        let isYes =  twoBtnAlert(question: str)
        if (isYes) {
            
            self.stickerLayers.removeAll()
            self.bgImageView.image = nil
            self.currentEditOption = .backgrounds
            self.designView.bgColor = NSColor.clear
            for sticker in designView.subviews{
                if sticker is ZDStickerView{
                    sticker.removeFromSuperview()
                }
            }
            bgImageView.image = nil
            for  sublayer in self.designView.layer!.sublayers! {
                if sublayer is CAGradientLayer{
                    sublayer.removeFromSuperlayer()
                }
            }
            
        }
        
        
    }
    func showZipSavePanel(_ path:String,completion: @escaping (Bool) -> Void) -> Void {
        
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = ["zip"]
            savePanel.nameFieldStringValue = "Business Card " + Date().string(format: "yyyy-MM-dd HH mm ss")
            savePanel.beginSheetModal(for: self.view.window!) {[weak self](response) in
                guard let self = self else {return}
                if response == .OK{
                    if let url = savePanel.url {
                        do {
                            let filePath = url.path
                            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
                            try data.write(to: URL.init(fileURLWithPath: filePath))
                            self.isSavePanelOpen = false
                            if #available(OSX 10.14, *) {
                                SKStoreReviewController.requestReview()
                            }
                            completion(true)
                        }catch {

                        }
                    }
                    self.isSavePanelOpen = false
                }else if response == .cancel {

                    completion(true)
                    self.isSavePanelOpen = false
                }
            }
    }
    
    
    func showHudbuyProd(completion: @escaping (Bool) -> Void){
        hudView.isHidden = false
        hud = MBProgressHUD.showAdded(to: self.hudView, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {[weak self] in
            guard let self = self else {return}
            completion(true)
        }
        
    }
    func hideHud() -> Void {
        print("HUD REMOVED")
        hudView.isHidden = true
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            MBProgressHUD.hide(for: self.hudView, animated: true)
        }
    }
    func addStickerToView(imageView:NSImageView) -> Void {
        
        let newStickerFrame = NSRect(x: 100, y: 100 , width: imageView.frame.width, height: imageView.frame.height)
        let zdView = StickerManager.getZDSticker(frame: newStickerFrame)
        zdView.contentView = imageView
        zdView.stickerViewDelegate = self
        
        addShapeSticker(sticker: zdView, atIndex: 0)
        zdView.showEditingHandles()
    }
    func addShapeSticker(sticker:ZDStickerView,atIndex: Int? = nil) {
        sticker.contentView.wantsLayer = true
        sticker.contentView.layer?.masksToBounds = false
        sticker.stickerViewDelegate = self
        self.designView.addSubview(sticker)
        
        self.currentSelectedShape = sticker
       
        
        if atIndex != nil {
            self.stickerLayers.insert(sticker, at: atIndex!)
        }else {
            self.stickerLayers.insert(sticker, at: 0)
        }
        DispatchQueue.main.async {
            let transform = sticker.transform
            sticker.transform = transform
        }
       // self.changeUndoBtnStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.currentTextSelectionChanged.rawValue), object: self.currentSelectedShape?.contentView)
        }
    }
    func updateStikerLayers() {
        var index = 1
        for layer in stickerLayers {
            layer.wantsLayer = true
            layer.layer?.zPosition = CGFloat(999-index)
            index += 1
        }
       // self.tableView.reloadData()
        //self.backgroundImageView.layer?.zPosition = CGFloat(999-(layers.count+2))
        
        let isContain = self.stickerLayers.contains { (view) -> Bool in
            return (view as? ZDStickerView)?.type() == .image
        }
//        if isContain{
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.StatusStickerOpacityChanged.rawValue), object: nil, userInfo: ["status":true])
//        }else{
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.StatusStickerOpacityChanged.rawValue), object: nil, userInfo: ["status":false])
//        }
    }
    @objc func addText(_ notification:NSNotification) -> Void {
        
        if let dView = notification.object as? ZdContentView {
            
            let point = CGPoint.init(x: NSMidX(self.designView.frame)-100, y:200)
            self.addNewTextView(dView, leftConst: -1*(point.x-100.0), bottomConst: point.y-50.0,textStr: dView.txtView.stringValue)
            let sticker = StickerManager.getZDSticker(frame: dView.frame)
            sticker.center = point
            
            //dView.translatesAutoresizingMaskIntoConstraints = true
            sticker.contentView = dView
            self.addShapeSticker(sticker: sticker)
        }
    }
    func  addNewTextView(_ dView:ZdContentView,leftConst:CGFloat,bottomConst:CGFloat,isLoadingFromModel:Bool = false,fontName:String = "American Typewriter",familyName:String  =  "American Typewriter",style:String  = "Regular",fontSize:CGFloat = 17, textStr:String =  "", textColor:NSColor = .black,isNeedToChangeZPosition: Bool = true,sendNotification:Bool = false,oldLayerIndex:Int? = nil) -> Void {
        
        
        
        
        if(dView.txtView.id == nil) {
            dView.txtView.id = NSUUID().uuidString
        }
        dView.txtView.fontName = fontName
        dView.txtView.familyName = familyName
        dView.txtView.fontStyle = style
        dView.isSelected = true
        dView.wantsLayer = true
        dView.txtView.layer?.masksToBounds = false
        
            DispatchQueue.main.async {
                let nFont = NSFont.init(name: fontName, size: fontSize)
                NSFontManager.shared.setSelectedFont(nFont!, isMultiple: true)
                if(nFont != nil) {
                    dView.txtView.font = nFont!
                    
                }
            }
        
        dView.txtView.placeholderString = "Add text in Text Box"
        dView.txtView.placeholderTextColor = textColor
        dView.txtView.textColor = textColor
        dView.txtView.stringValue = textStr
        dView.txtView.delegate = self
    }
    func removeShapeSticker(sticker: ZDStickerView) {
        if let stickerIndex = self.stickerLayers.firstIndex(of: sticker) {
            self.stickerLayers.remove(at: stickerIndex)
            updateStikerLayers()
            sticker.removeFromSuperview()

            self.currentSelectedShape = nil

        }
    }
    override func mouseDown(with event: NSEvent) {
        self.currentSelectedShape = nil
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.currentTextSelectionChanged.rawValue), object: nil)
    }
    func openPanel(isBg:Bool? = false){
      
      if let url = NSOpenPanel().selectUrl {
          
          do{
            
            let image = NSImage(byReferencing:url)
            let name = NSUUID().uuidString
            let filePath = "\(ImportedStickerpath)/\(name)"
            let path = URL.init(fileURLWithPath: filePath)
            let basePath = ImportedStickerpath
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: basePath) {
                do {
                    try fileManager.createDirectory(at: URL.init(fileURLWithPath: basePath), withIntermediateDirectories: true, attributes: nil)
                }catch {
                    return
                }
            }
            
            if image.pngWrite(to: path){
                if isBg == true{
                    self.importBgView.isHidden = true
                    self.bgImageView.image = image
                    //self.orignalBgImage = image
                    //let img = self.orignalBgImage?.addNormalFilter(filter: filterTypes[0])
                   
                   // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.BgViewDidChanged.rawValue), object: self.backgroundImageView)
                }else{
                    self.addImageSticker(image: image)
                }
            }
            
            
            
          }
      }
      else {
         
      }
    }
}
extension ViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        //self.tableView.reloadData()
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
//        if let sticker = self.currentSelectedShape, let txtField =  obj.object as? NSTextField {
//            //self.changeText(txtField.stringValue, sticker: sticker)
//        }
    }

}
extension ViewController: ZDStickerViewDelegate {
    
    func stickerViewDidClose(_ sticker: ZDStickerView!) {
        //isAlertModelOpend = true
        var str = "Do you want to delete this text ?"
        if(sticker.type() == .image) {
            str = "Do you want to delete this Asset ?"
        }
        let isYes =  twoBtnAlert(question: str)
       // isAlertModelOpend = false
        if (isYes) {
            self.removeShapeSticker(sticker: sticker)
            
        }
        
    }
    func transformStickerView(_ sticker: ZDStickerView,_ transform: CGAffineTransform) {
        //let oldTrans = sticker.transform
//        undoManagerLM.registerUndo(withTarget: self) { (targetSelf) in
//            targetSelf.transformStickerView(sticker,oldTrans)
//        }
        sticker.transform = transform
       // self.changeUndoBtnStatus()
    }
    func resizeStickerView(_ sticker: ZDStickerView,_ frame: CGRect,dFrame : NSSize? = nil) {
//        let oldFrame = sticker.frame
//        let oldDFrame = self.designView.bounds.size
//        undoManagerLM.registerUndo(withTarget: self) { (targetSelf) in
//            targetSelf.resizeStickerView(sticker,oldFrame,dFrame: oldDFrame)
//        }
        var nFrame = frame
         if let savedSize = dFrame, dFrame != NSSize.zero{
           let diffSize = CGSize(width: self.designView.frame.width/savedSize.width , height: self.designView.frame.height/savedSize.height)
           let scale = diffSize.height
           if (scale != 1) {
             nFrame = frame.scale(by: scale)
           }
         }
        
        sticker.resizeFrame(nFrame)
        
        //self.changeUndoBtnStatus()
    }
    
    
    func stickerViewDidBeginResizing(_ sticker: ZDStickerView!) {
//        if let shape = sticker.contentView as? ShapeImageView {
//            shape.shouldScalePath = true
//        }
        resizeStickerView(sticker,sticker.frame)
    }
    func stickerViewDidBeginEditing(_ sticker: ZDStickerView!) {
        
        if self.currentSelectedShape != sticker {
            self.currentSelectedShape = sticker
        }
    }
}
