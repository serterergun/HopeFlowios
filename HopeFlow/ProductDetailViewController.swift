import UIKit

class ProductDetailViewController: UIViewController {
    private var product: Product
    private var allPhotos: [ListingPhotoResponse] = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Photo gallery
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(DetailPhotoCell.self, forCellWithReuseIdentifier: "DetailPhotoCell")
        cv.isPagingEnabled = true
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.hidesForSinglePage = true
        pc.pageIndicatorTintColor = .systemGray3
        pc.currentPageIndicatorTintColor = .black
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .systemPurple
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addBasketButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Basket", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 24
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Message", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await BasketManager.shared.refreshBasketItems()
            checkProductAvailabilityAndLoadPhotos()
        }
    }
    
    private func checkProductAvailabilityAndLoadPhotos() {
        guard let id = product.id else {
            setupUI()
            configureWithProduct()
            return
        }
        Task {
            do {
                // API: /basket-items/check-product?product_id=xxx
                let urlString = "\(NetworkManager.shared.baseURL)/api/v1/basket-items/check-product?product_id=\(id)"
                guard let url = URL(string: urlString) else {
                    await MainActor.run {
                        self.setupUI()
                        self.configureWithProduct()
                    }
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = AuthManager.shared.token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    await MainActor.run {
                        self.setupUI()
                        self.configureWithProduct()
                    }
                    return
                }
                struct ProductAvailabilityResponse: Decodable {
                    let product_id: Int
                    let is_in_basket: Bool
                    let is_available: Bool
                }
                let availability = try JSONDecoder().decode(ProductAvailabilityResponse.self, from: data)
                self.product = Product(
                    id: self.product.id,
                    title: self.product.title,
                    description: self.product.description,
                    user_id: self.product.user_id,
                    category_id: self.product.category_id,
                    price: self.product.price,
                    isFavorite: self.product.isFavorite,
                    image_url: self.product.image_url,
                    location: self.product.location,
                    latitude: self.product.latitude,
                    longitude: self.product.longitude,
                    created_at: self.product.created_at,
                    user_info: self.product.user_info,
                    listing_photos: self.product.listing_photos,
                    is_available: availability.is_available
                )
                // Sonra fotoğrafları yükle
                let photos = try await NetworkManager.shared.fetchListingPhotos(listingId: id)
                let filtered = photos.filter { $0.listing_id == id }
                await MainActor.run {
                    self.allPhotos = filtered
                    self.setupUI()
                    self.configureWithProduct()
                }
            } catch {
                await MainActor.run {
                    self.setupUI()
                    self.configureWithProduct()
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(photosCollectionView)
        contentView.addSubview(pageControl)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(ownerNameLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addBasketButton)
        contentView.addSubview(sendMessageButton)
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            photosCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            photosCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 300),
            pageControl.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ownerNameLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            ownerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.topAnchor.constraint(equalTo: ownerNameLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addBasketButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            addBasketButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addBasketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addBasketButton.heightAnchor.constraint(equalToConstant: 48),
            sendMessageButton.topAnchor.constraint(equalTo: addBasketButton.bottomAnchor, constant: 12),
            sendMessageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sendMessageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sendMessageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        addBasketButton.addTarget(self, action: #selector(addBasketButtonTapped), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        // Set item size to full width
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.bounds.width, height: 300)
        }
        pageControl.numberOfPages = allPhotos.count > 0 ? allPhotos.count : (product.image_url != nil ? 1 : 0)
        pageControl.currentPage = 0
    }
    
    private func configureWithProduct() {
        titleLabel.text = product.title
        priceLabel.text = "£\(product.priceAsDouble ?? 0)"
        ownerNameLabel.text = "\(product.user_info?.first_name ?? "") \(product.user_info?.last_name_initial ?? "")"
        locationLabel.text = product.location
        descriptionLabel.text = product.description
        
        // Update button state based on availability
        if let isAvailable = product.is_available {
            if isAvailable {
                addBasketButton.setTitle("Add to Basket", for: .normal)
                addBasketButton.backgroundColor = .systemBlue
                addBasketButton.isEnabled = true
            } else {
                addBasketButton.setTitle("Not Available", for: .normal)
                addBasketButton.backgroundColor = .systemGray
                addBasketButton.isEnabled = false
            }
        }
        
        photosCollectionView.reloadData()
    }
    
    @objc private func addBasketButtonTapped() {
        // Check if user is logged in
        guard AuthManager.shared.isLoggedIn else {
            let alert = UIAlertController(title: "Login Required", message: "Please login to add items to your basket", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }

        guard let listingId = product.id else {
            let alert = UIAlertController(title: "Error", message: "Product information is incomplete", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // LOCAL: Sepette var mı kontrolü
        let basketItems = BasketManager.shared.getBasketItems()
        if basketItems.contains(where: { $0.listing_id == listingId }) {
            let alert = UIAlertController(title: "Already in Basket", message: "This product is already in your basket.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Checking Availability...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)

        Task {
            do {
                // Ürünün güncel durumunu kontrol et
                let urlString = "\(NetworkManager.shared.baseURL)/api/v1/basket-items/check-product?product_id=\(listingId)"
                guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = AuthManager.shared.token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 404 {
                        // Ürün sepette yok, sepete ekle
                        let _ = try await BasketManager.shared.addItemToBasket(listingId: listingId)
                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) {
                                let alert = UIAlertController(title: "Added to Basket", message: "Item has been added to your basket!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "View Basket", style: .default) { _ in
                                    if let tabBarController = self.tabBarController {
                                        tabBarController.selectedIndex = 1 // Switch to Basket tab
                                    }
                                })
                                alert.addAction(UIAlertAction(title: "Continue Shopping", style: .cancel))
                                self.present(alert, animated: true)
                            }
                        }
                        return
                    } else if !(200...299).contains(httpResponse.statusCode) {
                    throw NetworkError.invalidResponse
                    }
                }
                struct ProductAvailabilityResponse: Decodable {
                    let product_id: Int
                    let is_in_basket: Bool
                    let is_available: Bool
                }
                let availability = try JSONDecoder().decode(ProductAvailabilityResponse.self, from: data)
                if !availability.is_available {
                    await MainActor.run {
                        loadingAlert.dismiss(animated: true) {
                            let alert = UIAlertController(title: "Item Not Available", message: "This item is no longer available.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                    return
                }

                // Ürün müsait, sepete ekle
                let _ = try await BasketManager.shared.addItemToBasket(listingId: listingId)
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Added to Basket", message: "Item has been added to your basket!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "View Basket", style: .default) { _ in
                            if let tabBarController = self.tabBarController {
                                tabBarController.selectedIndex = 1 // Switch to Basket tab
                            }
                        })
                        alert.addAction(UIAlertAction(title: "Continue Shopping", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        var message = error.localizedDescription
                        if let netError = error as? NetworkError {
                            switch netError {
                            case .serverError(let msg):
                                message = msg
                            default: break
                            }
                        }
                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func sendMessageButtonTapped() {
        // Check if user is logged in
        guard AuthManager.shared.isLoggedIn else {
            let alert = UIAlertController(title: "Login Required", message: "Please login to send messages", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        // TODO: Implement message functionality
        // For now, show placeholder
        let alert = UIAlertController(title: "Send Message", message: "Message functionality will be implemented soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Photo Gallery CollectionView

extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count > 0 ? allPhotos.count : (product.image_url != nil ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailPhotoCell", for: indexPath) as! DetailPhotoCell
        var imageUrl: String?
        if allPhotos.count > 0, indexPath.item < allPhotos.count {
            let path = allPhotos[indexPath.item].path
            if path.hasPrefix("http") {
                imageUrl = path
            } else {
                imageUrl = "\(NetworkManager.shared.baseURL)\(path)"
            }
        } else if let url = product.image_url {
            imageUrl = url
        }
        cell.setImage(with: imageUrl)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photosCollectionView {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            pageControl.currentPage = page
        }
    }
}

class DetailPhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func setImage(with urlString: String?) {
        imageView.image = nil
        imageView.backgroundColor = UIColor.homeCardBackground
        guard let urlString = urlString, !urlString.isEmpty else {
            showPlaceholderImage()
            return
        }
        let fullUrl: URL?
        if urlString.hasPrefix("http") {
            fullUrl = URL(string: urlString)
        } else {
            let constructedUrl = "\(NetworkManager.shared.baseURL)\(urlString)"
            fullUrl = URL(string: constructedUrl)
        }
        guard let url = fullUrl else {
            showPlaceholderImage()
            return
        }
        imageView.backgroundColor = UIColor.systemGray6
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self?.imageView.image = image
                    self?.imageView.backgroundColor = .clear
                } else {
                    self?.showPlaceholderImage()
                }
            }
        }.resume()
    }
    private func showPlaceholderImage() {
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = UIColor.homeSecondary
        imageView.backgroundColor = UIColor.homeCardBackground
    }
} 