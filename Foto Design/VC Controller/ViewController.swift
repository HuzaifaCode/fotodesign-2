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

    @IBOutlet weak var dashboardView: DashboardView!
    
   
    @IBOutlet weak var txtView: NSTextView!
    
    @IBOutlet weak var changeTxtView: NSView!
    
    @IBOutlet weak var templatestView: NSView!
    @IBOutlet weak var templatesCollectionView: NSCollectionView!
    @IBOutlet weak var templateHeadingLbl: NSTextField!
    
    
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
    
    
    var stickers: [StickerView] = []
    var currentSticer: StickerView? = nil {
        didSet {
            
            for sticker in stickers {
                sticker.isEditinMode = false
            }
            NSColorPanel.shared.orderOut(nil)
            if let sticker = currentSticer {
                sticker.isEditinMode = true
                if let textView = sticker.contentView as? StickerTextField {
//                    textVC?.sticker = currentSticer
//                    self.mainMenuState = .text
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue), object: self.currentSticer)
                    
                    self.currentEditOption = .text
                }else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue), object: self.currentSticer)
                    self.currentEditOption = .shape
//                    self.logoVC?.sticker = currentSticer
//                    self.mainMenuState = .logo
                }
//                opacitySlider.floatValue = Float(sticker.contentView.alphaValue)
//                btnOpacity.isHidden = false
//                btnDelete.isHidden = false
//                btnDuplicate.isHidden = false
//                opacitySlider.isHidden = false
//                btnDelete.alphaValue = 1
            }else {
               // btnOpacity.isHidden = true
               // btnDelete.isHidden = true
               // btnDuplicate.isHidden = true
//                opacitySlider.isHidden = true
//                opacitySliderWidth.constant = 0
//                self.mainMenuState = .bg
            }
           // self.layersTableView.reloadData()
        }
    }
    
    
    
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
            self.templatestView.isHidden = true
            if editorType == .poster {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Poster"])
                dashboardView.adjustSize(template: Constatnts.poster)
            }else if editorType == .flyer {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Flyer"])
                dashboardView.adjustSize(template: Constatnts.poster)
            }else if editorType == .invitation {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Inviation"])
                dashboardView.adjustSize(template: Constatnts.poster)
                    // setDesignViewSize(aspectRatio: (0.7072/1))
            }else if editorType == .logo {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Logo"])
                setDesignViewSize(aspectRatio: (1/1))
                dashboardView.adjustSize(template: Constatnts.logo)
                self.templateHeadingLbl.stringValue = "Logo Templates"
                self.templatestView.isHidden = false
                self.templatesCollectionView.reloadData()
            }else if editorType == .ytChannelArt {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Channel Art"])
                dashboardView.adjustSize(template: Constatnts.channelArt)
//                designViewHeightConstraint.constant = 350
//                setDesignViewSize(aspectRatio: (1.7777/1))
            }else if editorType == .fbCover {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Cover"])
                dashboardView.adjustSize(template: Constatnts.fbCover)
//                designViewHeightConstraint.constant = 200
//                setDesignViewSize(aspectRatio: (2.701/1))
            }else if editorType == .ytThumbnail {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "YT Thumbnail"])
                //designViewHeightConstraint.constant = 350
               // setDesignViewSize(aspectRatio: (1.7777/1))
                dashboardView.adjustSize(template: Constatnts.thumbnail)
                self.templateHeadingLbl.stringValue = "YT Video Thumbnails"
                self.templatestView.isHidden = false
                self.templatesCollectionView.reloadData()
                //loadLocalSvg()
            }else if editorType == .googleCover {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Google Cover"])
//                designViewHeightConstraint.constant = 360
//                setDesignViewSize(aspectRatio: (1.7714/1))
                dashboardView.adjustSize(template: Constatnts.googleCover)
            }else if editorType == .fbPost {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Post"])
                dashboardView.adjustSize(template: Constatnts.fbPost)
//                designViewHeightConstraint.constant = 450
//                setDesignViewSize(aspectRatio: (1.1928/1))
            }else if editorType == .instaPost {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Insta Post"])
                dashboardView.adjustSize(template: Constatnts.logo)
            }else if editorType == .pintrastGraphic {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "Pintrast"])
                dashboardView.adjustSize(template: Constatnts.pintrast)
