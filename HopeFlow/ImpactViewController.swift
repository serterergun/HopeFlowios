import UIKit

struct BadgeModel {
    let icon: String
    let title: String
}

class BadgeCell: UICollectionViewCell {
    static let identifier = "BadgeCell"
    let circleView = UIView()
    let iconView = UIImageView()
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        circleView.backgroundColor = UIColor(hex: "#B4CEB3")
        circleView.layer.cornerRadius = 35
        circleView.layer.masksToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor(hex: "#6D28D9")
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            circleView.widthAnchor.constraint(equalToConstant: 70),
            circleView.heightAnchor.constraint(equalToConstant: 70)
        ])
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = UIColor(hex: "#546A76")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [circleView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            stack.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func configure(with badge: BadgeModel) {
        iconView.image = UIImage(systemName: badge.icon)
        titleLabel.text = badge.title
    }
}

class ImpactViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Total donation amount
    private let totalDonationLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Donated: £0.00"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .systemPurple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Impact message
    private let impactMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "You are making a real difference! 🌱"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Badges
    private let badgesTitle: UILabel = {
        let label = UILabel()
        label.text = "Badges"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    // Badge grid view
    private var badgesCollection: UICollectionView!
    // Charity impact cards
    private let charityImpactTitle: UILabel = {
        let label = UILabel()
        label.text = "Charity Impacts"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let charityImpactStack = UIStackView()
    // Share your impact butonu
    private let shareImpactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share your impact", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .impactPurple
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let badges: [BadgeModel] = [
        BadgeModel(icon: "flame.fill", title: "First Donation"),
        BadgeModel(icon: "leaf.fill", title: "10 Items Saved"),
        BadgeModel(icon: "calendar", title: "3 Months Active"),
        BadgeModel(icon: "star.fill", title: "Top Giver"),
        BadgeModel(icon: "heart.fill", title: "Community Hero")
    ]

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Impact"
        view.backgroundColor = UIColor(hex: "#F5F3FF")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        let width = (UIScreen.main.bounds.width - 48 - 32) / 3 // 24pt kenar, 16pt aralık
        layout.itemSize = CGSize(width: width, height: 100)
        badgesCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        badgesCollection.backgroundColor = .clear
        badgesCollection.dataSource = self
        badgesCollection.delegate = self
        badgesCollection.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.identifier)
        badgesCollection.translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        shareImpactButton.addTarget(self, action: #selector(shareImpactTapped), for: .touchUpInside)
    }

    private func setupUI() {
        // Total donation and message
        view.addSubview(totalDonationLabel)
        view.addSubview(impactMessageLabel)
        view.addSubview(shareImpactButton)
        NSLayoutConstraint.activate([
            totalDonationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            totalDonationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalDonationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            impactMessageLabel.topAnchor.constraint(equalTo: totalDonationLabel.bottomAnchor, constant: 12),
            impactMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            impactMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            shareImpactButton.topAnchor.constraint(equalTo: impactMessageLabel.bottomAnchor, constant: 20),
            shareImpactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareImpactButton.widthAnchor.constraint(equalToConstant: 220),
            shareImpactButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        // Badges
        view.addSubview(badgesTitle)
        badgesTitle.topAnchor.constraint(equalTo: shareImpactButton.bottomAnchor, constant: 24).isActive = true
        badgesTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        // Badge grid (collection view)
        view.addSubview(badgesCollection)
        NSLayoutConstraint.activate([
            badgesCollection.topAnchor.constraint(equalTo: badgesTitle.bottomAnchor, constant: 8),
            badgesCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            badgesCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            badgesCollection.heightAnchor.constraint(equalToConstant: 220)
        ])
        // Charity impact
        view.addSubview(charityImpactTitle)
        charityImpactTitle.topAnchor.constraint(equalTo: badgesCollection.bottomAnchor, constant: 32).isActive = true
        charityImpactTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        charityImpactStack.axis = .vertical
        charityImpactStack.spacing = 16
        charityImpactStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(charityImpactStack)
        NSLayoutConstraint.activate([
            charityImpactStack.topAnchor.constraint(equalTo: charityImpactTitle.bottomAnchor, constant: 8),
            charityImpactStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            charityImpactStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        // Example impact cards
        let impact1 = makeImpactCard(text: "You helped 5 families this month!")
        let impact2 = makeImpactCard(text: "Supported 2 charities: Red Cross, Save the Children")
        charityImpactStack.addArrangedSubview(impact1)
        charityImpactStack.addArrangedSubview(impact2)
        totalDonationLabel.textColor = UIColor(hex: "#6D28D9")
        impactMessageLabel.textColor = UIColor(hex: "#546A76")
        badgesTitle.textColor = UIColor(hex: "#6D28D9")
        charityImpactTitle.textColor = UIColor(hex: "#6D28D9")
        shareImpactButton.backgroundColor = UIColor(hex: "#8B5CF6")
        shareImpactButton.setTitleColor(.white, for: .normal)
    }
    private func makeImpactCard(text: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#FAD4D8")
        card.layer.cornerRadius = 14
        card.layer.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(hex: "#6D28D9")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }
    @objc private func shareImpactTapped() {
        // Kartı oluştur
        let card = makeShareableImpactCard()
        // UIView'dan UIImage'a çevir
        let renderer = UIGraphicsImageRenderer(size: card.bounds.size)
        let image = renderer.image { ctx in
            card.drawHierarchy(in: card.bounds, afterScreenUpdates: true)
        }
        // Paylaşım menüsünü aç
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = shareImpactButton
            popover.sourceRect = shareImpactButton.bounds
        }
        present(activityVC, animated: true)
    }
    private func makeShareableImpactCard() -> UIView {
        let card = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        card.backgroundColor = UIColor(hex: "#FAD4D8")
        card.layer.cornerRadius = 18
        card.layer.masksToBounds = true
        let logo = UIImageView(image: UIImage(systemName: "leaf.fill"))
        logo.tintColor = UIColor(hex: "#6D28D9")
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(logo)
        let totalLabel = UILabel()
        totalLabel.text = totalDonationLabel.text
        totalLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        totalLabel.textColor = UIColor(hex: "#6D28D9")
        totalLabel.textAlignment = .center
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(totalLabel)
        let messageLabel = UILabel()
        messageLabel.text = impactMessageLabel.text
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = UIColor(hex: "#546A76")
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(messageLabel)
        let appLabel = UILabel()
        appLabel.text = "Shared via Charitivist"
        appLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        appLabel.textColor = UIColor(hex: "#8B5CF6")
        appLabel.textAlignment = .center
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(appLabel)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            logo.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 36),
            logo.heightAnchor.constraint(equalToConstant: 36),
            totalLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 8),
            totalLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            totalLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            appLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            appLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        return card
    }
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badges.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgeCell.identifier, for: indexPath) as! BadgeCell
        cell.configure(with: badges[indexPath.item])
        return cell
    }
} 