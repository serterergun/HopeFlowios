import UIKit
import PhotosUI

class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    private let profileImageView = UIImageView()
    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let emailField = UITextField()
    private let createdAtLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let changePasswordButton = UIButton(type: .system)
    private let deleteAccountButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        setupUI()
        loadProfile()
    }
    
    private func setupUI() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 48
        profileImageView.backgroundColor = .systemGray5
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(systemName: "person.crop.circle.fill")
        profileImageView.tintColor = .systemGray3
        profileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        profileImageView.addGestureRecognizer(tap)
        
        firstNameField.placeholder = "First Name"
        firstNameField.borderStyle = .roundedRect
        firstNameField.autocapitalizationType = .words
        lastNameField.placeholder = "Last Name"
        lastNameField.borderStyle = .roundedRect
        lastNameField.autocapitalizationType = .words
        emailField.placeholder = "Email"
        emailField.borderStyle = .roundedRect
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.isEnabled = false
        createdAtLabel.font = .systemFont(ofSize: 14)
        createdAtLabel.textColor = .secondaryLabel
        createdAtLabel.textAlignment = .right
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        changePasswordButton.setTitle("Change Password", for: .normal)
        changePasswordButton.titleLabel?.font = .systemFont(ofSize: 16)
        changePasswordButton.setTitleColor(.systemBlue, for: .normal)
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        deleteAccountButton.setTitle("Delete Account", for: .normal)
        deleteAccountButton.titleLabel?.font = .systemFont(ofSize: 16)
        deleteAccountButton.setTitleColor(.systemRed, for: .normal)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        
        let fieldsStack = UIStackView(arrangedSubviews: [firstNameField, lastNameField, emailField, createdAtLabel, saveButton, changePasswordButton, deleteAccountButton])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 18
        fieldsStack.alignment = .fill
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImageView)
        view.addSubview(fieldsStack)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 96),
            profileImageView.heightAnchor.constraint(equalToConstant: 96),
            fieldsStack.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
            fieldsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            fieldsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func loadProfile() {
        guard let user = AuthManager.shared.currentUser else { return }
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        emailField.text = user.email
        if let createdAt = user.createdAt {
            createdAtLabel.text = "Joined: " + String(createdAt.prefix(10))
        } else {
            createdAtLabel.text = nil
        }
        if let urlStr = user.profilePhotoUrl, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    @objc private func saveTapped() {
        let alert = UIAlertController(title: "Saved", message: "Your profile has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func changePhotoTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.profileImageView.alpha = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.profileImageView.alpha = 1.0
            }
        }
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.uploadProfilePhoto(image)
            }
        }
    }
    
    private func uploadProfilePhoto(_ image: UIImage) {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        guard let url = URL(string: "\(NetworkManager.shared.baseURL)/api/v1/users/\(userId)/upload-profile-photo") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = AuthManager.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var data = Data()
        let filename = "profile.jpg"
        let mimetype = "image/jpeg"
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
            data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        }
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let updatedUser = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    AuthManager.shared.currentUser = updatedUser
                    if let urlStr = updatedUser.profilePhotoUrl, let url = URL(string: urlStr) {
                        URLSession.shared.dataTask(with: url) { data, _, _ in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self?.profileImageView.image = image
                                }
                            }
                        }.resume()
                    }
                }
            } catch {
                print("Profile photo upload error: \(error)")
            }
        }.resume()
    }
    
    @objc private func changePasswordTapped() {
        let alert = UIAlertController(title: "Change Password", message: "Password change coming soon.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            // Hesap silme işlemi burada yapılacak
        })
        present(alert, animated: true)
    }
} 