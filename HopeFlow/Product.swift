import Foundation

struct UserInfo: Codable {
    let first_name: String?
    let last_name_initial: String?
}

struct Product: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let user_id: Int?
    let category_id: Int?
    let given_price: String?
    var isFavorite: Bool?
    let image_url: String?
    let location: String?
    let created_at: String?
    let updated_at: String?
    let user_info: UserInfo?
    
    // Computed property to get given_price as Double
    var givenPriceAsDouble: Double? {
        guard let priceString = given_price else { return nil }
        return Double(priceString)
    }
} 