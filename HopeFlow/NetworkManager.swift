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

struct ListingPhotoResponse: Codable {
    let id: Int
    let listing_id: Int
    let path: String
    let is_primary: Bool
    let created_at: String?
    let updated_at: String?
}

struct BasketItemResponse: Codable {
    let id: Int
    let basket_id: Int
    let listing_id: Int
    let created_at: String?
    let updated_at: String?
    let is_active: Bool?
}

struct BasketResponse: Codable {
    let id: Int
    let user_id: Int
    let created_at: String?
    let updated_at: String?
    let is_active: Bool?
    let items: [BasketItemResponse]?
}

struct BasketCreate: Codable {
    let user_id: Int
}

struct BasketItemCreate: Codable {
    let basket_id: Int
    let listing_id: Int
}

struct BasketItemWithProduct: Codable {
    let id: Int
    let basket_id: Int
    let listing_id: Int
    let created_at: String?
    let updated_at: String?
    let is_active: Bool
    let listing: Product
}

struct BasketDetailResponse: Codable {
    let id: Int
    let user_id: Int
    let created_at: String?
    let updated_at: String?
    let is_active: Bool
    let items: [BasketItemResponse]
}

class NetworkManager {
    static let shared = NetworkManager()
    
    // Configurable base URL - development ve production için farklı URL'ler
    var baseURL: String {
        #if DEBUG
        return "http://localhost:8000"
        #else
        return "https://your-production-api.com" // Production URL'ini buraya ekleyin
        #endif
    }
    
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
        
        print("DEBUG: Sending login request to: \(url)")
        print("DEBUG: Login parameters: \(parameters)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("DEBUG: Login response status code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Login failed")
        }
        
        // Parse the response to get the token
        do {
            let responseDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("DEBUG: Login response: \(responseDict ?? [:])")
            
            guard let token = responseDict?["access_token"] as? String else {
                print("DEBUG: No access_token found in response")
                throw NetworkError.serverError("No token received")
            }
            
            print("DEBUG: Token received: \(token)")
            return (nil, token)
        } catch {
            print("DEBUG: Failed to parse login response: \(error)")
            throw NetworkError.decodingError
        }
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
    
