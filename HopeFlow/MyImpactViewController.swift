import UIKit
import Charts

class MyImpactViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        // Başlık
        let titleLabel = UILabel()
        titleLabel.text = "My Impact"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // İstatistik kartları
        let statsStack = UIStackView()
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 16
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsStack)

        let itemsSavedCard = ImpactStatCard(icon: "leaf.fill", value: "12", label: "Items Saved")
        let donationsCard = ImpactStatCard(icon: "gift.fill", value: "5", label: "Donations")
        let badgesCard = ImpactStatCard(icon: "star.fill", value: "3", label: "Badges")
        statsStack.addArrangedSubview(itemsSavedCard)
        statsStack.addArrangedSubview(donationsCard)
        statsStack.addArrangedSubview(badgesCard)

        // Motive edici mesaj
        let messageLabel = UILabel()
        messageLabel.text = "You are making a real difference! 🌱"
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        messageLabel.textColor = .systemGreen
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)

        // Bar chart (Items Saved per Month)
        let chartTitle = UILabel()
        chartTitle.text = "Items Saved per Month"
        chartTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        chartTitle.textColor = .label
        chartTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartTitle)

        let barChartView = SimpleBarChartView(months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"], values: [2, 3, 1, 4, 2, 5])
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barChartView)

        // Rozetler (Achievements)
        let badgesTitle = UILabel()
        badgesTitle.text = "Achievements"
        badgesTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        badgesTitle.textColor = .label
        badgesTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badgesTitle)

        let badgesScroll = UIScrollView()
        badgesScroll.showsHorizontalScrollIndicator = false
        badgesScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badgesScroll)
        let badgesStack = UIStackView()
        badgesStack.axis = .horizontal
        badgesStack.spacing = 16
        badgesStack.translatesAutoresizingMaskIntoConstraints = false
        badgesScroll.addSubview(badgesStack)
        // Örnek rozetler
        let badge1 = BadgeView(icon: "flame.fill", title: "First Donation")
        let badge2 = BadgeView(icon: "leaf.fill", title: "10 Items Saved")
        let badge3 = BadgeView(icon: "calendar", title: "3 Months Active")
        badgesStack.addArrangedSubview(badge1)
        badgesStack.addArrangedSubview(badge2)
        badgesStack.addArrangedSubview(badge3)

        // Topluluk etkisi
        let communityLabel = UILabel()
        communityLabel.text = "Together, HopeFlow users saved 1,200 items this month!"
        communityLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        communityLabel.textColor = .systemBlue
        communityLabel.textAlignment = .center
        communityLabel.numberOfLines = 0
        communityLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.07)
        communityLabel.layer.cornerRadius = 12
        communityLabel.layer.masksToBounds = true
        communityLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(communityLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            statsStack.heightAnchor.constraint(equalToConstant: 100),
            messageLabel.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            chartTitle.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            chartTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            barChartView.topAnchor.constraint(equalTo: chartTitle.bottomAnchor, constant: 8),
            barChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            barChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            barChartView.heightAnchor.constraint(equalToConstant: 180),
            badgesTitle.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: 32),
            badgesTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            badgesScroll.topAnchor.constraint(equalTo: badgesTitle.bottomAnchor, constant: 8),
            badgesScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            badgesScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            badgesScroll.heightAnchor.constraint(equalToConstant: 70),
            badgesStack.topAnchor.constraint(equalTo: badgesScroll.topAnchor),
            badgesStack.bottomAnchor.constraint(equalTo: badgesScroll.bottomAnchor),
            badgesStack.leadingAnchor.constraint(equalTo: badgesScroll.leadingAnchor),
            badgesStack.trailingAnchor.constraint(equalTo: badgesScroll.trailingAnchor),
            communityLabel.topAnchor.constraint(equalTo: badgesScroll.bottomAnchor, constant: 32),
            communityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            communityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            communityLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

class ImpactStatCard: UIView {
    init(icon: String, value: String, label: String) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let descLabel = UILabel()
        descLabel.text = label
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, valueLabel, descLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class BadgeView: UIView {
    init(icon: String, title: String) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            widthAnchor.constraint(equalToConstant: 110),
            heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SimpleBarChartView: UIView {
    private let months: [String]
    private let values: [Int]
    private let barColor: UIColor = .systemGreen
    private let labelFont: UIFont = .systemFont(ofSize: 12, weight: .medium)
    init(months: [String], values: [Int]) {
        self.months = months
        self.values = values
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func draw(_ rect: CGRect) {
        guard months.count == values.count, let maxValue = values.max(), maxValue > 0 else { return }
        let context = UIGraphicsGetCurrentContext()
        let barWidth = rect.width / CGFloat(months.count * 2)
        let spacing = barWidth
        let chartHeight = rect.height - 28 // 20 for label, 8 for padding
        for (i, value) in values.enumerated() {
            let x = CGFloat(i) * (barWidth + spacing) + spacing/2
            let barHeight = CGFloat(value) / CGFloat(maxValue) * chartHeight
            let y = chartHeight - barHeight
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            barColor.setFill()
            context?.fill(barRect)
            // Ay label'ı
            let label = months[i] as NSString
            let labelRect = CGRect(x: x, y: chartHeight + 4, width: barWidth, height: 16)
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            label.draw(in: labelRect, withAttributes: [
                .font: labelFont,
                .foregroundColor: UIColor.secondaryLabel,
                .paragraphStyle: style
            ])
        }
    }
} 