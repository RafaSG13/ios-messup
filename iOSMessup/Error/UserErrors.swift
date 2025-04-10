
import Foundation

enum AuthError: LocalizedError {
    case userNotFound
    case userAlreadyExists
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No se encontró un usuario con ese correo electrónico."
        case .userAlreadyExists:
            return "Ya existe una cuenta con este correo electrónico."
        case .invalidCredentials:
            return "Correo electrónico o contraseña incorrectos."
        }
    }
}
