import Foundation
import UIKit

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case serverError(String)
    case decodingError
}

struct Charity: Codable {
    let id: Int
    let name: String
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000" // Local FastAPI backend for development
    
    private init() {}
    
    func register(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/v1/users/") else {
            throw NetworkError.invalidURL
        }
        
        let parameters: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getCurrentUser(token: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/api/v1/users/me") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // New login function that returns token
    func loginAndGetToken(email: String, password: String) async throws -> (User?, String) {
        guard let url = URL(string: "\(baseURL)/api/v1/token") else {
            throw NetworkError.invalidURL
        }
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        let (data, response) = try await URLSession.shared.data(for: request)
        print("RESPONSE:", response)
        print("DATA:", String(data: data, encoding: .utf8) ?? "")
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        // Parse token and (optionally) user
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let token = json?["access_token"] as? String else {
            throw NetworkError.decodingError
        }
        // Optionally parse user if present
        var user: User? = nil
        if let userDict = json?["user"] as? [String: Any],
           let userData = try? JSONSerialization.data(withJSONObject: userDict),
           let parsedUser = try? JSONDecoder().decode(User.self, from: userData) {
            user = parsedUser
        }
        return (user, token)
    }
    
    func fetchListing(by id: String) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/api/v1/listings/\(id)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        do {
            let product = try JSONDecoder().decode(Product.self, from: data)
            return product
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func createListing(title: String, description: String, categoryId: Int, userId: Int, postCode: String) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/api/v1/listings") else {
            throw NetworkError.invalidURL
        }
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "category_id": categoryId,
            "user_id": userId,
            "post_code": postCode
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        let (data, response) = try await URLSession.shared.data(for: request)
        print("RESPONSE:", response)
        print("DATA:", String(data: data, encoding: .utf8) ?? "")
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        do {
            let product = try JSONDecoder().decode(Product.self, from: data)
            return product
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String? {
        guard let url = URL(string: "\(baseURL)/api/v1/upload") else {
            throw NetworkError.invalidURL
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidData
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Unknown error occurred")
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let imageUrl = json["url"] as? String {
            return imageUrl
        }
        
        return nil
    }
    
    func addListingPhoto(listingId: Int, path: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/listing-photos") else {
            throw NetworkError.invalidURL
        }
        let parameters: [String: Any] = [
            "listing_id": listingId,
            "path": path
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        let (data, response) = try await URLSession.shared.data(for: request)
        print("PHOTO RESPONSE:", response)
        print("PHOTO DATA:", String(data: data, encoding: .utf8) ?? "")
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Photo upload failed")
        }
    }
    
    func fetchAllListings() async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/api/v1/listings/") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode([Product].self, from: data)
    }
    
    func fetchListingsByUser(userId: Int) async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/api/v1/listings?user_id=\(userId)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        print("Listings Response:", response)
        print("Listings Data:", String(data: data, encoding: .utf8) ?? "")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to fetch listings. Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let products = try JSONDecoder().decode([Product].self, from: data)
            print("Fetched \(products.count) products for user \(userId)")
            
            // Gelen ürünlerin user_id'lerini kontrol et ve sadece istenen kullanıcının ürünlerini filtrele
            let filteredProducts = products.filter { product in
                guard let productUserId = product.user_id else { return false }
                return productUserId == userId
            }
            
            print("Filtered to \(filteredProducts.count) products for user \(userId)")
            for product in filteredProducts {
                print("Product ID:", product.id ?? "nil", "User ID:", product.user_id ?? "nil")
            }
            
            return filteredProducts
        } catch {
            print("Decoding error:", error)
            throw NetworkError.decodingError
        }
    }

    func fetchPurchasesByUser(userId: Int) async throws -> [Product] {
        guard let url = URL(string: "\(baseURL)/api/v1/purchases?user_id=\(userId)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode([Product].self, from: data)
    }

    func fetchCharities() async throws -> [Charity] {
        guard let url = URL(string: "\(baseURL)/api/v1/charities/") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode([Charity].self, from: data)
    }
} 