    func createListing(title: String, description: String, categoryId: Int, userId: Int, postCode: String, charityId: Int) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/api/v1/listings") else {
            throw NetworkError.invalidURL
        }
        let parameters: [String: Any] = [
            "title": title,
            "description": description,
            "category_id": categoryId,
            "user_id": userId,
            "post_code": postCode,
            "charity_id": charityId
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
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
        let products = try JSONDecoder().decode([Product].self, from: data)
        return products
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
            
            // Gelen ürünlerin user_id'lerini kontrol et ve sadece istenen kullanıcının ürünlerini filtrele
            let filteredProducts = products.filter { product in
                guard let productUserId = product.user_id else { return false }
                return productUserId == userId
            }
            
            return filteredProducts
        } catch {
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
    
    // MARK: - S3 Photo Upload
    func uploadListingPhotoToS3(image: UIImage, listingId: Int, isPrimary: Bool = false) async throws -> ListingPhotoResponse {
        guard let url = URL(string: "\(baseURL)/api/v1/listing-photos/upload") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NetworkError.invalidData
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // listing_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"listing_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(listingId)\r\n".data(using: .utf8)!)
        
        // is_primary
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"is_primary\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(isPrimary)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to upload photo")
        }
        
        // Parse response to get photo details
        do {
            let photoResponse = try JSONDecoder().decode(ListingPhotoResponse.self, from: data)
            return photoResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Create Listing with Photos (Optimized)
    func createListingWithPhotos(
        title: String,
        description: String,
        categoryId: Int,
        userId: Int,
        postCode: String,
        charityId: Int,
        price: Double? = nil,
        condition: String? = nil,
        images: [UIImage] = []
    ) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/api/v1/listings/with-photos") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Text fields
        let textFields = [
            "title": title,
            "description": description,
            "category_id": "\(categoryId)",
            "user_id": "\(userId)",
            "post_code": postCode,
            "charity_id": "\(charityId)"
        ]
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Optional fields
        if let price = price {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(price)\r\n".data(using: .utf8)!)
        }
        
        if let condition = condition {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"condition\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(condition)\r\n".data(using: .utf8)!)
        }
        
        // Images
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"photo_\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to create listing with photos")
        }
        
        do {
            let product = try JSONDecoder().decode(Product.self, from: data)
            return product
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Update and Delete Listings
    
    func updateListing(id: Int, data: [String: Any]) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/listings/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: data)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to update listing")
        }
    }
    
    func deleteListing(id: Int) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/listings/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to delete listing")
        }
    }

    // Fetch all photos for a listing by listing_id
    func fetchListingPhotos(listingId: Int) async throws -> [ListingPhotoResponse] {
        guard let url = URL(string: "\(baseURL)/api/v1/listing-photos?listing_id=\(listingId)") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode([ListingPhotoResponse].self, from: data)
    }

    // MARK: - Basket Management
    func createBasket(userId: Int) async throws -> BasketResponse {
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/") else {
            throw NetworkError.invalidURL
        }
        
        let parameters: [String: Any] = [
            "user_id": userId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to create basket")
        }
        
        do {
            let basket = try JSONDecoder().decode(BasketResponse.self, from: data)
            return basket
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func getOrCreateBasket() async throws -> BasketResponse {
        guard let currentUser = AuthManager.shared.currentUser,
              let userId = currentUser.id else {
            print("DEBUG: No current user found in AuthManager")
            throw NetworkError.serverError("User not found")
        }
        
        print("DEBUG: Getting basket for user ID: \(userId)")
        
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/user/\(userId)/get-or-create") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG: Adding authorization header with token: \(token)")
        } else {
            print("DEBUG: No token available in AuthManager")
            print("DEBUG: AuthManager token: \(AuthManager.shared.token ?? "nil")")
            print("DEBUG: AuthManager isLoggedIn: \(AuthManager.shared.isLoggedIn)")
        }
        
        print("DEBUG: Sending request to: \(url)")
        print("DEBUG: Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("DEBUG: Response status code: \(httpResponse.statusCode)")
        print("DEBUG: Response headers: \(httpResponse.allHeaderFields)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("DEBUG: Response body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to get or create basket")
        }
        
        do {
            let basket = try JSONDecoder().decode(BasketResponse.self, from: data)
            print("DEBUG: Successfully decoded basket: \(basket)")
            return basket
        } catch {
            print("DEBUG: Failed to decode basket response: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    func getBaskets() async throws -> [BasketResponse] {
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG: Adding authorization header with token: \(token)")
        } else {
            print("DEBUG: No token available in AuthManager")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("DEBUG: Response status code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to fetch baskets")
        }
        
        do {
            let baskets = try JSONDecoder().decode([BasketResponse].self, from: data)
            return baskets
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func addItemToBasket(basketId: Int, listingId: Int) async throws -> BasketItemResponse {
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/\(basketId)/items") else {
            throw NetworkError.invalidURL
        }
        
        let parameters: [String: Any] = [
            "basket_id": basketId,
            "listing_id": listingId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG: Adding authorization header with token: \(token)")
        } else {
            print("DEBUG: No token available in AuthManager")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("DEBUG: Response status code: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to add item to basket")
        }
        
        do {
            let basketItem = try JSONDecoder().decode(BasketItemResponse.self, from: data)
            return basketItem
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func removeItemFromBasket(basketId: Int, itemId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/\(basketId)/items/\(itemId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to remove item from basket")
        }
    }

    func getBasketItemsWithProducts() async throws -> [BasketItemWithProduct] {
        // First get or create the user's basket
        let basket = try await getOrCreateBasket()
        
        // If the basket has items, fetch their product details
        if let items = basket.items, !items.isEmpty {
            print("DEBUG: Basket has \(items.count) items, fetching product details")
            let basketItems = try await fetchBasketItemsWithProducts(basketId: basket.id)
            return basketItems
        } else {
            print("DEBUG: Basket has no items")
            return []
        }
    }
    
    private func fetchBasketItemsWithProducts(basketId: Int) async throws -> [BasketItemWithProduct] {
        print("DEBUG: fetchBasketItemsWithProducts called for basket ID: \(basketId)")
        
        guard let url = URL(string: "\(baseURL)/api/v1/baskets/\(basketId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add authorization header if available
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("DEBUG: Adding authorization header with token: \(token)")
        } else {
            print("DEBUG: No token available in AuthManager")
        }
        
        print("DEBUG: Sending request to: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("DEBUG: Response status code: \(httpResponse.statusCode)")
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("DEBUG: Response body: \(responseString)")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["detail"] {
                throw NetworkError.serverError(errorMessage)
            }
            throw NetworkError.serverError("Failed to fetch basket details")
        }
        
        do {
            let basketDetail = try JSONDecoder().decode(BasketDetailResponse.self, from: data)
            print("DEBUG: Successfully decoded basket detail with \(basketDetail.items.count) items")
            
            // Fetch product details for each basket item
            var basketItemsWithProducts: [BasketItemWithProduct] = []
            
            for basketItem in basketDetail.items {
                do {
                    let product = try await fetchListing(by: String(basketItem.listing_id))
                    let basketItemWithProduct = BasketItemWithProduct(
                        id: basketItem.id,
                        basket_id: basketItem.basket_id,
                        listing_id: basketItem.listing_id,
                        created_at: basketItem.created_at,
                        updated_at: basketItem.updated_at,
                        is_active: basketItem.is_active ?? true,
                        listing: product
                    )
                    basketItemsWithProducts.append(basketItemWithProduct)
                } catch {
                    print("DEBUG: Failed to fetch product details for listing ID \(basketItem.listing_id): \(error)")
                    // Continue with other items even if one fails
                }
            }
            
            print("DEBUG: Successfully created \(basketItemsWithProducts.count) basket items with products")
            return basketItemsWithProducts
        } catch {
            print("DEBUG: Failed to decode basket detail response: \(error)")
            throw NetworkError.decodingError
        }
    }
} 
