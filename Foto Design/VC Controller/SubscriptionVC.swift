//
//  SubscriptionVC.swift
//  Foto Design
//
//  Created by My Mac on 20/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//

import Cocoa

import Localize_Swift

class SubscriptionVC: NSViewController {

    
    var hud:MBProgressHUD?
    
    @IBOutlet weak var proHeading: NSTextField!
    @IBOutlet weak var proDes: NSTextField!
    
    @IBOutlet weak var weeklyHeadingLbl: NSTextField!
    @IBOutlet weak var weeklyPriceLbl: NSTextField!
    
    @IBOutlet weak var monthlyHeadingLbl: NSTextField!
    @IBOutlet weak var monthlyPriceLbl: NSTextField!
    
    @IBOutlet weak var yearlyHeadingLbl: NSTextField!
    @IBOutlet weak var yealyPriceLbl: NSTextField!
    
    @IBOutlet weak var lifetimeHeadingLbl: NSTextField!
    @IBOutlet weak var lifetimePriceLbl: NSTextField!
    
    @IBOutlet weak var freeTrialLbl: NSTextField!
    
    @IBOutlet weak var weeklyView: NSView!
    @IBOutlet weak var lifetimeView: NSView!
    @IBOutlet weak var monthlyView: NSView!
    @IBOutlet weak var buyBtn: NSButton!
    @IBOutlet weak var yearlyView: NSView!
    
    @IBOutlet var subsDetailTxt: NSTextView!
    @IBOutlet weak var cancelBtn: NSButton!
    @IBOutlet weak var restoreBtn: NSButton!
    
