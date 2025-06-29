import UIKit
import PhotosUI

class EditProductViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    private let product: Product
    var onProductUpdated: (() -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let priceTextField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let conditionButton = UIButton(type: .system)
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        return cv
    }()
    
    private var selectedCategory: Int?
    private var selectedCondition: String?
    private var selectedPhotos: [UIImage] = []
    private var charities: [Charity] = []
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit Donation"
        setupNavigationBar()
        setupScrollView()
        setupUI()
        loadProductData()
        fetchCharities()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupUI() {
        // Title Field
        let titleLabel = UILabel()
        titleLabel.text = "Product Name"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.placeholder = "Enter product name"
        titleTextField.borderStyle = .roundedRect
        titleTextField.delegate = self
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Description Field
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Description"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Price Field
        let priceLabel = UILabel()
        priceLabel.text = "Price (£)"
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priceTextField.placeholder = "0.00"
        priceTextField.borderStyle = .roundedRect
        priceTextField.keyboardType = .decimalPad
        priceTextField.delegate = self
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Category Button
        let categoryLabel = UILabel()
        categoryLabel.text = "Category"
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryButton.setTitle("Select Category", for: .normal)
        categoryButton.backgroundColor = .systemGray6
        categoryButton.layer.cornerRadius = 8
        categoryButton.contentHorizontalAlignment = .left
        var categoryConfig = UIButton.Configuration.plain()
        categoryConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        categoryButton.configuration = categoryConfig
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Condition Button
        let conditionLabel = UILabel()
        conditionLabel.text = "Condition"
        conditionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        conditionButton.setTitle("Select Condition", for: .normal)
        conditionButton.backgroundColor = .systemGray6
        conditionButton.layer.cornerRadius = 8
        conditionButton.contentHorizontalAlignment = .left
        var conditionConfig = UIButton.Configuration.plain()
        conditionConfig.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        conditionButton.configuration = conditionConfig
        conditionButton.addTarget(self, action: #selector(conditionTapped), for: .touchUpInside)
        conditionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Photos Section
        let photosLabel = UILabel()
        photosLabel.text = "Photos"
        photosLabel.font = UIFont.boldSystemFont(ofSize: 16)
        photosLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let addPhotoButton = UIButton(type: .system)
        addPhotoButton.setTitle("Add Photo", for: .normal)
        addPhotoButton.backgroundColor = .systemBlue
        addPhotoButton.setTitleColor(.white, for: .normal)
        addPhotoButton.layer.cornerRadius = 8
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all views to content view
        [titleLabel, titleTextField, descriptionLabel, descriptionTextView, priceLabel, priceTextField,
         categoryLabel, categoryButton, conditionLabel, conditionButton, photosLabel, addPhotoButton, photosCollectionView].forEach {
            contentView.addSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            priceLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceTextField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            priceTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            priceTextField.heightAnchor.constraint(equalToConstant: 44),
            
            categoryLabel.topAnchor.constraint(equalTo: priceTextField.bottomAnchor, constant: 20),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            conditionLabel.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 20),
            conditionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            conditionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            conditionButton.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 8),
            conditionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            conditionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            conditionButton.heightAnchor.constraint(equalToConstant: 44),
            
            photosLabel.topAnchor.constraint(equalTo: conditionButton.bottomAnchor, constant: 20),
            photosLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photosLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addPhotoButton.topAnchor.constraint(equalTo: photosLabel.bottomAnchor, constant: 8),
            addPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 120),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 44),
            
            photosCollectionView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 12),
            photosCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            photosCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 80),
            photosCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadProductData() {
        titleTextField.text = product.title
        descriptionTextView.text = product.description
        priceTextField.text = "\(product.priceAsDouble ?? 0)"
        selectedCategory = product.category_id
        
        if let categoryId = selectedCategory {
            let categoryName = categoryNames[categoryId] ?? "Unknown"
            categoryButton.setTitle(categoryName, for: .normal)
        }
    }
    
    private func fetchCharities() {
        Task {
            do {
                charities = try await NetworkManager.shared.fetchCharities()
            } catch {
                print("Failed to fetch charities: \(error)")
            }
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(title: "Error", message: "Please enter a product name")
            return
        }
        
        guard let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Please enter a description")
            return
        }
        
        guard let priceText = priceTextField.text, let price = Double(priceText), price >= 0 else {
            showAlert(title: "Error", message: "Please enter a valid price")
            return
        }
        
        guard let category = selectedCategory else {
            showAlert(title: "Error", message: "Please select a category")
            return
        }
        
        // Create updated product data
        let updatedProduct = [
            "title": title,
            "description": description,
            "price": price,
            "category_id": category
        ] as [String : Any]
        
        Task {
            do {
                try await NetworkManager.shared.updateListing(id: product.id ?? 0, data: updatedProduct)
                DispatchQueue.main.async {
                    self.onProductUpdated?()
                    self.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to update product: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func categoryTapped() {
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        
        for (id, name) in categoryNames {
            alert.addAction(UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.selectedCategory = id
                self?.categoryButton.setTitle(name, for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func conditionTapped() {
        let alert = UIAlertController(title: "Select Condition", message: nil, preferredStyle: .actionSheet)
        
        let conditions = ["New", "Like New", "Good", "Fair", "Poor"]
        for condition in conditions {
            alert.addAction(UIAlertAction(title: condition, style: .default) { [weak self] _ in
                self?.selectedCondition = condition
                self?.conditionButton.setTitle(condition, for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProductViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedPhotos.append(image)
                        self?.photosCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension EditProductViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
        
        let imageView = UIImageView()
        imageView.image = selectedPhotos[indexPath.item]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Remove photo
        selectedPhotos.remove(at: indexPath.item)
        collectionView.reloadData()
    }
} 