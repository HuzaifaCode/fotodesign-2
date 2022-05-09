//
//  ApiManager.swift
//  Foto Design
//
//  Created by My Mac on 07/04/2022.
//  Copyright © 2022 Digi Tech Solutions. All rights reserved.
//

import Foundation

import Alamofire
import Cocoa
import AppCenter
import AppCenterAnalytics



class ApiManager {
    static func getImages(type: String,completion: @escaping (ResponceData?,String?) -> Void,progress: @escaping (Int) -> Void) {
        let baseURL = "https://pixabay.com/api/?key=26554571-94879eb7c8fe53c76c3e66b28&image_type=photo&q=" + type + "&per_page=100&min_height=500&min_width=500"
        
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = HTTPMethod.post.rawValue

        let parameters: [String: Any] = [
            "key": "26554571-94879eb7c8fe53c76c3e66b28"
        ]

        guard let josnData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            completion(nil,nil)
            return

        }


        AF.upload(josnData, with: req).uploadProgress { (progressV) in
            let value = Int(progressV.fractionCompleted*100.0)
            progress(value)
        }.responseDecodable { (res: DataResponse<ResponceData, AFError>) in
            switch res.result {
                case .success(let result):
                    completion(result,nil)
                    break
                case .failure(let error):
                    completion(nil,error.localizedDescription)
                    break
            }
        }
    }
    
    static func downloadFile(url:String,completion: @escaping (URL?,String?) -> Void,progress: @escaping (Int) -> Void) {
        AF.download(url).downloadProgress { (progressV) in
            let value = Int(progressV.fractionCompleted*100.0)
            progress(value)
        }.response { (res) in
            switch res.result {
                
            case .success(_):
                completion(res.fileURL,nil)
            case .failure(_):
                completion(nil,res.error?.localizedDescription)
            }
        }
    }
}

// MARK: - Mdata
struct Responce: Decodable {
    let code: Int?
    let status: String?
    let data: ResponceData?
    let error: String?
}


struct ResponceData: Decodable {
    let total: Int
    let totalHits: Int?
    let hits: [PhotoObject]?
}
struct PhotoObject: Codable {
    let previewURL: String
    let largeImageURL: String
}



class FotoEventManager {
    
    static let shared  = FotoEventManager ()
    
    func logEvent (name: MyAnalyticsEventsName, parameters : [String : Any]? = nil){
        var eventName =  name.rawValue
        
        let code = Locale.current.regionCode
        
        if code == "PK"{
            return
        }
        
        
        #if DEBUG
            eventName = "Debug " + eventName
        #endif
        
        if let params = parameters {
        
            let properties = EventProperties()
            params.forEach { (strKey, anyValue) in
                if let boolVal = anyValue as? Bool{
                    properties.setEventProperty(boolVal, forKey: strKey)
                }else if let strVal = anyValue as? String{
                    properties.setEventProperty(strVal, forKey: strKey)
                }else if let dateVal = anyValue as? Date{
                    properties.setEventProperty(dateVal, forKey: strKey)
                }else if let doubVal = anyValue as? Double{
                    properties.setEventProperty(doubVal, forKey: strKey)
                }
            }
            Analytics.trackEvent(eventName, withProperties: properties)
            
        }else{
            Analytics.trackEvent(eventName)
        }
    }
    
    func addEvent(editorType:DesignViewType,eventType:MyAnalyticsEventsName){
        if editorType == .poster {
            self.logEvent(name: eventType, parameters: ["Name" : "Poster"])
        }else if editorType == .flyer {
            self.logEvent(name: eventType, parameters: ["Name" : "Flyer"])
        }else if editorType == .invitation {
            self.logEvent(name: eventType, parameters: ["Name" : "Inviation"])
        }else if editorType == .logo {
            self.logEvent(name: eventType, parameters: ["Name" : "Logo"])
        }else if editorType == .ytChannelArt {
            self.logEvent(name: eventType, parameters: ["Name" : "Channel Art"])
        }else if editorType == .fbCover {
            self.logEvent(name: eventType, parameters: ["Name" : "FB Cover"])
        }else if editorType == .ytThumbnail {
            self.logEvent(name: eventType, parameters: ["Name" : "YT Thumbnail"])
        }else if editorType == .googleCover {
            self.logEvent(name: eventType, parameters: ["Name" : "Google Cover"])
        }else if editorType == .fbPost {
            self.logEvent(name: eventType, parameters: ["Name" : "FB Post"])
        }else if editorType == .instaPost {
            self.logEvent(name: eventType, parameters: ["Name" : "Insta Post"])
        }else if editorType == .pintrastGraphic {
            self.logEvent(name: eventType, parameters: ["Name" : "Pintrast"])
        }else if editorType == .fbAd {
            self.logEvent(name: eventType, parameters: ["Name" : "FB Add"])
        }
    }
    
}


enum MyAnalyticsEventsName : String {
    case DesignType = "Layout Selection",
    saveDesign = "Save Design",
    templateSave = "Template Save",
    Templates = "Templates",
    Create = "Create your Own"

}
