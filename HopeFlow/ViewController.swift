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
    private var products: [Product] = []
    private var groupedProducts: [String: [Product]] = [:]
    private var selectedRange: String = "5km"
    private var selectedAddress: String = ""
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private let sampleListingIDs = ["1", "2", "3", "4"]

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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupCollectionView()
        fetchProducts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProducts()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchProducts() {
        Task {
            do {
                let products = try await NetworkManager.shared.fetchAllListings()
                self.products = products
                self.groupProductsByCategory()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
    }

    private func groupProductsByCategory() {
        groupedProducts = Dictionary(grouping: products) { product in
            categoryNames[product.category_id ?? 0] ?? "Uncategorized"
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .estimated(260))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(260))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(26)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)
            section.interGroupSpacing = 12

            // Header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
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
            if let userLoc = userLocation, let lat = product.latitude, let lon = product.longitude {
                let productLoc = CLLocation(latitude: lat, longitude: lon)
                let distance = userLoc.distance(from: productLoc)
                distanceString = distance < 1000
                    ? String(format: "%.0f m", distance)
                    : String(format: "%.1f km", distance / 1000)
            } else {
                distanceString = "0 mi"
            }
            cell.configure(with: product, ownerName: ownerName, distanceString: distanceString)
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
