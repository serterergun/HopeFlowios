import UIKit

class DonationsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var products: [Product] = []
    private var groupedProducts: [String: [Product]] = [:]
    private var selectedSegment: Int = 0 // 0: My Donations, 1: My Purchases

    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["My Donations", "My Purchases"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 4, left: 16, bottom: 80, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        return cv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "You have not purchased any products yet."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donations"
        view.backgroundColor = .systemBackground
        setupSegmentedControl()
        setupCollectionView()
        setupEmptyLabel()
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoginOrLogout), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLoginOrLogout), name: .userDidLogout, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AuthManager.shared.currentUser == nil {
            products = []
            groupedProducts = [:]
            collectionView.reloadData()
        } else {
            fetchData()
        }
    }

    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
    }

    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func segmentChanged() {
        selectedSegment = segmentedControl.selectedSegmentIndex
        if selectedSegment == 0 {
            // My Donations
            emptyLabel.isHidden = true
            collectionView.isHidden = false
            groupProductsByCategory()
            collectionView.reloadData()
        } else {
            // My Purchases
            emptyLabel.isHidden = false
            collectionView.isHidden = true
        }
    }

    func fetchData() {
        guard let user = AuthManager.shared.currentUser, let userId = user.id else {
            print("Donations: Kullanıcı login değil veya id yok!")
            products = []
            groupedProducts = [:]
            collectionView.reloadData()
            return
        }
        print("Donations: Kullanıcı login, kendi ürünleri çekiliyor... User ID:", userId)
        Task {
            do {
                products = try await NetworkManager.shared.fetchListingsByUser(userId: userId)
                print("Donations: Çekilen ürün sayısı:", products.count)
                
                // Ürünlerin user_id'lerini kontrol et
                for product in products {
                    print("Product ID:", product.id ?? "nil", "User ID:", product.user_id ?? "nil")
                }
                
                if products.isEmpty {
                    print("Donations: API'den boş liste döndü.")
                    await MainActor.run {
                        self.collectionView.isHidden = true
                        self.emptyLabel.isHidden = false
                        self.emptyLabel.text = "You haven't added any products yet."
                    }
                } else {
                    print("Donations: Ürünler başarıyla çekildi.")
                    groupProductsByCategory()
                    await MainActor.run {
                        if self.selectedSegment == 0 {
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                            self.emptyLabel.isHidden = true
                        } else {
                            self.collectionView.isHidden = true
                            self.emptyLabel.isHidden = false
                        }
                    }
                }
            } catch {
                print("Donations: Hata:", error)
                products = []
                groupedProducts = [:]
                await MainActor.run {
                    self.collectionView.isHidden = true
                    self.emptyLabel.isHidden = false
                    self.emptyLabel.text = "Error loading your products. Please try again."
                    self.collectionView.reloadData()
                }
            }
        }
    }

    private func groupProductsByCategory() {
        groupedProducts = Dictionary(grouping: products) { product in
            categoryNames[product.category_id ?? 0] ?? "Uncategorized"
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = products[indexPath.item]
        var ownerName: String? = nil
        if let userInfo = product.user_info {
            ownerName = "\(userInfo.first_name ?? "") \(userInfo.last_name_initial ?? "")"
        }
        cell.configure(with: product, ownerName: ownerName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 3 // 16 left + 16 right + 16 aradaki spacing
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 280) // Sabit yükseklik
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .userDidLogin, object: nil)
        NotificationCenter.default.removeObserver(self, name: .userDidLogout, object: nil)
    }

    @objc private func userDidLoginOrLogout() {
        fetchData()
    }
} 