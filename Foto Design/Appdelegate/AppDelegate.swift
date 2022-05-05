//
//  AppDelegate.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 13/07/2021.
//

import Cocoa
import StoreKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    

    var loadedProducts: [SKProduct]?
    var isRecieptLoaded:Bool = false
    var is_Lifetime = false
    var is_subscribed = false
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        getPurchases()
        loadProducts()
        
        let fonts = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil)
        fonts?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
        
        let font = Bundle.main.urls(forResourcesWithExtension: "TTF", subdirectory: nil)
        font?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
        let OTF_fonts = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil)
        OTF_fonts?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
        
        
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
    
    func verifyReceipt() -> Void {
        
        let appleValidator = AppleReceiptValidator(service: .production , sharedSecret: "28fff44e5b08443e809b477b311cf085")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) {[weak self](result) in
            guard let self = self else {return}
            switch result {
            case .success(let receipt):
                let productIds = Set([Monthly_Plan,Weekly_Plan])
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                
                let purchaseResult2 =
                    SwiftyStoreKit.verifyPurchase(productId: Lifetime_Plan, inReceipt: receipt)
                switch purchaseResult2 {
                case .notPurchased:
                    print("no Chackar Allowed")
                    self.isRecieptLoaded = true
                    userDefaults.set(false, forKey: is_Lifetime_User)
                    //self.refreshData()
                case .purchased(item: let item):
                    self.isRecieptLoaded = true
                    userDefaults.set(true, forKey: is_Lifetime_User)
                    self.is_Lifetime = true
                    //self.refreshData()
                }
                
                switch purchaseResult {
                case .purchased( _ , _):
                    self.isRecieptLoaded = true
                    self.is_subscribed = true
                    userDefaults.set(true, forKey: IS_SUBSCRIBED_USER)
                    self.refreshData()
                case .expired( _, _):
                    self.isRecieptLoaded = true
                    userDefaults.set(false, forKey: IS_SUBSCRIBED_USER)
                    self.refreshData()
                case .notPurchased:
                    self.isRecieptLoaded = true
                    userDefaults.set(false, forKey: IS_SUBSCRIBED_USER)
                    self.refreshData()
                case .billingRetry( _, _):
                    self.isRecieptLoaded = true
                    self.is_subscribed = true
                    userDefaults.set(true, forKey: IS_SUBSCRIBED_USER)
                    self.refreshData()
                    break
                }
                
            case .error(let error):
                self.refreshData()
            case .cancelError(error: let error):
                
                userDefaults.set(false, forKey: IS_SUBSCRIBED_USER)
                self.refreshData()
                break
            }
            
        }
    }
    func refreshData(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.Refresh_Data.rawValue), object: nil, userInfo: nil)
    }
    
    
    func getPurchases()-> Void{
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment , product in
            return true
        }
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            
        }
    }
    func loadProducts(){
        SwiftyStoreKit.retrieveProductsInfo([Monthly_Plan,Weekly_Plan,Lifetime_Plan]) { (results) in
            if results.retrievedProducts.count > 0 {
                self.loadedProducts =  Array(results.retrievedProducts)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.products_loaded.rawValue), object: nil, userInfo: nil)
            }
        }
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
