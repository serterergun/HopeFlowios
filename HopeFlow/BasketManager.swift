import Foundation

class BasketManager {
    static let shared = BasketManager()
    
    private var currentBasket: BasketResponse?
    private var basketItems: [BasketItemWithProduct] = []
    
    private init() {}
    
    // MARK: - Basket Management
    
    func getOrCreateBasket() async throws -> BasketResponse {
        if let existingBasket = currentBasket {
            return existingBasket
        }
        
        // Use the new API endpoint to get or create basket
        let basket = try await NetworkManager.shared.getOrCreateBasket()
        currentBasket = basket
        return basket
    }
    
    func addItemToBasket(listingId: Int) async throws -> BasketItemResponse {
        // Sepette aynı ürün var mı kontrolü
        if basketItems.contains(where: { $0.listing_id == listingId }) {
            throw NetworkError.serverError("This product is already in your basket.")
        }
        let basket = try await getOrCreateBasket()
        let basketItem = try await NetworkManager.shared.addItemToBasket(basketId: basket.id, listingId: listingId)
        
        // Refresh basket items after adding
        await refreshBasketItems()
        
        // Notify that basket was updated
        NotificationCenter.default.post(name: .basketDidUpdate, object: nil)
        
        return basketItem
    }
    
    func removeItemFromBasket(itemId: Int) async throws {
        guard let basket = currentBasket else {
            throw NetworkError.serverError("No active basket")
        }
        
        try await NetworkManager.shared.removeItemFromBasket(basketId: basket.id, itemId: itemId)
        
        // Remove from local array
        basketItems.removeAll { $0.id == itemId }
        
        // Notify that basket was updated
        NotificationCenter.default.post(name: .basketDidUpdate, object: nil)
    }
    
    func refreshBasketItems() async {
        do {
            let items = try await NetworkManager.shared.getBasketItemsWithProducts()
            basketItems = items
            
            // Notify that basket was updated
            NotificationCenter.default.post(name: .basketDidUpdate, object: nil)
        } catch {
            print("Failed to refresh basket items: \(error)")
            basketItems = []
        }
    }
    
    func clearBasket() {
        currentBasket = nil
        basketItems.removeAll()
        
        // Notify that basket was updated
        NotificationCenter.default.post(name: .basketDidUpdate, object: nil)
    }
    
    // MARK: - Getters
    
    func getCurrentBasket() -> BasketResponse? {
        return currentBasket
    }
    
    func getBasketItems() -> [BasketItemWithProduct] {
        return basketItems
    }
    
    func getBasketItemCount() -> Int {
        return basketItems.count
    }
}

// Notification.Name extension
extension Notification.Name {
    static let basketDidUpdate = Notification.Name("basketDidUpdate")
} 