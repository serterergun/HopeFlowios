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
        titleLabel.text = "Charitivist"
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
            let basketVC = BasketViewController()
            basketVC.tabBarItem = UITabBarItem(title: "Basket", image: UIImage(systemName: "cart"), tag: 1)
            let beHopeVC = DonateViewController()
            beHopeVC.tabBarItem = UITabBarItem(title: "Donate", image: UIImage(systemName: "plus.circle.fill"), tag: 2)
            let messagesVC = MessagesViewController()
            messagesVC.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 3)
            let accountVC = UINavigationController(rootViewController: AccountViewController())
            accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 4)
            let tabBarController = CustomTabBarController()
            tabBarController.viewControllers = [homeVC, basketVC, beHopeVC, messagesVC, accountVC]
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let indicatorHeight: CGFloat = 2
    private let customTabBarHeight: CGFloat = 83
    private let indicator = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .systemBackground
        updateTabBarColors(selectedIndex: selectedIndex)
        indicator.backgroundColor = UIColor.homePrimary
        indicator.layer.cornerRadius = indicatorHeight / 2
        indicator.layer.masksToBounds = true
        tabBar.addSubview(indicator)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Tab bar yüksekliğini artır
        var tabFrame = tabBar.frame
        let diff = customTabBarHeight - tabFrame.height
        if abs(diff) > 1 {
            tabFrame.size.height = customTabBarHeight
            tabFrame.origin.y = view.frame.size.height - customTabBarHeight
            tabBar.frame = tabFrame
        }
        updateIndicator(animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateIndicator(animated: false)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Account sekmesine tıklandığında login kontrolü yap
        if let navigationController = viewController as? UINavigationController,
           navigationController.viewControllers.first is AccountViewController {
            // Kullanıcı login değilse login ekranını göster
            if !AuthManager.shared.isLoggedIn {
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                loginVC.onRegisterTapped = { [weak self] in
                    let registerVC = RegisterViewController()
                    registerVC.modalPresentationStyle = .fullScreen
                    self?.present(registerVC, animated: true)
                }
                present(loginVC, animated: true)
                return false // Account sekmesine geçişi engelle
            }
        }
        return true
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateIndicator(animated: true)
    }
    private func updateTabBarColors(selectedIndex: Int) {
        switch selectedIndex {
        case 0:
            tabBar.tintColor = .homePrimary
            tabBar.unselectedItemTintColor = .secondaryColor
        case 1:
            tabBar.tintColor = .systemBlue
            tabBar.unselectedItemTintColor = .secondaryColor
        default:
            tabBar.tintColor = .systemBlue
            tabBar.unselectedItemTintColor = .secondaryColor
        }
    }
    private func updateIndicator(animated: Bool) {
        guard let items = tabBar.items, items.count > 0 else { return }
        let tabBarButtons = tabBar.subviews.filter { $0.isUserInteractionEnabled && $0 is UIControl }
        guard selectedIndex < tabBarButtons.count else { return }
        let sortedButtons = tabBarButtons.sorted { $0.frame.minX < $1.frame.minX }
        let selectedButton = sortedButtons[selectedIndex]
        let indicatorHeight = self.indicatorHeight
        let indicatorY: CGFloat = 0 // Tab bar'ın üst kenarıyla aynı hizada
        var indicatorX: CGFloat
        var indicatorWidth: CGFloat
        if selectedIndex == 0 {
            // İlk tab: çizgi sol kenardan başlasın, ikonun ortasına kadar uzasın
            indicatorX = 0
            indicatorWidth = selectedButton.frame.maxX
        } else if selectedIndex == sortedButtons.count - 1 {
            // Son tab: çizgi ikonun başından başlasın, sağ kenara kadar uzasın
            indicatorX = selectedButton.frame.minX
            indicatorWidth = tabBar.bounds.width - selectedButton.frame.minX
        } else {
            // Ortadakiler: ikonun ortasında, dar çizgi
            indicatorWidth = selectedButton.frame.width * 0.6
            indicatorX = selectedButton.frame.midX - indicatorWidth / 2
        }
        let indicatorFrame = CGRect(x: indicatorX, y: indicatorY, width: indicatorWidth, height: indicatorHeight)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.indicator.frame = indicatorFrame
            }
        } else {
            self.indicator.frame = indicatorFrame
        }
        // Change indicator color based on selected tab
        if selectedIndex == 0 {
            self.indicator.backgroundColor = .homePrimary
        } else if selectedIndex == 1 {
            self.indicator.backgroundColor = .systemBlue
        } else {
            self.indicator.backgroundColor = .systemBlue
        }
        updateTabBarColors(selectedIndex: selectedIndex)
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        updateIndicator(animated: true)
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