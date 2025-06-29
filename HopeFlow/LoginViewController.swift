import UIKit
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate {
    public var onRegisterTapped: (() -> Void)?
    private var passwordRevealTimer: Timer?
    private var passwordPreviousText: String = ""
    
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
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.smartInsertDeleteType = .no
        field.spellCheckingType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let showHidePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    // Şifre gücü enum'u
    private enum PasswordStrength: Int {
        case weak = 0
        case medium
        case strong
    }
    // Şifre gücü kontrol fonksiyonu
    private func checkPasswordStrength(_ password: String) -> PasswordStrength {
        if password.count < 6 { return .weak }
        let hasLetters = password.rangeOfCharacter(from: .letters) != nil
        let hasDigits = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: .symbols) != nil || password.rangeOfCharacter(from: .punctuationCharacters) != nil
        if hasLetters && hasDigits && hasSpecial { return .strong }
        if (hasLetters && hasDigits) || (hasLetters && hasSpecial) || (hasDigits && hasSpecial) { return .medium }
        return .weak
    }
    
    // Biyometrik giriş butonu
    private lazy var biometricButton: UIButton = {
        let button = UIButton(type: .system)
        let biometricType = self.biometricType()
        let imageName = biometricType == .faceID ? "faceid" : "touchid"
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(authenticateWithBiometrics), for: .touchUpInside)
        button.isHidden = biometricType == .none
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Şifre yöneticisi ve otomatik tamamlama kaldırıldı
        if #available(iOS 11.0, *) {
            passwordField.textContentType = .password
        }
        // Biyometrik butonu ekle
        view.addSubview(biometricButton)
        NSLayoutConstraint.activate([
            biometricButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16),
            biometricButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            biometricButton.widthAnchor.constraint(equalToConstant: 40),
            biometricButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        // App arkaplana geçince şifreyi koru
        NotificationCenter.default.addObserver(self, selector: #selector(protectPassword), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unprotectPassword), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        passwordField.rightView = showHidePasswordButton
        passwordField.rightViewMode = .always
        showHidePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(forgotPasswordButton)
        
        NSLayoutConstraint.activate([
            emailField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),
            
            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
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
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        let loadingAlert = UIAlertController(title: "Logging in...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                try await AuthManager.shared.login(email: email, password: password)
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        if let tabBarController = self.tabBarController {
                            tabBarController.selectedIndex = 4
                        }
                        self.dismiss(animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc private func registerTapped() {
        let registerVC = RegisterViewController()
        if let nav = self.navigationController {
            nav.pushViewController(registerVC, animated: true)
        } else {
            present(registerVC, animated: true)
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
    
    @objc private func handleForgotPassword() {
        let alert = UIAlertController(
            title: "Reset Password",
            message: "Enter your email to receive a password reset link",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            self?.sendPasswordReset(email: email)
        })
        present(alert, animated: true)
    }
    
    private func sendPasswordReset(email: String) {
        print("Password reset link sent to: \(email)")
        let alert = UIAlertController(title: "Sent", message: "If this email exists, a reset link has been sent.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    // UITextFieldDelegate: Email alanını küçük harfe zorla
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            if let textRange = Range(range, in: textField.text ?? "") {
                let updatedText = (textField.text ?? "").replacingCharacters(in: textRange, with: string.lowercased())
                textField.text = updatedText
                return false
            }
        }
        // passwordField için hiçbir text manipülasyonu yapma, sadece return true
        return true
    }
    
    // Biyometrik tipini belirle
    private func biometricType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
    
    // Biyometrik giriş fonksiyonu
    @objc private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        // Biyometrik doğrulama başarılı
                        self?.loginWithSavedCredentials()
                    } else {
                        // Hata durumu
                        let alert = UIAlertController(title: "Error", message: "Biometric authentication failed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    // Biyometrik ile giriş (örnek: email ve şifreyi doldurup login fonksiyonunu çağırabilirsin)
    private func loginWithSavedCredentials() {
        // Burada Keychain veya UserDefaults'tan email/şifre çekip login fonksiyonunu çağırabilirsin
        // Örnek: self.loginTapped()
        // Şimdilik sadece info mesajı gösterelim
        let alert = UIAlertController(title: "Success", message: "Biometric login successful!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // App arkaplana geçince şifreyi koru
    @objc private func protectPassword() {
        passwordField.isSecureTextEntry = true
        // passwordField.text = "" // Eğer güvenlik için tamamen silmek istersen açabilirsin
    }
    
    @objc private func unprotectPassword() {
        // Şifre alanını yeniden etkinleştir (gerekirse ek işlem yapılabilir)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}