//
//  SaveOptionsVC.swift
//  TypoGraphy Editor
//
//  Created by My Mac on 14/07/2021.
//  Copyright © 2021 Digi Tech Solutions. All rights reserved.
//


import Foundation
import Cocoa


protocol SaveProtocol: class {
    func jpgClicked() -> Void
    func pngClicked() -> Void
    func pdfClicked() -> Void
}


class SaveOptions: NSViewController {

    
    weak var delegate:SaveProtocol?
    
    
    class func options()-> SaveOptions{
        return NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SaveOptions") as! SaveOptions
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func pngBtnClicked(_ sender: Any) {
        delegate?.pngClicked()
    }
    @IBAction func jpgBtnClicked(_ sender: Any) {
        delegate?.jpgClicked()
    }
    @IBAction func pdfBtnClicked(_ sender: Any) {
        delegate?.pdfClicked()
    }
    
}
