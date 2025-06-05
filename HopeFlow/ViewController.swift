//
//  ViewController.swift
//  HopeFlow
//
//  Created by Serter Ergün on 02/06/2025.
//

import UIKit
import CoreLocation

// Kategori id -> isim eşlemesi
let categoryNames: [Int: String] = [
    1: "Books",
    2: "Clothes",
    3: "Entertainment",
    4: "Home",
    5: "Electronics"
]

private struct UserName: Codable {
    let id: Int?
    let first_name: String?
    let last_name: String?
}

class ViewController: UIViewController {
    private var products: [Product] = []
    private var groupedProducts: [String: [Product]] = [:]
    private var selectedRange: String = "5km"
    private var selectedAddress: String = ""
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private let sampleListingIDs = ["1", "2", "3", "4"] // örnek ID'ler, backend'den gerçek ID'ler ile değiştirilebilir
    private var userCache: [Int: (firstName: String, lastName: String)] = [:]

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 80, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        self.title = nil
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategoryHeader")
    }

    private func fetchProducts() {
        Task {
            do {
                let products = try await NetworkManager.shared.fetchAllListings()
                self.products = products
                self.groupProductsByCategory()
                self.fetchAllUsers(for: products)
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

    private func fetchAllUsers(for products: [Product]) {
        let userIds = Set(products.compactMap { $0.user_id })
        for userId in userIds {
            if userCache[userId] == nil {
                fetchUser(userId: userId)
            }
        }
    }

    private func fetchUser(userId: Int) {
        guard let url = URL(string: "http://localhost:8000/api/v1/users/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            if let user = try? JSONDecoder().decode(UserName.self, from: data) {
                DispatchQueue.main.async {
                    self.userCache[userId] = (user.first_name ?? "", user.last_name ?? "")
                    self.collectionView.reloadData()
                }
            }
        }.resume()
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
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.collectionView
            popover.sourceRect = CGRect(x: self.collectionView.bounds.midX, y: 0, width: 0, height: 0)
            popover.permittedArrowDirections = .up
        }
        self.present(alert, animated: true)
    }

    // ViewController'da showLocationPicker fonksiyonu ekle:
    func showLocationPicker() {
        let picker = LocationPickerViewController()
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            if let userId = product.user_id, let user = userCache[userId] {
                ownerName = "\(user.firstName) \(user.lastName)"
            }
            cell.configure(with: product, ownerName: ownerName)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2 + 8 // left + right + aradaki spacing
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 220)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 16, bottom: 80, right: 16)
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 56)
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

// ViewController'da LocationPickerDelegate protokolünü uygula:
extension ViewController: LocationPickerDelegate {
    func locationPicker(didSelect location: CLLocationCoordinate2D, range: Double, address: String) {
        self.selectedRange = String(format: "%.1f mi", range)
        self.selectedAddress = address.isEmpty ? "Current Location" : address
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
}

