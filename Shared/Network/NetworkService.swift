//
//  NetworkService.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import Foundation

typealias Parameters = [String: String]

// Enums are used to avoid typos when calling from view controllers.
enum EndPoint: String {
    case vod = "https://api.pac-12.com/v3/vod"
    case schools = "https://api.pac-12.com/v3/schools"
    case sports = "https://api.pac-12.com/v3/sports"
    case bogus = "://api.pac-12.com/v3/sports"

    func url() -> String {
        return self.rawValue
    }
}

enum CustomError: Error {
    case invalidURL
    case unableToDecodeData
}

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    // Set the number of items requested for vod paging
    let pageSize = "10"

    // Plays sound every time paging for new data takes place and displays card # in UI.
    let debuggingEnabled = true

    func fetchData<T: Decodable>(endPoint: EndPoint, completion: @escaping (T?, Error?) -> ()) {
        let urlString = endPoint.url()
        guard let url = URL(string: urlString) else {
            completion(nil, CustomError.invalidURL)
            return
        }

        URLSession.shared.dataTask(with: url) { (data, resp, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, CustomError.unableToDecodeData)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }.resume()
    }

    // The only difference between this call and the above is the ability to set the page and page size.
    // Note we hard code the page size to 10 per assessment requirements since API docs state this defaults to 20.
    func fetchPageableData<T: Decodable>(endPoint: EndPoint, page: Int = 0, completion: @escaping (T?, Error?) -> ()) {
        let urlString = endPoint.url()
        guard let url = URL(string: urlString) else {
            completion(nil, CustomError.invalidURL)
            return
        }

        let urlRequest = URLRequest(url: url)
        let parameters = ["page": "\(page)", "pagesize": pageSize]
        let encodedURLRequest = urlRequest.encode(with: parameters)

        URLSession.shared.dataTask(with: encodedURLRequest) { (data, resp, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, CustomError.unableToDecodeData)
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }.resume()
    }
}

// Convenience function to encode the page and pagesize parameters for video on demand endpoint.
extension URLRequest {
    func encode(with parameters: Parameters?) -> URLRequest {
        guard let parameters = parameters else {
            return self
        }

        var encodedURLRequest = self

        if let url = self.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            var newUrlComponents = urlComponents
            let queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            newUrlComponents.queryItems = queryItems
            encodedURLRequest.url = newUrlComponents.url
            return encodedURLRequest
        } else {
            return self
        }
    }
}
