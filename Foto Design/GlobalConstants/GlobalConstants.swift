//
//  GlobalConstants.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//

//
//  GlobalConstants.swift
//  Screen Shot Generator
//
//  Created by My Mac on 10/07/2021.
//

import Foundation
import Cocoa

let APP_OPEN_COUNT = "AppLaunchCount"

let NOTIFICATION_CENTER = NotificationCenter.default

let appDelegate = NSApp.delegate as! AppDelegate
let userDefaults = UserDefaults.standard


let Lifetime_Plan = "com.fotodesign.lifetimeplan"
let Monthly_Plan = "com.fotodesign.monthly"
let Weekly_Plan = "com.fotodesign.weekly"
//let Yearly_Plan = "com.myapps.screenshots.yearly"

let IS_SUBSCRIBED_USER = "creationDaty"
let is_Lifetime_User = "isNeedToClearChache"


let TERMS_OF_USE = "https://sites.google.com/view/myapps-tech/terms-of-use"
let PRIVACY_POLICY = "https://sites.google.com/view/myapps-tech/privacy-policy"




let MAIN_COLOR = "9B2F82"


let IS_FREE_USERS = "isFreeUsers"
let documentDiroctoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let ImportedStickerpath = documentDiroctoryPath.appending("/Stickers")



func isProUser()->Bool{
    
    if appDelegate.isRecieptLoaded == true{
        if appDelegate.is_subscribed == true{
            return true
        }
        if appDelegate.is_Lifetime == true{
            return true
        }
    }else{
        if userDefaults.bool(forKey: is_Lifetime_User) == true{
            return true
        }
        if userDefaults.bool(forKey: IS_SUBSCRIBED_USER) == true{
            return true
        }
    }
    
    
    return false
}



enum NotificationKey: String
{
    case BusinessCardSelected             = "BusinessCardSelected"
    case TextAdded             = "TextAdded"
    case shapeSelected             = "shapeSelected"
    case AddText = "AddText"
    case TextChanged = "TextChanged"
    case ColorChanged = "ColorChanged"
    case StickerColorChanged = "StickerColorChanged"
    case TextBorderDidChanged = "TextBorderDidChanged"
    case bgColorChanged = "bgColorChanged"
    case FontChanged = "FontChanged"
    case textAlignmentChanged = "TextAlignmentChanged"
    case selectionChanged = "currentTextSelectionChanged"
    case importImageSticker = "importImageSticker"
    case importBackgroundSticker = "importBackgroundSticker"
    case cardSideSeleceted = "cardSideSeleceted"
    case DesignTypeSelected = "DesignTypeSelected"
    case Refresh_Data = "refreshData"
    case dismiss_Clicked = "dismiss_Clicked"
    case ShowProScreen = "ShowProScreen"
    case products_loaded = "productsloaded"
    case Text_Style_Sticker_Added = "TextStyleStickerAdded"
}

func loadImageNamed(name: String) -> NSImage? {
    
    if NSImage(named: name) != nil {
        return NSImage(named: name)
    }
    
    return NSImage(named: "card0")
}


// ZDView Constants

enum saveFileType : String {
    case Png = "png", Jpg = "jpg", Pdf = "pdf"
}

enum Direction : Int {
    case left = 1, right = 2, top = 3, bottom = 4
}

enum EditOption : Int {
    case importBg = 1, shape = 2, backgrounds = 3, text = 4
}

enum TextOption : Int {
    case none = 1, style = 2, editing = 3
}

enum DesignViewType : CGFloat {
    case poster = 2.45, flyer = 2.586, invitation = 2.828, logo = 2.0, ytChannelArt = 2.3148, fbCover = 2.255, ytThumbnail = 2.0572, googleCover = 1.945, fbPost = 1.7512, instaPost = 2.16, pintrastGraphic = 2.204, fbAd = 2.0934, none = 0.0
}


