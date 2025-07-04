import UIKit
import CoreLocation

class MyFavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var favoriteProducts: [Product] = []
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        return cv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .homeBackground
        title = "My Favorite"
        setupCollectionView()
        fetchFavorites()
    }
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func fetchFavorites() {
        Task {
            do {
                let allProducts = try await NetworkManager.shared.fetchAllListings()
                let favoriteIDs = FavoriteManager.shared.getFavoriteIDs()
                let filtered = allProducts.filter { product in
                    if let id = product.id {
                        return favoriteIDs.contains(id)
                    }
                    return false
                }.map { product -> Product in
                    var mutableProduct = product
                    if let id = product.id {
                        mutableProduct.isFavorite = favoriteIDs.contains(id)
                    }
                    return mutableProduct
                }
                DispatchQueue.main.async {
                    self.favoriteProducts = filtered
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to fetch favorite products: \(error)")
            }
        }
    }
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .estimated(200))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(26)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 12, bottom: 32, trailing: 16)
            section.interGroupSpacing = 12
            return section
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { favoriteProducts.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = favoriteProducts[indexPath.item]
        var ownerName: String? = nil
        if let userInfo = product.user_info {
            ownerName = "\(userInfo.first_name ?? "") \(userInfo.last_name_initial ?? "")"
        }
        var distanceString: String? = nil
        if let userLoc = ViewController.userLocation, let lat = product.latitudeAsDouble, let lon = product.longitudeAsDouble {
            let productLoc = CLLocation(latitude: lat, longitude: lon)
            let distance = userLoc.distance(from: productLoc)
            distanceString = distance < 1000
                ? String(format: "%.0f m", distance)
                : String(format: "%.1f km", distance / 1000)
        } else {
            distanceString = "0 mi"
        }
        let currentUserId = AuthManager.shared.currentUser?.id
        let isOwnProduct = (currentUserId != nil && product.user_id == currentUserId)
        cell.configure(with: product, ownerName: ownerName, favoriteAction: isOwnProduct ? nil : { [weak self] in
            guard let id = product.id, let userId = AuthManager.shared.currentUser?.id else { return }
            FavoriteManager.shared.removeFavorite(userId: userId, productId: id) { _ in
                DispatchQueue.main.async {
                    self?.fetchFavorites()
                }
            }
        }, distanceString: distanceString)
        cell.setFavoriteButtonHidden(isOwnProduct)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = favoriteProducts[indexPath.item]
        let detailVC = ProductDetailViewController(product: product)
        if let nav = self.navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            let navVC = UINavigationController(rootViewController: detailVC)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
} 