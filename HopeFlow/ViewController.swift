//
//  ViewController.swift
//  HopeFlow
//
//  Created by Serter Ergün on 02/06/2025.
//

import UIKit
import CoreLocation

let categoryNames: [Int: String] = [
    1: "Books",
    2: "Clothes",
    3: "Entertainment",
    4: "Home",
    5: "Electronics"
]

class ViewController: UIViewController, CLLocationManagerDelegate {
    static var userLocation: CLLocation?
    private var products: [Product] = []
    private var filteredProducts: [Product] = []
    private var groupedProducts: [String: [Product]] = [:]
    private var selectedRange: String = "5km"
    private var selectedAddress: String = ""
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private let sampleListingIDs = ["1", "2", "3", "4"]
    private var basketListingIds: Set<Int> = []

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search products..."
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        cv.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategoryHeader")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .homeBackground
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupSearchBar()
        setupCollectionView()
        checkAppStateAndLoadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAppStateAndLoadData()
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.barTintColor = .homeBackground
        searchBar.backgroundColor = .homeBackground
        searchBar.searchTextField.backgroundColor = .homeCardBackground
        searchBar.searchTextField.textColor = .homePrimary
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategoryHeader")
    }

    private func checkAppStateAndLoadData() {
        // 1. Kullanıcı login mi?
        let isLoggedIn = AuthManager.shared.isLoggedIn
        Task {
            // 2. Tüm ürünleri çek
            let products = try? await NetworkManager.shared.fetchAllListings()
            var updatedProducts = products ?? []
            var basketItems: [BasketItemWithProduct] = []
            if isLoggedIn {
                // 3. Kullanıcı login ise, sepeti kontrol et
                basketItems = (try? await NetworkManager.shared.getBasketItemsWithProducts()) ?? []
                let basketListingIds = Set(basketItems.map { $0.listing_id })
                // Her ürünün is_in_basket alanını güncelle
                updatedProducts = updatedProducts.map { product in
                    var mutableProduct = product
                    if let id = product.id {
                        mutableProduct.is_in_basket = basketListingIds.contains(id)
                    } else {
                        mutableProduct.is_in_basket = false
                    }
                    return mutableProduct
                }
            }
            await MainActor.run {
                self.products = updatedProducts
                self.filteredProducts = updatedProducts
                self.groupProductsByCategory()
                self.collectionView.reloadData()
                // Sepet badge'i veya başka bir gösterge burada güncellenebilir
            }
        }
    }

    private func groupProductsByCategory() {
        groupedProducts = Dictionary(grouping: filteredProducts) { product in
            categoryNames[product.category_id ?? 0] ?? "Uncategorized"
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(260)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(260)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            group.interItemSpacing = .fixed(2) // 2pt boşluk

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 16, trailing: 2)
            section.interGroupSpacing = 8

            // Header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(56))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ViewController.userLocation = locations.last
        userLocation = locations.last
        collectionView.reloadData()
    }

    func showRangePicker() {
        let alert = UIAlertController(title: "Select Range", message: nil, preferredStyle: .actionSheet)
        let ranges: [Double] = [0.1, 0.3, 0.5, 1, 2, 5, 10, 25, 50, 100]
        for r in ranges {
            alert.addAction(UIAlertAction(title: String(format: "%.1f mi", r), style: .default, handler: { [weak self] _ in
                self?.selectedRange = String(format: "%.1f mi", r)
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }

    func showLocationPicker() {
        let picker = LocationPickerViewController()
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }

    @objc func addProductButtonTapped() {
        if !AuthManager.shared.isLoggedIn {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
            return
        }
    }

    @objc func purchaseButtonTapped() {
        if !AuthManager.shared.isLoggedIn {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
            return
        }
    }
}

// MARK: - Collection View Delegate/DataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupedProducts.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Array(groupedProducts.keys)[section]
        return groupedProducts[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let category = Array(groupedProducts.keys)[indexPath.section]
        if let product = groupedProducts[category]?[indexPath.item] {
            var ownerName: String? = nil
            if let userInfo = product.user_info {
                ownerName = "\(userInfo.first_name ?? "") \(userInfo.last_name_initial ?? "")"
            }
            var distanceString: String? = nil
            if let userLoc = userLocation, let lat = product.latitudeAsDouble, let lon = product.longitudeAsDouble {
                let productLoc = CLLocation(latitude: lat, longitude: lon)
                let distance = userLoc.distance(from: productLoc)
                distanceString = distance < 1000
                    ? String(format: "%.0f m", distance)
                    : String(format: "%.1f km", distance / 1000)
            } else {
                distanceString = "0 mi"
            }
            
            // Set favorite state
            var mutableProduct = product
            if let id = product.id {
                mutableProduct.isFavorite = FavoriteManager.shared.isFavorite(productId: id)
            }
            
            let currentUserId = AuthManager.shared.currentUser?.id
            let isOwnProduct = (currentUserId != nil && product.user_id == currentUserId)
            
            cell.configure(with: mutableProduct, ownerName: ownerName, favoriteAction: isOwnProduct ? nil : {
                guard let id = mutableProduct.id, let userId = AuthManager.shared.currentUser?.id else { return }
                if FavoriteManager.shared.isFavorite(productId: id) {
                    FavoriteManager.shared.removeFavorite(userId: userId, productId: id) { _ in
                        DispatchQueue.main.async {
                            mutableProduct.isFavorite = false
                            cell.configure(with: mutableProduct, ownerName: ownerName, favoriteAction: cell.favoriteAction, distanceString: distanceString)
                        }
                    }
                } else {
                    FavoriteManager.shared.addFavorite(userId: userId, productId: id) { _ in
                        DispatchQueue.main.async {
                            mutableProduct.isFavorite = true
                            cell.configure(with: mutableProduct, ownerName: ownerName, favoriteAction: cell.favoriteAction, distanceString: distanceString)
                        }
                    }
                }
            }, distanceString: distanceString)
            cell.setFavoriteButtonHidden(isOwnProduct)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath) as! CategoryHeaderView
            let category = Array(groupedProducts.keys)[indexPath.section]
            headerView.titleLabel.text = category
            return headerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(groupedProducts.keys)[indexPath.section]
        if let product = groupedProducts[category]?[indexPath.item] {
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
}

// MARK: - Location Picker Delegate

extension ViewController: LocationPickerDelegate {
    func locationPicker(didSelect location: CLLocationCoordinate2D, range: Double, address: String) {
        self.selectedRange = String(format: "%.1f mi", range)
        self.selectedAddress = address.isEmpty ? "Current Location" : address
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { product in
                let title = product.title?.lowercased() ?? ""
                let desc = product.description?.lowercased() ?? ""
                return title.contains(searchText.lowercased()) || desc.contains(searchText.lowercased())
            }
        }
        groupProductsByCategory()
        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
