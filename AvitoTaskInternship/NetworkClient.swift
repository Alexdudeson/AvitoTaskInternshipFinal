//
//  NetworkClient.swift
//  AvitoTaskInternship
//
//  Created by Alexey Yarov on 31.10.2022.
//

import Foundation

struct NetworkClient {

    private enum NetworkError: Error {
        case codeError
    }

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                handler(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
               response.statusCode < 150 || response.statusCode >= 400 {
                handler(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else { return }
            handler(.success(data))
        }

        task.resume()
    }
}

