//
//  GeneralManager.swift
//  Foto Design
//
//  Created by My Mac on 27/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//

import Foundation



class GeneralManager {
    static let shared  = GeneralManager ()
    func getEditorString(editor:DesignViewType)-> String {
        
        if editor == .logo {
            return "Company Logo"
        }else if editor == .ytThumbnail {
            return "Top 5 Vidoes"
        }else if editor == .fbPost || editor == .instaPost || editor == .fbAd {
            return "Special Big Sale"
        }else if editor == .ytChannelArt || editor == .fbCover || editor == .pintrastGraphic {
            return "Time to Travel"
        }else if editor == .invitation {
            return "Birthday Party"
        }else if editor == .poster {
            return "Promote Your Business"
        }else if editor == .flyer {
            return "Big Sale 70% OFF"
        }
        
        
        return "Text Goes Here"
        
    }
}


