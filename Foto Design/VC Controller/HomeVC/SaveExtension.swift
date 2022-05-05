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
       // self.designView.isHidden = false
        //let scale:CGFloat = self.editorType.rawValue
        

        //guard let logoData = self.dashboardView.frontPNG() else { return }
        
        
        guard let logoScaleData = self.dashboardView.designPNG(scale: editorType.rawValue) else { return }
        
//        if let logoData = self.dashboardView?.frontPNG() {
//            snapshot = NSImage.init(data: logoData)!
//        }
       
 
        
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let destinationPath = "file://" + documentsPath
//        if let destURL = NSURL.init(string: destinationPath) {
//            var type:NSBitmapImageRep.FileType = .jpeg
//            var extensionType = selectedExt
//            if selectedExt == "png"{
//                type = .png
//                extensionType = "png"
//            }
           // if let isSaved = snapshot?.saveImage(as: "tempImage", fileType: type, at: destURL as URL) {
               // if (isSaved){
                 //   let fileURLString = documentsPath+"/tempImage."+extensionType
                    showSavePanel(data: logoScaleData){[weak self](isSave) in
                        guard self != nil else {return}
                        if isSave{
                            completion(true)
                        }else{
                            completion(false)
                        }
                        
                    }
               // }
           // }
     //   }
        
//        self.zipImages(data: [snapshot!], completion: {(success) -> Void in
//            self.showZipSavePanel(success!.path, completion: {(save) -> Void in
//
//
//                completion(true)
//
//            })
//        })
    }
    func showSavePanel(data:Data,completion: @escaping (Bool) -> Void) -> Void {
        
        if(!self.isSavePanelOpen) {
            self.isSavePanelOpen = true
            let savePanel = NSSavePanel()
            //if isHighRes == true{
               savePanel.allowedFileTypes = [selectedExt]
//            }else{
//                savePanel.allowedFileTypes = ["pdf"]
//            }
            
            var fileName = "Social Post"
            if editorType == .logo {
                fileName = "Logo"
            }else if editorType == .invitation{
                fileName = "Invitation"
            }else if editorType == .poster{
                fileName = "Poster"
            }else if editorType == .flyer{
                fileName = "Flyer"
            }else if editorType == .ytThumbnail{
                fileName = "YT Thumbnail"
            }else if editorType == .ytChannelArt{
                fileName = "YT Channel Art"
            }else if editorType == .fbPost{
                fileName = "FB Post"
            }else if editorType == .fbAd{
                fileName = "FB Ad"
            }else if editorType == .fbCover{
                fileName = "FB Cover"
            }else if editorType == .pintrastGraphic{
                fileName = "Pintrast"
            }
            
            fileName = (fileName ?? "Social Post") + " " + Date().string(format: "yyyy-MM-dd HH mm ss")
            savePanel.nameFieldStringValue = fileName ?? "Social Post"
            savePanel.beginSheetModal(for: self.view.window!) {[weak self](response) in
                guard let self = self else {return}
                if response == .OK{
                    if let url = savePanel.url {
                        do {
                            let filePath = url.path
                            
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
}