    var selectedProdcut = Weekly_Plan
    
    
    lazy var sheetViewController: NSViewController = {
        return self.storyboard!.instantiateController(withIdentifier: "SubscriptionVC")
        as! NSViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        //   getPurchases()
        //   let tap = NSClickGestureRecognizer(target: self, action: #selector(self.yearlyTap(_:)))
        //yearlyView.addGestureRecognizer(tap)
           
       let tap1 = NSClickGestureRecognizer(target: self, action: #selector(self.monthlyTap(_:)))
       monthlyView.addGestureRecognizer(tap1)
        
        let tap2 = NSClickGestureRecognizer(target: self, action: #selector(self.lifetimeTap(_:)))
        lifetimeView.addGestureRecognizer(tap2)
        
        let tap3 = NSClickGestureRecognizer(target: self, action: #selector(self.weeklyTap(_:)))
        weeklyView.addGestureRecognizer(tap3)
        

        loadprices()
        NOTIFICATION_CENTER.addObserver(self,
                  selector: #selector(refreshData),
                  name:NSNotification.Name( NotificationKey.Refresh_Data.rawValue),object: nil)
        
        NOTIFICATION_CENTER.addObserver(self,
                   selector: #selector(refresh),
                   name:NSNotification.Name( NotificationKey.products_loaded.rawValue),object: nil)
        
        
        updateStrings()
        
    }
    @objc func refresh(){
        self.loadprices()
    }
    
    
    func updateStrings(){
        proHeading.stringValue = "UPGRADE TO PREMIUM".localized()
        proDes.stringValue = "Save Time & Money - Access Everything".localized()
        freeTrialLbl.stringValue = "3 Days Free Trial".localized()
        monthlyHeadingLbl.stringValue = "MONTHLY  PLAN".localized()
        weeklyHeadingLbl.stringValue = "WEEKLY  PLAN".localized()
        lifetimeHeadingLbl.stringValue = "LIFETIME  PLAN".localized()
       // yearlyHeadingLbl.stringValue = "YEARLY  PLAN".localized()
        buyBtn.title = "C O N T I N U E".localized()
        cancelBtn.title = "Cancel".localized()
        restoreBtn.title = "Restore".localized()
        let step1 = "STEP 1 - The Foto Design includes an optional auto-renewable subscription. Payment will be charged to your iTunes account at confirmation of purchase and will automatically renew (at the duration/price selected) unless auto-renew is turned off at least 24 hrs before the end of the current period. ".localized()
        let step2 = "STEP 2 - Account will be charged for renewal within 24-hours prior to the end of the current period. Current subscription may not be cancelled during the active subscription period; however, you can manage your subscription and/or turn off auto-renewal by visiting your iTunes Account Settings after purchase. ".localized()
        let step3 = "\n" + "STEP 3 - Any unused portion of the free one week initial period will be forfeited when you purchase a subscription.".localized() + "\n"
        subsDetailTxt.string = step1 + step2 + step3
    }
    
    func loadprices(){
        if let products  = appDelegate.loadedProducts{
            for prod in products{
                if prod.productIdentifier == Monthly_Plan {
                    monthlyPriceLbl.stringValue = prod.localizedPrice ?? "$7.99"
                }else if prod.productIdentifier == Weekly_Plan{
                    weeklyPriceLbl.stringValue = prod.localizedPrice ?? "$3.99"
                }else if prod.productIdentifier == Weekly_Plan{
                    lifetimePriceLbl.stringValue = prod.localizedPrice ?? "$24.99"
                }
            }
        }else {
            
        }
    }
    
    @objc func refreshData(){
        self.hideHud()
        if userDefaults.bool(forKey: IS_SUBSCRIBED_USER) == true || userDefaults.bool(forKey: is_Lifetime_User) == true{
            self.view.window?.close()
        }
    }
    
    func getPurchases()-> Void{
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment , product in
            return true
        }
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

        }
    }
    func resetPlanViews(){
        monthlyPriceLbl.textColor = NSColor.init(hex: "000000")
       // monthlyHeadingLbl.textColor = NSColor.init(hex: "000000")
//        yealyPriceLbl.textColor = NSColor.init(hex: "000000")
//        yearlyHeadingLbl.textColor = NSColor.init(hex: "000000")
      //  lifetimeHeadingLbl.textColor = NSColor.init(hex: "000000")
        lifetimePriceLbl.textColor = NSColor.init(hex: "000000")
        weeklyPriceLbl.textColor = NSColor.init(hex: "000000")
      //  weeklyHeadingLbl.textColor = NSColor.init(hex: "000000")
        weeklyView.bgColor = NSColor.init(hex: "ffffff")
        monthlyView.bgColor = NSColor.init(hex: "ffffff")
       // yearlyView.bgColor = NSColor.init(hex: "ffffff")
        lifetimeView.bgColor = NSColor.init(hex: "ffffff")
        freeTrialLbl.textColor = NSColor.init(hex: "000000")
    }
    @objc func weeklyTap(_ sender: NSClickGestureRecognizer? = nil) {
        // handling code
        resetPlanViews()
        weeklyPriceLbl.textColor = NSColor.init(hex: "ffffff")
        weeklyHeadingLbl.textColor = NSColor.init(hex: "ffffff")

        if Locale.current.regionCode == "PK"{
            buyBtn.title = "C O N T I N U E".localized()
        }else{
            buyBtn.title = "Start 3 Days Free Trial".localized()
        }
        
       
        
        
        freeTrialLbl.textColor = NSColor.init(hex: "ffffff")
        weeklyView.bgColor = NSColor.init(hex: "9B2F82")

        
        selectedProdcut = Weekly_Plan
    }
    
    @objc func monthlyTap(_ sender: NSClickGestureRecognizer? = nil) {
        // handling code
        resetPlanViews()
        monthlyPriceLbl.textColor = NSColor.init(hex: "ffffff")
        monthlyHeadingLbl.textColor = NSColor.init(hex: "ffffff")
        
        buyBtn.title = "C O N T I N U E".localized()
        
        freeTrialLbl.textColor = NSColor.init(hex: "000000")
        
        monthlyView.bgColor = NSColor.init(hex: "9B2F82")
  
        
        selectedProdcut = Monthly_Plan
    }
    @objc func yearlyTap(_ sender: NSClickGestureRecognizer? = nil) {
        // handling code
        resetPlanViews()
        yealyPriceLbl.textColor = NSColor.init(hex: "ffffff")
        yearlyHeadingLbl.textColor = NSColor.init(hex: "ffffff")
        freeTrialLbl.textColor = NSColor.init(hex: "000000")
        yearlyView.bgColor = NSColor.init(hex: "9B2F82")
        
        buyBtn.title = "C O N T I N U E".localized()
        //selectedProdcut = Yearly_Plan
    }
    @objc func lifetimeTap(_ sender: NSClickGestureRecognizer? = nil) {
        // handling code
        resetPlanViews()
        lifetimeHeadingLbl.textColor = NSColor.init(hex: "ffffff")
        lifetimePriceLbl.textColor = NSColor.init(hex: "ffffff")
        freeTrialLbl.textColor = NSColor.init(hex: "000000")
        
        lifetimeView.bgColor = NSColor.init(hex: "9B2F82")
        selectedProdcut = Lifetime_Plan
    }
    
    func showHudbuyProd(completion: @escaping (Bool) -> Void){
        
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {[weak self] in
            guard let self = self else {return}
            completion(true)
        }
        
    }
    
    func showHud(_ relativeView:NSView? = nil) -> Void {
        if(relativeView != nil)
        {
            hud = MBProgressHUD.showCustomHUDAdded(to: self.view, for: relativeView, animated: true)
        }
        else
        {
          hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func showProgressHud() -> Void {
       hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = "Loading"
        hud?.mode = MBProgressHUDModeAnnularDeterminate
    }
    
    
    func hideHud() -> Void {
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(self)
       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.dismiss_Clicked.rawValue), object: nil, userInfo: nil)
    }
    @IBAction func restore(_ sender: Any) {
        self.showHudbuyProd(){[weak self](isSaved) in
            //guard let self = self else {return}
            appDelegate.verifyReceipt()
        }
      //  self.showProgressHud()
        
    }
    
    @IBAction func buyBtnPressed(_ sender: Any) {
        // DispatchQueue.main.async {
//        DispatchQueue.main.async {[weak self] in
//            guard let self = self else {return}
//            self.showHud(self.view)
//        }
        self.showHudbuyProd(){[weak self](isSaved) in
            guard let self = self else {return}
            self.buyProduct(product: self.selectedProdcut)
        }
        
            //DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                //completion()
                
            //}
       // }
        
        
    }
    @IBAction func privacyBtnPressed(_ sender: Any) {
        openAppWithUrl(url: PRIVACY_POLICY)

    }
    @IBAction func termsBtnPressed(_ sender: Any) {
        openAppWithUrl(url: TERMS_OF_USE)
    }
    
    func buyProduct(product:String) -> Void {
       
        
       
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            
            case .success ( _):

                DispatchQueue.main.async {
                    
                    if product == Monthly_Plan || product == Weekly_Plan {
                        userDefaults.set(true, forKey: IS_SUBSCRIBED_USER)
                    }else{
                        
                        userDefaults.set(true, forKey: is_Lifetime_User)
                    }
                    
                    self.hideHud()
                    
                    appDelegate.refreshData()
                }

                break
            case .error(let error):
                
            
                DispatchQueue.main.async {
                    self.hideHud()
                   
               }
            
            case .restored( _):
                DispatchQueue.main.async {
                    if product == Monthly_Plan || product == Weekly_Plan{
                        userDefaults.set(true, forKey: IS_SUBSCRIBED_USER)
                    }else{
                        userDefaults.set(true, forKey: is_Lifetime_User)
                    }
                    self.hideHud()
                    appDelegate.refreshData()
                    
                }

                break
            }
            
        }
    }
    
    
}
