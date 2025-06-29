import UIKit

class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let settings: [(icon: String, title: String)] = [
        ("person.crop.circle", "Profile"),
        ("gift.fill", "My Donations"),
        ("star.fill", "My Favorite"),
        ("chart.bar.fill", "My Impact"),
        ("person.3.fill", "Invite Friends"),
        ("bell.fill", "Notifications"),
        ("arrow.backward.square", "Log Out")
    ]
    private let footerLinks: [String] = []
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
        // Login kontrolü artık CustomTabBarController'da yapılıyor
    }
    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        // Profil resmi
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 28
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        // Kullanıcı adı
        let nameLabel = UILabel()
        nameLabel.text = AuthManager.shared.currentUser?.fullName ?? "User"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        // Yatayda profil resmi + ad
        let hStack = UIStackView(arrangedSubviews: [profileImageView, nameLabel])
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        // 'Settings' başlığı kaldırıldı
        // Dikeyde: sadece profil+ad
        let vStack = UIStackView(arrangedSubviews: [hStack])
        vStack.axis = .vertical
        vStack.spacing = 12
        vStack.alignment = .leading
        vStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(vStack)
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            vStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: headerView.topAnchor),
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
        // Footer link eklenmeyecek
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
        if item.title == "Profile" {
            let profileVC = ProfileViewController()
            if let nav = self.navigationController {
                nav.pushViewController(profileVC, animated: true)
            } else {
                profileVC.modalPresentationStyle = .fullScreen
                present(profileVC, animated: true)
            }
            return
        }
        if item.title == "Log Out" {
            AuthManager.shared.logout()
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.onRegisterTapped = { [weak self] in
                let registerVC = RegisterViewController()
                if let nav = self?.navigationController {
                    nav.pushViewController(registerVC, animated: true)
                } else {
                    self?.present(registerVC, animated: true)
                }
            }
            present(loginVC, animated: true)
            return
        }
        if item.title == "My Donations" {
            guard AuthManager.shared.isLoggedIn else { return }
            let myDonationsVC = MyDonationsViewController()
            if let nav = self.navigationController {
                nav.pushViewController(myDonationsVC, animated: true)
            } else {
                myDonationsVC.modalPresentationStyle = .fullScreen
                present(myDonationsVC, animated: true)
            }
            return
        }
        if item.title == "My Favorite" {
            guard AuthManager.shared.isLoggedIn else { return }
            let myFavoriteVC = MyFavoriteViewController()
            if let nav = self.navigationController {
                nav.pushViewController(myFavoriteVC, animated: true)
            } else {
                myFavoriteVC.modalPresentationStyle = .fullScreen
                present(myFavoriteVC, animated: true)
            }
            return
        }
        if item.title == "My Impact" {
            guard AuthManager.shared.isLoggedIn else { return }
            let myImpactVC = MyImpactViewController()
            if let nav = self.navigationController {
                nav.pushViewController(myImpactVC, animated: true)
            } else {
                myImpactVC.modalPresentationStyle = .fullScreen
                present(myImpactVC, animated: true)
            }
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