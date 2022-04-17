//
//  TextVC.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//

import Cocoa

class TextVC: NSViewController {

    @IBOutlet weak var editOptionsBtn: NSButton!
    @IBOutlet weak var textStylesBtn: NSButton!
    @IBOutlet weak var textOptionsView: NSView!
    @IBOutlet weak var textStylesView: NSView!
    @IBOutlet weak var txtField: NSTextField!
    
    // Text Options Outlets
    @IBOutlet weak var rightAlignBtn: NSButton!
    @IBOutlet weak var centerAllignBtn: NSButton!
    @IBOutlet weak var leftAllignBtn: NSButton!
    
    
    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var fontCombobox: NSComboBox!
    @IBOutlet weak var styleCombobox: NSComboBox!
    @IBOutlet weak var sizeCombobox: NSComboBox!
    @IBOutlet weak var borderColorPicker: NSColorWell!
    //@IBOutlet weak var shadowColorPicker: NSColorWell!
    @IBOutlet weak var strokeSlider: NSSlider!
    @IBOutlet weak var opacitySlider: NSSlider!
    @IBOutlet weak var heightSlider: NSSlider!
    @IBOutlet weak var widthSlider: NSSlider!
    
    
    var fontFamilyNames = NSFontManager.shared.availableFontFamilies
    var filterFontFamilyNames = NSFontManager.shared.availableFontFamilies
    var fontSizes:[String] = [String]()
    var filterFontFamilySizes:[String] = [String]()
    var currentSelectedFontFamily:String?
    var fontStyleNames = [String]()
    var filterStyleNames = [String]()
    var fontUsableNames = [String]()
    var filterFontUsableNames = [String]()
    
    
    var currentTextView:StickerTextField? = nil {
        didSet {
            self.updateUI()
        }
    }
    var sticker: StickerView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        txtField.delegate = self
        
        
        for index in 1...300 {
            self.fontSizes.append(String(index))
        }
        self.filterFontFamilySizes = self.fontSizes
        
