//
//  Networking file.swift
//  ImgurRedo
//
//  Created by Mcrew-Tech on 16/11/2021.
//

import Foundation
import UIKit

//struct Networking {
//    static var stop = false
//    let testLink = "https://i.imgur.com/WzU9QqB.jpeg"
//    
//    func downloadStuff() async {
//        Task {
//            do {
//                let results = try await withThrowingTaskGroup(of: UIImage.self, body: { group -> [UIImage] in
//                    for i in 1...11 {
//                        group.addTask {
//                            let url = URL(string: testLink)!
//                            let request = URLRequest(url: url)
//                            try Task.checkCancellation()
//                            let (data,response) = try await URLSession.shared.data(for: request)
//                            let image = UIImage(data: data)
//                            print("Finished task \(i)")
//                            return image!
//                        }
//                    }
//                    
//                    var results: [UIImage] = []
//                    for try await result in group {
//                        if Networking.stop {
//                            group.cancelAll()
//                            throw CancellationError()
//                        } else {
//                            results.append(result)
//                        }
//                    }
//                    print("Finished Tasks")
//                    return results
//                })
//                print(results.count)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//}
//for i in 1...20 {
//    group.addTask {
//        print("Begin sleeping in \(i)")
//        await Task.sleep(1_000_000_000 * UInt64(i))
//        try Task.checkCancellation()
//        print("Finished sleeping in \(i)")
//        return UIImage()
//    }
//}
