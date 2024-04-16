//
//  ErrorMessage.swift
//  Amplify
//
//  Created by Hassan dad khan on 08/08/2023.
//

import Foundation

struct ErrorMessage : Codable {
    let code : String?
    let message : String?
    let data : ErrorData?
    
    enum CodingKeys: String, CodingKey {
        
        case code = "code"
        case message = "message"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(String.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(ErrorData.self, forKey: .data)
    }
    
}
struct ErrorData : Codable {
    let status : Int?
    let json_error_code : Int?
    let json_error_message : String?

    enum CodingKeys: String, CodingKey {

        case status = "status"
        case json_error_code = "json_error_code"
        case json_error_message = "json_error_message"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        json_error_code = try values.decodeIfPresent(Int.self, forKey: .json_error_code)
        json_error_message = try values.decodeIfPresent(String.self, forKey: .json_error_message)
    }

}

struct CustomError: Error {
    var message: String = ""
    
    init(message: String) {
        self.message = message
    }
}

extension CustomError: LocalizedError {
    var errorDescription: String? {message}
}

enum ResponceStatus: String {
    case Success = "Success"
    case Error = "Error"
}
