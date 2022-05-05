//
//  VCExtension.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//

import Foundation


extension ViewController {
    func showSavePopup(view: NSView){
        mainPopover?.close()
        self.currentSticer = nil
        let vc = SaveOptions.options()
        let width = Int(self.dashboardView.logoView.frame.size.width * 2)//* editorType.rawValue * 2)
        let height = Int(self.dashboardView.logoView.frame.size.height * 2)//* editorType.rawValue * 2)
        vc.sizeString = "\(width)x\(height) px"
        if editorType == .ytThumbnail {
            vc.sizeString = "1280x720 px"
        }
        
        vc.delegate = self
        mainPopover = showPopover(viewController: vc, viewForBounds: view)
    }
    func showPopover(viewController: NSViewController, viewForBounds: NSView) -> NSPopover
    {
        let popover = NSPopover()
        popover.contentViewController = viewController
        popover.contentSize = viewController.view.frame.size
        popover.behavior = .semitransient
        
        popover.show(relativeTo: viewForBounds.bounds, of: viewForBounds, preferredEdge: NSRectEdge.minX)
        return popover
    }
    
    func saveClicked(){
        
        if editorType == .poster {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Poster"])
        }else if editorType == .flyer {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Flyer"])
        }else if editorType == .invitation {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Inviation"])
        }else if editorType == .logo {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Logo"])
        }else if editorType == .ytChannelArt {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Channel Art"])
        }else if editorType == .fbCover {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "FB Cover"])
        }else if editorType == .ytThumbnail {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "YT Thumbnail"])
        }else if editorType == .googleCover {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Google Cover"])
        }else if editorType == .fbPost {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "FB Post"])
        }else if editorType == .instaPost {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Insta Post"])
        }else if editorType == .pintrastGraphic {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "Pintrast"])
        }else if editorType == .fbAd {
            FotoEventManager.shared.logEvent(name: .saveDesign, parameters: ["Name" : "FB Add"])
        }
        
        
        
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            self.showHudbuyProd(){[weak self](isSaved) in
                guard let self = self else {return}
                self.saveImage(withHightRes: true){[weak self](isSaved) in
                    guard let self = self else {return}
                    
                    if isSaved{
                        self.hideHud()
                    }else{
                        self.hideHud()
                    }
                }
            }
        }
    }
    
}
extension ViewController: SaveProtocol {
    func pngClicked() {
        self.mainPopover?.close()
        self.selectedExt = "png"
        saveClicked()
    }
    func pdfClicked() {
        self.mainPopover?.close()
        self.selectedExt = "pdf"
        //self.createPdf()
    }
    func jpgClicked() {
        self.mainPopover?.close()
        self.selectedExt = "jpg"
        saveClicked()
    }
}



extension ViewController{
    
    func addBorder(_ borderWidth:CGFloat,borderColor:NSColor,sticker: ZDStickerView) {
        guard  let textView = sticker.contentView as? FotoContentView else {
            return
        }
       
        textView.txtView.borderColor = borderColor
        textView.txtView.borderWidth = borderWidth
        if(borderWidth > 0.0) {
            textView.txtView.isBorder = true
        }else {
            textView.txtView.isBorder = false
        }
    }
    @objc func bgColorChanged(_ notification:Notification) -> Void {
        var angle = 0.0
        if let dict = notification.object as? [String:Any] {
            if let color = dict["color"] as? NSColor {
                self.dashboardView.setLogoBGColor(color: color)
            }
            if let lcolor = dict["leftColor"] as? NSColor, let rcolor = dict["rightColor"] as? NSColor{
                
                if let gangle = dict["angle"] as? Float{
                    angle = Double(gangle)
                }
                self.dashboardView.setLogoBgGradientColor(fromColor: lcolor, toColor: rcolor,angle: Float((angle ?? 0.0)))
            }
        }
    }
}


extension ViewController{
    
    
    func printBtnClicked(){
        self.currentSticer = nil
        var images = [NSImage]()
        let scale:CGFloat = 2.5
         let snapshot = self.dashboardView.logoView.snapshot()
        images.append(snapshot)

        if images.count > 0{
            if let printView = self.convertImagesToSingleView(images, spaceMargin: 50){
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else {return}
                    
                    self.showPrintDialog(printView: printView)
                }
            }
        }
    }
    
    func convertImagesToSingleView( _ images: [NSImage],
                                        spaceMargin: CGFloat = .zero,
                                        useFlippedView: Bool = true) -> NSView?{
            
            var singleView: NSView?
           
            var imageViewsList: [NSImageView] = []
            var totalHeight: CGFloat = .zero
            var lastImgY: CGFloat = .zero
            var isFirstImage: Bool = true
            for img in images{
                
                var imgViewOrigin : CGPoint = .zero
                if #available(OSX 10.12, *) {
                    let imgView : NSImageView = .init(image: img)
                    imgView.frame = .init(origin: imgViewOrigin,
                                          size: img.size)
                    if !isFirstImage{
                        imgViewOrigin.y = lastImgY + spaceMargin
                        imgView.frame.origin = imgViewOrigin
                        totalHeight += spaceMargin
                    }
                    imageViewsList.append(imgView)
                    lastImgY = imgView.frame.maxY
                    isFirstImage = false
                    totalHeight += imgView.bounds.height
                } else {
                    // Fallback on earlier versions
                }
                
                
            }
            
            if let firstImgViewWidth = imageViewsList.first?.bounds.width{
                let printViewSize: NSSize = .init( width: firstImgViewWidth,
                                                   height: totalHeight)
                
                if (useFlippedView){
                    singleView = CustomFlippedView()
                }
                
                let singleViewFrame: NSRect = .init( origin: .zero,
                                                     size: printViewSize)
                singleView?.frame = singleViewFrame
                for imgView in imageViewsList{
                    singleView?.addSubview(imgView)
                }
            }
            return singleView
        }
    
    func showPrintDialog(printView: NSView){
            
            var paperSize : CGSize = printView.frame.size
            var verticalPaginationMode : NSPrintInfo.PaginationMode = .fit
            
//            switch templateType {
//            case .BusinessCards:
                if let singleSideSize = printView.subviews.first?.bounds.size{
                    paperSize = .init(width: singleSideSize.width, height: singleSideSize.height + 150)
                    verticalPaginationMode = .automatic
                }
//            default:
//                paperSize = printView.frame.size
//            }
            
            let printInfo = NSPrintInfo.shared
            printInfo.isHorizontallyCentered = true
            printInfo.isVerticallyCentered = true
            printInfo.horizontalPagination = .fit
            printInfo.verticalPagination = verticalPaginationMode
            printInfo.paperSize = paperSize
            
            let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
            printOperation.showsPrintPanel = true
            printOperation.printPanel.options.insert(.showsScaling)
            printOperation.printPanel.options.insert(.showsPaperSize)
            
            if let mainWindow = NSApp.mainWindow{
                let selector = #selector( self.printOperationDidRun(
                    printOperation:
                    success:
                    contextInfo:))
                printOperation.runModal( for: mainWindow,
                                         delegate: self,
                                         didRun: selector,
                                         contextInfo: nil)
            }
        }
    @objc func printOperationDidRun( printOperation: NSPrintOperation,
                                        success: Bool,
                                        contextInfo: UnsafeMutableRawPointer?){
            self.hideHud()
       }
}
