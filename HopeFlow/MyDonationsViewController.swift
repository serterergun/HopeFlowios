import UIKit

class MyDonationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var products: [Product] = []

    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(MyDonationCell.self, forCellWithReuseIdentifier: "MyDonationCell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .homeBackground
        title = "My Donations"
        setupCollectionView()
        fetchMyDonations()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchMyDonations() {
        guard let userId = AuthManager.shared.currentUser?.id else {
            dismiss(animated: true)
            return
        }
        Task {
            do {
                let products = try await NetworkManager.shared.fetchListingsByUser(userId: userId)
                self.products = products
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to fetch donations: \(error)")
            }
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(240))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

            // Group (2 items per row)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(260))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            group.interItemSpacing = .fixed(0)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 8, bottom: 32, trailing: 8)
            section.interGroupSpacing = 16

            return section
        }
    }

    // MARK: - Collection View Delegate/DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyDonationCell", for: indexPath) as! MyDonationCell
        let product = products[indexPath.item]
        cell.configure(with: product)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        showEditOptions(for: product)
    }

    private func showEditOptions(for product: Product) {
        let alert = UIAlertController(title: "Edit Donation", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit Details", style: .default) { [weak self] _ in
            self?.editProduct(product)
        })
        
        alert.addAction(UIAlertAction(title: "Delete Donation", style: .destructive) { [weak self] _ in
            self?.deleteProduct(product)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    private func editProduct(_ product: Product) {
        // Navigate to edit product screen
        let editVC = EditProductViewController(product: product)
        editVC.onProductUpdated = { [weak self] in
            self?.fetchMyDonations() // Refresh the list
        }
        let navVC = UINavigationController(rootViewController: editVC)
        present(navVC, animated: true)
    }

    private func deleteProduct(_ product: Product) {
        let confirmAlert = UIAlertController(title: "Delete Donation", message: "Are you sure you want to delete this donation?", preferredStyle: .alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(product)
        })
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(confirmAlert, animated: true)
    }

    private func performDelete(_ product: Product) {
        guard let productId = product.id else { return }
        
        Task {
            do {
                try await NetworkManager.shared.deleteListing(id: productId)
                DispatchQueue.main.async {
                    self.fetchMyDonations() // Refresh the list
                }
            } catch {
                DispatchQueue.main.async {
                    let errorAlert = UIAlertController(title: "Error", message: "Failed to delete donation: \(error.localizedDescription)", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
}

// MARK: - MyDonationCell

class MyDonationCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .homePrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .homeAccent
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.homeCardBackground
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "£\(product.priceAsDouble ?? 0)"
        
        // Reset image view
        productImageView.image = nil
        productImageView.backgroundColor = UIColor.homeCardBackground
        
        // Load product image if available
        if let imageUrl = product.image_url, !imageUrl.isEmpty {
            // Handle both local file paths and full URLs
            let fullUrl: URL
            if imageUrl.hasPrefix("http") {
                // Full URL (S3 or external)
                guard let url = URL(string: imageUrl) else {
                    showPlaceholderImage()
                    return
                }
                fullUrl = url
            } else {
                // Local file path - construct full URL
                let constructedUrl = "\(NetworkManager.shared.baseURL)\(imageUrl)"
                guard let url = URL(string: constructedUrl) else {
                    showPlaceholderImage()
                    return
                }
                fullUrl = url
            }
            
            // Show loading state
            productImageView.backgroundColor = UIColor.systemGray6
            
            URLSession.shared.dataTask(with: fullUrl) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.productImageView.image = image
                        self?.productImageView.backgroundColor = .clear
                    } else {
                        self?.showPlaceholderImage()
                    }
                }
            }.resume()
        } else {
            showPlaceholderImage()
        }
    }
    
    private func showPlaceholderImage() {
        productImageView.image = UIImage(systemName: "photo")
        productImageView.tintColor = UIColor.homeSecondary
        productImageView.backgroundColor = UIColor.homeCardBackground
    }
} 