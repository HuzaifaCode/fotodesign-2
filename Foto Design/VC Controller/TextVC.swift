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

    @IBOutlet weak var textStylesTView: NSTableView!
    var textStyles:[FontStyles]?
    
    var fontFamilyNames = NSFontManager.shared.availableFontFamilies
    var filterFontFamilyNames = NSFontManager.shared.availableFontFamilies
    var fontSizes:[String] = [String]()
    var filterFontFamilySizes:[String] = [String]()
    var currentSelectedFontFamily:String?
    var fontStyleNames = [String]()
    var filterStyleNames = [String]()
    var fontUsableNames = [String]()
    var filterFontUsableNames = [String]()
    
    var editorType:DesignViewType = .none
    
    
    var currentTextView:StickerTextField? = nil {
        didSet {
            self.updateUI()
        }
    }
    var sticker: StickerView?
    
    var selectedTab:TextOption = .none{
        didSet{
            
            textStylesView.isHidden = true
            textOptionsView.isHidden = true
            
            editOptionsBtn.bgColor = .white
            textStylesBtn.bgColor = .white
            if #available(macOS 10.14, *) {
                textStylesBtn.contentTintColor = NSColor.init(named: "Primary_Color")!
                editOptionsBtn.contentTintColor = NSColor.init(named: "Primary_Color")!
            } else {
                // Fallback on earlier versions
            }
            
            
            if selectedTab == .editing {
                if #available(macOS 10.14, *) {
                    editOptionsBtn.bgColor = NSColor.init(named: "Primary_Color")!
                    editOptionsBtn.contentTintColor = .white
                }
                textOptionsView.isHidden = false
            }else if selectedTab == .style {
                if #available(macOS 10.14, *) {
                    textStylesBtn.bgColor = NSColor.init(named: "Primary_Color")!
                    textStylesBtn.contentTintColor = .white
                }
                textStylesView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        txtField.delegate = self
        
        selectedTab = .style
        
        for index in 1...300 {
            self.fontSizes.append(String(index))
        }
        self.filterFontFamilySizes = self.fontSizes
        
        NotificationCenter.default.addObserver(self,selector: #selector(changeCurrentTextView(_:)),name: NSNotification.Name(rawValue: NotificationKey.selectionChanged.rawValue),
                                                      object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(loadStickers(_:)),name: NSNotification.Name(rawValue: NotificationKey.DesignTypeSelected.rawValue),
                                                      object: nil)
        
        
        
        do {
            let data = settingJson.data(using: .utf8)!
            let model = try JSONDecoder().decode(TextStyles.self, from: data)
            self.textStyles = model.templates
            textStylesTView.reloadData()
        }catch {
            
            print("can't load Fonts File.")
        }
        
        updateUI()
    }
    
    @objc func loadStickers(_ notification:NSNotification) -> Void {
        if let type = notification.object as? DesignViewType {
            self.editorType = type
            self.selectedTab = .style
            self.textStylesTView.reloadData()
        }else {
           // self.currentTextView =  nil
        }
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
//        textOptionsView.isHidden = false
//        textStylesView.isHidden = true
        selectedTab = .editing
    }
    @IBAction func stylesButtonPressed(_ sender: Any) {
//        textOptionsView.isHidden = true
//        textStylesView.isHidden = false
        selectedTab = .style
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
                selectedTab = .editing
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
    }
    @IBAction func borderColorDidChanged(_ sender: NSColorWell) {
        if let text = self.getTextField() {
            text.strokeColor = sender.color
        }

            var dict:[String:Any] = [String:Any]()
            dict["borderWidth"] = CGFloat(strokeSlider.floatValue)
            dict["borderColor"] = sender.color
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextBorderDidChanged.rawValue), object: dict, userInfo: nil)

    }
    
    @IBAction func opacitySliderDidChanged(_ sender: NSSlider) {
        if let text = self.getTextField() {
            text.alphaValue = CGFloat(sender.floatValue)
        }
    }
    
    @IBAction func chnageColor(_ sender: NSColorWell) {
        if let text = self.getTextField() {
            text.foregroundColor = sender.color
        }
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
                self.colorPicker.color = dView.foregroundColor ?? NSColor.black
                self.borderColorPicker.color = dView.borderColour ?? NSColor.black

            }else {
                fontCombobox.isEnabled = false
                styleCombobox.isEnabled = false
                sizeCombobox.isEnabled = false
                strokeSlider.isEnabled = false

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
            colorPicker.isEnabled = false
            borderColorPicker.isEnabled = false
            updateAlignementUI()
        }
    }
}
extension TextVC: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        if let txtField =  obj.object as? NSTextField {
            print(txtField.stringValue)
            if let sticker = self.sticker {
                if let text = sticker.contentView as? StickerTextField {
                    //if let txt = txtView.string {
                        text.text = txtField.stringValue
                        self.sticker?.resizeToFontSize()
                    //}
                }
            }
            
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.TextChanged.rawValue), object: nil, userInfo: ["text":txtField.stringValue])
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
extension TextVC: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let count = textStyles{
            return count.count
        }
        return 0//self.stickers.count
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let cell = tableView.makeView(withIdentifier: TextStyleTableCellView.cellIdentifier, owner: self) as? TextStyleTableCellView else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
        if let textStyle = self.textStyles?[row]{
            cell.textLbl.stringValue = GeneralManager.shared.getEditorString(editor: self.editorType)
            let font = NSFont.init(name: textStyle.familyName ?? "Ederson-Regular", size: 25)
            cell.textLbl.font = font
            cell.textLbl.textColor = NSColor.init(hex: (textStyle.colorString ?? "000000"))
        }else{
            cell.textLbl.stringValue = "Beauty Logo"
            let font = NSFont.init(name: "Ederson-Regular", size: 25)
            cell.textLbl.font = font
        }
        

        return cell
    }
        func tableViewSelectionDidChange(_ notification: Notification) {
            let row = self.textStylesTView.selectedRow
            if let style = textStyles?[row]{
                var txtSyle = style
                txtSyle.textString = GeneralManager.shared.getEditorString(editor: self.editorType) //"Beauty Logo"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKey.Text_Style_Sticker_Added.rawValue), object:txtSyle, userInfo: nil)
            }
            
            
        }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
       
    
        
}
class TextStyleTableCellView: NSTableCellView {

    @IBOutlet weak var textLbl: NSTextField!
    @IBOutlet weak var thumbView: NSImageView!
    @IBOutlet weak var box: NSBox!
    static let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "TextStyleTableCellView")
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
class LayerTableRowView: NSTableRowView {

    override func drawSelection(in dirtyRect: NSRect) {
        if selectionHighlightStyle != .none {
            let selectionRect = bounds.insetBy(dx: 2.5, dy: 2.5)

            let selectionPath = NSBezierPath(rect: selectionRect)
            selectionPath.fill()
            selectionPath.stroke()
        }
      }
}
