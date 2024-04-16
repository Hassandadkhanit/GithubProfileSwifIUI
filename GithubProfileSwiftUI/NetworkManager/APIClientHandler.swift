//
//  APIHandler.swift
//  GitHubProfile
//
//  Created by Noctis on 31/03/2023.
//

import Foundation
import Alamofire

typealias APICompletionHander = (_ data : Data?,_ response : HTTPURLResponse?,_ error : Error?) -> Void

enum MemeType: String {
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case png = "image/png"
}

/// Defines the Network service errors.
enum NetworkError: Error {
    case unknownError
    case connectionError
    case invalidCredentials
    case invalidRequest
    case invalidURL
    case notFound
    case invalidResponse
    case serverError
    case serverUnavailable
    case timeOut
}

class APIClientHandler {
    
    var sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration)
    }()
    
    init(session: Session = Session(configuration: URLSessionConfiguration.af.default)) {
        self.sessionManager = session
    }
    
    static func getHTTPHeaders(ContentType: String = "application/json") -> HTTPHeaders {
        return [
            "Content-Type": ContentType,
            "Authorization" : "Bearer \("")"
        ]
    }
    
    //MARK: - API Requests
    func sendRequest(urlString: String,
                     parameters: Parameters?,
                     httpMethod: HTTPMethod,
                     headers: HTTPHeaders? = getHTTPHeaders(),
                     encoding: ParameterEncoding = JSONEncoding.default)  async throws -> Result<Data?, Error> {
        
        guard let url = URL.init(string: urlString) else {
            return .failure(CustomError(message: "\(NetworkError.invalidURL)"))
        }
        
        return await withCheckedContinuation { continuation in
            self.sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        #if DEBUG
                        self.showRequestDetailForSuccess(responseObject: response)
                        #endif
                        
                        continuation.resume(returning: .success(response.data))
                        break
                    case .failure(_):
                        #if DEBUG
                        self.showRequestDetailForFailure(responseObject: response)
                        #endif
                        
                        let error = self.getErrorResponse(responseObject: response)
                        continuation.resume(returning: .failure(error))
                        break
                    }
                }
        }
    }
    
    func sendDownloadRequest(urlString: String,
                          parameters: Parameters?,
                          httpMethod: HTTPMethod,
                          headers: HTTPHeaders? = getHTTPHeaders(),
                             encoding: ParameterEncoding = JSONEncoding.default,
                             progressCompletion: @escaping ((_ progress: Progress) -> Void)
    ) async throws -> Result<DownloadResponse?,Error> {
            guard let url = URL.init(string: urlString) else {
                return .failure(CustomError(message: "\(NetworkError.invalidURL)"))
            }
            let destinationPath: DownloadRequest.Destination = {_,_ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
                let fileURL = documentsURL.appendingPathComponent("downloaded_files/\(url.lastPathComponent)")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
        return await withCheckedContinuation { continuation in
            
            self.sessionManager.download(url, method: httpMethod, parameters: parameters, encoding: encoding, headers: headers, to: destinationPath)
                .downloadProgress(closure: { progress in
                    progressCompletion(progress)
                })
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        #if DEBUG
                        self.showRequestDetailForDownloadedSuccess(responseObject: response)
                        #endif
                        let downloadResponse = DownloadResponse(url: response.response?.url, fileURL: response.fileURL , memeType: response.response?.mimeType)
                        continuation.resume(returning: .success(downloadResponse))
                        break
                    case .failure(let error):
                        #if DEBUG
                        self.showRequestDetailForDownloadFailure(responseObject: response)
                        #endif
                        continuation.resume(returning: .failure(error))
                        break
                    }
                }
        }
        
    }
    
    func sendUploadRequest(urlString: String,
                           fileData: [Data],
                           imageKeyName : [String],
                           imageNameWithType : String,
                           memeType: MemeType,
                           parameters: Parameters?,
                           httpMethod: HTTPMethod,
                           headers: HTTPHeaders? = getHTTPHeaders(ContentType: "multipart/form-data"),
                           encoding: ParameterEncoding = JSONEncoding.default) async throws -> Result<Data?,Error> {
        
        guard let url = URL.init(string: urlString) else {
            return .failure(CustomError(message: "\(NetworkError.invalidURL)"))
        }
        
        return await withCheckedContinuation { continuation in
            
            self.sessionManager.upload(multipartFormData: { multiPartData in
                for (key, value) in parameters ?? Parameters() {
                    multiPartData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                for (index,data) in fileData.enumerated() {
                    multiPartData.append(data, withName: imageKeyName[index], fileName: imageNameWithType, mimeType: memeType.rawValue)
                }
                
            }, to: url, method: httpMethod,  headers: headers)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success:
                    #if DEBUG
                    self.showRequestDetailForSuccess(responseObject: response)
                    #endif
                    continuation.resume(returning: .success(response.data))
                    break
                case .failure(_):
                    let error = self.getErrorResponse(responseObject: response)
                    #if DEBUG
                    self.showRequestDetailForFailure(responseObject: response)
                    #endif
                    continuation.resume(returning: .failure(error))
                    break
                }
                
            }
        }
        
    }
    
    //MARK: - CreateError
    func getErrorResponse(responseObject response: AFDataResponse<Data?>) -> Error {
            
            var errorMessage = ""
            if let bodyData = response.data {
                do {
                    let responseObj = try JSONDecoder().decode(ErrorMessage.self, from: bodyData)
                    if !(responseObj.message?.isBlank ?? false) {
                        errorMessage = responseObj.message ?? ""
                    } else {
                        if let errorMsg = response.error?.localizedDescription, !errorMsg.isBlank {
                            errorMessage = errorMsg
                        } else {
                            errorMessage = "Msg_ApiFailed".localized
                        }
                    }
                } catch let error as NSError {
                    errorMessage = error.localizedDescription
                }

            } else {
                if let errorMsg = response.error?.localizedDescription, !errorMsg.isBlank {
                    errorMessage = response.error?.localizedDescription ?? ""
                } else {
                    errorMessage = "Msg_ApiFailed".localized
                }
            }
            
            let userInfo : [String: Any] = [NSLocalizedDescriptionKey : errorMessage]
            return NSError(domain: Bundle.main.bundleIdentifier ?? "", code: response.response?.statusCode ?? 404, userInfo: userInfo) as Error
        }
    
    

    // MARK: - API Download Logger
    
    func showRequestDetailForDownloadedSuccess(responseObject response: AFDownloadResponse<URL?>) {
        
        print("\n\n\n✅✅✅✅ ------- Success Response Start ------- ✅✅✅✅\n")
        print("URL: "+(response.request?.url?.absoluteString ?? ""))
        
        print("=========    HTTP Method: \(response.request?.httpMethod ?? "N/A")    ==========")
        
        print("=========    Status Code: \(response.response?.statusCode.description ?? "N/A")    ==========")
        
        if let header = response.request?.allHTTPHeaderFields {
            print("=========    HTTP Header Fields   ==========")
            print(header as AnyObject)
        }
        
        
        if let bodyData : Data = response.request?.httpBody {
            let bodyString = String(data: bodyData, encoding: .utf8)
            print("\n=========   Request httpBody   ========== \n" + (bodyString ?? ""))
        } else {
            print("\n=========   Request httpBody   ========== \n" + "Found Request Body Nil")
        }
        print("\n=========   Response Body   ========== \n" + "URL:\(response.response?.url?.absoluteString ?? "") \n Downloaded file URL: \(response.fileURL?.absoluteString ?? "")\n" + "MemeType:\(response.response?.mimeType ?? "")")
        print("\n✅✅✅✅ ------- Success Response End ------- ✅✅✅✅\n\n\n")
        
    }
    
    func showRequestDetailForDownloadFailure(responseObject response: AFDownloadResponse<URL?>) {
        
        print("\n\n\n❌❌❌❌ ------- Failure Response Start ------- ❌❌❌❌\n")
                
        print("URL: "+(response.request?.url?.absoluteString ?? ""))
        
        print("=========    HTTP Method: \(response.request?.httpMethod ?? "N/A")    ==========")
        
        print("=========    Status Code: \(response.response?.statusCode.description ?? "N/A")    ==========")
        
        if let header = response.request?.allHTTPHeaderFields {
            print("=========    HTTP Header Fields   ==========")
            print(header as AnyObject)
        }
        print("\n=========   Response Body   ========== \n" + "URL:\(response.response?.url?.absoluteString ?? "")\n Downloaded file URL: \(response.fileURL?.absoluteString ?? "")\n" + "MemeType:\(response.response?.mimeType ?? "")")
        if let responseData = response.resumeData, let responseString = String(data: responseData, encoding: .utf8), !responseString.isBlank {
                print(responseString)
            } else {
                if let errorMsg = response.error?.localizedDescription, !errorMsg.isBlank {
                    print(errorMsg)
                } else {
                    print("Found Response Body Nil")
                }
            }
        print("\n❌❌❌❌ ------- Failure Response End ------- ❌❌❌❌\n\n\n")
        
    }
    // MARK: - API Data Logger

    func showRequestDetailForSuccess(responseObject response: AFDataResponse<Data?>) {
        
        print("\n\n\n✅✅✅✅ ------- Success Response Start ------- ✅✅✅✅\n")
        
        
        print("URL: "+(response.request?.url?.absoluteString ?? ""))
        
        print("=========    HTTP Method: \(response.request?.httpMethod ?? "N/A")    ==========")
        
        print("=========    Status Code: \(response.response?.statusCode.description ?? "N/A")    ==========")
        
        if let header = response.request?.allHTTPHeaderFields {
            print("=========    HTTP Header Fields   ==========")
            print(header as AnyObject)
        }
        
        
        if let bodyData : Data = response.request?.httpBody {
            let bodyString = String(data: bodyData, encoding: .utf8)
            print("\n=========   Request httpBody   ========== \n" + (bodyString ?? ""))
        } else {
            print("\n=========   Request httpBody   ========== \n" + "Found Request Body Nil")
        }
        
        if let responseData : Data = response.data {
            let responseString = String(data: responseData, encoding: .utf8)
            print("\n=========   Response Body   ========== \n" + (responseString ?? ""))
        } else {
            print("\n=========   Response Body   ========== \n" + "Found Response Body Nil")
        }
        print("\n✅✅✅✅ ------- Success Response End ------- ✅✅✅✅\n\n\n")
        
    }
    
    func showRequestDetailForFailure(responseObject response: AFDataResponse<Data?>) {
        
        print("\n\n\n❌❌❌❌ ------- Failure Response Start ------- ❌❌❌❌\n")
                
        print("URL: "+(response.request?.url?.absoluteString ?? ""))
        
        print("=========    HTTP Method: \(response.request?.httpMethod ?? "N/A")    ==========")
        
        print("=========    Status Code: \(response.response?.statusCode.description ?? "N/A")    ==========")
        
        if let header = response.request?.allHTTPHeaderFields {
            print("=========    HTTP Header Fields   ==========")
            print(header as AnyObject)
        }
        
        if let bodyData : Data = response.request?.httpBody {
            let bodyString = String(data: bodyData, encoding: .utf8)
            print("\n=========    Request httpBody   ========== \n" + (bodyString ?? ""))
        } else {
            print("\n=========    Request httpBody   ========== \n" + "Found Request Body Nil")
        }
        
        print("\n=========   Response Body   ========== \n")
        
        
            
        if let responseData = response.data, let responseString = String(data: responseData, encoding: .utf8), !responseString.isBlank {
                print(responseString)
            } else {
                if let errorMsg = response.error?.localizedDescription, !errorMsg.isBlank {
                    print(errorMsg)
                } else {
                    print("Found Response Body Nil")
                }
            }
        
        
        print("\n❌❌❌❌ ------- Failure Response End ------- ❌❌❌❌\n\n\n")
    }
}

