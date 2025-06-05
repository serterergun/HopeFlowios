import Foundation

struct User: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
    let profilePhotoUrl: String?
    
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profilePhotoUrl = "profile_photo_url"
    }
} 