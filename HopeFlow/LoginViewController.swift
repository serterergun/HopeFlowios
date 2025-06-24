import UIKit

class LoginViewController: UIViewController {
    public var onRegisterTapped: (() -> Void)?
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.keyboardType = .asciiCapable
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Register", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.keyboardType = .emailAddress
        emailField.textContentType = .emailAddress
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.keyboardType = .asciiCapable
        passwordField.textContentType = .password
    }
    
    private func setupUI() {
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Logging in...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                try await AuthManager.shared.login(email: email, password: password)
                // Dismiss loading alert and login screen on main thread
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.dismiss(animated: true)
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
    
    @objc private func registerTapped() {
        if let onRegisterTapped = onRegisterTapped {
            onRegisterTapped()
            return
        }
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
} 