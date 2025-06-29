import UIKit

protocol ProductRowCellDelegate: AnyObject {
    func productRowCell(_ cell: ProductRowCell, didSelectProduct product: Product)
}

class ProductRowCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let identifier = "ProductRowCell"
    private var products: [Product] = []
    weak var delegate: ProductRowCellDelegate?

    private let horizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(horizontalCollectionView)
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        horizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            horizontalCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with products: [Product]) {
        self.products = products
        horizontalCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = products[indexPath.item]
        
        // Set favorite state
        var mutableProduct = product
        if let id = product.id {
            mutableProduct.isFavorite = FavoriteManager.shared.isFavorite(productId: id)
        }
        
        cell.configure(with: mutableProduct, favoriteAction: {
            guard let id = mutableProduct.id, let userId = AuthManager.shared.currentUser?.id else { return }
            if FavoriteManager.shared.isFavorite(productId: id) {
                FavoriteManager.shared.removeFavorite(userId: userId, productId: id) { _ in
                    DispatchQueue.main.async {
                        mutableProduct.isFavorite = false
                        cell.configure(with: mutableProduct, favoriteAction: cell.favoriteAction)
                    }
                }
            } else {
                FavoriteManager.shared.addFavorite(userId: userId, productId: id) { _ in
                    DispatchQueue.main.async {
                        mutableProduct.isFavorite = true
                        cell.configure(with: mutableProduct, favoriteAction: cell.favoriteAction)
                    }
                }
            }
        })
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 8
        let width = height * 0.95
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.productRowCell(self, didSelectProduct: products[indexPath.item])
    }
} 