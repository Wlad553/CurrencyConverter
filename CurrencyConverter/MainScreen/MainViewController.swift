//
//  MainViewController.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 12/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MainViewController: UIViewController {
    let mainView = MainView()
    let viewModel: MainViewModelType
    
    private let disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Inits
    init(viewModel: MainViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        viewModel = MainViewModel(router: AppCoordinator().weakRouter)
        super.init(coder: coder)
    }
    
    // MARK: - ViewController Lifecycle
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.fitTableViewHeightToNumberOfRows(animated: false)
    }
    
    // MARK: - Subscription List
    private func makeSubscriptions() {
        subscribeToTapRecognizerEvent()
        subscribeToViewButtonsTap()
        subscribeToAddCurrencyButtonTap()
        bindFavoriteCurrenciesToFavoriteCurrenciesTableView()
        subscribeToTableViewEvents()
        subscribeToFavoriteCurrencies()
        addNotificationCenterRxObservers()
    }
    
    // MARK: Subscriptions
    private func subscribeToTapRecognizerEvent() {
        mainView.tapRecognizer.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToViewButtonsTap() {
        // Bid & Ask buttons
        [mainView.bidButton, mainView.askButton].forEach { [weak self] button in
            guard let self = self else { return }
            button.rx
                .tap
                .subscribe (onNext: { _ in
                    let newSelectedPrice: Currency.Price = self.mainView.bidButton.isEnabled ? .bid : .ask
                    self.viewModel.selectedPrice.accept(newSelectedPrice)
                    self.mainView.animatePriceButtonsTap(sender: button)
                })
                .disposed(by: self.disposeBag)
        }
        
        // Edit button
        mainView.editButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.mainView.toggleTableViewIsEditing()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Navigation
    private func subscribeToAddCurrencyButtonTap() {
        mainView.addCurrencyButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                view.endEditing(true)
                if mainView.favoriteCurrenciesTableView.isEditing {
                    mainView.toggleTableViewIsEditing()
                }
                viewModel.prepareForTransition()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource & Subscriptions
extension MainViewController {
    private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfCurrencies> {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                            reloadAnimation: .fade,
                                                            deleteAnimation: .fade)
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCurrencies>(animationConfiguration: animationConfiguration,
                                                                                     configureCell: { [weak self] _, tableView, indexPath, currency in
            guard let self = self else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCurrencyCell.reuseIdentifier, for: indexPath)
            (cell as? FavoriteCurrencyCell)?.viewModel = CurrencyCellViewModel(currency: currency)
            (cell as? FavoriteCurrencyCell)?.isEditingToggle(animated: false, isTableViewEditing: mainView.isTableViewEditing.value)
            return cell
        },
                                                                                     canEditRowAtIndexPath: { _, _ in true },
                                                                                     canMoveRowAtIndexPath: { _, _ in true})
        return dataSource
    }
    
    private func bindFavoriteCurrenciesToFavoriteCurrenciesTableView() {
        viewModel.favoriteCurrencies
            .bind(to: mainView.favoriteCurrenciesTableView.rx
                .items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
    
    private func subscribeToTableViewEvents() {
        mainView.favoriteCurrenciesTableView.rx
            .modelDeleted(Currency.self)
            .subscribe (onNext: { [weak self] currency in
                self?.viewModel.deleteCurrencyFromFavorites(currency)
            })
            .disposed(by: disposeBag)
        
        mainView.favoriteCurrenciesTableView.rx
            .itemMoved
            .subscribe(onNext: { [weak self] sourceIndexPath, destinationIndexPath in
                self?.viewModel.moveCurrency(from: sourceIndexPath, to: destinationIndexPath)
                
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToFavoriteCurrencies() {
        viewModel.favoriteCurrencies
            .subscribe(onNext: { [weak self] _ in
                self?.mainView.fitTableViewHeightToNumberOfRows(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: NotificationCenter Subscriptions
extension MainViewController {
    private func addNotificationCenterRxObservers() {
        NotificationCenter.default.rx
           .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.mainView.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
           .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.mainView.toggleScrollViewContentOffset(notification: notification)
            })
            .disposed(by: disposeBag)
    }
}
