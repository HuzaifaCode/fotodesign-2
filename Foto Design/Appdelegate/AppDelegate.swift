//
//  AppDelegate.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 13/07/2021.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
           return true
       }


    @IBAction func helpBtnPressed(_ sender: Any) {
        CommonUtils.openEmail(address: "myounas.apps@gmail.com", subject: "Foto Design Support", body: "")
    }
    
}

struct CommonUtils {
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
        let html = NSString.init(format: "<br> <br> <br> <br><br> %@ <br>%@<br><b>OSX Versoin :</b> %@ <br> <b>Device Type :</b> %@ <br> Your Feedback.",body,"Foto Design" , ProcessInfo.processInfo.operatingSystemVersionString,deviceName)
        
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = [address]
        service?.subject = "Foto Design | MAC | \(buildVersion)"
        
        service?.perform(withItems: [String.init(html).convertHtml()])
    }
}
