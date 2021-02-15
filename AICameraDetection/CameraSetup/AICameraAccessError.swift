//
//  AICameraAccessError.swift
//  AICameraDetection
//
//  Created by Азиз on 30.01.2021.
//

import Foundation

public enum AICameraAccessError: String {
    case notGranded
    case denied
    case restricted
    case unrecognizedError
}

extension AICameraAccessError {
    var description: String {
        switch self {
            case .notGranded: return "⛔️ The user has NOT granded to access the camera"
            case .denied: return "⛔️ The user has denied previously to access the camera"
            case .restricted: return "⛔️ The user can't give camera access due to some restriction"
            case .unrecognizedError: return "⛔️ Something want wrong due we can't access the camera"
        }
    }
}