        NotificationCenter.default.addObserver(self,selector: #selector(changeCurrentTextView(_:)),name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue),
                                                      object: nil)
        
        
        updateUI()
    }
    
    func setFont() {
        if let sticker = self.sticker {
            if let text = sticker.contentView as? StickerTextField {
                let fontFamily = fontCombobox.stringValue
                if  let members = NSFontManager.shared.availableMembers(ofFontFamily: fontFamily) {
                    for member in members {
                        
                        let title = filterStyleNames[self.styleCombobox.indexOfSelectedItem]
                        if let memberName = member[1] as? String  {
                            if memberName == title {
                                if let fontName = member[0] as? String {
                                    text.fontName = fontName
                                    text.fitText()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getTextField() -> StickerTextField? {
        //if let sticker = self.sticker {
            if let text = currentTextView as? StickerTextField {
                return text
            }
        //}
        return nil
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        textOptionsView.isHidden = false
        textStylesView.isHidden = true
    }
    @IBAction func stylesButtonPressed(_ sender: Any) {
        textOptionsView.isHidden = true
        textStylesView.isHidden = false
    }
    @IBAction func addTextButtonPressed(_ sender: Any) {
        self.addTextView()
        txtField.becomeFirstResponder()
    }
    @IBAction func leftAlignBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.textAlignmentChanged.rawValue), object:NSTextAlignment.left, userInfo: nil)
        self.updateAlignementUI()
    }
    
    @IBAction func rightAlignBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.textAlignmentChanged.rawValue), object:NSTextAlignment.right, userInfo: nil)
        self.updateAlignementUI()
    }
    @IBAction func centerAlignBtnPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.textAlignmentChanged.rawValue), object:NSTextAlignment.center, userInfo: nil)
        self.updateAlignementUI()
    }
   
    @objc func updateAlignementUI() -> Void {
        
        self.leftAllignBtn.bgColor = NSColor.clear
        self.centerAllignBtn.bgColor = NSColor.clear
        self.rightAlignBtn.bgColor = NSColor.clear
        
        if(self.currentTextView != nil) {
            let alignment = self.currentTextView?.alignment
            if(alignment == .right) {
                self.rightAlignBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
            }else if(alignment == .left) {
               self.leftAllignBtn.bgColor = NSColor.init(hex: MAIN_COLOR)

            }else if(alignment == .center) {
                self.centerAllignBtn.bgColor = NSColor.init(hex: MAIN_COLOR)
            }
        }
    }
    @objc func changeCurrentTextView(_ notification:NSNotification) -> Void {
        if let zdView = notification.object as? StickerView {
            self.sticker = zdView
            if let txtView = zdView.contentView as? StickerTextField{
                self.currentTextView = txtView
            }
        }else {
            self.currentTextView =  nil
        }
    }
    func addTextView() -> Void {
        if let drView = FotoContentView.createFromNib() {
            drView.txtView.stringValue = "Enter Text Here"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.AddText.rawValue), object: drView, userInfo: nil)
        }
    }
    @IBAction func strokeSliderDidChanged(_ sender: NSSlider) {
        if let text = self.getTextField() {
            text.strokeWidth = CGFloat(sender.floatValue)
        }
        
//        var dict:[String:Any] = [String:Any]()
//        //let width = Int(borderWidthTextField.stringValue) ?? 0
//        dict["borderWidth"] = CGFloat(sender.floatValue)
//        dict["borderColor"] = borderColorPicker.color
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextBorderDidChanged.rawValue), object: dict, userInfo: nil)
    }
    @IBAction func borderColorDidChanged(_ sender: NSColorWell) {
        if let text = self.getTextField() {
            text.strokeColor = sender.color
        }
        
        //if let txtView = self.currentTextView?.txtView {
            var dict:[String:Any] = [String:Any]()
            //let width = Int(borderWidthTextField.stringValue) ?? 0
            dict["borderWidth"] = CGFloat(strokeSlider.floatValue)
            dict["borderColor"] = sender.color
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextBorderDidChanged.rawValue), object: dict, userInfo: nil)
        //}
    }
    
    @IBAction func opacitySliderDidChanged(_ sender: NSSlider) {
        if let text = self.getTextField() {
            text.alphaValue = CGFloat(sender.floatValue)
        }
        
       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.OpacitySliderChanged.rawValue), object:CGFloat(sender.floatValue), userInfo: nil)
    }
    @IBAction func stickerHeightSliderDidChanged(_ sender: NSSlider) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.stickerHeightChanged.rawValue), object:CGFloat(sender.floatValue), userInfo: nil)
    }
    @IBAction func stickerWidthSliderDidChanged(_ sender: NSSlider) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.stickerWidthChanged.rawValue), object:CGFloat(sender.floatValue), userInfo: nil)
    }
    
    @IBAction func chnageColor(_ sender: NSColorWell) {
        if let text = self.getTextField() {
            text.foregroundColor = sender.color
        }
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.ColorChanged.rawValue), object: sender.color, userInfo: nil)
    }
    
    
    @objc func updateUI() -> Void {
        
        if currentTextView != nil {
            self.opacitySlider.isEnabled = true
            txtField.isEnabled = true
            updateAlignementUI()
            self.filterFontFamilyNames = self.fontFamilyNames
            self.filterStyleNames = self.fontStyleNames
            self.filterFontUsableNames = self.fontUsableNames
            self.filterFontFamilySizes = self.fontSizes
            colorPicker.isEnabled = true
            borderColorPicker.isEnabled = true
            heightSlider.isEnabled = true
            widthSlider.isEnabled = true
            self.txtField.stringValue = currentTextView?.stringValue ?? ""
            self.fontCombobox.reloadData()
            self.styleCombobox.reloadData()
            self.sizeCombobox.reloadData()
            self.colorPicker.deactivate()
            if let dView = self.currentTextView {
                fontCombobox.isEnabled = true
                styleCombobox.isEnabled = true
                sizeCombobox.isEnabled = true
                strokeSlider.isEnabled = true
                self.currentSelectedFontFamily = dView.font?.familyName
                self.fontCombobox.stringValue = dView.font?.familyName ?? ""
                self.opacitySlider.floatValue = Float(dView.alphaValue)
                self.strokeSlider.floatValue = Float(dView.borderW)
                
                let index = self.fontFamilyNames.firstIndex(of: dView.font?.familyName ?? "")
                //self.changesMadeByMe = true
                //self.fontCombobox.selectItem(at: index ?? 0)
                //self.changesMadeByMe = false
                if let fontStyles =  NSFontManager.shared.availableMembers(ofFontFamily: dView.font?.familyName ?? "") {
                    if(self.fontUsableNames.count > 0) {
                        self.fontUsableNames.removeAll()
                    }
                    if(self.fontStyleNames.count > 0) {
                        self.fontStyleNames.removeAll()
                    }
                    for fontMemnber in fontStyles{
                        if fontMemnber.count > 1{
                            if let member1 = fontMemnber[0] as? String, let member2 = fontMemnber[1] as? String {
                                if !self.fontUsableNames.contains(member1){
                                    self.fontUsableNames.append(member1)
                                    self.fontStyleNames.append(member2)
                                }
                            }
                        }
                    }

                    self.filterFontUsableNames = self.fontUsableNames
                    self.filterStyleNames = self.fontStyleNames
                    self.styleCombobox.reloadData()

                }
                if let font = dView.font {
                    if let index = self.filterFontFamilySizes.firstIndex(of: String(Int(font.pointSize))) {
                        //self.changesMadeByMe = true
                       // self.sizeCombobox.selectItem(at: index)
                        //self.changesMadeByMe = false
                    }

                    self.sizeCombobox.stringValue = String(Int(font.pointSize))
                }
                self.colorPicker.color = dView.textColor ?? NSColor.black
                self.borderColorPicker.color = dView.borderColour ?? NSColor.black

            }else {
                fontCombobox.isEnabled = false
                styleCombobox.isEnabled = false
                sizeCombobox.isEnabled = false
                strokeSlider.isEnabled = false
                //self.fontCombobox.selectItem(at: 1)
                //self.styleCombobox.selectItem(at: 1)
                //self.sizeCombobox.selectItem(at: 13)

            }
        }else{
            txtField.isEnabled = false
            fontCombobox.isEnabled = false
            styleCombobox.isEnabled = false
            sizeCombobox.isEnabled = false
            txtField.stringValue = "Enter Text Here"
            self.fontCombobox.stringValue = "Select Font"
            self.sizeCombobox.stringValue = "13"
            self.styleCombobox.stringValue = "Regular"
            self.strokeSlider.floatValue = 0
            self.strokeSlider.isEnabled = false
            self.opacitySlider.floatValue = 0
            self.opacitySlider.isEnabled = false
            heightSlider.isEnabled = false
            widthSlider.isEnabled = false
            colorPicker.isEnabled = false
            borderColorPicker.isEnabled = false
            updateAlignementUI()
        }
//        self.updateAlignementUI()
//        self.updateBoldItalicUnderLineBtnUI()
//        self.updateSliders()
//        self.updateBorderUI()
//        self.updateRotation()
        
    }
}
extension TextVC: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        if let txtField =  obj.object as? NSTextField {
            print(txtField.stringValue)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextChanged.rawValue), object: nil, userInfo: ["text":txtField.stringValue])
        }
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
        if let txtField =  obj.object as? NSTextField {
            print(txtField.stringValue)
        }
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        if let txtField =  obj.object as? NSTextField {
            print(txtField.stringValue)
            
        }
    }

}
extension TextVC: NSComboBoxDataSource {
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if(comboBox == self.fontCombobox) {
            return filterFontFamilyNames.count
        }else if(comboBox == self.sizeCombobox) {
            return filterFontFamilySizes.count
        }else if(comboBox == self.styleCombobox) {
            return filterStyleNames.count
        }
        return 0
    }
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if(comboBox == self.fontCombobox && index > -1 && index < filterFontFamilyNames.count) {
            return filterFontFamilyNames[index]
        }else if(comboBox ==  sizeCombobox && index > -1 && index < filterFontFamilySizes.count) {
            return filterFontFamilySizes[index]
        }else if(comboBox == self.styleCombobox && index > -1 && index < filterStyleNames.count) {
            return self.filterStyleNames[index]
        }
        return ""
        
    }
}
//MARK:- TextField + Control Delegates
extension TextVC: NSComboBoxDelegate {
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        if currentTextView != nil {
            if let box  = notification.object as? NSComboBox {
                
                let index = self.fontCombobox.indexOfSelectedItem
                if(index >= 0 && index < self.filterFontFamilyNames.count) {
                    self.currentSelectedFontFamily = self.filterFontFamilyNames[index]
                }
                if let cSelectedFontFamilyName = self.currentSelectedFontFamily {
                    if(box == self.fontCombobox) {
                        if let fontStyles =  NSFontManager.shared.availableMembers(ofFontFamily: cSelectedFontFamilyName) {
                            
                            self.fontStyleNames.removeAll()
                            self.fontUsableNames.removeAll()
                            
                            for fontMemnber in fontStyles{
                                if fontMemnber.count > 1{
                                    if let member1 = fontMemnber[0] as? String, let member2 = fontMemnber[1] as? String {
                                        self.fontUsableNames.append(member1)
                                        self.fontStyleNames.append(member2)
                                    }
                                }
                            }
                            
                            self.filterFontUsableNames = self.fontUsableNames
                            self.filterStyleNames = self.fontStyleNames
                            
                            self.styleCombobox.reloadData()
                            
                            if(self.filterStyleNames.count > 0) {
                                self.styleCombobox.selectItem(at: 0)
                                self.styleCombobox.stringValue = self.filterStyleNames[0]
                            }
                            
                            var dict:[String:Any] = [String:Any]()
                            dict["fontName"] = cSelectedFontFamilyName
                           // dict["fontSize"] = CGFloat(size)
                            if let sticker = self.sticker {
                                if let text = sticker.contentView as? StickerTextField {
                                    text.fontName = cSelectedFontFamilyName
                                    
                                    text.fitText()
                                }
                            }
                        }
                    }else if box == sizeCombobox {
                        //var dict:[String:Any] = [String:Any]()
                        //dict["fontSize"] = CGFloat(self.sizeCombobox.indexOfSelectedItem + 1)
                        if let sticker = self.sticker {
                            if let text = sticker.contentView as? StickerTextField {
                                text.fontSize = CGFloat(self.sizeCombobox.indexOfSelectedItem + 1)
                                sticker.resizeToFontSize()
                            }
                        }
                        
                       // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FontChanged.rawValue), object: dict, userInfo: nil)
                    }else if box == styleCombobox {
                        if(self.styleCombobox.indexOfSelectedItem > -1){
                            let style = self.filterFontUsableNames[self.styleCombobox.indexOfSelectedItem]
                            let styleName = self.filterStyleNames[self.styleCombobox.indexOfSelectedItem]
                            var dict:[String:Any] = [String:Any]()
                            dict["fontName"] = style
                            dict["fontStyle"] = styleName
//
//                            if let sticker = self.sticker {
//                                if let text = sticker.contentView as? StickerTextField {
//                                    text.fontSize = CGFloat(self.sizeCombobox.indexOfSelectedItem + 1)
//                                    text.fitText()
//                                }
//                            }
                            
                            setFont()
                            
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FontChanged.rawValue), object: dict, userInfo: nil)
                        }
                        
                    }else if(self.styleCombobox.indexOfSelectedItem > -1)  {
                        if (self.styleCombobox.indexOfSelectedItem >= self.filterFontUsableNames.count) || self.styleCombobox.indexOfSelectedItem >= self.filterStyleNames.count {
                            return
                        }
                        
                        let style = self.filterFontUsableNames[self.styleCombobox.indexOfSelectedItem]
                        let styleName = self.filterStyleNames[self.styleCombobox.indexOfSelectedItem]
                        var size:CGFloat = 13
                        if(self.sizeCombobox.indexOfSelectedItem > -1) {
                            if(self.filterFontFamilySizes.count > self.sizeCombobox.indexOfSelectedItem) {
                                size = CGFloat(Int(filterFontFamilySizes[self.sizeCombobox.indexOfSelectedItem]) ?? 13)
                            }
                        }
                        
                        var fontFamilyName = ""
                        if(self.fontCombobox.indexOfSelectedItem > -1 && self.fontCombobox.indexOfSelectedItem < self.filterFontFamilyNames.count ) {
                            fontFamilyName = self.filterFontFamilyNames[self.fontCombobox.indexOfSelectedItem]
                        }
                        
                        var dict:[String:Any] = [String:Any]()
                        dict["fontName"] = style
                        dict["fontSize"] = size
                        dict["fontStyle"] = styleName
                        dict["fontFamily"] = fontFamilyName
                        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FontChanged.rawValue), object: dict, userInfo: nil)
                        
                        
                    }else if (self.sizeCombobox.indexOfSelectedItem > -1) {
                        print("font size changed")
    //                    if let pSize = self.currentTextView?.txtView.font?.pointSize, let familyName = self.currentTextView?.txtView.familyName {
    //                        var dict:[String:Any] = [String:Any]()
    //                       // dict["fontName"] = self.fontUsableNames[cIndex]
    //                        dict["fontSize"] = CGFloat(self.sizeCombobox.indexOfSelectedItem)
    //                        //dict["fontStyle"] = style
    //                        //dict["fontFamily"] = familyName
    //                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.FontChanged.rawValue), object: dict, userInfo: nil)
    //                        //self.updateBoldItalicUnderLineBtnUI()
    //                    }
                    }
                    
                }
            }
        }
        
    }
