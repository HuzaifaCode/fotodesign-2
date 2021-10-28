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


let NOTIFICATION_CENTER = NotificationCenter.default

let appDelegate = NSApp.delegate as! AppDelegate
let userDefaults = UserDefaults.standard

let IS_FREE_USERS = "isFreeUsers"
let documentDiroctoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let ImportedStickerpath = documentDiroctoryPath.appending("/Stickers")


enum NotificationKey: String
{
    case BusinessCardSelected             = "BusinessCardSelected"
    case TextAdded             = "TextAdded"
    case shapeSelected             = "shapeSelected"
    case AddText = "AddText"
    case TextChanged = "TextChanged"
    case ColorChanged = "ColorChanged"
    case StickerColorChanged = "StickerColorChanged"
    case OpacitySliderChanged = "OpacitySliderChanged"
    case stickerHeightChanged = "stickerheightChanged"
    case stickerWidthChanged = "stickerWidthChanged"
    case TextBorderDidChanged = "TextBorderDidChanged"
    case bgColorChanged = "bgColorChanged"
    case FontChanged = "FontChanged"
    case textAlignmentChanged = "TextAlignmentChanged"
    case selectionChanged = "currentTextSelectionChanged"
    case importImageSticker = "importImageSticker"
    case importBackgroundSticker = "importBackgroundSticker"
    case cardSideSeleceted = "cardSideSeleceted"
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

enum SideMenu : Int {
    case front = 1, back = 2, none = 3, ipad = 4
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



class StickerManager:NSObject {
    
    
   class func getZDSticker(frame:CGRect = CGRect(x: 0, y: 0, width: 300, height: 300)) -> ZDStickerView {
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

