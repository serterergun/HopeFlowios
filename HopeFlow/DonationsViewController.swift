import UIKit

class DonationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var myListings: [Product] = []
    private var myPurchases: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donations"
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        fetchData()
    }

    func fetchData() {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        Task {
            do {
                myListings = try await NetworkManager.shared.fetchListingsByUser(userId: userId)
            } catch {
                myListings = []
            }
            do {
                myPurchases = try await NetworkManager.shared.fetchPurchasesByUser(userId: userId)
            } catch {
                myPurchases = []
            }
            await MainActor.run {
                self.tableView.reloadData()
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? myListings.count : myPurchases.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "My Donations" : "My Purchases"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let product = (indexPath.section == 0 ? myListings : myPurchases)[indexPath.row]
        cell.textLabel?.text = product.title
        cell.detailTextLabel?.text = product.description
        return cell
    }
} 