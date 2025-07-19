import UIKit

class MessageComposeViewController: UIViewController {
    private let listingId: Int?
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)

    init(listingId: Int?) {
        self.listingId = listingId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)

        sendButton.setTitle("Gönder", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 120),

            sendButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func sendButtonTapped() {
        guard let text = textView.text, !text.isEmpty else { return }
        // Burada mesaj gönderme fonksiyonunu çağıracağız (API entegrasyonu)
        dismiss(animated: true)
    }
} 