//
//  ZDStickerView-Extentions.swift
//  Quote Maker - Asif Nadeem
//
//  Created by Asif Nadeem on 06/08/2019.
//  Copyright © 2019 Asif Nadeem. All rights reserved.
//

import Foundation
import PocketSVG

extension ZDStickerView {
    
    
//    func moveDown(isFast: Bool) {
//        let centerPoint = self.center
//        self.setCenterLocation(CGPoint(x: centerPoint.x - 10, y: centerPoint.y))
//
//    }
    func moveTo(direction:Direction,isFast:Bool) {
        var increment:CGFloat = 1
        if isFast {
            increment = 20
        }
        let centerPoint = self.center
        var newCenter = CGPoint.zero
        switch direction {
        case .top:
            newCenter = CGPoint(x: centerPoint.x, y: centerPoint.y + increment)
        case .bottom:
            newCenter = CGPoint(x: centerPoint.x, y: centerPoint.y - increment)
        case .left:
            newCenter = CGPoint(x: centerPoint.x - increment, y: centerPoint.y)
        case .right:
            newCenter = CGPoint(x: centerPoint.x + increment, y: centerPoint.y)
        default:
            break
        }
        
        guard let superView = self.superview else {return}
        // Ensure the translation won't cause the view to move offscreen.
        var midPointX = self.bounds.midX
        if (newCenter.x > (superView.bounds.size.width - midPointX + self.bounds.size.width/2))
        {
            newCenter.x = (superView.bounds.size.width - midPointX + self.bounds.size.width/2)
        }
        
        if (newCenter.x < midPointX - self.bounds.size.width/2)
        {
            newCenter.x = midPointX - self.bounds.size.width/2
        }
        
        var midPointY = self.bounds.midY
        if (newCenter.y > (superView.bounds.size.height - midPointY + self.bounds.size.height/2))
        {
            newCenter.y = (superView.bounds.size.height - midPointY + self.bounds.size.height/2)
        }
        
        if (newCenter.y < midPointY - self.bounds.size.height/2)
        {
            newCenter.y = midPointY - self.bounds.size.height/2
        }
        
        self.setCenterLocation(newCenter)
        
    }

    func updateStyle(_ attributes:ZDAttributes? = nil) {
        if attributes != nil {
            self.attributes = attributes
        }
        
        if let subLayers = self.contentView.layer?.sublayers {
            for layer in subLayers {
                if let shapeLayer =  layer  as? CAShapeLayer {
                    self.contentView.alphaValue = CGFloat(self.attributes.shapeOpacity)
                    shapeLayer.fillColor =  self.attributes.pathFillColor.cgColor
                    shapeLayer.strokeColor = self.attributes.pathStrokeColor.cgColor
                    shapeLayer.shadowRadius = self.attributes.shadowRadius
                    shapeLayer.shadowColor = self.attributes.shadowColor.cgColor
                    shapeLayer.shadowOffset = self.attributes.shadowOffset
                    shapeLayer.shadowOpacity = self.attributes.shadowOpacity
                    if !self.attributes.isShadowActive {
                        shapeLayer.shadowOpacity = 0
                    }
                    shapeLayer.strokeColor = self.attributes.pathStrokeColor.cgColor
                    shapeLayer.lineWidth = self.attributes.strokeWidth
                    shapeLayer.lineDashPattern = self.attributes.lineDashedPattern as? [NSNumber]
                    if !self.attributes.isBorderActive {
                         shapeLayer.lineWidth = 0
                    }
                }
             
            }
        }
        
    }
    func type() -> ZDStickerViewType {
        if contentView is DraggingImageView {
            return ZDStickerViewType.image
        }else if contentView is ZdContentView {
            return ZDStickerViewType.text
        }
        return .none
    }
//    func getStickerData() -> ShapeImageView {
//        let transform = self.transform
//        self.transform = .identity
//        let data = ZDStickerViewData()
//        data.frame = self.frame
//        data.transform = transform
//        data.attributes = self.attributes
//        if let subLayers = self.contentView.layer?.sublayers {
//            for layer in subLayers {
//                if let shapeLayer =  layer  as? CAShapeLayer {
//                    data.path = shapeLayer.path
//                }
//            }
//        }
//        self.transform = transform
//        return data
//    }
    
}
