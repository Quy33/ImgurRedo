//
//  NetWorkManager.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation

struct NetWorkManager {
    private let baseURL = "https://api.imgur.com/3"
    
    private let clientID = "11dd115895de7c5"
    
    func requestGallery(parameter p: GalleryParameterModel) async throws {
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
    }
    //MARK: JSON Parser
    
}
//MARK: NetWorking Error Enums
enum NetworkingError: Error {
    case invalidData
    case badImage
}
