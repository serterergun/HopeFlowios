import Foundation

struct UserFavorite: Codable {
    let id: Int?
    let user_id: Int
    let listing_id: Int
}

class FavoriteManager {
    static let shared = FavoriteManager()
    private init() {}
    
    private var favoriteIDs: Set<Int> = []
    
    func isFavorite(productId: Int) -> Bool {
        return favoriteIDs.contains(productId)
    }
    
    func fetchFavoritesFromBackend(userId: Int, completion: @escaping (Result<Set<Int>, Error>) -> Void) {
        guard let url = URL(string: "\(NetworkManager.shared.baseURL)/api/v1/user-favorite/user/\(userId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            do {
                let favorites = try JSONDecoder().decode([UserFavorite].self, from: data)
                let ids = Set(favorites.map { $0.listing_id })
                self?.favoriteIDs = ids
                completion(.success(ids))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addFavorite(userId: Int, productId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(NetworkManager.shared.baseURL)/api/v1/user-favorite/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let body = ["user_id": userId, "listing_id": productId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self?.favoriteIDs.insert(productId)
            completion(.success(()))
        }.resume()
    }
    
    func removeFavorite(userId: Int, productId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(NetworkManager.shared.baseURL)/api/v1/user-favorite/?user_id=\(userId)&listing_id=\(productId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self?.favoriteIDs.remove(productId)
            completion(.success(()))
        }.resume()
    }
    
    func getFavoriteIDs() -> Set<Int> {
        return favoriteIDs
    }
} 