import UIKit

class SplashViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Load the logo image from the images folder
        if let logoImage = UIImage(named: "logo") {
            logoImageView.image = logoImage
        } else {
            // Fallback to text if image is not found
            let fallbackLabel = UILabel()
            fallbackLabel.text = "Charitivist"
            fallbackLabel.font = UIFont.systemFont(ofSize: 44, weight: .bold)
            fallbackLabel.textColor = UIColor(hex: "#6D28D9")
            fallbackLabel.textAlignment = .center
            fallbackLabel.translatesAutoresizingMaskIntoConstraints = false
            logoImageView.addSubview(fallbackLabel)
            
            NSLayoutConstraint.activate([
                fallbackLabel.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
                fallbackLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor)
            ])
        }
        
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200)
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