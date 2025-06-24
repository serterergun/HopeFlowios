import UIKit

struct MessagePreview {
    let id: Int
    let senderName: String
    let senderImage: UIImage?
    let summary: String
    let date: String
    let isSponsored: Bool
}

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search messages"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    private let filterScroll = UIScrollView()
    private let filterStack = UIStackView()
    private let tableView = UITableView()
    private var allMessages: [MessagePreview] = []
    private var filteredMessages: [MessagePreview] = []
    private let filters = ["Focused", "Jobs", "Unread", "Drafts", "InMail"]
    private var selectedFilter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupFilters()
        setupTableView()
        loadDummyMessages()
        applyFilter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        tableView.contentInset.bottom = tabBarHeight
        if #available(iOS 13.0, *) {
            tableView.verticalScrollIndicatorInsets.bottom = tabBarHeight
        } else {
            tableView.scrollIndicatorInsets.bottom = tabBarHeight
        }
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    private func setupFilters() {
        filterScroll.showsHorizontalScrollIndicator = false
        filterScroll.translatesAutoresizingMaskIntoConstraints = false
        filterStack.axis = .horizontal
        filterStack.spacing = 12
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterScroll)
        filterScroll.addSubview(filterStack)
        NSLayoutConstraint.activate([
            filterScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            filterScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScroll.heightAnchor.constraint(equalToConstant: 40),
            filterStack.topAnchor.constraint(equalTo: filterScroll.topAnchor),
            filterStack.bottomAnchor.constraint(equalTo: filterScroll.bottomAnchor),
            filterStack.leadingAnchor.constraint(equalTo: filterScroll.leadingAnchor, constant: 16),
            filterStack.trailingAnchor.constraint(equalTo: filterScroll.trailingAnchor, constant: -16),
            filterStack.heightAnchor.constraint(equalTo: filterScroll.heightAnchor)
        ])
        for (i, filter) in filters.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(filter, for: .normal)
            btn.setTitleColor(i == selectedFilter ? .white : .systemGreen, for: .normal)
            btn.backgroundColor = i == selectedFilter ? .systemGreen : .clear
            btn.layer.cornerRadius = 16
            btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
                config.baseBackgroundColor = i == selectedFilter ? .systemGreen : .clear
                config.baseForegroundColor = i == selectedFilter ? .white : .systemGreen
                btn.configuration = config
            } else {
                btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            }
            btn.tag = i
            btn.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            filterStack.addArrangedSubview(btn)
        }
    }
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView.rowHeight = 72
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: filterScroll.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func loadDummyMessages() {
        allMessages = [
            MessagePreview(id: 1, senderName: "Emilia Bland", senderImage: UIImage(named: "profile1"), summary: "Sponsored · Advance your tech career with an MSc 🎓", date: "Mon", isSponsored: true),
            MessagePreview(id: 2, senderName: "Gokhan Karakuleli", senderImage: UIImage(named: "profile2"), summary: "Gokhan sent a post", date: "Jun 11", isSponsored: false),
            MessagePreview(id: 3, senderName: "Oguzhan Eraslan", senderImage: nil, summary: "You sent a post", date: "Jun 11", isSponsored: false),
            MessagePreview(id: 4, senderName: "Becky Coxon - Candidate Specialist", senderImage: UIImage(named: "profile3"), summary: "Hello Becky, Thank you so much for taking the time to reply to my messages. That's really kind...", date: "Jun 4", isSponsored: false),
            MessagePreview(id: 5, senderName: "Tom Haygarth", senderImage: UIImage(named: "profile4"), summary: "Hi Tom, I appreciate you taking the time to reply and I look forward to the day when you will cont...", date: "Jun 2", isSponsored: false),
            MessagePreview(id: 6, senderName: "Kaylynn Sideris", senderImage: UIImage(named: "profile5"), summary: "Hi Kaylynn, I hope you are well. I checked almost all jobs on the website yesterday but there is no...", date: "May 27", isSponsored: false),
            MessagePreview(id: 7, senderName: "Gokce Cicek Ergun", senderImage: UIImage(named: "profile6"), summary: "Zip #61 | 0:27 🏁 With 1 backtrack ⛔️ Lnkd.in/zip.", date: "May 17", isSponsored: false),
            MessagePreview(id: 8, senderName: "Levent Ozturk", senderImage: UIImage(named: "profile7"), summary: "sağırlar nasil dusunuyordan acilmisti konu", date: "May 16", isSponsored: false),
            MessagePreview(id: 9, senderName: "Cyrus Ernest Paddy  (MBA, MSc, B.Eng, ...", senderImage: UIImage(named: "profile8"), summary: "Dear Cyrus, First of all, thank you very much for taking the time to answer my questions. I hope...", date: "May 8", isSponsored: false),
            MessagePreview(id: 10, senderName: "Serkan Uz", senderImage: UIImage(named: "profile9"), summary: "https://www.linkedin.com/jobs/view/4206792594", date: "May 6", isSponsored: false),
            MessagePreview(id: 11, senderName: "Damien Delahunty", senderImage: nil, summary: "Hi, Thanks for connecting! I'm currently working...", date: "May 2", isSponsored: false)
        ]
    }
    private func applyFilter() {
        // Dummy: sadece filtre ismiyle arama yapıyormuş gibi davran
        filteredMessages = allMessages // Burada gerçek filtreleme eklenebilir
        tableView.reloadData()
    }
    @objc private func filterTapped(_ sender: UIButton) {
        selectedFilter = sender.tag
        for (i, view) in filterStack.arrangedSubviews.enumerated() {
            guard let btn = view as? UIButton else { continue }
            btn.setTitleColor(i == selectedFilter ? .white : .systemGreen, for: .normal)
            btn.backgroundColor = i == selectedFilter ? .systemGreen : .clear
        }
        applyFilter()
    }
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let msg = filteredMessages[indexPath.row]
        cell.configure(with: msg)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Burada mesaj detay ekranına geçiş yapılabilir
    }
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMessages = allMessages
        } else {
            filteredMessages = allMessages.filter { $0.senderName.lowercased().contains(searchText.lowercased()) || $0.summary.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}

class MessageCell: UITableViewCell {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let summaryLabel = UILabel()
    private let dateLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func setupUI() {
        profileImageView.layer.cornerRadius = 28
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = UIFont.systemFont(ofSize: 14)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 2
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 56),
            profileImageView.heightAnchor.constraint(equalToConstant: 56),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            summaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            summaryLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            summaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    func configure(with msg: MessagePreview) {
        nameLabel.text = msg.senderName
        summaryLabel.text = msg.summary
        dateLabel.text = msg.date
        if let img = msg.senderImage {
            profileImageView.image = img
        } else {
            profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
            profileImageView.tintColor = .systemGray3
        }
        if msg.isSponsored {
            nameLabel.textColor = .systemGreen
        } else {
            nameLabel.textColor = .label
        }
    }
} 