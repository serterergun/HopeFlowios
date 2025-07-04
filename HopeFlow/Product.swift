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
    let price: String?
    var isFavorite: Bool?
    let image_url: String?
    let location: String?
    let latitude: String?
    let longitude: String?
    let created_at: String?
    let user_info: UserInfo?
    let listing_photos: [ListingPhotoResponse]?
    let is_available: Bool?
    var is_in_basket: Bool?
    
    // Computed property to get price as Double
    var priceAsDouble: Double? {
        guard let price = price else { return nil }
        return Double(price)
    }
    
    // Computed properties to get coordinates as Double
    var latitudeAsDouble: Double? {
        guard let latitude = latitude else { return nil }
        return Double(latitude)
    }
    
    var longitudeAsDouble: Double? {
        guard let longitude = longitude else { return nil }
        return Double(longitude)
    }
} 