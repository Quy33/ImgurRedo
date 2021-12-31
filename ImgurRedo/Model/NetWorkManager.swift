//
//  NetWorkManager.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation
import UIKit

struct NetWorkManager {
    private let baseURL = "https://api.imgur.com/3"
    
    static let baseImgLink = "https://i.imgur.com"
    
    private let header = (key: "Authorization", value: "Client-ID 11dd115895de7c5")
    
    func requestGallery(parameter p: GarleryParameter) async throws -> RawGallery {
        guard var urlComponents = URLComponents(string: "\(baseURL)/gallery/\(p.section)/\(p.sort)/\(p.window)/\(p.page)") else {
            throw NetworkingError.invalidData
        }
                
        urlComponents.queryItems = [
            URLQueryItem(name: p.showViral.key, value: "\(p.showViral.value)"),
            URLQueryItem(name: p.mature.key, value: "\(p.mature.value)"),
            URLQueryItem(name: p.album_previews.key, value: "\(p.album_previews.value)")
        ]
        guard let url = urlComponents.url else {
            throw NetworkingError.invalidData
        }
        
        let data = try await downloadData(url)

        return try parseJson(data)
    }
    //MARK: DownLoad data function
    private func downloadData(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(header.value, forHTTPHeaderField: header.key)
        
        let (data,response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingError.invalidData
        }
        return data
    }
    //MARK: JSON Parser
    private func parseJson<T: Decodable>(_ data: Data) throws -> T {
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    }
    //MARK: Link Detector
    func detectLinks(text: String) -> [String] {
        let type: NSTextCheckingResult.CheckingType = .link
        var urlStrings: [String] = []
        do {
            let range = NSMakeRange(0, text.utf16.count)
            let detector = try NSDataDetector(types: type.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: range)

            urlStrings = matches.compactMap{ $0.url?.absoluteString }
            urlStrings = urlStrings.map{ trimLink($0) }
            
            return urlStrings
        } catch {
            print(error)
        }
        return urlStrings
    }
    private func trimLink(_ text: String) -> String {
        var result = ""
        guard let range = text.range(of: "http") else {
            return result
        }
        let subString = text[range.lowerBound..<text.endIndex]
        
        result = String(subString)
        if result.contains("http://") {
            result = result.replacingOccurrences(of: "http", with: "https")
        }
        return result
    }
    
    //MARK: Download Image Functions
    func singleDownload(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data,response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingError.badImage
        }
        guard let image = UIImage(data: data) else {
            throw NetworkingError.badImage
        }
        return image
    }
    
    func batchesDownload(urls: [URL]) async throws -> [UIImage] {
        typealias imageTuple = (index: Int, image: UIImage)
        var results: [UIImage] = []
        
        results = try await withThrowingTaskGroup(of: imageTuple.self) {
            group -> [UIImage] in
            
            for (index,url) in urls.enumerated() {
                group.addTask {
                    try Task.checkCancellation()
                    let image = try await singleDownload(url: url)
                    let tuple = (index: index, image: image)
                    return tuple
                }
            }
            
            var results: [imageTuple] = []
            for try await result in group {
                if Task.isCancelled {
                    group.cancelAll()
                } else {
                    results.append(result)
                }
            }
            results = results.sorted{ $0.index < $1.index }
            let images: [UIImage] = results.map { $0.image }
            return images
        }
        return results
    }
//MARK: Detail Screen Networking
    func requestDetail(isAlbum: Bool, id: String) async throws -> RawDetail {
        let detail = isAlbum ? "album" : "image"
        let detailUrlString = "\(baseURL)/\(detail)/\(id)"
        
        guard let detailUrl = URL(string: detailUrlString) else {
            throw NetworkingError.invalidData
        }
        
        let detailData = try await downloadData(detailUrl)
        
        return try parseJson(detailData)
    }
//MARK: Comment Screen Networking
    func concatCommentLink(withGalleryInfo info: GalleryTuple) -> URL? {
        guard !info.id.isEmpty else { return nil }
        let detail = info.isAlBum ? "album" : "image"
        let detailUrlString = "\(baseURL)/\(detail)/\(info.id)"
        let commentUrlString = detailUrlString + "/comments"
        return URL(string: commentUrlString)
    }
    func requestComment(_ url: URL) async throws -> RawComment {
        let detailData = try await downloadData(url)
        return try parseJson(detailData)
    }
}
//MARK: NetWorking Error Enums
enum NetworkingError: Error {
    case invalidData
    case badImage
}
extension NetworkingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Failed to download data"
        case .badImage:
            return "Failed to download image"
        }
    }
}