//                designViewHeightConstraint.constant = 500
//                setDesignViewSize(aspectRatio: (0.6669/1))
            }else if editorType == .fbAd {
                FotoEventManager.shared.logEvent(name: .DesignType, parameters: ["Name" : "FB Add"])
//                designViewHeightConstraint.constant = 300
//                setDesignViewSize(aspectRatio: (1.9108/1))
                dashboardView.adjustSize(template: Constatnts.fbAd)
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
                    if let textView = zdSticker.contentView as? FotoContentView {
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
        
        //dashboardView.selectCardSide(.front)
        
        
        self.mainSelectionViiew = .layoutSelection
        currentEditOption = .shape
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
        
        
        if userDefaults.integer(forKey: APP_OPEN_COUNT) != 0 {
           let count =  userDefaults.integer(forKey: APP_OPEN_COUNT)
            //if count % 2 == 1 {
                showRatingPopUp()
            //}
            userDefaults.setValue(count + 1, forKey: APP_OPEN_COUNT)
        }else{
            userDefaults.setValue(1, forKey: APP_OPEN_COUNT)
        }
        
        
    }

    override func viewDidAppear() {
        
        setDesignViewSize()
        self.downImageFromFirebase()
       
        dashboardView.didSelect = {
            self.currentSticer = nil
            self.currentSelectedShape = nil
        }
        
    }
    
    @IBAction func createBtnClicked(_ sender: Any) {
        self.templatestView.isHidden = true
    }
    @IBAction func backToLayoutsClicked(_ sender: Any) {
        cardSelectionView.isHidden = false
        editingView.isHidden = true
        self.templatestView.isHidden = true
    }
    @IBAction func cancelBtnAction(_ sender: NSButton) {
        self.changeTxtView.isHidden = true
    }
    @IBAction func changeTxtBtnAction(_ sender: NSButton) {
        if let sticker = self.currentSticer {
            if let text = sticker.contentView as? StickerTextField {
                //if let txt = txtView.string {
                    text.text = txtView.string
                    self.currentSticer?.resizeToFontSize()
                //}
            }
            self.currentSticer = sticker
        }
        self.changeTxtView.isHidden = true
    }
    
    func loadLocalSvg() {
        
        if let path = Bundle.main.path(forResource: "thumb22", ofType:"svg") {
            // use path
            print(path)
            do {
                let data: Data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                let str = String(data: data, encoding: .utf8)
                print(str)
                if let frontSVG = str {
                    
                    //self.designView.isHidden = true
                    
                    
                    let svgView = SVGKView()
                    svgView.frame = dashboardView.logoView.bounds
                    view.addSubview(svgView)
                    svgView.isHidden = true
                    svgView.loadSVG(data: frontSVG.data(using: .utf8)!)
                //return
                   
                    if let bgImage = svgView.bgImage {
                        dashboardView.setFrontBGImage(image: bgImage)
                    }else if let bgColor = svgView.bgColor {
                        dashboardView.setLogoBGColor(color: bgColor)
                       // backgroundVC?.bgColor.color = bgColor
                    }
                    
                    
                    for layer in svgView.layers {
                        
                        if let textLayer = layer as? SVGTextLayer {
                            let y = self.dashboardView.logoView.frame.height - textLayer.frame.origin.y - textLayer.frame.height
                            let frame = CGRect(x: textLayer.frame.origin.x, y: y, width: textLayer.frame.width+5, height: textLayer.frame.height)
                            let text = StickerTextField(frame: frame)
                            let attributedString = textLayer.string as! NSAttributedString
                            var attributes = attributedString.attributes(at: 0, effectiveRange: nil)
                            
                            for attr in attributes {
                              print(attr.key, attr.value)
                                if let fontt = attr.value as? NSFont{
                                    print(fontt)
                                }
                            }

                            text.textAttributes = attributes

                            text.text = attributedString.string
                            let st = StickerView(contentView: text)
                            text.backgroundColor = .clear

                            if let color = attributes[NSAttributedString.Key.foregroundColor] {
                                text.foregroundColor = NSColor(cgColor: color as! CGColor)
                            }else {
                                text.foregroundColor = .black
                            }
                            if let font = attributes[NSAttributedString.Key.font] as? NSFont {
                                text.fontName = font.fontName
                                //text.letterSpacing = font.
                                if let letterSpacing = textLayer.value(forKey: "letter-spacing") as? String {
                                    let emValue = letterSpacing.replacingOccurrences(of: "em", with: "")
                                    text.letterSpacing = CGFloat((Double(emValue) ?? 0)) * font.pointSize
                                }
                            }
                            
                            st.delegate = self
                            self.addStickerView(sticker: st)
                            text.fitText()
                            st.resizeToFontSize()
                            
                        }else if let imageLayer = layer as? CALayerWithClipRender {
                            let y = self.dashboardView.logoView.frame.height - imageLayer.frame.origin.y - imageLayer.frame.height
                            let frame = CGRect(x: imageLayer.frame.origin.x, y: y, width: imageLayer.frame.width, height: imageLayer.frame.height)
                            let cgImage = layer.contents as! CGImage
                            let image = NSImage(cgImage: cgImage, size: imageLayer.bounds.size)
                            let imgView = ImageView(frame: frame)
                            imgView.image = image
                            imgView.imageScaling = .scaleProportionallyUpOrDown
                            let st = StickerView(contentView: imgView)
                            st.delegate = self
                            self.addStickerView(sticker: st)
                        }else if let shapLayer = layer as? CAShapeLayerWithHitTest {
                            
                            
                            let y = self.dashboardView.logoView.frame.height - shapLayer.frame.origin.y - shapLayer.frame.height
                            let frame = CGRect(x: shapLayer.frame.origin.x, y: y, width: shapLayer.frame.width, height: shapLayer.frame.height)
                            let imgView = ShapeView(frame: frame)
                            if let path = shapLayer.path {
                                let newShapeLayer = CAShapeLayer()
                                newShapeLayer.frame = path.boundingBox
                                newShapeLayer.path = path
                                
                                newShapeLayer.fillColor = shapLayer.fillColor
                                
                               
                                imgView.wantsLayer = true
                                imgView.layer = newShapeLayer
                            }
                            if let color = shapLayer.fillColor {
                                let st = StickerView(contentView: imgView)
                                st.delegate = self
                                self.addStickerView(sticker: st)
                            }
                            
                            
                        }else if let grLayer = layer as? SVGGradientLayer {
                            
                            
                            let y = self.dashboardView.logoView.frame.height - grLayer.frame.origin.y - grLayer.frame.height
                            let frame = CGRect(x: grLayer.frame.origin.x, y: y, width: grLayer.frame.width, height: grLayer.frame.height)
                            let imgView = GradientView(frame: frame)

                            imgView.wantsLayer = true
                            imgView.layer = grLayer
                            let st = StickerView(contentView: imgView)
                            st.delegate = self
                            self.addStickerView(sticker: st)
                            
                            
                        }
                    }
                }
                self.currentSticer = nil
            }catch {
                print(error.localizedDescription)
            }
        }
        
//
//        do {
//            let data = thumbnailsJson.data(using: .utf8)!
//            let model = try JSONDecoder().decode(ThumnailJson.self, from: data)
//
//            print(model)
//        }catch {
//
//            print("can't load settings.",error.localizedDescription)
//        }
    }
    
    func loadSvgFromData(data:Data) {
        let str = String(data: data, encoding: .utf8)
        print(str)
        if let frontSVG = str {
            
           // self.designView.isHidden = true
            
            
            let svgView = SVGKView()
            svgView.frame = dashboardView.logoView.bounds
            view.addSubview(svgView)
            svgView.isHidden = true
            svgView.loadSVG(data: frontSVG.data(using: .utf8)!)
        //return
           
            if let bgImage = svgView.bgImage {
                dashboardView.setFrontBGImage(image: bgImage)
            }else if let bgColor = svgView.bgColor {
                dashboardView.setLogoBGColor(color: bgColor)
               // backgroundVC?.bgColor.color = bgColor
            }
            
            
            for layer in svgView.layers {
                
                if let textLayer = layer as? SVGTextLayer {
                    let y = self.dashboardView.logoView.frame.height - textLayer.frame.origin.y - textLayer.frame.height
                    let frame = CGRect(x: textLayer.frame.origin.x, y: y, width: textLayer.frame.width+5, height: textLayer.frame.height)
                    let text = StickerTextField(frame: frame)
                    let attributedString = textLayer.string as! NSAttributedString
                    var attributes = attributedString.attributes(at: 0, effectiveRange: nil)
                    
                    for attr in attributes {
                      print(attr.key, attr.value)
                        if let fontt = attr.value as? NSFont{
                            print(fontt)
                        }
                    }

                    text.textAttributes = attributes

                    text.text = attributedString.string
                    let st = StickerView(contentView: text)
                    text.backgroundColor = .clear

                    if let color = attributes[NSAttributedString.Key.foregroundColor] {
                        text.foregroundColor = NSColor(cgColor: color as! CGColor)
                    }else {
                        text.foregroundColor = .black
                    }
                    if let font = attributes[NSAttributedString.Key.font] as? NSFont {
                        text.fontName = font.fontName
                        //text.letterSpacing = font.
                        if let letterSpacing = textLayer.value(forKey: "letter-spacing") as? String {
                            let emValue = letterSpacing.replacingOccurrences(of: "em", with: "")
                            text.letterSpacing = CGFloat((Double(emValue) ?? 0)) * font.pointSize
                        }
                    }
                    
                    st.delegate = self
                    self.addStickerView(sticker: st)
                    text.fitText()
                    st.resizeToFontSize()
                    
                }else if let imageLayer = layer as? CALayerWithClipRender {
                    let y = self.dashboardView.logoView.frame.height - imageLayer.frame.origin.y - imageLayer.frame.height
                    let frame = CGRect(x: imageLayer.frame.origin.x, y: y, width: imageLayer.frame.width, height: imageLayer.frame.height)
                    let cgImage = layer.contents as! CGImage
                    let image = NSImage(cgImage: cgImage, size: imageLayer.bounds.size)
                    let imgView = ImageView(frame: frame)
                    imgView.image = image
                    imgView.imageScaling = .scaleProportionallyUpOrDown
                    let st = StickerView(contentView: imgView)
                    st.delegate = self
                    self.addStickerView(sticker: st)
                }else if let shapLayer = layer as? CAShapeLayerWithHitTest {
                    
                    
                    let y = self.dashboardView.logoView.frame.height - shapLayer.frame.origin.y - shapLayer.frame.height
                    let frame = CGRect(x: shapLayer.frame.origin.x, y: y, width: shapLayer.frame.width, height: shapLayer.frame.height)
                    let imgView = ShapeView(frame: frame)
                    if let path = shapLayer.path {
                        let newShapeLayer = CAShapeLayer()
                        newShapeLayer.frame = path.boundingBox
                        newShapeLayer.path = path
                        
                        newShapeLayer.fillColor = shapLayer.fillColor
                        
                       
                        imgView.wantsLayer = true
                        imgView.layer = newShapeLayer
                    }
                    if let color = shapLayer.fillColor {
                        let st = StickerView(contentView: imgView)
                        st.delegate = self
                        self.addStickerView(sticker: st)
                    }
                    
                    
                }else if let grLayer = layer as? SVGGradientLayer {
                    
                    
                    let y = self.dashboardView.logoView.frame.height - grLayer.frame.origin.y - grLayer.frame.height
                    let frame = CGRect(x: grLayer.frame.origin.x, y: y, width: grLayer.frame.width, height: grLayer.frame.height)
                    let imgView = GradientView(frame: frame)

                    imgView.wantsLayer = true
                    imgView.layer = grLayer
                    let st = StickerView(contentView: imgView)
                    st.delegate = self
                    self.addStickerView(sticker: st)
                    
                    
                }
            }
        }
        self.currentSticer = nil
    }
    
    
    func showRatingPopUp(){
        if #available(OSX 10.14, *) {
            SKStoreReviewController.requestReview()
        }
    }
    func downSvgFromFirebase(name:String){
        
        let storage = Storage.storage()

        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Create a storage reference from our app
        // Create a reference to the file you want to download
        let islandRef = storageRef.child(name)


        self.showHudbuyProd(completion: { [weak self] res in
            
            guard let self = self else { return }
            
            islandRef.getData(maxSize: 1 * 2024 * 1024) { data, error in
              if let error = error {
                // Uh-oh, an error occurred!
              } else {
                if let dat = data{
                    self.hideHud()
                    self.templatestView.isHidden = true
                    self.loadSvgFromData(data: dat)
                }
              }
            }
            
        })
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        
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
                if let version = json?["version"] as? [String]{
                    if appVersion < version[0] {
                        self.updateView.isHidden = false
                    }
                }
            }catch{
                
            }
          }
        }
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        openApps { (_) in
        }
    }
    @IBAction func layoutBtnClicked(_ sender: Any) {
        cardSelectionView.isHidden = false
        editingView.isHidden = true
        
        for sticker in self.stickers {
            sticker.removeFromSuperview()
        }

        self.stickers.removeAll()
        self.dashboardView.logoBGView.image = nil
        
        
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
                editorType = .logo
            }else if button.tag == 1 {
                editorType = .flyer
            }else if button.tag == 2 {
                editorType = .invitation
            }else if button.tag == 3 {
                editorType = .poster
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
        self.designView.isHidden = true
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
                                let resizeImg = img?.resizeMaintainingAspectRatio(withSize: self.dashboardView.logoBGView.frame.size)
//                                self.bgImageView.imageScaling = .scaleNone
//
//                                    self.bgImageView.image = resizeImg
                                self.dashboardView.logoBGView.imageScaling = .scaleNone
                                self.dashboardView.setFrontBGImage(image: resizeImg!)
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
                    let fontName = (sticker.contentView as? FotoContentView)?.txtView.font?.fontName ?? ""
                    let style = (sticker.contentView as? FotoContentView)?.txtView.fontStyle ?? ""
                    let familyName = (sticker.contentView as? FotoContentView)?.txtView.familyName ?? ""
                    
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
        guard  let textView = sticker.contentView as? FotoContentView else {
            return
        }
        textView.txtView.textAlign = alignment
    }
    
    
    func updateFontSize(newFontSize:CGFloat?,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? FotoContentView else {
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
        guard  let textView = sticker.contentView as? FotoContentView else {
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
        guard  let textView = sticker.contentView as? FotoContentView else {
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
    @objc func shapeSelected(_ notification: Notification){
        if let userInfo = notification.userInfo{
            if let name = userInfo["index"] as? String{

                if let img = loadImageNamed(name: name) {
                        self.addNewIcon(icon: img)
                }
                
            }
        }
    }
    @objc func textChanged(_ notification: Notification){
        if let userInfo = notification.userInfo{
            if let txt = userInfo["text"] as? String{
                if let zdContentView = self.currentSelectedShape?.contentView as? FotoContentView{
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
            // self.designView.isHidden = false
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
            
            for sticker in self.stickers {
                sticker.removeFromSuperview()
            }
            self.stickers.removeAll()
            self.dashboardView.logoBGView.image = nil
            
        }
    }
//    func showZipSavePanel(_ path:String,completion: @escaping (Bool) -> Void) -> Void {
//
//            let savePanel = NSSavePanel()
//            savePanel.allowedFileTypes = ["zip"]
//            savePanel.nameFieldStringValue = "Business Card " + Date().string(format: "yyyy-MM-dd HH mm ss")
//            savePanel.beginSheetModal(for: self.view.window!) {[weak self](response) in
//                guard let self = self else {return}
//                if response == .OK{
//                    if let url = savePanel.url {
//                        do {
//                            let filePath = url.path
//                            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
//                            try data.write(to: URL.init(fileURLWithPath: filePath))
//                            self.isSavePanelOpen = false
//                            if #available(OSX 10.14, *) {
//                                SKStoreReviewController.requestReview()
//                            }
//                            completion(true)
//                        }catch {
//
//                        }
//                    }
//                    self.isSavePanelOpen = false
//                }else if response == .cancel {
//
//                    completion(true)
//                    self.isSavePanelOpen = false
//                }
//            }
//    }
    
    
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
        
//        let newStickerFrame = NSRect(x: 100, y: 100 , width: imageView.frame.width, height: imageView.frame.height)
//        let zdView = StickerManager.getZDSticker(frame: newStickerFrame)
//        zdView.contentView = imageView
//        zdView.stickerViewDelegate = self
//
//        addShapeSticker(sticker: zdView, atIndex: 0)
//        zdView.showEditingHandles()
    }
    func addShapeSticker(sticker:ZDStickerView,atIndex: Int? = nil) {
//        sticker.contentView.wantsLayer = true
//        sticker.contentView.layer?.masksToBounds = false
//        sticker.stickerViewDelegate = self
//       // self.designView.addSubview(sticker)
//        self.dashboardView.addSubview(sticker)
//        self.currentSelectedShape = sticker
//       
//        
//        if atIndex != nil {
//            self.stickerLayers.insert(sticker, at: atIndex!)
//        }else {
//            self.stickerLayers.insert(sticker, at: 0)
//        }
//        DispatchQueue.main.async {
//            //let transform = sticker.transform
//            //sticker.transform = transform
//        }
//       // self.changeUndoBtnStatus()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
//            
//            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.currentTextSelectionChanged.rawValue), object: self.currentSelectedShape?.contentView)
//        }
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
    
    func addNewIcon(icon: NSImage) {
        //self.hideHud()
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let imgView = ImageView(frame: frame)
        imgView.image = icon
        imgView.imageScaling = .scaleProportionallyUpOrDown
        let st = StickerView(contentView: imgView)
        st.delegate = self
        st.center = self.dashboardView.center
        self.addStickerView(sticker: st)
       
    }
    
    
    @objc func addText(_ notification:NSNotification) -> Void {
        
        let text = StickerTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        text.text = "Enter Text Here"
        let st = StickerView(contentView: text)
        text.fontName = "Arial Narrow"
        text.fontSize = 23.0
        text.fitText()
        text.backgroundColor = .clear
        text.foregroundColor = .black
        st.center = dashboardView.logoView.center
        st.delegate = self
        
        self.addStickerView(sticker: st)
        
        currentSticer = st
        
        
//
//        if let dView = notification.object as? FotoContentView {
//
//            let point = CGPoint.init(x: NSMidX(self.designView.frame)-100, y:200)
//            self.addNewTextView(dView, leftConst: -1*(point.x-100.0), bottomConst: point.y-50.0,textStr: dView.txtView.stringValue)
//            let sticker = StickerManager.getZDSticker(frame: dView.frame)
//            sticker.center = point
//
//            //dView.translatesAutoresizingMaskIntoConstraints = true
//            sticker.contentView = dView
//            self.addShapeSticker(sticker: sticker)
//        }
    }
    func  addNewTextView(_ dView:FotoContentView,leftConst:CGFloat,bottomConst:CGFloat,isLoadingFromModel:Bool = false,fontName:String = "American Typewriter",familyName:String  =  "American Typewriter",style:String  = "Regular",fontSize:CGFloat = 17, textStr:String =  "", textColor:NSColor = .black,isNeedToChangeZPosition: Bool = true,sendNotification:Bool = false,oldLayerIndex:Int? = nil) -> Void {
        
        
        
        
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
        self.currentSticer = nil
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
                   // self.importBgView.isHidden = true
                   // self.bgImageView.image = image
                    
                    self.dashboardView.logoBGView.imageScaling = .scaleNone
                    dashboardView.setFrontBGImage(image: image)
                    //self.orignalBgImage = image
                    //let img = self.orignalBgImage?.addNormalFilter(filter: filterTypes[0])
                   
                   // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.BgViewDidChanged.rawValue), object: self.backgroundImageView)
                }else{
                    self.addNewIcon(icon: image)
                }
            }
            
            
            
          }
      }
      else {
         
      }
    }
}
extension ViewController: NSTextFieldDelegate {
    
//    func controlTextDidChange(_ obj: Notification) {
//        //self.tableView.reloadData()
//    }
//
//    func controlTextDidBeginEditing(_ obj: Notification) {
////        if let sticker = self.currentSelectedShape, let txtField =  obj.object as? NSTextField {
////            //self.changeText(txtField.stringValue, sticker: sticker)
////        }
//    }
    func controlTextDidChange(_ obj: Notification) {
        
//        if let txtField =  obj.object as? NSTextField {
//            print(txtField.stringValue)
//           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextChanged.rawValue), object: nil, userInfo: ["text":txtField.stringValue])
//
//        }
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
//        if let txtField =  obj.object as? NSTextField {
//            print(txtField.stringValue)
//        }
    }
    func controlTextDidEndEditing(_ obj: Notification) {
//        if let txtField =  obj.object as? NSTextField {
//            print(txtField.stringValue)
//
//        }
    }
    

}
//extension ViewController: ZDStickerViewDelegate {
//
//    func stickerViewDidClose(_ sticker: ZDStickerView!) {
//        //isAlertModelOpend = true
//        var str = "Do you want to delete this Asset ?"
////        if(sticker.type() == .image) {
////            str = "Do you want to delete this Asset ?"
////        }
//        let isYes =  twoBtnAlert(question: str)
//       // isAlertModelOpend = false
//        if (isYes) {
//            self.removeShapeSticker(sticker: sticker)
//
//        }
//
//    }
//    func transformStickerView(_ sticker: ZDStickerView,_ transform: CGAffineTransform) {
//        //let oldTrans = sticker.transform
////        undoManagerLM.registerUndo(withTarget: self) { (targetSelf) in
////            targetSelf.transformStickerView(sticker,oldTrans)
////        }
//       // sticker.transform = transform
//       // self.changeUndoBtnStatus()
//    }
//    func resizeStickerView(_ sticker: ZDStickerView,_ frame: CGRect,dFrame : NSSize? = nil) {
////        let oldFrame = sticker.frame
////        let oldDFrame = self.designView.bounds.size
////        undoManagerLM.registerUndo(withTarget: self) { (targetSelf) in
////            targetSelf.resizeStickerView(sticker,oldFrame,dFrame: oldDFrame)
////        }
//        var nFrame = frame
//         if let savedSize = dFrame, dFrame != NSSize.zero{
//           let diffSize = CGSize(width: self.designView.frame.width/savedSize.width , height: self.designView.frame.height/savedSize.height)
//           let scale = diffSize.height
//           if (scale != 1) {
//             nFrame = frame.scale(by: scale)
//           }
//         }
//
//        sticker.resizeFrame(nFrame)
//
//        //self.changeUndoBtnStatus()
//    }
//
//
//    func stickerViewDidBeginResizing(_ sticker: ZDStickerView!) {
////        if let shape = sticker.contentView as? ShapeImageView {
////            shape.shouldScalePath = true
////        }
//        resizeStickerView(sticker,sticker.frame)
//    }
//    func stickerViewDidBeginEditing(_ sticker: ZDStickerView!) {
//
//        if self.currentSelectedShape != sticker {
//            self.currentSticer = nil
//            self.currentSelectedShape = sticker
//        }
//    }
//}


extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if editorType == .logo{
            return 15
        }
        return 14
    }
    
    func resetCell(cell:ListItem){
        cell.tempImg.image = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

            if let item = collectionView.makeItem(withIdentifier: ListItem.itemIdentifier, for: indexPath) as? ListItem {
                
                    resetCell(cell: item)
                    item.createLbl.isHidden = true
                    var thumb_Name = "yt_thumb"
                    if editorType == .logo{
                        thumb_Name = "logo_thumb"
                    }
                    if let path = Bundle.main.path(forResource: thumb_Name+String(indexPath.item), ofType:"png") {
                        
                        item.tempImg.image = NSImage.init(contentsOf: URL.init(fileURLWithPath: path))
                    }
                    return item
            }
        return NSCollectionViewItem()
        
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        collectionView.deselectItems(at: indexPaths)
       
        if let indexPath = indexPaths.first{
           

            if editorType == .logo {
                FotoEventManager.shared.logEvent(name: .Templates, parameters: ["Name" : "Logo"])
                self.downSvgFromFirebase(name: "logos/logo"+String(indexPath.item)+".svg")
            }else if editorType == .ytThumbnail{
                FotoEventManager.shared.logEvent(name: .Templates, parameters: ["Name" : "YT Thumbnail"])
                self.downSvgFromFirebase(name: "yt_thumbnails/thumb"+String(indexPath.item)+".svg")
            }

        }
    }
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

        
        var width = ((collectionView.frame.width) / 4 ) - 20
        
        if editorType == .logo{
            var width = ((collectionView.frame.width) / 4 ) - 20
            return CGSize(width: width, height: width)
        }
        
        return CGSize(width: width, height: width/1.7778)
        
        
    }
}
