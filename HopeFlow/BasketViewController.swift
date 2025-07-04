import UIKit

class BasketViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var basketItems: [BasketItemWithProduct] = []
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cart")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Your basket is empty"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Add some items to get started"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let browseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Browse Items", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(BasketItemCell.self, forCellWithReuseIdentifier: "BasketItemCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Checkout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basket"
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        setupNotifications()
        loadBasketItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBasketItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove notification observers when view disappears
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        // Empty state
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateView.addSubview(emptyStateSubtitle)
        emptyStateView.addSubview(browseButton)
        
        // Collection view
        view.addSubview(collectionView)
        
        // Checkout button
        view.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            // Empty state
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            browseButton.topAnchor.constraint(equalTo: emptyStateSubtitle.bottomAnchor, constant: 24),
            browseButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            browseButton.widthAnchor.constraint(equalToConstant: 160),
            browseButton.heightAnchor.constraint(equalToConstant: 44),
            browseButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor, constant: -16),
            
            // Checkout button
            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        browseButton.addTarget(self, action: #selector(browseButtonTapped), for: .touchUpInside)
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)
    }
    
    private func setupNotifications() {
        // Listen for basket updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(basketDidUpdate),
            name: .basketDidUpdate,
            object: nil
        )
    }
    
    @objc private func basketDidUpdate() {
        // Refresh basket items when notification is received
        loadBasketItems()
    }
    
    private func loadBasketItems() {
        print("DEBUG: loadBasketItems called")
        
        // Check if user is logged in
        guard AuthManager.shared.isLoggedIn else {
            print("DEBUG: User not logged in")
            basketItems = []
            updateUI()
            return
        }
        
        print("DEBUG: User is logged in, loading basket items")
        
        Task {
            do {
                // Get or create basket using the new method
                let basket = try await BasketManager.shared.getOrCreateBasket()
                print("DEBUG: Got basket: \(basket)")
                
                // Load basket items with product details (basket_item tablosundan)
                let items = try await NetworkManager.shared.getBasketItemsWithProducts()
                print("DEBUG: Got basket items: \(items.count) items")
                
                // Sepetteki tüm ürünleri göster (filtreleme yok)
                await MainActor.run {
                    self.basketItems = items
                    print("DEBUG: Updated basketItems array with \(items.count) items")
                    self.updateUI()
                }
            } catch {
                await MainActor.run {
                    print("DEBUG: Failed to load basket: \(error)")
                    self.basketItems = []
                    self.updateUI()
                }
            }
        }
    }
    
    private func updateUI() {
        print("DEBUG: updateUI called with \(basketItems.count) items")
        
        if basketItems.isEmpty {
            print("DEBUG: Showing empty state")
            emptyStateView.isHidden = false
            collectionView.isHidden = true
            checkoutButton.isHidden = true
        } else {
            print("DEBUG: Showing basket items")
            emptyStateView.isHidden = true
            collectionView.isHidden = false
            checkoutButton.isHidden = false
            collectionView.reloadData()
        }
    }
    
    @objc private func browseButtonTapped() {
        if let tabBarController = tabBarController {
            tabBarController.selectedIndex = 0 // Switch to Home tab
        }
    }
    
    @objc private func checkoutButtonTapped() {
        // TODO: Implement checkout functionality
        let alert = UIAlertController(title: "Checkout", message: "Checkout functionality will be implemented soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DEBUG: numberOfItemsInSection called, returning \(basketItems.count)")
        return basketItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("DEBUG: cellForItemAt called for index \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasketItemCell", for: indexPath) as! BasketItemCell
        let basketItem = basketItems[indexPath.item]
        print("DEBUG: Configuring cell with product: \(basketItem.listing.title ?? "nil")")
        cell.configure(with: basketItem.listing)
        cell.removeButton.tag = indexPath.item
        cell.removeButton.addTarget(self, action: #selector(removeItemTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32 // 16pt padding on each side
        return CGSize(width: width, height: 120)
    }
    
    // MARK: - Actions
    
    @objc private func removeItemTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < basketItems.count else { return }
        
        let alert = UIAlertController(title: "Remove Item", message: "Are you sure you want to remove this item from your basket?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let basketItem = self.basketItems[index]
            
            Task {
                do {
                    try await BasketManager.shared.removeItemFromBasket(itemId: basketItem.id)
                    await MainActor.run {
                        self.basketItems.remove(at: index)
                        self.updateUI()
                    }
                } catch {
                    await MainActor.run {
                        let alert = UIAlertController(title: "Error", message: "Failed to remove item from basket", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - BasketItemCell

class BasketItemCell: UICollectionViewCell {
    
    private var currentImagePath: String?
    private var imageLoadTask: Task<Void, Never>?
    private var imageLoadToken: UUID?
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(removeButton)
        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            removeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 32),
            removeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with product: Product) {
        var product = product
        // Eğer image_url yoksa ve listing_photos varsa, image_url'u ilk fotoğraf path'i ile doldur
        if (product.image_url == nil || product.image_url?.isEmpty == true),
           let photos = product.listing_photos, let firstPhoto = photos.first {
            product = Product(
                id: product.id,
                title: product.title,
                description: product.description,
                user_id: product.user_id,
                category_id: product.category_id,
                price: product.price,
                isFavorite: product.isFavorite,
                image_url: firstPhoto.path, // image_url'u set et
                location: product.location,
                latitude: product.latitude,
                longitude: product.longitude,
                created_at: product.created_at,
                user_info: product.user_info,
                listing_photos: product.listing_photos,
                is_available: product.is_available,
                is_in_basket: product.is_in_basket
            )
        }
        titleLabel.text = product.title
        priceLabel.text = "£\(product.priceAsDouble ?? 0)"
        titleLabel.textColor = .label
        priceLabel.textColor = .systemGreen
        contentView.alpha = 1.0
        
        // Debug: Print product info
        print("🔍 Configuring BasketItemCell:")
        print("   - Product ID: \(product.id?.description ?? "nil")")
        print("   - Title: \(product.title ?? "nil")")
        print("   - Image URL: \(product.image_url ?? "nil")")
        print("   - Listing Photos: \(product.listing_photos?.count ?? 0)")
        
        // Reset image view
        productImageView.image = nil
        productImageView.backgroundColor = UIColor.systemGray6
        currentImagePath = nil
        imageLoadTask?.cancel()
        let token = UUID()
        imageLoadToken = token
        
        // Home ekranındaki mantıkla aynı şekilde yükle
        if let imageUrl = product.image_url, !imageUrl.isEmpty {
            print("   - Loading image from: \(imageUrl)")
            let fullUrl: URL?
            if imageUrl.hasPrefix("http") {
                fullUrl = URL(string: imageUrl)
            } else {
                let constructedUrl = "\(NetworkManager.shared.baseURL)\(imageUrl)"
                fullUrl = URL(string: constructedUrl)
            }
            if let url = fullUrl {
                print("   - Final URL: \(String(describing: url))")
                imageLoadTask = Task { [weak self] in
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        await MainActor.run {
                            guard self?.imageLoadToken == token else { return }
                            if let image = UIImage(data: data) {
                                print("   - ✅ Image loaded successfully")
                                self?.productImageView.image = image
                                self?.productImageView.backgroundColor = .clear
                            } else {
                                print("   - ❌ Image data invalid")
                                self?.showPlaceholderImage()
                            }
                        }
                    } catch {
                        await MainActor.run {
                            guard self?.imageLoadToken == token else { return }
                            print("   - ❌ Image loading failed: \(error.localizedDescription)")
                            self?.showPlaceholderImage()
                        }
                    }
                }
            } else {
                print("   - ❌ Invalid constructed URL: \(imageUrl)")
                showPlaceholderImage()
            }
        } else if let id = product.id {
            // image_url ve listing_photos yoksa, API'den çek
            print("   - No image_url or listing_photos, fetching from API for listing_id: \(id)")
            imageLoadTask = Task { [weak self] in
                do {
                    let photos = try await NetworkManager.shared.fetchListingPhotos(listingId: id)
                    if let firstPhoto = photos.first {
                        print("   - Got photo from API for listing_id \(id): \(firstPhoto.path) (photo.listing_id: \(firstPhoto.listing_id))")
                        let path = firstPhoto.path
                        let fullUrl: URL?
                        if path.hasPrefix("http") {
                            fullUrl = URL(string: path)
                        } else {
                            let constructedUrl = "\(NetworkManager.shared.baseURL)\(path)"
                            fullUrl = URL(string: constructedUrl)
                        }
                        if let url = fullUrl {
                            print("   - Final URL: \(String(describing: url))")
                            do {
                                let (data, _) = try await URLSession.shared.data(from: url)
                                await MainActor.run {
                                    guard self?.imageLoadToken == token else { return }
                                    if let image = UIImage(data: data) {
                                        print("   - ✅ Image loaded successfully")
                                        self?.productImageView.image = image
                                        self?.productImageView.backgroundColor = .clear
                                    } else {
                                        print("   - ❌ Image data invalid")
                                        self?.showPlaceholderImage()
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    guard self?.imageLoadToken == token else { return }
                                    print("   - ❌ Image loading failed: \(error.localizedDescription)")
                                    self?.showPlaceholderImage()
                                }
                            }
                        } else {
                            print("   - ❌ Invalid constructed URL: \(path)")
                            await MainActor.run { self?.showPlaceholderImage() }
                        }
                    } else {
                        print("   - ❌ No valid image URL available (API'den de gelmedi)")
                        await MainActor.run { self?.showPlaceholderImage() }
                    }
                } catch {
                    print("   - ❌ Failed to fetch listing photos for listing_id \(id): \(error)")
                    await MainActor.run { self?.showPlaceholderImage() }
                }
            }
        } else {
            print("   - ❌ No valid image URL available")
            showPlaceholderImage()
        }
    }
    
    private func showPlaceholderImage() {
        productImageView.image = UIImage(systemName: "photo")
        productImageView.tintColor = .systemGray3
        productImageView.backgroundColor = .systemGray6
    }
} 