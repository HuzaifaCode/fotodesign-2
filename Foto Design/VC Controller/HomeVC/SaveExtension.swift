//
//  SaveExtension.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//



import Foundation
import StoreKit
import Zip
import PDFKit


extension ViewController{
    func saveImage(withHightRes: Bool,completion: @escaping (Bool) -> Void) {
        
       // printBtnClicked()
        self.designView.isHidden = false
        let scale:CGFloat = self.editorType.rawValue //withHightRes == true ? 3 : 2
        let snapshot = self.takeScreenShot(true, scale: scale)
 
        //let resieImg = snapshot?.resizeImage(image: <#T##NSImage#>, w: <#T##Int#>, h: <#T##Int#>)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let destinationPath = "file://" + documentsPath
        if let destURL = NSURL.init(string: destinationPath) {
            var type:NSBitmapImageRep.FileType = .jpeg
            var extensionType = "jpg"
            if withHightRes{
                type = .png
                extensionType = "png"
            }
            if let isSaved = snapshot?.saveImage(as: "tempImage", fileType: type, at: destURL as URL) {
                if (isSaved){
                    let fileURLString = documentsPath+"/tempImage."+extensionType
                    showSavePanel(fileURLString,withHightRes){[weak self](isSave) in
                        guard self != nil else {return}
                        if isSave{
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    }
                }
            }
        }
        
//        self.zipImages(data: [snapshot!], completion: {(success) -> Void in
//            self.showZipSavePanel(success!.path, completion: {(save) -> Void in
//
//
//                completion(true)
//
//            })
//        })
    }
    func showSavePanel(_ path:String,_ isHighRes:Bool = false,completion: @escaping (Bool) -> Void) -> Void {
        
        if(!self.isSavePanelOpen) {
            self.isSavePanelOpen = true
            let savePanel = NSSavePanel()
            if isHighRes == true{
               savePanel.allowedFileTypes = ["png"]
            }else{
                savePanel.allowedFileTypes = ["pdf"]
            }
            
            var fileName = "Social Post"
            fileName = (fileName ?? "Social Post") + " " + Date().string(format: "yyyy-MM-dd HH mm ss")
            savePanel.nameFieldStringValue = fileName ?? "Social Post"
            savePanel.beginSheetModal(for: self.view.window!) {[weak self](response) in
                guard let self = self else {return}
                if response == .OK{
                    if let url = savePanel.url {
                        do {
                            let filePath = url.path
                            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
                            try data.write(to: URL.init(fileURLWithPath: filePath))
                            completion(true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                                guard let self = self else{return}
                                if #available(OSX 10.14, *) {
                                    SKStoreReviewController.requestReview()
                                } else {
                                    //self.rateUS()
                                }

                                
                                self.isSavePanelOpen = false
                                
                            })
                        }catch {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {[weak self] in
                                guard let self = self else {return}
                                self.hideHud()
                                self.isSavePanelOpen = false
                                _ = twoBtnAlert(question: "Sorry for the inconvenience", text: "There was a problem while saving your Document.")
                            })
                        }
                    }
                    
                }else {
                    
                    self.isSavePanelOpen = false
                    completion(false)
                }
            }
        }
    }
    
    func takeScreenShot(_ isLargeQuality:Bool = true,scale:CGFloat = 8, forceWatermarkRemoval: Bool = false) -> NSImage? {
        self.designView.isHidden = false
        self.currentSelectedShape = nil
        let oldFrame = self.designView.frame
        //self.btnCrossWatermark.isHidden = true
//        if forceWatermarkRemoval{
//            self.atermarkImgView.isHidden = true
//        }else{
//            if !Utility.isProductPro(){
//                if let tempView = self.atermarkImgView{
//                    self.atermarkImgView.removeFromSuperview()
//                    self.atermarkImgView.layer?.zPosition = 999
//                    self.atermarkImgView.isHidden = false
//                    self.designView.addSubview(tempView)
//                }
//            }
//        }
        self.designView.layoutSubtreeIfNeeded()
        let myView = self.designView
        //var hiddenViews:[NSView] = [NSView]()
//        for sticker in self.layers {
//            if let textView = (sticker as? CAStickerView)?.contentView as? LogoTextView {
//                if(textView.stringValue == "" && !sticker.isHidden) {
//                    sticker.isHidden = true
//                    hiddenViews.append(sticker)
//                }
//            }
//        }
        
        if(isLargeQuality) {
            self.designViewHeightConstraint.constant = self.designViewHeightConstraint.constant * scale
            
            self.designView.layoutSubtreeIfNeeded()
            bgImageView.layer?.sublayers?[0].frame.size.height = designView.frame.height
            bgImageView.layer?.sublayers?[0].frame.size.width = designView.frame.width
            for subView in self.designView.subviews {
                if(subView is ZDStickerView) {
                    if let stickerView = subView as? ZDStickerView {
                        let transfrom = stickerView.transform
                        stickerView.frame = stickerView.frame.scale(by: scale)
                       // stickerView.contentView.frame =  stickerView.contentView.frame.scale(by: scale)
                        stickerView.transform = transfrom
                        if let sView = (stickerView.contentView as? ZdContentView)?.txtView {
                            
                            sView.oldFontSize = sView.font!.pointSize
                            let font = NSFont.init(name: sView.fontName, size: sView.font!.pointSize * scale )
                            sView.font = font
                            let alignment = sView.textAlign
                            sView.textAlign = alignment
                            
                            if(sView.shadowOffset.width > 0.0 || sView.shadowOffset.height > 0.0) {
                                sView.shadowOffset.width = sView.shadowOffset.width*scale
                                sView.shadowOffset.height = sView.shadowOffset.height*(-scale)
                                sView.shadowRadius = sView.shadowRadius*scale
                                sView.isShadow = true
                            }
                        }
//                        if let sView = stickerView.contentView as? ShapeImageView {
//                            if let shadowOffset =  sView.shadowOffset {
//                                sView.shadowOffset?.width = shadowOffset.width * scale
//                                sView.shadowOffset?.height = shadowOffset.height * scale
//                            }
//                            if let lineDashPattern =  sView.lineDashPattern {
//                                sView.lineDashPattern = [
//                                    NSNumber(value: Float( CGFloat(truncating: lineDashPattern[0]) * scale)),
//                                    NSNumber(value: Float( CGFloat(truncating: lineDashPattern[1]) * scale))
//                                ]
//                            }
//                            if let strokeWidth =  sView.strokeWidth {
//                                sView.strokeWidth =  strokeWidth * scale
//                            }
//                            sView.updateShape()
//                        }
                        
                        let stickerTransform = stickerView.transform
                        stickerView.transform = stickerTransform
                    }
                }
//                else if subView.tag == 345 {
//                    for const in subView.constraints {
//                        const.constant = const.constant * scale
//                    }
//                    self.waterMarkRightConstraint.constant = self.waterMarkRightConstraint.constant * scale
//                    self.waterMarkBottomConstraint.constant = self.waterMarkBottomConstraint.constant * scale
//                    myView?.addSubview(subView)
//                    myView?.layer?.zPosition = 999
//
//                }else {
//                }
            }
        }
        if let mView = myView {
            if bgImageView.image?.name() == "BackGrounds0"{
                //bgImageView.imageName = "BackGrounds0"
                bgImageView.image = nil
                mView.layer?.backgroundColor = .clear
                bgImageView.layer?.backgroundColor = .clear
            }
            let snapshot = mView.snapshot()
            if(isLargeQuality) {
                self.designView.frame = oldFrame
                self.designViewHeightConstraint.constant = self.designViewHeightConstraint.constant / scale
                self.designView.layoutSubtreeIfNeeded()
                for subView in self.designView.subviews {
//                    if(subView is BgImageView) {
//                        let width = designView.frame.width//subView.frame.width/scale
//                        let height = designView.frame.height//subView.frame.height/scale
//                        if let sView = subView as? BgImageView {
//                            if(sView.imageType == .gradient) {
//                                if let subLayers = sView.layer?.sublayers {
//                                    for subLayer in subLayers {
//                                        subLayer.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
//                                    }
//                                }
//                            }
//                        }
//                    }else
                    if(subView is ZDStickerView) {
                        if let stickerView = subView as? ZDStickerView {
                            let transfrom = stickerView.transform
                            stickerView.frame = stickerView.frame.scaleDown(by: scale)
                           // stickerView.contentView.frame = stickerView.contentView.frame.scaleDown(by: scale)
                            stickerView.transform = transfrom
                            if let sView = (stickerView.contentView as? ZdContentView)?.txtView {
                                if let font = NSFont.init(name: sView.fontName, size: sView.oldFontSize) {
                                    sView.font = font
                                    let alignment = sView.textAlign
                                    sView.textAlign = alignment
                                }
                                
                                if(sView.shadowOffset.width > 0.0 || sView.shadowOffset.height > 0.0) {
                                    sView.shadowOffset.width = sView.shadowOffset.width/scale
                                    sView.shadowOffset.height = sView.shadowOffset.height/(-scale)
                                    sView.shadowRadius = sView.shadowRadius/scale
                                    sView.isShadow = true
                                }
                            }
//                            if let sView = stickerView.contentView as? ShapeImageView {
//
//                                if let shadowOffset =  sView.shadowOffset {
//                                    sView.shadowOffset?.width = shadowOffset.width / scale
//                                    sView.shadowOffset?.height = shadowOffset.height / scale
//                                }
//                                if let lineDashPattern =  sView.lineDashPattern {
//                                    sView.lineDashPattern = [
//                                        NSNumber(value: Float( CGFloat(truncating: lineDashPattern[0]) / scale)),
//                                        NSNumber(value: Float( CGFloat(truncating: lineDashPattern[1]) / scale))
//                                    ]
//                                }
//                                if let strokeWidth =  sView.strokeWidth {
//                                    sView.strokeWidth =  strokeWidth / scale
//                                }
//                                sView.updateShape()
//                            }
                            
                            let stickerTransform = stickerView.transform
                            stickerView.transform = stickerTransform
                            
                        }
                        
                    }
//                    else if subView.tag == 345 {
//                        for const in subView.constraints {
//                            const.constant = const.constant / scale
//                        }
//                        self.waterMarkRightConstraint.constant = self.waterMarkRightConstraint.constant / scale
//                        self.waterMarkBottomConstraint.constant = self.waterMarkBottomConstraint.constant / scale
//                        myView?.addSubview(subView)
//                        myView?.layer?.zPosition = 999
//                    }else {
//
//                    }
                }
            }
//            self.btnCrossWatermark.layer?.zPosition = 999
//            for hidenView in hiddenViews {
//                hidenView.isHidden = false
//            }
//
            
//            self.circularProgressIndicator.wantsLayer = true
//            self.circularProgressIndicator.layer?.zPosition = 999
//            self.overlayImageView.layer?.zPosition = (self.backgroundImageView.layer?.zPosition ?? 0) + 1
//            self.atermarkImgView.isHidden = true
//            if self.backgroundImageView.imageName == "BackGrounds0"{
//                self.backgroundImageView.image =  #imageLiteral(resourceName: "BackGrounds0")
//            }
            return snapshot
        }
        return nil
    }
    
