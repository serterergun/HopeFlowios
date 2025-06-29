import UIKit

class RegisterViewController: UIViewController {
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "First Name"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Last Name"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let confirmPasswordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Confirm Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Login", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Şifre gücü göstergesi barı ve etiketi
    private let passwordStrengthBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = .systemGray4
        bar.layer.cornerRadius = 2
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    private let passwordStrengthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.text = "Password Strength: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private enum PasswordStrength: Int {
        case weak = 0
        case medium
        case strong
    }
    private func checkPasswordStrength(_ password: String) -> PasswordStrength {
        if password.count < 6 { return .weak }
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: .symbols) != nil || password.rangeOfCharacter(from: .punctuationCharacters) != nil
        if hasLetters && hasDigits && hasSpecial { return .strong }
        if (hasLetters && hasDigits) || (hasLetters && hasSpecial) || (hasDigits && hasSpecial) { return .medium }
        return .weak
    }
    
    private let showHidePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        firstNameField.autocorrectionType = .no
        firstNameField.autocapitalizationType = .none
        lastNameField.autocorrectionType = .no
        lastNameField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.textContentType = .oneTimeCode
        confirmPasswordField.autocorrectionType = .no
        confirmPasswordField.autocapitalizationType = .none
        confirmPasswordField.textContentType = .oneTimeCode
        passwordField.addTarget(self, action: #selector(passwordFieldDidChange), for: .editingChanged)
        passwordField.rightView = showHidePasswordButton
        passwordField.rightViewMode = .always
        showHidePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        firstNameField.addTarget(self, action: #selector(firstNameEditingChanged), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(lastNameEditingChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailEditingChanged), for: .editingChanged)
    }
    
    private func setupUI() {
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(passwordStrengthBar)
        view.addSubview(passwordStrengthLabel)
        view.addSubview(confirmPasswordField)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            firstNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            firstNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            firstNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 16),
            lastNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lastNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            passwordStrengthBar.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 4),
            passwordStrengthBar.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            passwordStrengthBar.widthAnchor.constraint(equalTo: passwordField.widthAnchor, multiplier: 0.5),
            passwordStrengthBar.heightAnchor.constraint(equalToConstant: 4),
            
            passwordStrengthLabel.topAnchor.constraint(equalTo: passwordStrengthBar.bottomAnchor, constant: 2),
            passwordStrengthLabel.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordStrengthLabel.bottomAnchor, constant: 16),
            confirmPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            confirmPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            registerButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 32),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 48),
            
            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    @objc private func registerTapped() {
        guard let firstName = firstNameField.text, !firstName.isEmpty,
              let lastName = lastNameField.text, !lastName.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Registering...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                try await AuthManager.shared.register(firstName: firstName, lastName: lastName, email: email, password: password)
                
                // Dismiss loading alert on main thread
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        // Show success message
                        self.showAlert(title: "Success", message: "Registration successful! Please login with your credentials.") { _ in
                            // Dismiss registration screen and show login
                            self.dismiss(animated: true) {
                                // Show login screen
                                let loginVC = LoginViewController()
                                loginVC.modalPresentationStyle = .fullScreen
                                self.present(loginVC, animated: true)
                            }
                        }
                    }
                }
            } catch {
                // Dismiss loading alert and show error on main thread
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc private func loginTapped() {
        dismiss(animated: true)
    }
    
    @objc private func passwordFieldDidChange() {
        let password = passwordField.text ?? ""
        let strength = checkPasswordStrength(password)
        switch strength {
        case .weak:
            passwordStrengthBar.backgroundColor = .systemRed
            passwordStrengthLabel.text = "Password Strength: Weak"
            passwordStrengthLabel.textColor = .systemRed
        case .medium:
            passwordStrengthBar.backgroundColor = .systemYellow
            passwordStrengthLabel.text = "Password Strength: Medium"
            passwordStrengthLabel.textColor = .systemYellow
        case .strong:
            passwordStrengthBar.backgroundColor = .systemGreen
            passwordStrengthLabel.text = "Password Strength: Strong"
            passwordStrengthLabel.textColor = .systemGreen
        }
    }
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        showHidePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
        if passwordField.isFirstResponder {
            passwordField.becomeFirstResponder()
        }
    }
    
    @objc private func firstNameEditingChanged() {
        guard let text = firstNameField.text, !text.isEmpty else { return }
        let formatted = text.prefix(1).uppercased() + text.dropFirst().lowercased()
        if firstNameField.text != formatted {
            firstNameField.text = formatted
        }
    }
    @objc private func lastNameEditingChanged() {
        guard let text = lastNameField.text, !text.isEmpty else { return }
        let formatted = text.prefix(1).uppercased() + text.dropFirst().lowercased()
        if lastNameField.text != formatted {
            lastNameField.text = formatted
        }
    }
    @objc private func emailEditingChanged() {
        guard let text = emailField.text, !text.isEmpty else { return }
        let formatted = text.lowercased()
        if emailField.text != formatted {
            emailField.text = formatted
        }
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
} 