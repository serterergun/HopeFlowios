import UIKit

class SplashViewController: UIViewController {
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "HopeFlow"
        label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        label.textColor = UIColor(hex: "#6D28D9")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F5F3FF")
        view.addSubview(logoLabel)
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.7, animations: {
                self.view.alpha = 0
            }, completion: { _ in
                // Ana uygulamaya geçiş (tab bar controller)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
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
            })
        }
    }
} 