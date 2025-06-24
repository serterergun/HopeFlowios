import UIKit

class ImpactViewController: UIViewController {
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
    // Social media sharing buttons
    private let socialStack: UIStackView = {
        let instagram = UIButton(type: .system)
        instagram.setImage(UIImage(systemName: "camera"), for: .normal)
        instagram.tintColor = .systemPurple
        instagram.setTitle(" Instagram", for: .normal)
        let facebook = UIButton(type: .system)
        facebook.setImage(UIImage(systemName: "f.square"), for: .normal)
        facebook.tintColor = .systemBlue
        facebook.setTitle(" Facebook", for: .normal)
        let twitter = UIButton(type: .system)
        twitter.setImage(UIImage(systemName: "bird"), for: .normal)
        twitter.tintColor = .systemTeal
        twitter.setTitle(" Twitter", for: .normal)
        let stack = UIStackView(arrangedSubviews: [instagram, facebook, twitter])
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    private let badgesScroll = UIScrollView()
    private let badgesStack = UIStackView()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Impact"
        view.backgroundColor = .white
        setupUI()
    }

    private func setupUI() {
        // Total donation and message
        view.addSubview(totalDonationLabel)
        view.addSubview(impactMessageLabel)
        NSLayoutConstraint.activate([
            totalDonationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            totalDonationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalDonationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            impactMessageLabel.topAnchor.constraint(equalTo: totalDonationLabel.bottomAnchor, constant: 12),
            impactMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            impactMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        // Social media sharing
        view.addSubview(socialStack)
        NSLayoutConstraint.activate([
            socialStack.topAnchor.constraint(equalTo: impactMessageLabel.bottomAnchor, constant: 24),
            socialStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        // Badges
        view.addSubview(badgesTitle)
        badgesTitle.topAnchor.constraint(equalTo: socialStack.bottomAnchor, constant: 32).isActive = true
        badgesTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        badgesScroll.showsHorizontalScrollIndicator = false
        badgesScroll.translatesAutoresizingMaskIntoConstraints = false
        badgesStack.axis = .horizontal
        badgesStack.spacing = 16
        badgesStack.translatesAutoresizingMaskIntoConstraints = false
        badgesScroll.addSubview(badgesStack)
        view.addSubview(badgesScroll)
        NSLayoutConstraint.activate([
            badgesScroll.topAnchor.constraint(equalTo: badgesTitle.bottomAnchor, constant: 8),
            badgesScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            badgesScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            badgesScroll.heightAnchor.constraint(equalToConstant: 80),
            badgesStack.topAnchor.constraint(equalTo: badgesScroll.topAnchor),
            badgesStack.bottomAnchor.constraint(equalTo: badgesScroll.bottomAnchor),
            badgesStack.leadingAnchor.constraint(equalTo: badgesScroll.leadingAnchor),
            badgesStack.trailingAnchor.constraint(equalTo: badgesScroll.trailingAnchor)
        ])
        // Example badges
        let badge1 = makeBadge(icon: "flame.fill", title: "First Donation")
        let badge2 = makeBadge(icon: "leaf.fill", title: "10 Items Saved")
        let badge3 = makeBadge(icon: "calendar", title: "3 Months Active")
        badgesStack.addArrangedSubview(badge1)
        badgesStack.addArrangedSubview(badge2)
        badgesStack.addArrangedSubview(badge3)
        // Charity impact
        view.addSubview(charityImpactTitle)
        charityImpactTitle.topAnchor.constraint(equalTo: badgesScroll.bottomAnchor, constant: 32).isActive = true
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
        totalDonationLabel.textColor = .impactDark
        impactMessageLabel.textColor = .impactDark
        badgesTitle.textColor = .impactPurple
        charityImpactTitle.textColor = .impactPurple
    }
    private func makeBadge(icon: String, title: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .impactPink
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .impactLila
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .impactMid
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            view.widthAnchor.constraint(equalToConstant: 110),
            view.heightAnchor.constraint(equalToConstant: 70)
        ])
        return view
    }
    private func makeImpactCard(text: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .impactPink
        card.layer.cornerRadius = 14
        card.layer.masksToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .impactPurple
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
} 