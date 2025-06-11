import UIKit

class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Arka plan degrade
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)

        // Logo veya App adı
        let titleLabel = UILabel()
        titleLabel.text = "HopeFlow"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Açıklama
        let descLabel = UILabel()
        descLabel.text = "Share kindness, discover hope."
        descLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        descLabel.textColor = .white
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descLabel)

        // Devam Et butonu
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Be the Hope", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        continueButton.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.9)
        continueButton.layer.cornerRadius = 24
        continueButton.layer.shadowColor = UIColor.black.cgColor
        continueButton.layer.shadowOpacity = 0.2
        continueButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        continueButton.layer.shadowRadius = 8
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            continueButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 40),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func continueTapped() {
        // Ana uygulamaya geçiş
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            // Tab bar controller'ı tekrar oluştur
            let homeVC = UINavigationController(rootViewController: ViewController())
            homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
            let donationsVC = DonationsViewController()
            donationsVC.tabBarItem = UITabBarItem(title: "Donations", image: UIImage(systemName: "gift.fill"), tag: 1)
            let beHopeVC = BeHopeViewController()
            beHopeVC.tabBarItem = UITabBarItem(title: "Be the Hope", image: UIImage(systemName: "plus.circle.fill"), tag: 2)
            let myImpactVC = MyImpactViewController()
            myImpactVC.tabBarItem = UITabBarItem(title: "My Impact", image: UIImage(systemName: "chart.bar.xaxis"), tag: 3)
            let accountVC = UINavigationController(rootViewController: AccountViewController())
            accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 4)
            let tabBarController = CustomTabBarController()
            tabBarController.viewControllers = [homeVC, donationsVC, beHopeVC, myImpactVC, accountVC]
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true // push veya present yok, doğrudan sekme değişsin
    }
}

class UserManager {
    static let shared = UserManager()
    private init() {}
    var name: String? = "Jane Doe"
    var email: String? = "jane.doe@email.com"
    func logout() {
        name = nil
        email = nil
    }
}

// Account sekmesi için yeni bir ViewController
class AccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let items: [(title: String, icon: String, color: UIColor)] = [
        ("Notification Settings", "bell.badge", .systemOrange),
        ("My Watchlist", "star.fill", .systemYellow),
        ("Profile", "person.crop.circle.fill", .systemBlue),
        ("Account Settings", "gearshape.fill", .systemGray)
    ]
    let profileView = UIView()
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let logoutButton = UIButton(type: .system)
    let loginButton = UIButton(type: .system)
    let registerButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
        view.backgroundColor = .systemGroupedBackground
        setupProfileView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = profileView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setupLogoutButton()
        setupAuthButtons()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func setupProfileView() {
        let width = UIScreen.main.bounds.width
        let container = UIView()
        container.backgroundColor = .clear

        // Profil resmi
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 36
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // Ad
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // E-posta
        emailLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        container.addSubview(nameLabel)
        container.addSubview(emailLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 72),
            imageView.heightAnchor.constraint(equalToConstant: 72),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            emailLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        // Yüksekliği Auto Layout ile belirle
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = container.systemLayoutSizeFitting(targetSize).height
        container.frame = CGRect(x: 0, y: 0, width: width, height: height)

        tableView.tableHeaderView = container
    }
    
    func setupLogoutButton() {
        logoutButton.setTitle("Log Out", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutButton.backgroundColor = .clear
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        tableView.contentInset.bottom = 60
    }
    
    func setupAuthButtons() {
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.systemGreen, for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        view.addSubview(registerButton)
        NSLayoutConstraint.activate([
            registerButton.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -8),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func updateUI() {
        if AuthManager.shared.isAuthenticated, let user = AuthManager.shared.currentUser {
            nameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
            emailLabel.text = user.email ?? ""
            profileImageView.isHidden = false
            logoutButton.isHidden = false
            loginButton.isHidden = true
            registerButton.isHidden = true
        } else {
            nameLabel.text = ""
            emailLabel.text = ""
            profileImageView.isHidden = true
            logoutButton.isHidden = true
            loginButton.isHidden = false
            registerButton.isHidden = false
        }
    }
    
    @objc func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            AuthManager.shared.logout()
            self.updateUI()
            // Home ekranına yönlendir
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let homeVC = UINavigationController(rootViewController: ViewController())
                homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
                let donationsVC = DonationsViewController()
                donationsVC.tabBarItem = UITabBarItem(title: "Donations", image: UIImage(systemName: "gift.fill"), tag: 1)
                let beHopeVC = BeHopeViewController()
                beHopeVC.tabBarItem = UITabBarItem(title: "Be the Hope", image: UIImage(systemName: "plus.circle.fill"), tag: 2)
                let myImpactVC = MyImpactViewController()
                myImpactVC.tabBarItem = UITabBarItem(title: "My Impact", image: UIImage(systemName: "chart.bar.xaxis"), tag: 3)
                let accountVC = UINavigationController(rootViewController: AccountViewController())
                accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 4)
                let tabBarController = CustomTabBarController()
                tabBarController.viewControllers = [homeVC, donationsVC, beHopeVC, myImpactVC, accountVC]
                tabBarController.selectedIndex = 0 // Home sekmesi seçili
                window.rootViewController = tabBarController
                window.makeKeyAndVisible()
            }
        })
        present(alert, animated: true)
    }
    
    @objc func loginTapped() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    @objc func registerTapped() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = item.color
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemGroupedBackground
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if item.title == "Notification Settings" {
            let vc = NotificationSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            vc.title = item.title
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class NotificationSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let settings: [(title: String, key: String)] = [
        ("Push Notifications", "push"),
        ("Email Notifications", "email"),
        ("SMS Notifications", "sms"),
        ("App Sounds", "sounds")
    ]
    var values: [String: Bool] = [
        "push": true,
        "email": false,
        "sms": false,
        "sounds": true
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notification Settings"
        view.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { settings.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let setting = settings[indexPath.row]
        cell.textLabel?.text = setting.title
        let sw = UISwitch()
        sw.isOn = values[setting.key] ?? false
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = sw
        return cell
    }
    @objc func switchChanged(_ sender: UISwitch) {
        let key = settings[sender.tag].key
        values[key] = sender.isOn
        // Burada tercihi kaydedebilirsin (UserDefaults vs.)
    }
} 