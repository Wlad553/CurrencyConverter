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
        viewModel = MainViewModel(router: AppCoordinator().weakRouter,
                                  coreDataManager: CoreDataManager(),
                                  networkCurrenciesDataManager: NetworkRatesDataManager())
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
        
        viewModel.fetchRatesDataIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.fitTableViewHeightToNumberOfRows(animated: false)
    }
    
    // MARK: - Subscription List
    private func makeSubscriptions() {
        subscribeToRatesDataError()
        subscribeToConvertedAmounts()
        subscribeToTapRecognizerEvent()
        subscribeToViewButtonsTap()
        subscribeToAddCurrencyButtonTap()
        bindFavoriteCurrenciesToFavoriteCurrenciesTableView()
        subscribeToTableViewEvents()
        subscribeToFavoriteCurrencies()
        addNotificationCenterRxObservers()
    }
    
    // MARK: ViewModel Subscriptions
    private func subscribeToRatesDataError() {
        viewModel.ratesData
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] ratesData in
                guard let self = self, let firstRateObject = ratesData.first else { return }
                mainView.lastUpdatedSublabel.text = viewModel.dateFormattedRequestTime(requestTimestamp: firstRateObject.requestTimestamp)
            },
                       onError: { [weak self] error in
                self?.presentOkActionAlertController(title: "Currency Rates Download Error",
                                                     message: "Unable to download currency rates, please check your network connection or try again later")
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToConvertedAmounts() {
        viewModel.convertedAmounts
            .subscribe(onNext: { [weak self] double in
                guard let self = self else { return }
                mainView.visibleCells.forEach { cell in
                    guard let currency = cell.viewModel?.currency.value,
                          let convertedAmount = self.viewModel.convertedAmounts.value[currency]
                    else {
                        cell.amountTextField.text = String()
                        return
                    }
                    if !cell.amountTextField.isFirstResponder {
                        cell.amountTextField.text = ConverterNumberFormatter().convertToString(double: convertedAmount)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: UIView Events Subscriptions
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
                    self.viewModel.selectedPrice = newSelectedPrice
                    self.mainView.animatePriceButtonsTap(sender: button)
                    self.viewModel.updateConvertedAmountsIfNeeded()
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
        
        // Share button
        mainView.shareButton.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                guard let stringToShare = self?.viewModel.stringToShare(), !stringToShare.isEmpty else {
                    self?.presentOkActionAlertController(title: "Nothing to share",
                                                         message: "Please, type convert amount first")
                    return
                }
                
                let activityViewController = UIActivityViewController(activityItems: [stringToShare], applicationActivities: nil)
                self?.present(activityViewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
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
    
    private func presentOkActionAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        okAction.accessibilityIdentifier = "okAction"
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }}

// MARK: - UICollectionViewDataSource & Subscriptions
extension MainViewController {
    private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfCurrencies> {
        let animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                            reloadAnimation: .fade,
                                                            deleteAnimation: .fade)
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionOfCurrencies>(animationConfiguration: animationConfiguration,
                                                                                     configureCell: { [weak self] _, tableView, indexPath, currency in
            guard let self = self,
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCurrencyCell.reuseIdentifier, for: indexPath) as? FavoriteCurrencyCell
            else { return UITableViewCell() }
            cell.viewModel = CurrencyCellViewModel(currency: currency)
            cell.isEditingToggle(animated: false, isTableViewEditing: mainView.isTableViewEditing.value)
            let formatter = ConverterNumberFormatter()
            if let convertedAmount = viewModel.convertedAmounts.value[currency] {
                cell.amountTextField.text = formatter.convertToString(double: convertedAmount)
            }
            cell.amountTextField.rx
                .controlEvent(.editingChanged)
                .subscribe(onNext: { [weak self] _ in
                    guard let newText = cell.amountTextField.text,
                          let amount = formatter.number(from: newText)?.doubleValue
                    else {
                        self?.viewModel.convertedAmounts.accept([:])
                        return
                    }
                    self?.viewModel.convert(amount: amount, convertedCurrency: currency)
                })
                .disposed(by: disposeBag)
            return cell
        },
                                                                                     canEditRowAtIndexPath: { _, _ in true },
                                                                                     canMoveRowAtIndexPath: { _, _ in true })
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
