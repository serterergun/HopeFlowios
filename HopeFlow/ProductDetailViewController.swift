import UIKit

class ProductDetailViewController: UIViewController {
    private var product: Product
    private var allPhotos: [ListingPhotoResponse] = []
    private var isLoadingPhotos = false
    private var isUISetup = false // Prevent multiple UI setup calls
    var canMessageSeller: Bool = false // Satın alma kontrolü (şimdilik manuel)
    
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
    
    // Photo gallery - Amazon style
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(DetailPhotoCell.self, forCellWithReuseIdentifier: "DetailPhotoCell")
        cv.isPagingEnabled = true
        cv.bounces = false
        cv.decelerationRate = UIScrollView.DecelerationRate.fast
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.hidesForSinglePage = true
        pc.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pc.currentPageIndicatorTintColor = .black
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let photoCounterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let photoCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let photoLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
    
    private let galleryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.up")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Satıcıya Mesaj Gönder", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Başta gizli
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
        print("[DEBUG] ProductDetailViewController viewDidLoad, product id: \(product.id ?? -1)")
        
        // Setup UI first
        setupUI()
        configureWithProduct()
        
        // Then load data
        Task { [weak self] in
            await BasketManager.shared.refreshBasketItems()
            if let id = self?.product.id {
                await self?.loadAllProductPhotos(listingId: id)
            }
            await self?.checkProductAvailabilityAndLoadPhotos()
        }
        setupMessageButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("[DEBUG] photosCollectionView frame: \(photosCollectionView.frame)")
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = galleryContainer.bounds.width > 32 ? galleryContainer.bounds.width - 32 : UIScreen.main.bounds.width - 64
            layout.itemSize = CGSize(width: width, height: 220)
        }
    }
    
    private func checkProductAvailabilityAndLoadPhotos() async {
        guard let id = product.id else {
            await MainActor.run {
                self.updatePhotoGallery()
            }
            return
        }
        isLoadingPhotos = true
        do {
            // Sadece listing tablosunda ürün var mı kontrol et
            let listingUrl = "\(NetworkManager.shared.baseURL)/api/v1/listings/\(id)"
            guard let url = URL(string: listingUrl) else {
                await MainActor.run {
                    self.updatePhotoGallery()
                }
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = AuthManager.shared.token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error", message: "Product not found.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                return
            }
            await MainActor.run {
                self.updatePhotoGallery()
            }
        } catch {
            await MainActor.run {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func loadAllProductPhotos(listingId: Int) async {
        print("[DEBUG] loadAllProductPhotos called with listingId: \(listingId)")
        do {
            let photos = try await NetworkManager.shared.fetchListingPhotos(listingId: listingId)
            print("[DEBUG] API'den gelen photo count: \(photos.count)")
            await MainActor.run { [weak self] in
                self?.allPhotos = photos
                self?.updatePhotoGallery()
            }
        } catch {
            print("Error loading photos: \(error)")
            await MainActor.run { [weak self] in
                self?.updatePhotoGallery()
            }
        }
    }
    
    private func setupUI() {
        guard !isUISetup else { return }
        isUISetup = true
        
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Galeri container'ı ekle
        contentView.addSubview(galleryContainer)
        galleryContainer.addSubview(photosCollectionView)
        galleryContainer.addSubview(pageControl)
        galleryContainer.addSubview(photoCounterView)
        photoCounterView.addSubview(photoCountLabel)
        galleryContainer.addSubview(photoLoadingIndicator)
        
        // Favori ve paylaş butonları
        galleryContainer.addSubview(favoriteButton)
        galleryContainer.addSubview(shareButton)
        
        // Diğer alanlar
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
            
            // Galeri container üstte, kenarlardan boşluklu ve yüksekliği 320
            galleryContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            galleryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            galleryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            galleryContainer.heightAnchor.constraint(equalToConstant: 320),
            
            // Fotoğraf galerisi container içinde, aspectFit ve paddingli
            photosCollectionView.topAnchor.constraint(equalTo: galleryContainer.topAnchor, constant: 16),
            photosCollectionView.leadingAnchor.constraint(equalTo: galleryContainer.leadingAnchor, constant: 16),
            photosCollectionView.trailingAnchor.constraint(equalTo: galleryContainer.trailingAnchor, constant: -16),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 220),
            
            // PageControl ortada ve alt boşluklu
            pageControl.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: galleryContainer.centerXAnchor),
            
            // Sayaç sağ üstte
            photoCounterView.topAnchor.constraint(equalTo: galleryContainer.topAnchor, constant: 16),
            photoCounterView.trailingAnchor.constraint(equalTo: galleryContainer.trailingAnchor, constant: -16),
            photoCounterView.heightAnchor.constraint(equalToConstant: 24),
            photoCounterView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            photoCountLabel.topAnchor.constraint(equalTo: photoCounterView.topAnchor, constant: 4),
            photoCountLabel.bottomAnchor.constraint(equalTo: photoCounterView.bottomAnchor, constant: -4),
            photoCountLabel.leadingAnchor.constraint(equalTo: photoCounterView.leadingAnchor, constant: 8),
            photoCountLabel.trailingAnchor.constraint(equalTo: photoCounterView.trailingAnchor, constant: -8),
            
            // Favori ve paylaş butonları alt kısımda, sağ ve solda
            favoriteButton.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: -8),
            favoriteButton.leadingAnchor.constraint(equalTo: galleryContainer.leadingAnchor, constant: 24),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            shareButton.bottomAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: -8),
            shareButton.trailingAnchor.constraint(equalTo: galleryContainer.trailingAnchor, constant: -24),
            shareButton.widthAnchor.constraint(equalToConstant: 32),
            shareButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Yükleniyor göstergesi ortada
            photoLoadingIndicator.centerXAnchor.constraint(equalTo: photosCollectionView.centerXAnchor),
            photoLoadingIndicator.centerYAnchor.constraint(equalTo: photosCollectionView.centerYAnchor),
            
            // Diğer alanlar galeri container'ın altında
            titleLabel.topAnchor.constraint(equalTo: galleryContainer.bottomAnchor, constant: 24),
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
            
            addBasketButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            addBasketButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addBasketButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addBasketButton.heightAnchor.constraint(equalToConstant: 48),
            
            sendMessageButton.topAnchor.constraint(equalTo: addBasketButton.bottomAnchor, constant: 16),
            sendMessageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sendMessageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 48),
            sendMessageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
        
        addBasketButton.addTarget(self, action: #selector(addBasketButtonTapped), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        
        pageControl.numberOfPages = allPhotos.count > 0 ? allPhotos.count : (product.image_url != nil ? 1 : 0)
        pageControl.currentPage = 0
        updatePhotoCounter()
        photoLoadingIndicator.startAnimating()
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
        
        // Update photo gallery
        updatePhotoGallery()
        photoLoadingIndicator.stopAnimating()
        isLoadingPhotos = false
    }
    
    private func updatePhotoGallery() {
        let totalPhotos = allPhotos.count
        
        // Update page control
        pageControl.numberOfPages = totalPhotos
        pageControl.currentPage = 0
        
        // Update photo counter
        updatePhotoCounter()
        
        // Reload collection view
        photosCollectionView.reloadData()
        
        // Reset scroll position
        if totalPhotos > 0 {
            photosCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    private func updatePhotoCounter() {
        let totalPhotos = allPhotos.count
        
        if totalPhotos > 1 {
            photoCountLabel.text = "1 of \(totalPhotos)"
            photoCounterView.isHidden = false
        } else {
            photoCounterView.isHidden = true
        }
    }
    
    @objc private func addBasketButtonTapped() {
        // Check if user is logged in
        guard AuthManager.shared.isLoggedIn else {
            let alert = UIAlertController(title: "Login Required", message: "Please login to add items to your basket", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { [weak self] _ in
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self?.present(loginVC, animated: true)
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
        let loadingAlert = UIAlertController(title: "Adding to Basket...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)

        Task { [weak self] in
            do {
                // 1. Ürün listing tablosunda var mı?
                let listingUrl = "\(NetworkManager.shared.baseURL)/api/v1/listings/\(listingId)"
                guard let url = URL(string: listingUrl) else { throw NetworkError.invalidURL }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = AuthManager.shared.token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                let (_, listingResponse) = try await URLSession.shared.data(for: request)
                if let httpResponse = listingResponse as? HTTPURLResponse, httpResponse.statusCode == 404 {
                    await MainActor.run {
                        loadingAlert.dismiss(animated: true) {
                            let alert = UIAlertController(title: "Error", message: "Product not found.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(alert, animated: true)
                        }
                    }
                    return
                }

                // 2. Sepete ekle (yeni endpoint ile)
                let _ = try await NetworkManager.shared.addItemToBasketNew(listingId: listingId)
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Added to Basket", message: "Item has been added to your basket!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "View Basket", style: .default) { [weak self] _ in
                            if let tabBarController = self?.tabBarController {
                                tabBarController.selectedIndex = 1
                            }
                        })
                        alert.addAction(UIAlertAction(title: "Continue Shopping", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func sendMessageButtonTapped() {
        // Check if user is logged in
        guard AuthManager.shared.isLoggedIn else {
            let alert = UIAlertController(title: "Login Required", message: "Please login to send messages", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { [weak self] _ in
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self?.present(loginVC, animated: true)
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

    private func setupMessageButton() {
        view.addSubview(messageButton)
        NSLayoutConstraint.activate([
            messageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            messageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            messageButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        messageButton.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        messageButton.isHidden = !canMessageSeller
    }

    @objc private func messageButtonTapped() {
        let messageVC = MessageComposeViewController(listingId: product.id)
        messageVC.modalPresentationStyle = .formSheet
        present(messageVC, animated: true)
    }
}

// MARK: - Photo Gallery CollectionView

extension ProductDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("[DEBUG] cellForItemAt çağrıldı, index: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailPhotoCell", for: indexPath) as! DetailPhotoCell
        var imageUrl: String?
        if allPhotos.count > 0, indexPath.item < allPhotos.count {
            let photo = allPhotos[indexPath.item]
            let path = photo.path
            if path.hasPrefix("http") {
                imageUrl = path
            } else {
                imageUrl = "\(NetworkManager.shared.baseURL)\(path)"
            }
        }
        cell.setImage(with: imageUrl, photoInfo: nil)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == photosCollectionView {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            pageControl.currentPage = page
            // Fotoğraf sayacı sadece birden fazla fotoğraf varsa gösterilsin
            if allPhotos.count > 1 {
                photoCountLabel.text = "\(page + 1) of \(allPhotos.count)"
                photoCounterView.isHidden = false
            } else {
                photoCounterView.isHidden = true
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == photosCollectionView {
            let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
            pageControl.currentPage = page
            if allPhotos.count > 1 {
                photoCountLabel.text = "\(page + 1) of \(allPhotos.count)"
                photoCounterView.isHidden = false
            } else {
                photoCounterView.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Show photo in full screen when tapped
        showPhotoInFullScreen(at: indexPath.item)
    }
    
    private func showPhotoInFullScreen(at index: Int) {
        let fullScreenVC = FullScreenPhotoViewController(photos: allPhotos, product: product, initialIndex: index)
        fullScreenVC.modalPresentationStyle = .fullScreen
        present(fullScreenVC, animated: true)
    }
}

class DetailPhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .systemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let photoInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(photoInfoLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            photoInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            photoInfoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoInfoLabel.heightAnchor.constraint(equalToConstant: 20),
            photoInfoLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -16)
        ])
        
        // Add tap gesture for better UX
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        // This will trigger the collection view's didSelectItemAt
        if let collectionView = superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    func setImage(with urlString: String?, photoInfo: String? = nil) {
        imageView.image = nil
        loadingIndicator.startAnimating()
        photoInfoLabel.isHidden = true
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
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                if let data = data, let image = UIImage(data: data) {
                    self?.imageView.image = image
                } else {
                    self?.showPlaceholderImage()
                }
            }
        }.resume()
    }
    
    private func showPlaceholderImage() {
        loadingIndicator.stopAnimating()
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = UIColor.homeSecondary
        imageView.backgroundColor = UIColor.homeCardBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadingIndicator.stopAnimating()
        photoInfoLabel.isHidden = true
    }
} 