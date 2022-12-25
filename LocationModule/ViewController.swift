//
//  ViewController.swift
//  LocationModule
//
//  Created by Jose on 23/12/2022.
//

import UIKit
import Combine

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    @IBOutlet weak var lblCourse: UILabel!
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    @IBOutlet weak var lblTimestamp: UILabel!
    
    // MARK: - Ivars
    let viewModel = ViewModel()
    var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startLocationManager()
    }
    
    // MARK: Private
    fileprivate func setupBindings() {
        viewModel.$hasError
            .receive(on: DispatchQueue.main)
            .filter{ $0 != "" && $0 != " " }
            .sink { [weak self] error in
                let alert = UIAlertController(title: NSLocalizedString("uhoh", comment: ""), message: error, preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default)
                alert.addAction(action)
                self?.present(alert, animated: true)
            }
            .store(in: &subscriptions)
        
        viewModel.latitudePublisher
            .assign(to: \.text, on: lblLatitude)
            .store(in: &subscriptions)
        
        viewModel.longitudePublisher
            .assign(to: \.text, on: lblLongitude)
            .store(in: &subscriptions)
        
        viewModel.speedPublisher
            .assign(to: \.text, on: lblSpeed)
            .store(in: &subscriptions)
        
        viewModel.coursePublisher
            .assign(to: \.text, on: lblCourse)
            .store(in: &subscriptions)
        
        viewModel.accuracyPublisher
            .assign(to: \.text, on: lblAccuracy)
            .store(in: &subscriptions)
        
        viewModel.timestampPublisher
            .assign(to: \.text, on: lblTimestamp)
            .store(in: &subscriptions)
    }
}

