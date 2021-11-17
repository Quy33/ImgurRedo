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
        return try parseJSON(data)
    }
    //MARK: JSON Parser
    private func parseJSON(_ data: Data) throws -> DataModel {
        let model = try JSONDecoder().decode(DataModel.self, from: data)
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
                    print("Begin downloading \(index)")
                    let image = try await singleDownload(url: url)
                    let tuple = (index: index, image: image)
                    print("Finished \(index)")
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
}
//MARK: NetWorking Error Enums
enum NetworkingError: Error {
    case invalidData
    case badImage
}
