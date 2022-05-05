//
//  GModel.swift
//  Foto Design
//
//  Created by My Mac on 14/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//

import Foundation
import Cocoa


struct ThumnailJson: Codable {
    let thumb0: String?
    var isFree: Bool? = false
}

struct TextStyles: Codable {
    let templates: [FontStyles]

}
struct FontStyles: Codable {
    var familyName:String?
    var colorString:String?
    var fontSize:Double?
    var textString:String?

}
let settingJson: String = """
{
            "templates" : [
             {
                 "familyName" : "Ederson-Regular",
                 "colorString" : "dec1ad",
                 "fontSize" : 30

             },
             {
                 "familyName" : "SpicyRice-Regular",
                 "colorString" : "a72c52",
                 "fontSize" : 25

             },
             {
                 "familyName" : "AgencyFB-Reg",
                 "colorString" : "9a2e81",
                 "fontSize" : 27

             },
             {
                 "familyName" : "Vonique92",
                 "colorString" : "273a1b",
                 "fontSize" : 25

             },
             {
                 "familyName" : "MinimaSSiBold",
                 "colorString" : "55360a",
                 "fontSize" : 30

             },
             {
                 "familyName" : "SegoeUIBlack",
                 "colorString" : "3d8b95",
                 "fontSize" : 25

             },
             {
                 "familyName" : "AsiyahScript",
                 "colorString" : "107c79",
                 "fontSize" : 22

             },
             {
                 "familyName" : "Mistral",
                 "colorString" : "f06832",
                 "fontSize" : 30

             },
             {
                 "familyName" : "Ariston",
                 "colorString" : "319538",
                 "fontSize" : 30

             }
         ],
         "shapes" : [],
         "showAds" : true,
         "fonts" : []
}
"""


