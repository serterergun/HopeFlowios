import UIKit

class MyDonationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var products: [Product] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "My Donations"
        setupTableView()
        setupCloseButton()
        fetchMyDonations()
    }
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DonationCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    @objc private func closeTapped() {
        dismiss(animated: true)
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
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to fetch donations: \(error)")
            }
        }
    }
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.title ?? "(No Title)"
        cell.detailTextLabel?.text = product.description
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }
} 