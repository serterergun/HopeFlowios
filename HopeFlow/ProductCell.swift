import UIKit

class ProductCell: UICollectionViewCell {
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
        iv.layer.cornerRadius = 16
        iv.backgroundColor = UIColor.homeAccent
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
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
    
    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .homeAccent
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.backgroundColor = .homeAccent
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let distanceIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "mappin.and.ellipse")
        iv.tintColor = .white
        iv.backgroundColor = .homeAccent
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        productImageView.addSubview(profileImageView)
        productImageView.addSubview(ownerNameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(favoriteButton)
        productImageView.addSubview(distanceIconView)
        productImageView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor, constant: 8),
            profileImageView.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: -8),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            ownerNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            ownerNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            ownerNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: productImageView.trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            locationLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            
            distanceIconView.trailingAnchor.constraint(equalTo: distanceLabel.leadingAnchor, constant: -4),
            distanceIconView.centerYAnchor.constraint(equalTo: distanceLabel.centerYAnchor),
            distanceIconView.widthAnchor.constraint(equalToConstant: 20),
            distanceIconView.heightAnchor.constraint(equalToConstant: 20),
            
            distanceLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -8),
            distanceLabel.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: -8),
            distanceLabel.heightAnchor.constraint(equalToConstant: 20),
            distanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])
    }
    
    func configure(with product: Product, ownerName: String? = nil, favoriteAction: (() -> Void)? = nil, distanceString: String? = nil) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = "£\(product.givenPriceAsDouble ?? 0)"
        locationLabel.text = product.location
        if let userInfo = product.user_info {
            ownerNameLabel.text = "\(userInfo.first_name ?? "") \(userInfo.last_name_initial ?? "")"
        } else {
            ownerNameLabel.text = ""
        }
        ownerNameLabel.textColor = .homeSecondary
        ownerNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        ownerNameLabel.isHidden = false
        favoriteButton.isSelected = product.isFavorite ?? false
        
        productImageView.image = nil
        productImageView.backgroundColor = UIColor.homeCardBackground
        if let imageUrl = product.image_url, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.productImageView.image = image
                        self?.productImageView.backgroundColor = .clear
                    }
                }
            }.resume()
        }
        
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .white
        profileImageView.backgroundColor = UIColor.homeAccent
        
        favoriteButton.addAction(UIAction { _ in
            favoriteAction?()
        }, for: .touchUpInside)
        
        if let distanceString = distanceString {
            distanceLabel.text = distanceString
            distanceLabel.isHidden = false
            distanceIconView.isHidden = false
        } else {
            distanceLabel.isHidden = true
            distanceIconView.isHidden = true
        }
    }
} 