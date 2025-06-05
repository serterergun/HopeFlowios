import UIKit
import MapKit
import CoreLocation

protocol LocationPickerDelegate: AnyObject {
    func locationPicker(didSelect location: CLLocationCoordinate2D, range: Double, address: String)
}

class LocationPickerViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    weak var delegate: LocationPickerDelegate?
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    private let mapView = MKMapView()
    private let applyButton = UIButton(type: .system)
    private let addressLabel = UILabel()
    private let searchBar = UISearchBar()
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var selectedCoordinate: CLLocationCoordinate2D?
    private var selectedAddress: String?
    private var searchTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        mapView.delegate = self
        setupUI()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchBar.delegate = self
        searchCompleter.delegate = self
    }

    private func setupUI() {
        // Search Bar
        searchBar.placeholder = "Search for address"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        // Address label
        addressLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addressLabel.textColor = .label
        addressLabel.textAlignment = .center
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addressLabel)
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addressLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        // Map
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        // Apply button
        applyButton.setTitle("Apply", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        applyButton.backgroundColor = .systemPurple
        applyButton.layer.cornerRadius = 22
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        view.addSubview(applyButton)
        NSLayoutConstraint.activate([
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            applyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchTableView == nil {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.dataSource = self
            tableView.delegate = self
            view.addSubview(tableView)
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.heightAnchor.constraint(equalToConstant: 200)
            ])
            searchTableView = tableView
        }
        searchTableView?.isHidden = false
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchTableView?.isHidden = true
    }

    // MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            selectedCoordinate = annotation.coordinate
        }
    }

    @objc private func applyTapped() {
        let coordinate = selectedCoordinate ?? currentLocation
        let address = addressLabel.text ?? ""
        if let loc = coordinate {
            delegate?.locationPicker(didSelect: loc, range: 0, address: address)
            self.dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Location unavailable", message: "Please select a location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            currentLocation = loc.coordinate
            let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: true)
            let pin = MKPointAnnotation()
            pin.coordinate = loc.coordinate
            mapView.addAnnotation(pin)
            // Adres bul
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
                if let placemark = placemarks?.first {
                    self?.addressLabel.text = [placemark.locality, placemark.subLocality, placemark.name].compactMap { $0 }.joined(separator: ", ")
                }
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        addressLabel.text = "Location unavailable"
    }
}

extension LocationPickerViewController: MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableView?.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            self?.selectedCoordinate = coordinate
            self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            self?.mapView.addAnnotation(pin)
            self?.mapView.setCenter(coordinate, animated: true)
            self?.addressLabel.text = completion.title + (completion.subtitle.isEmpty ? "" : ", " + completion.subtitle)
            self?.searchBar.resignFirstResponder()
            self?.searchTableView?.isHidden = true
        }
    }
} 