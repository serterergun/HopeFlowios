import UIKit
import CoreLocation

class BeHopeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    // UI
    private var images: [UIImage] = []
    private let nameField = UITextField()
    private let descView = UITextView()
    private let priceField = UITextField()
    private let usageField = UITextField()
    private let photosLabel = UILabel()
    private var photosCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 72)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv;
    }()
    private let autoPriceLabel = UILabel()
    private let hopeItButton = UIButton(type: .system)
    private let categoryField = UITextField()
    private let categoryPicker = UIPickerView()
    private let categories = ["Books", "Clothes", "Entertainment", "Home", "Electronics"]
    private let userPriceField = UITextField()
    private let postcodeField = UITextField()
    private let usagePicker = UIPickerView()
    private let usageOptions = ["1 year", "2 years", "3 years", "4 years", "5 years", "6 years", "7 years", "8 years", "9 years", "10+ years"]
    private let suggestedPriceLabel = UILabel()
    private let suggestedPriceField = UITextField()
    private var isEditingSuggestedPrice = false
    private let setYourPriceField = UITextField()

    private var products: [Product] = []
    private var groupedProducts: [String: [Product]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        usagePicker.dataSource = self
        usagePicker.delegate = self
        setupUI()
        // Usage Duration için ilk değer otomatik seçili olsun
        usagePicker.selectRow(0, inComponent: 0, animated: false)
        usageField.text = usageOptions[0]
        descView.delegate = self
        fetchProducts()
    }

    private func setupUI() {
        let commonFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        // Product Name
        nameField.placeholder = "Product Name"
        nameField.font = commonFont
        nameField.borderStyle = .roundedRect
        nameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameField)
        // Kategori
        categoryField.placeholder = "Category"
        categoryField.font = commonFont
        categoryField.borderStyle = .roundedRect
        categoryField.translatesAutoresizingMaskIntoConstraints = false
        categoryField.inputView = categoryPicker
        view.addSubview(categoryField)
        // Photos label
        photosLabel.text = "Photos"
        photosLabel.font = commonFont
        photosLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photosLabel)
        // Photos collection view
        view.addSubview(photosCollection)
        photosCollection.translatesAutoresizingMaskIntoConstraints = false
        photosCollection.dataSource = self
        photosCollection.delegate = self
        photosCollection.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photosCollection.register(AddPhotoCell.self, forCellWithReuseIdentifier: "AddPhotoCell")
        // Description
        descView.font = commonFont
        descView.layer.cornerRadius = 8
        descView.layer.borderWidth = 1
        descView.layer.borderColor = UIColor.systemGray4.cgColor
        descView.text = "Description"
        descView.textColor = .secondaryLabel
        descView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descView)
        // Postcode
        postcodeField.placeholder = "Postcode"
        postcodeField.font = commonFont
        postcodeField.borderStyle = .roundedRect
        postcodeField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postcodeField)
        // Price
        priceField.placeholder = "Original Price (£)"
        priceField.font = commonFont
        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .decimalPad
        priceField.translatesAutoresizingMaskIntoConstraints = false
        priceField.delegate = self
        view.addSubview(priceField)
        // Usage Duration
        usageField.placeholder = "Usage Duration"
        usageField.font = commonFont
        usageField.borderStyle = .roundedRect
        usageField.inputView = usagePicker
        usageField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usageField)
        // Suggested Price (sadece bilgi amaçlı, tıklanamaz)
        suggestedPriceLabel.text = "Suggested Price: £0.00"
        suggestedPriceLabel.font = commonFont
        suggestedPriceLabel.textColor = .secondaryLabel
        suggestedPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        suggestedPriceLabel.isUserInteractionEnabled = false
        view.addSubview(suggestedPriceLabel)
        // Set Your Price (manuel giriş)
        setYourPriceField.placeholder = "Set Your Price (£)"
        setYourPriceField.font = commonFont
        setYourPriceField.borderStyle = .roundedRect
        setYourPriceField.keyboardType = .decimalPad
        setYourPriceField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(setYourPriceField)
        // Hope It butonu
        hopeItButton.setTitle("Be the Hope", for: .normal)
        hopeItButton.setTitleColor(.white, for: .normal)
        hopeItButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        hopeItButton.backgroundColor = .systemPurple
        hopeItButton.layer.cornerRadius = 22
        hopeItButton.translatesAutoresizingMaskIntoConstraints = false
        hopeItButton.addTarget(self, action: #selector(hopeItTapped), for: .touchUpInside)
        view.addSubview(hopeItButton)
        // Layout
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            categoryField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            categoryField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            categoryField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            photosLabel.topAnchor.constraint(equalTo: categoryField.bottomAnchor, constant: 16),
            photosLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            photosCollection.topAnchor.constraint(equalTo: photosLabel.bottomAnchor, constant: 10),
            photosCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            photosCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            photosCollection.heightAnchor.constraint(equalToConstant: 72),
            descView.topAnchor.constraint(equalTo: photosCollection.bottomAnchor, constant: 18),
            descView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            descView.heightAnchor.constraint(equalToConstant: 80),
            postcodeField.topAnchor.constraint(equalTo: descView.bottomAnchor, constant: 14),
            postcodeField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            postcodeField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            priceField.topAnchor.constraint(equalTo: postcodeField.bottomAnchor, constant: 16),
            priceField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            usageField.topAnchor.constraint(equalTo: postcodeField.bottomAnchor, constant: 16),
            usageField.leadingAnchor.constraint(equalTo: priceField.trailingAnchor, constant: 16),
            usageField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            priceField.widthAnchor.constraint(equalTo: usageField.widthAnchor),
            suggestedPriceLabel.topAnchor.constraint(equalTo: priceField.bottomAnchor, constant: 12),
            suggestedPriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            suggestedPriceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            setYourPriceField.topAnchor.constraint(equalTo: suggestedPriceLabel.bottomAnchor, constant: 8),
            setYourPriceField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            setYourPriceField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            hopeItButton.topAnchor.constraint(equalTo: setYourPriceField.bottomAnchor, constant: 32),
            hopeItButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            hopeItButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            hopeItButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1 // +1: Add photo cell
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath) as! AddPhotoCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.imageView.image = images[indexPath.item - 1]
            cell.deleteButton.tag = indexPath.item - 1
            cell.deleteButton.addTarget(self, action: #selector(deletePhoto(_:)), for: .touchUpInside)
            return cell
        }
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addPhotoTapped()
        }
    }
    // MARK: - Add Photo
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            images.append(image)
            photosCollection.reloadData()
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    @objc private func deletePhoto(_ sender: UIButton) {
        let index = sender.tag
        images.remove(at: index)
        photosCollection.reloadData()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAutoPrice()
    }
    func updateAutoPrice() {
        let price = Double(priceField.text ?? "") ?? 0
        let usageText = usageField.text ?? ""
        let discountRates: [String: Double] = [
            "1 year": 0.20,
            "2 years": 0.25,
            "3 years": 0.30,
            "4 years": 0.35,
            "5 years": 0.40,
            "6 years": 0.45,
            "7 years": 0.50,
            "8 years": 0.55,
            "9 years": 0.60,
            "10+ years": 0.65
        ]
        let discount = discountRates[usageText] ?? 0.0
        let suggested = price * (1.0 - discount)
        let text = String(format: "Suggested Price: £%.2f", suggested)
        suggestedPriceLabel.text = text
        if !isEditingSuggestedPrice {
            suggestedPriceField.text = String(format: "%.2f", suggested)
        }
    }
    @objc private func hopeItTapped() {
        // Önce kullanıcı girişi kontrolü
        guard let currentUser = AuthManager.shared.currentUser else {
            let alert = UIAlertController(title: "Login Required", message: "Please login to add a product", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Login", style: .default) { _ in
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        guard let userId = currentUser.id else {
            let alert = UIAlertController(title: "Error", message: "User ID not found. Please log out and log in again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Diğer alanların kontrolü
        guard let title = nameField.text, !title.isEmpty,
              let description = descView.text, !description.isEmpty,
              let originalPriceText = priceField.text, let originalPrice = Double(originalPriceText),
              let suggestedPriceText = suggestedPriceField.text, let suggestedPrice = Double(suggestedPriceText),
              let givenPriceText = setYourPriceField.text, let givenPrice = Double(givenPriceText),
              let postCode = postcodeField.text, !postCode.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let categoryId = categoryPicker.selectedRow(inComponent: 0) + 1
        let usageDuration = usagePicker.selectedRow(inComponent: 0)
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Creating listing...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        Task {
            do {
                let product = try await NetworkManager.shared.createListing(
                    title: title,
                    description: description,
                    categoryId: categoryId,
                    userId: userId,
                    originalPrice: originalPrice,
                    usageDuration: usageDuration,
                    suggestedPrice: suggestedPrice,
                    givenPrice: givenPrice,
                    postCode: postCode
                )
                // Eğer fotoğraf varsa, local path'i kaydet
                if let productId = product.id, let _ = self.images.first {
                    let imagePath = "local_image.jpg"
                    try? await NetworkManager.shared.addListingPhoto(listingId: productId, path: imagePath)
                }
                // Dismiss loading alert and show success message
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Success", message: "Your product has been listed!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            // Clear the form
                            self.nameField.text = ""
                            self.categoryField.text = ""
                            self.descView.text = "Description"
                            self.descView.textColor = .secondaryLabel
                            self.postcodeField.text = ""
                            self.priceField.text = ""
                            self.usageField.text = ""
                            self.setYourPriceField.text = ""
                            self.suggestedPriceField.text = ""
                            self.images.removeAll()
                            self.photosCollection.reloadData()
                            // Anasayfaya yönlendir
                            if let tabBarController = self.tabBarController {
                                tabBarController.selectedIndex = 0
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                self.dismiss(animated: true)
                            }
                        })
                        self.present(alert, animated: true)
                    }
                }
            } catch {
                // Dismiss loading alert and show error message
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        var message = error.localizedDescription
                        if let netError = error as? NetworkError {
                            switch netError {
                            case .serverError(let msg):
                                message = msg
                            default: break
                            }
                        }
                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else if pickerView == usagePicker {
            return usageOptions.count
        }
        return 0
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories[row]
        } else if pickerView == usagePicker {
            return usageOptions[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            categoryField.text = categories[row]
            categoryField.resignFirstResponder()
        } else if pickerView == usagePicker {
            usageField.text = usageOptions[row]
            usageField.resignFirstResponder()
            updateAutoPrice()
        }
    }

    private func fetchProducts() {
        Task {
            do {
                let products = try await NetworkManager.shared.fetchAllListings()
                self.products = products
                self.groupProductsByCategory()
                DispatchQueue.main.async {
                    self.photosCollection.reloadData()
                }
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
    }

    private func groupProductsByCategory() {
        groupedProducts = Dictionary(grouping: products) { product in
            categoryNames[product.category_id ?? 0] ?? "Uncategorized"
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath) as! CategoryHeaderView
            let category = Array(groupedProducts.keys)[indexPath.section]
            headerView.titleLabel.text = category
            return headerView
        }
        return UICollectionReusableView()
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == descView && textView.text == "Description" {
            textView.text = ""
            textView.textColor = .label
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descView && textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Description"
            textView.textColor = .secondaryLabel
        }
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray4
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class AddPhotoCell: UICollectionViewCell {
    let plusView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray5
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    let plusLabel: UILabel = {
        let l = UILabel()
        l.text = "+"
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textColor = .systemBlue
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(plusView)
        plusView.addSubview(plusLabel)
        NSLayoutConstraint.activate([
            plusView.topAnchor.constraint(equalTo: contentView.topAnchor),
            plusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            plusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            plusView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            plusLabel.centerXAnchor.constraint(equalTo: plusView.centerXAnchor),
            plusLabel.centerYAnchor.constraint(equalTo: plusView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension BeHopeViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == priceField {
            let currentText = textField.text ?? ""
            if Range(range, in: currentText) != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.updateAutoPrice()
                }
            }
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usageField {
            if usageField.text?.isEmpty ?? true {
                usagePicker.selectRow(0, inComponent: 0, animated: false)
                usageField.text = usageOptions[0]
                updateAutoPrice()
            }
        }
    }
} 