class Constatnts {
    static let totalTemplates: Int = 50
    static let logo = TempleteSize(
        "",
        1,
        CGSize(width: 600, height: 600)
    )
    static let thumbnail = TempleteSize(
        "",
        1.7778,
        CGSize(width: 600, height: 600)
    )
    static let poster = TempleteSize(
        "",
        0.7072,
        CGSize(width: 400, height: 565)
    )
    static let fbCover = TempleteSize(
        "",
        2.701,
        CGSize(width: 400, height: 565)
    )
    static let channelArt = TempleteSize(
        "",
        1.7777,
        CGSize(width: 400, height: 565)
    )
    static let googleCover = TempleteSize(
        "",
        1.7714,
        CGSize(width: 400, height: 565)
    )
    static let fbPost = TempleteSize(
        "",
        1.1928,
        CGSize(width: 400, height: 565)
    )
    static let pintrast = TempleteSize(
        "",
        0.6669,
        CGSize(width: 400, height: 565)
    )
    static let fbAd = TempleteSize(
        "",
        1.9108,
        CGSize(width: 400, height: 565)
    )
    static let totalBG: Int = 272
}
struct TempleteSize {
    var displayText: String
    var size: CGSize
    var ratio: CGFloat
    init(_ displayText:String,_ ratio: CGFloat,_ size:CGSize? = .zero) {
        self.displayText = displayText
        self.size = size ?? .zero
        self.ratio = ratio
    }
}



enum MainSelectionType : Int {
    case none = 1, editing = 2, layoutSelection = 3
}
enum SideMenu : Int {
    case front = 1, back = 2, none = 3, ipad = 4
}

enum StickerSelection : Int {
    case logo = 1, icons = 2, none = 3, shappes = 4
}

func twoBtnAlert(question: String, text: String = "") -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.alertStyle = .warning
    alert.informativeText = text
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    return alert.runModal() == .alertFirstButtonReturn
}

func okAlert(question: String, text: String) -> NSApplication.ModalResponse{
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    return alert.runModal()
}

struct FeedbackEmail {
    static func openEmail(address: String, subject: String, body: String) {
        
        var deviceName = ""
        
        let deviceStr = Host.current().localizedName
        if let device = deviceStr?.components(separatedBy: "’s ").last {
            deviceName = device
        }
        
        var buildVersion = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String , let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = "\(version) (\(build))"
        }
        let html = NSString.init(format: "<br> <br> <br> <br><br> %@ <br>%@<br><b>OSX Versoin :</b> %@ <br> <b>Device Type :</b> %@ <br> This information will help us to find your issue.",body,"Design Business Cards" , ProcessInfo.processInfo.operatingSystemVersionString,deviceName)
        
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = [address]
        service?.subject = "Design Business Cards | MAC | \(buildVersion)"
        
        service?.perform(withItems: [String.init(html).convertHtml()])
    }
}

func openAppWithUrl(url:String) {
    
    guard let url = URL(string : url) else {
        //completion(false)
        return
    }
    
    NSWorkspace.shared.open(url)
}

class StickerManager:NSObject {
    
    
   class func getZDSticker(frame:CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)) -> ZDStickerView {
        let sticker = ZDStickerView(frame: frame)
        sticker.setButton(.del, image: #imageLiteral(resourceName: "cross"))
        sticker.setButton(.resize, image: #imageLiteral(resourceName: "resize"))
        sticker.setButton(.custom, image: #imageLiteral(resourceName: "ROTATE"))
        sticker.setButton(.edit, image: #imageLiteral(resourceName: "ROTATE"))
        sticker.wantsLayer = true
        sticker.layer?.masksToBounds = false
        return sticker
        
    }

}
class CustomFlippedView : NSView{
    override var isFlipped: Bool {return true}
}


func openApps(completion: @escaping ((_ success: Bool)->())) {
    
    
    guard let url = URL(string : "macappstore://apps.apple.com/us/app/1583273312") else {
        completion(false)
        return
    }
    
    NSWorkspace.shared.open(url)
}
