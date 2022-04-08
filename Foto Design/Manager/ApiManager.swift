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

class ResumableTimer: NSObject {

    private var timer: Timer? = Timer()
    private var callback: () -> Void

    private var startTime: TimeInterval?
    private var elapsedTime: TimeInterval?

    // MARK: Init

    init(interval: Double, callback: @escaping () -> Void) {
        self.callback = callback
        self.interval = interval
    }

    // MARK: API

    var isRepeatable: Bool = false
    var interval: Double = 0.0

    func isPaused() -> Bool {
        guard let timer = timer else { return false }
        return !timer.isValid
    }

    func start() {
        runTimer(interval: interval)
    }

    func pause() {
        elapsedTime = Date.timeIntervalSinceReferenceDate - (startTime ?? 0.0)
        timer?.invalidate()
    }

    func resume() {
        interval -= elapsedTime ?? 0.0
        runTimer(interval: interval)
    }

    func invalidate() {
        timer?.invalidate()
    }

    func reset() {
        startTime = Date.timeIntervalSinceReferenceDate
        runTimer(interval: interval)
    }

    // MARK: Private

    private func runTimer(interval: Double) {
        startTime = Date.timeIntervalSinceReferenceDate

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: isRepeatable) { [weak self] _ in
            self?.callback()
        }
    }
}





enum ProcessType: String {
    case upload = "Uploading"
    case convert = "Converting"
    case download = "Downloading"
}
class ApiManager {
    static func getImages(type: String,completion: @escaping (ResponceData?,String?) -> Void,progress: @escaping (Int) -> Void) {
        let baseURL = "https://pixabay.com/api/?key=26554571-94879eb7c8fe53c76c3e66b28&image_type=photo&q=" + type + "&orientation=vertical&per_page=100&min_height=500&min_width=500"
        
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = HTTPMethod.post.rawValue

        let parameters: [String: Any] = [
            "key": "26554571-94879eb7c8fe53c76c3e66b28"
        ]

        guard let josnData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            completion(nil,nil)
            return

        }
       // let url = "http://api.convertio.co/convert/\(id)/status"


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
    static func convert(file: URL,outputFormat: String,completion: @escaping (ResponceData?,String?) -> Void,progress: @escaping (Int) -> Void) {
        let baseURL = "http://api.convertio.co/convert"
        let data = try? Data(contentsOf: file)
        let base64 = data!.base64EncodedString()
        var req = URLRequest(url: URL(string: baseURL)!)
        req.httpMethod = HTTPMethod.post.rawValue

        let parameters: [String: Any] = [
            "apikey": "52ab32ed4dff0328982f4beffd2421c5",
            "input": "base64",
            "filename":"\(file.lastPathComponent)",
            "outputformat":"\(outputFormat)",
            "file": "\(base64)"
        ]

        guard let josnData = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else {
            completion(nil,nil)
            return
            
        }


        AF.upload(josnData, with: req).uploadProgress { (progressV) in
            let value = Int(progressV.fractionCompleted*100.0)
            progress(value)
        }.responseDecodable { (res: DataResponse<Responce, AFError>) in
            switch res.result {
                case .success(let result):
                    completion(result.data,result.error)
                    break
                case .failure(let error):
                    completion(nil,error.localizedDescription)
                    break
            }
        }
    }
    static func getStatus(id:String,completion: @escaping (ResponceData?,String?) -> Void) {
        let url = "http://api.convertio.co/convert/\(id)/status"
        var req = URLRequest(url: URL(string: url)!)
       
        req.httpMethod = HTTPMethod.get.rawValue

        AF.request(req).responseDecodable { (res: DataResponse<Responce, AFError>) in
            switch res.result {
                case .success(let result):
                    completion(result.data,result.error)
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
    
    static func delete(id:String) {
        let path = "http://api.convertio.co/convert/\(id)"
        var req = URLRequest(url: URL(string: path)!)
        req.httpMethod = HTTPMethod.delete.rawValue
        AF.request(req).response { (res) in
            
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
