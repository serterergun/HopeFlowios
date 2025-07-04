import UIKit

class ProductCell: UICollectionViewCell {
    var favoriteAction: (() -> Void)?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .homePrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .homeSecondary
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
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .homeSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor.homeAccent
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = .homeSecondary
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
    
    let favoriteBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterialDark)
        let v = UIVisualEffectView(effect: blur)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.layer.cornerRadius = 0
        button.clipsToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    let distanceContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.7)
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let distanceIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.tintColor = .white
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 0
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.60)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 4
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()
    
    let inBasketContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let inBasketLabel: UILabel = {
        let label = UILabel()
        label.text = "IN BASKET"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        // If the hit view is the favorite button or its blur view, return it
        if view == favoriteButton || view == favoriteBlurView {
            return view
        }
        
        // Check if the point is within the favorite button's frame
        let favoriteButtonFrame = favoriteButton.frame
        if favoriteButtonFrame.contains(point) {
            return favoriteButton
        }
        
        return view
    }
    
    private func setupUI() {
        contentView.addSubview(productImageView)
        productImageView.addSubview(overlayView)
        overlayView.addSubview(profileImageView)
        overlayView.addSubview(ownerNameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(locationLabel)
        productImageView.addSubview(favoriteBlurView)
        productImageView.addSubview(favoriteButton)
        productImageView.addSubview(distanceContainerView)
        distanceContainerView.addSubview(distanceIconView)
        distanceContainerView.addSubview(distanceLabel)
        contentView.addSubview(inBasketContainerView)
        inBasketContainerView.addSubview(inBasketLabel)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            overlayView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),
            overlayView.heightAnchor.constraint(equalToConstant: 36),
            
            profileImageView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            profileImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 24),
            profileImageView.heightAnchor.constraint(equalToConstant: 24),
            
            ownerNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            ownerNameLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            ownerNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor, constant: -8),
            
            favoriteBlurView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteBlurView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteBlurView.widthAnchor.constraint(equalToConstant: 32),
            favoriteBlurView.heightAnchor.constraint(equalToConstant: 32),
            favoriteButton.centerXAnchor.constraint(equalTo: favoriteBlurView.centerXAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: favoriteBlurView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            locationLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            distanceContainerView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -6),
            distanceContainerView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: -6),
            distanceContainerView.heightAnchor.constraint(equalToConstant: 24),
            distanceContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),
            
            distanceIconView.leadingAnchor.constraint(equalTo: distanceContainerView.leadingAnchor, constant: 8),
            distanceIconView.centerYAnchor.constraint(equalTo: distanceContainerView.centerYAnchor),
            distanceIconView.widthAnchor.constraint(equalToConstant: 14),
            distanceIconView.heightAnchor.constraint(equalToConstant: 14),
            
            distanceLabel.leadingAnchor.constraint(equalTo: distanceIconView.trailingAnchor, constant: 4),
            distanceLabel.trailingAnchor.constraint(equalTo: distanceContainerView.trailingAnchor, constant: -8),
            distanceLabel.centerYAnchor.constraint(equalTo: distanceContainerView.centerYAnchor, constant: 1),
            distanceLabel.heightAnchor.constraint(equalTo: distanceContainerView.heightAnchor),
            
            inBasketContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            inBasketContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            inBasketLabel.topAnchor.constraint(equalTo: inBasketContainerView.topAnchor, constant: 2),
            inBasketLabel.bottomAnchor.constraint(equalTo: inBasketContainerView.bottomAnchor, constant: -2),
            inBasketLabel.leadingAnchor.constraint(equalTo: inBasketContainerView.leadingAnchor, constant: 8),
            inBasketLabel.trailingAnchor.constraint(equalTo: inBasketContainerView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with product: Product, ownerName: String? = nil, favoriteAction: (() -> Void)? = nil, distanceString: String? = nil) {
        self.favoriteAction = favoriteAction
        
        titleLabel.text = product.title
        priceLabel.text = "£\(product.priceAsDouble ?? 0)"
        locationLabel.text = product.location
        
        // Debug: Print product info
        print("🔍 Configuring ProductCell:")
        print("   - Product ID: \(product.id?.description ?? "nil")")
        print("   - Title: \(product.title ?? "nil")")
        print("   - Image URL: \(product.image_url ?? "nil")")
        
        if let userInfo = product.user_info {
            ownerNameLabel.text = "\(userInfo.first_name ?? "") \(userInfo.last_name_initial ?? "")"
        } else {
            ownerNameLabel.text = ""
        }
        ownerNameLabel.textColor = .white
        ownerNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        ownerNameLabel.isHidden = false
        favoriteButton.isSelected = product.isFavorite ?? false
        
        // Update favorite button appearance
        updateFavoriteButtonAppearance()
        
        // Reset image view
        productImageView.image = nil
        productImageView.backgroundColor = UIColor.homeCardBackground
        
        // Load product image if available
        if let imageUrl = product.image_url, !imageUrl.isEmpty {
            print("   - Loading image from: \(imageUrl)")
            let fullUrl: URL?
            if imageUrl.hasPrefix("http") {
                guard let url = URL(string: imageUrl) else {
                    print("   - ❌ Invalid URL format: \(imageUrl)")
                    showPlaceholderImage()
                    return
                }
                fullUrl = url
            } else {
                // Local file path - construct full URL
                let constructedUrl = "\(NetworkManager.shared.baseURL)\(imageUrl)"
                guard let url = URL(string: constructedUrl) else {
                    print("   - ❌ Invalid constructed URL: \(constructedUrl)")
                    showPlaceholderImage()
                    return
                }
                fullUrl = url
            }
            
            print("   - Final URL: \(String(describing: fullUrl))")
            
            // Show loading state
            productImageView.backgroundColor = UIColor.systemGray6
            
            if let url = fullUrl {
                print("   - Final URL: \(url)")
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    DispatchQueue.main.async {
                        if let data = data, let image = UIImage(data: data) {
                            print("   - ✅Image loaded successfully")
                            self?.productImageView.image = image
                            self?.productImageView.backgroundColor = .clear
                        } else {
                            print("   - ❌ Image loading failed: \(error?.localizedDescription ?? "Unknown error")")
                            if let httpResponse = response as? HTTPURLResponse {
                                print("   - HTTP Status: \(httpResponse.statusCode)")
                            }
                            self?.showPlaceholderImage()
                        }
                    }
                }.resume()
            } else {
                print("   - ❌ Invalid constructed URL: \(String(describing: fullUrl))")
                showPlaceholderImage()
            }
        } else {
            print("   - ❌ No image URL available")
            showPlaceholderImage()
        }
        
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .white
        profileImageView.backgroundColor = UIColor.homeAccent
        
        // Remove existing actions and add new one
        favoriteButton.removeTarget(nil, action: nil, for: .allEvents)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        if let distanceString = distanceString {
            distanceLabel.text = distanceString
            distanceLabel.isHidden = false
            distanceIconView.isHidden = false
        } else {
            distanceLabel.isHidden = true
            distanceIconView.isHidden = true
        }
        
        // Sepette mi yazısını göster
        if product.is_in_basket == true {
            inBasketContainerView.isHidden = false
        } else {
            inBasketContainerView.isHidden = true
        }
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteAction?()
    }
    
    private func showPlaceholderImage() {
        productImageView.image = UIImage(systemName: "photo")
        productImageView.tintColor = UIColor.homeSecondary
        productImageView.backgroundColor = UIColor.homeCardBackground
    }
    
    private func updateFavoriteButtonAppearance() {
        favoriteButton.backgroundColor = .clear
        favoriteButton.tintColor = .clear
        favoriteButton.setBackgroundImage(nil, for: .normal)
        favoriteButton.setBackgroundImage(nil, for: .selected)
        
        if favoriteButton.isSelected {
            // Favorited: hide blur view, show only yellow star
            favoriteBlurView.isHidden = true
            favoriteButton.setImage(UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            // Not favorited: show blur view with white star
            favoriteBlurView.isHidden = false
            favoriteButton.setImage(UIImage(systemName: "star")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    func setFavoriteButtonHidden(_ hidden: Bool) {
        favoriteButton.isHidden = hidden
        favoriteBlurView.isHidden = hidden || favoriteBlurView.isHidden
    }
} 