//    func controlTextDidEndEditing(_ obj: Notification) {
//        if let dict = obj.userInfo {
//            if let comboBox  = obj.object as? NSComboBox {
//
//                if let value = dict["NSFieldEditor"] as? NSTextView {
//                    if(comboBox == self.sizeCombobox) {
//
//                        if let index = self.filterFontFamilySizes.firstIndex(of: value.string) {
//                            self.sizeCombobox.selectItem(at: index)
//                        }else {
//                            if let font = self.currentTextView?.txtView.font {
//                                // self.sizeCombobox.stringValue = String(Int(font.pointSize))
//                                self.filterFontFamilySizes = self.fontSizes
//                                comboBox.reloadData()
//                                if let oldIndex = self.filterFontFamilySizes.firstIndex(of: String(Int(font.pointSize))) {
//                                    self.sizeCombobox.selectItem(at: oldIndex)
//                                }
//                            }
//                        }
//                    }else if (comboBox == self.styleCombobox){
//                        if let index = self.filterStyleNames.firstIndex(of: value.string) {
//                            self.styleCombobox.selectItem(at: index)
//                        }else {
//                            if let fontStyle = self.currentTextView?.txtView.fontStyle {
//                                self.filterStyleNames = self.fontStyleNames
//                                self.filterFontUsableNames.removeAll()
//                                for filterStyleName in self.filterStyleNames {
//                                    if let index =  self.fontStyleNames.firstIndex(of: filterStyleName) {
//                                        self.filterFontUsableNames.append(self.fontUsableNames[index])
//                                    }
//                                }
//                                comboBox.reloadData()
//                                if let oldIndex = self.filterStyleNames.firstIndex(of: fontStyle) {
//                                    self.styleCombobox.selectItem(at: oldIndex)
//                                }
//                            }
//                        }
//                    }else if(comboBox == self.fontCombobox) {
//                        if let index = self.filterFontFamilyNames.firstIndex(of: value.string) {
//                            self.fontCombobox.selectItem(at: index)
//                        }else {
//                            if let fontName = self.currentTextView?.txtView.familyName {
//                                self.filterFontFamilyNames = self.fontFamilyNames
//                                comboBox.reloadData()
//                                if let oldIndex = self.filterFontFamilyNames.firstIndex(of: fontName) {
//                                    self.fontCombobox.selectItem(at: oldIndex)
//                                }
//                            }
//                        }
//                    }
//                }
//            }else{
//                if let textField  = obj.object as? NSTextField {
//                    var value = "0"
//                    if textField.stringValue.isNumeric(){
//                        value = textField.stringValue
//                    }
////                        if textField == self.shadowXTextField{
////                            shadowXChanged(value: CGFloat(Double(value) ?? 0))
////                        }else if textField == self.shadowYTextField{
////                            shadowYChanged(value: CGFloat(Double(value) ?? 0))
////                        }
////                        else if textField == self.shadowBlurTextField{
////                            shadowRadiusChanged(value: CGFloat(Double(value) ?? 0))
////                        }
////                        else if textField == self.borderWidthTextField{
////                            borderWidthDidChange(value: CGFloat(Double(value) ?? 0))
////                        }
//                }
//            }
//        }
//    }
}
