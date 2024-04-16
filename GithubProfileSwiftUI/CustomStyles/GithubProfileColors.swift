//
//  GithubProfileColors.swift
//  GithubProfileSwiftUI
//
//  Created by Hassan Dad Khan on 17/04/2024.
//

import UIKit
import SwiftUI


protocol GithubProfileColorsProtocol {
    var primary: Color {get set}
}

class GithubProfileColors:  GithubProfileColorsProtocol {
    var primary: Color = Color(hex: "#5b9423")
}

class GithubProfileUIColors: GithubProfileColorsProtocol {
    var primary: Color = Color(hex: "#5b9423")
}
