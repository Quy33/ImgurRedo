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
    
    private let clientID = "11dd115895de7c5"
    
    private let header = (key: "Authorization", value: "Client-ID 11dd115895de7c5")
    
    func requestGallery(parameter p: GalleryParameterModel) async throws -> DataModel {
        guard var urlComponents = URLComponents(string: "\(baseURL)/gallery/\(p.section)/\(p.sort)/\(p.window)/\(p.page)") else {
            throw NetworkingError.invalidData
        }
        urlComponents.queryItems = [
            URLQueryItem(name: p.showViral.key, value: "\(p.showViral.value)"),
            URLQueryItem(name: p.mature.key, value: "\(p.mature.value)"),
            URLQueryItem(name: p.album_previews.key, value: "\(p.album_previews.value)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        let headerValue = "Client-ID \(clientID)"
        request.setValue(headerValue, forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingError.invalidData
        }
        return try parseGallery(data)
    }
    //MARK: JSON Parser
    private func parseGallery(_ data: Data) throws -> DataModel {
        let model = try JSONDecoder().decode(DataModel.self, from: data)
        return model
    }
    private func parseDetail(_ data: Data) throws -> DetailDataModel {
        let model = try JSONDecoder().decode(DetailDataModel.self, from: data)
        return model
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
        
        results = try await withThrowingTaskGroup(of: imageTuple.self) { group -> [UIImage] in
            
            for (index,url) in urls.enumerated() {
                group.addTask {
                    let image = try await singleDownload(url: url)
                    let tuple = (index: index, image: image)
                    return tuple
                }
            }
            
            var results: [imageTuple] = []
            for try await result in group {
                results.append(result)
            }
            results = results.sorted{ $0.index < $1.index }
            let images: [UIImage] = results.map { $0.image }
            return images
        }
        return results
    }
//MARK: Detail Screen Networking
    func requestDetail(isAlbum: Bool, id: String) async throws -> DetailDataModel {
        let detail = isAlbum ? "album" : "image"
        let urlString = "\(baseURL)/\(detail)/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkingError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.setValue(header.value, forHTTPHeaderField: header.key)
        
        let (data,response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkingError.invalidData
        }
        return try parseDetail(data)
    }
}
//MARK: NetWorking Error Enums
enum NetworkingError: Error {
    case invalidData
    case badImage
}
