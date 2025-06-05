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
    }
    
    private func setupUI() {
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
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
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
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
                        self.showAlert(title: "Success", message: "Registration successful") { _ in
                            // Dismiss registration screen
                            self.dismiss(animated: true)
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
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
} 