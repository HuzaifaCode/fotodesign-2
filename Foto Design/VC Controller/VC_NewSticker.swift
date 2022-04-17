//
//  VC_NewSticker.swift
//  Foto Design
//
//  Created by My Mac on 15/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//

import Foundation



extension ViewController {
 
    func addStickerView(sticker:StickerView) {
        dashboardView.logoView.addSubview(sticker)
        stickers.insert(sticker, at: 0)
    }
    
}
extension ViewController: StickerViewDelegate {
    func stickerViewDidSelect(_ stickerView: StickerView) {
        currentSelectedShape = nil
        self.currentSticer = stickerView
    }
    
    func stickerViewDidStartMoving(_ stickerView: StickerView) {
        currentSelectedShape = nil
        self.currentSticer = stickerView
    }
    
    func stickerViewISMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidEndMoving(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        //self.currentSticer = stickerView
    }
    
    func stickerViewDidBeginResize(_ stickerView: StickerView) {
        //self.currentSticer = stickerView
    }
    
    func stickerViewDidResize(_ stickerView: StickerView) {
        
        //textVC?.stickerDidResize()
    }
    
    func stickerViewDidEndResize(_ stickerView: StickerView) {
        
    }
    
    func stickerViewdidClose(_ stickerView: StickerView) {
        print("deleted")
        let str = "Do you want to delete this text ?"

        let isYes =  twoBtnAlert(question: str)
        if (isYes) {
            if let currentSticer = self.currentSticer {
                currentSticer.removeFromSuperview()
                if let index = self.stickers.firstIndex(of: currentSticer) {
                    self.stickers.remove(at: index)
                    self.currentSticer = nil
                }
            }
        }
    }
    
    func stickerViewTxtChnages(_ stickerView: StickerView) {
        print("txt Changes")
        if let st = stickerView.contentView as? NSTextField{
            self.txtView.string = st.stringValue
        }
        changeTxtView.isHidden = false
    }
    
}

