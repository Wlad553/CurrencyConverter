//
//  MainViewController.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 12/01/2024.
//

import UIKit
import RxSwift
import RxCocoa
import XCoordinator

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
    
    // MARK: - Subscription List
    private func makeSubscriptions() {
        bindFavoriteCurrenciesToFavoriteCurrenciesTableView()
        subscribeToTapRecognizerEvent()
        subscribeToPriceButtonsTap()
        subscribeToAddCurrencyButtonTap()
        addRxObservers()
    }
    
    // MARK: Subscriptions
    private func subscribeToTapRecognizerEvent() {
        mainView.tapRecognizer.rx.event
            .subscribe { [weak self] _ in
                self?.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToPriceButtonsTap() {
        [mainView.bidButton, mainView.askButton].forEach { [weak self] button in
            guard let self = self else { return }
            button.rx
                .controlEvent(.touchUpInside)
                .subscribe (onNext: { _ in
                    let newSelectedPrice: Currency.Price = self.mainView.bidButton.isEnabled ? .bid : .ask
                    self.viewModel.selectedPrice.accept(newSelectedPrice)
                    self.mainView.animatePriceButtonsTap(sender: button)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: Navigation
    private func subscribeToAddCurrencyButtonTap() {
        mainView.addCurrencyButton.rx
            .controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.prepareForTransition()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController {
    private func bindFavoriteCurrenciesToFavoriteCurrenciesTableView() {
        viewModel.favoriteCurrencies
            .bind(to: mainView.favoriteCurrenciesTableView.rx
                .items(cellIdentifier: FavoriteCurrencyCell.reuseIdentifier, cellType: FavoriteCurrencyCell.self)) { _, currency, cell in
                    cell.viewModel = CurrencyCellViewModel(currency: currency)
                }
                .disposed(by: disposeBag)
    }
}

// MARK: NotificationCenter Subscriptions
extension MainViewController {
    private func addRxObservers() {
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
