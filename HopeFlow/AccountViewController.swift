import UIKit

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let settings: [(icon: String, title: String)] = [
        ("person.crop.circle", "Profile"),
        ("gift.fill", "My Donations"),
        ("bookmark.fill", "Saved Charities"),
        ("magnifyingglass", "Find Charities"),
        ("plus.app.fill", "Suggest a Charity"),
        ("bell.badge.fill", "Donation Reminders"),
        ("repeat.circle.fill", "Recurring Donations"),
        ("person.3.fill", "Invite Friends"),
        ("square.and.arrow.up.fill", "Share My Impact"),
        ("quote.bubble.fill", "Community Stories"),
        ("bell.fill", "Notifications"),
        ("questionmark.circle", "Help Center"),
        ("lock.shield", "Privacy Policy"),
        ("arrow.backward.square", "Log Out")
    ]
    private let footerLinks = [
        "Help Center",
        "Privacy Policy",
        "Accessibility"
    ]
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let footerStack = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupTableView()
        setupFooter()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show login if not authenticated
        if !AuthManager.shared.isLoggedIn {
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.onRegisterTapped = { [weak self] in
                let registerVC = RegisterViewController()
                registerVC.modalPresentationStyle = .fullScreen
                self?.present(registerVC, animated: true)
            }
            present(loginVC, animated: false)
        }
    }
    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 28
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let hStack = UIStackView(arrangedSubviews: [profileImageView, titleLabel])
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(hStack)
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            headerView.heightAnchor.constraint(equalToConstant: 72),
            hStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            hStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 56),
            profileImageView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140)
        ])
    }
    private func setupFooter() {
        footerStack.axis = .vertical
        footerStack.spacing = 4
        footerStack.alignment = .leading
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        for link in footerLinks {
            let btn = UIButton(type: .system)
            btn.setTitle(link, for: .normal)
            btn.setTitleColor(link.contains("Privacy") ? .systemBlue : .secondaryLabel, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: link.contains("Privacy") ? .semibold : .regular)
            btn.contentHorizontalAlignment = .leading
            btn.addTarget(self, action: #selector(footerLinkTapped(_:)), for: .touchUpInside)
            footerStack.addArrangedSubview(btn)
        }
        view.addSubview(footerStack)
        NSLayoutConstraint.activate([
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            footerStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { settings.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = settings[indexPath.row]
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: item.icon))
        iconView.tintColor = .label
        iconView.translatesAutoresizingMaskIntoConstraints = false
        // Title
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Row stack
        let hStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        hStack.axis = .horizontal
        hStack.spacing = 18
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
            hStack.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settings[indexPath.row]
        if item.title == "Log Out" {
            AuthManager.shared.logout()
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.onRegisterTapped = { [weak self] in
                let registerVC = RegisterViewController()
                registerVC.modalPresentationStyle = .fullScreen
                self?.present(registerVC, animated: true)
            }
            present(loginVC, animated: true)
            return
        }
        if item.title == "My Donations" {
            guard AuthManager.shared.isLoggedIn else { return }
            let myDonationsVC = MyDonationsViewController()
            myDonationsVC.modalPresentationStyle = .fullScreen
            present(myDonationsVC, animated: true)
            return
        }
        // Handle other navigation here
    }
    // Footer link tap
    @objc private func footerLinkTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }
        print("Tapped footer link: \(title)")
    }
} 