//    func takeScreenShot(_ isLargeQuality:Bool = true,scale:CGFloat = 8, forceWatermarkRemoval: Bool = false) -> NSImage? {
//       // self.designView.isHidden = false
//        self.currentSelectedShape = nil
//        let oldFrame = self.designView.frame
//        self.designView.layoutSubtreeIfNeeded()
//        let myView = self.designView
//
//        var hiddenViews:[NSView] = [NSView]()
//        for sticker in self.stickerLayers {
//            if let textView = (sticker as? ZDStickerView)?.contentView as? ZdContentView {
//                if(textView.txtView.stringValue == "" && !sticker.isHidden) {
//                    sticker.isHidden = true
//                    hiddenViews.append(sticker)
//                }
//            }
//        }
//
////        if(isLargeQuality) {
////            self.designView.frame = CGRect(origin: oldFrame.origin, size: CGSize(width: 1242, height: 2688))// oldFrame.scale(by: scale)
////
////            self.designView.layoutSubtreeIfNeeded()
////            bgImageView.layer?.sublayers?[0].frame.size.height = designView.frame.height
////            bgImageView.layer?.sublayers?[0].frame.size.width = designView.frame.width
////
////
////            for subView in self.designView.subviews {
////
////                if(subView is ZDStickerView) {
////
////                    if let stickerView = subView as? ZDStickerView {
////                        if let sView = stickerView.contentView as? ZdContentView {
////                            sView.txtView.textAlign = sView.txtView.textAlign
////                        }
////                        let stickerTransform = stickerView.transform
////                        stickerView.transform = stickerTransform
////                    }
////                }
////            }
////        }
//
//        if(isLargeQuality) {
//            self.designViewHeightConstraint.constant = self.designViewHeightConstraint.constant * scale
//
//            self.designView.layoutSubtreeIfNeeded()
//            bgImageView.layer?.sublayers?[0].frame.size.height = designView.frame.height
//            bgImageView.layer?.sublayers?[0].frame.size.width = designView.frame.width
//            for subView in self.designView.subviews {
//               // if(subView is CAStickerView) {
//                    if let stickerView = subView as? ZDStickerView {
//                        let transfrom = stickerView.transform
//                        stickerView.frame = stickerView.frame.scale(by: scale)
//                        stickerView.contentView.frame =  stickerView.contentView.frame.scale(by: scale)
//                        stickerView.transform = transfrom
//                        if let sView = stickerView.contentView as? ZDTextView {
//
//                            sView.oldFontSize = sView.font!.pointSize
//                            let font = NSFont.init(name: sView.fontName, size: sView.font!.pointSize * scale )
//                            sView.font = font
//                            let alignment = sView.textAlign
//                            sView.textAlign = alignment
//
//                            if(sView.shadowOffset.width > 0.0 || sView.shadowOffset.height > 0.0) {
//                                sView.shadowOffset.width = sView.shadowOffset.width*scale
//                                sView.shadowOffset.height = sView.shadowOffset.height*(-scale)
//                                sView.shadowRadius = sView.shadowRadius*scale
//                                sView.isShadow = true
//                            }
//                        }
////                        if let sView = stickerView.contentView as? ShapeImageView {
////                            if let shadowOffset =  sView.shadowOffset {
////                                sView.shadowOffset?.width = shadowOffset.width * scale
////                                sView.shadowOffset?.height = shadowOffset.height * scale
////                            }
////                            if let lineDashPattern =  sView.lineDashPattern {
////                                sView.lineDashPattern = [
////                                    NSNumber(value: Float( CGFloat(truncating: lineDashPattern[0]) * scale)),
////                                    NSNumber(value: Float( CGFloat(truncating: lineDashPattern[1]) * scale))
////                                ]
////                            }
////                            if let strokeWidth =  sView.strokeWidth {
////                                sView.strokeWidth =  strokeWidth * scale
////                            }
////                            sView.updateShape()
////                        }
////
//                        let stickerTransform = stickerView.transform
//                        stickerView.transform = stickerTransform
//                    }
////                }else if subView.tag == 345 {
////                    for const in subView.constraints {
////                        const.constant = const.constant * scale
////                    }
////                    self.waterMarkRightConstraint.constant = self.waterMarkRightConstraint.constant * scale
////                    self.waterMarkBottomConstraint.constant = self.waterMarkBottomConstraint.constant * scale
////                    myView?.addSubview(subView)
////                    myView?.layer?.zPosition = 999
////
////                }else {
////                }
//            }
//        }
//
//
//
//       // myView?.frame = CGRect(origin: oldFrame.origin, size: CGSize(width: 1242, height: 2688))//oldFrame.scale(by: scale)
//
//       // myView?.layoutSubtreeIfNeeded()
//        if let mView = myView {
//            let snapshot = mView.snapshot()
//            if(isLargeQuality) {
//                self.designView.frame = oldFrame
//                self.designViewHeightConstraint.constant = self.designViewHeightConstraint.constant / scale
//                self.designView.layoutSubtreeIfNeeded()
//                for subView in self.designView.subviews {
//                    if(subView is ZDStickerView) {
//                        if let stickerView = subView as? ZDStickerView {
//
//                            if let sView = stickerView.contentView as? ZdContentView {
//
//                                sView.txtView.textAlign = sView.txtView.textAlign
//
//                            }
//                            let stickerTransform = stickerView.transform
//                            stickerView.transform = stickerTransform
//
//                        }
//
//                    }else if subView.tag == 345 {
//                        for const in subView.constraints {
//                            const.constant = const.constant / scale
//                        }
//                        myView?.addSubview(subView)
//                        myView?.layer?.zPosition = 999
//                    }else {
//
//                    }
//                }
//            }
//            for hidenView in hiddenViews {
//                hidenView.isHidden = false
//            }
//            return snapshot
//        }
//        return nil
//    }
    func createTempDirectory() -> URL? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dir = documentDirectory.appendingPathComponent("temp-dir-\(UUID().uuidString)")
            do {
                try FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
            return dir
        } else {
            return nil
        }
    }
    func zipImages(data: [NSImage], completion: @escaping ((URL?) -> ())) {
        DispatchQueue.main.async {
            if let directory = self.saveImages(data: data) {
                do {
                    let zipFilePath = try Zip.quickZipFiles([directory], fileName: "archive-\(UUID().uuidString)")
                    completion(zipFilePath)
                } catch {
                    completion(nil)
                }
            }

            
        }
    }
    func saveImages(data: [NSImage]) -> URL? {

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let destinationPath = "file://" + documentsPath

        guard let directory = createTempDirectory() else { return nil }

        do {
            for (i, imageData) in data.enumerated() {
                let data = imageData.png
                let ext = selectedExt
                let imageName = (i == 0) ? "Front" : "Back"
                try data?.write(to: directory.appendingPathComponent("\(imageName).\(ext)"))
            }
            return directory
        } catch {
            return nil
        }
    }
    func createPdf(){
        
        var images = [NSImage]()
        let scale:CGFloat = 1.588
        if let snapshot = self.takeScreenShot(true, scale: scale){
            images.append(snapshot)
        }
        if images.count > 1{
            
        }
        
    }
}
