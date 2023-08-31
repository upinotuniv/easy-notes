//
//  ApiManager.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 29/08/23.
//

import Foundation
import Combine

enum APIError: Error {
    case requestFailed
    case decodeFailed
}

struct NotesResponse: Decodable {
    let message: String
    var data: NotesData
}

class APIManager {
    static let shared = APIManager()
    private let baseUrl = "http://localhost:3000"
    private init() {}
    
    func fetchData<T: Decodable>(path: String) -> AnyPublisher<T, Error> {
        let url = URL(string: "\(baseUrl)/\(path)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Response<T>.self, decoder: JSONDecoder())
            .map { response in
                return response.data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    struct Response<T: Decodable>: Decodable {
        let message: String
        let data: T
    }
    
    func fetchDataByID(id: Int, path: String) -> AnyPublisher<NotesData, Error> {
        let url = URL(string: "\(baseUrl)/\(path)/\(id)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NotesResponse.self, decoder: JSONDecoder())
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func postData<T: Encodable>(path: String, body: T) -> AnyPublisher<Void, Error> {
        let url = URL(string: "\(baseUrl)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed
                }
                
                if 200..<300 ~= httpResponse.statusCode {
                    return
                } else {
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("HTTP Status Code: \(httpResponse.statusCode)")
                        print("Response Data: \(dataString)")
                    }
                    throw APIError.requestFailed
                }
            }
            .mapError { error in
                return error
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func putData<T: Encodable>(path: String, id: Int, body: T) -> AnyPublisher<NotesData, Error> {
       let url = URL(string: "\(baseUrl)/\(path)/\(id)")!
       var request = URLRequest(url: url)
       request.httpMethod = "PUT"
       request.httpBody = try? JSONEncoder().encode(body)
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
       return URLSession.shared.dataTaskPublisher(for: request)
           .map(\.data)
           .decode(type: NotesResponse.self, decoder: JSONDecoder())
           .map(\.data)
           .receive(on: DispatchQueue.main)
           .eraseToAnyPublisher()
    }
    
    func deleteData(path: String, id: Int) -> AnyPublisher<String, Error> {
        let url = URL(string: "\(baseUrl)/\(path)/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.requestFailed
            }
            
            if 200..<300 ~= httpResponse.statusCode {
                return data
            } else {
                if let dataString = String(data: data, encoding: .utf8) {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    print("Response Data: \(dataString)")
                }
                throw APIError.requestFailed
            }
        }
        .decode(type: DeleteResponse.self, decoder: JSONDecoder())
        .map(\.message)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    struct DeleteResponse: Decodable {
        let message: String
    }
    
}
