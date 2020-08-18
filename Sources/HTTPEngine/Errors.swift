import Foundation

public struct Errors {
    public enum Request: Error {
        case invalidURL
    }

    public enum Response: Error {
        case couldNotRetrieveStatusCode
        case unexpectedStatusCode(HTTPURLResponse)
        case redirect(Int)
        case unknown(Int)

        public enum ClientError: Error {
            case badRequest_400
            case invalidCredentials_401
            case forbidden_403
            case notFound_404
            case notAllowed_405
            case conflict_409
            case tooManyRequests_429
            case unkown(Int)
        }

        public enum ServerError: Error {
            case internalServerError_500
            case notImplemented_501
            case badGateway_502
            case unavailable_503
            case timeout_504
            case unkown(Int)
        }

        
        /// Returns a human readable HTTP Error
        /// - Parameter statusCode: HTTP Status Code
        /// - Returns: Error?
        ///
        /// ```swift
        /// code ~= 300...399 -> Errors.Response.redirect(statusCode)
        /// code ~= 400 -> Errors.Response.ClientError.badRequest_400
        /// code ~= 401 -> Errors.Response.ClientError.invalidCredentials_401
        /// code ~= 403 -> Errors.Response.ClientError.forbidden_403
        /// code ~= 404 -> Errors.Response.ClientError.notFound_404
        /// code ~= 405 -> Errors.Response.ClientError.notAllowed_405
        /// code ~= 409 -> Errors.Response.ClientError.conflict_409
        /// code ~= 429 -> Errors.Response.ClientError.tooManyRequests_429
        /// code ~= 402, 410...418, 430...499 -> Errors.Response.ClientError.unkown(statusCode)
        /// code ~= 500 -> Errors.Response.ServerError.internalServerError_500
        /// code ~= 501 -> Errors.Response.ServerError.notImplemented_501
        /// code ~= 502 -> Errors.Response.ServerError.badGateway_502
        /// code ~= 503 -> Errors.Response.ServerError.unavailable_503
        /// code ~= 504 -> Errors.Response.ServerError.timeout_504
        /// code ~= 505...599 -> Errors.Response.ServerError.unkown(statusCode)
        /// default -> Errors.Response.unknown(statusCode)
        ///```
        public static func errorWith(statusCode: Int) -> Error? {
            switch statusCode {
            case 200...299: return nil
            case 300...399: return Errors.Response.redirect(statusCode)
            case 400: return Errors.Response.ClientError.badRequest_400
            case 401: return Errors.Response.ClientError.invalidCredentials_401
            case 403: return Errors.Response.ClientError.forbidden_403
            case 404: return Errors.Response.ClientError.notFound_404
            case 405: return Errors.Response.ClientError.notAllowed_405
            case 409: return Errors.Response.ClientError.conflict_409
            case 429: return Errors.Response.ClientError.tooManyRequests_429
            case 402, 410...418, 430...499: return Errors.Response.ClientError.unkown(statusCode)
            case 500: return Errors.Response.ServerError.internalServerError_500
            case 501: return Errors.Response.ServerError.notImplemented_501
            case 502: return Errors.Response.ServerError.badGateway_502
            case 503: return Errors.Response.ServerError.unavailable_503
            case 504: return Errors.Response.ServerError.timeout_504
            case 505...599: return Errors.Response.ServerError.unkown(statusCode)
            default:
                return Errors.Response.unknown(statusCode)
            }
        }
    }
}
