//
//  CurrenciesViewController.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import UIKit
import RxSwift
import RxDataSources

final class CurrenciesViewController: UIViewController {
    let currenciesView = CurrenciesView()
    let searchController = UISearchController()
    let viewModel: CurrenciesViewModelType
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Inits
    init(viewModel: CurrenciesViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        viewModel = CurrenciesViewModel(excludedCurrencies: [],
                                        router: AppCoordinator().weakRouter)
        super.init(coder: coder)
    }
    
    // MARK: - ViewController Lifecycle
    override func loadView() {
        super.loadView()
        view = currenciesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        makeSubscriptions()
    }
    
    // MARK: - NavigationItem setup
    private func setUpNavigationItem() {
        navigationItem.title = "Currencies"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel")
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "cancelButton"
        
        navigationItem.searchController = searchController
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.searchTextField.font = UIFont(name: Fonts.Lato.regular, size: 17)
        searchController.searchBar.searchTextField.accessibilityIdentifier = "searchTextField"
    }
    
    // MARK: - Subscriptions
    private func makeSubscriptions() {
        bindCurrenciesToTableView()
        subscribeToCancelBarButtonTap()
        subscribeToWillBeginDragging()
        subscribeToSearchResultsUpdate()
        addNotificationCenterRxObservers()
        subscribeToRowSelection()
    }
    
    // TableView Data
    private func bindCurrenciesToTableView() {
        viewModel.displayedCurrencies
            .bind(to: currenciesView.currenciesTableView.rx
                .items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
    
    // Cancel Button
    private func subscribeToCancelBarButtonTap() {
        navigationItem.leftBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // ScrollView
    private func subscribeToWillBeginDragging() {
        currenciesView.currenciesTableView.rx
            .willBeginDragging
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.searchController.searchBar.searchTextField.isFirstResponder {
                    self.searchController.searchBar.searchTextField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // Navigation
    private func subscribeToRowSelection() {
        currenciesView.currenciesTableView.rx
            .modelSelected(Currency.self)
            .subscribe { [weak self] currency in
                self?.viewModel.triggerUnwind(selectedCurrency: currency)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView DataSource
extension CurrenciesViewController {
    private func tableViewDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfCurrencies> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCurrencies> { _, tableView, indexPath, currency in
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.reuseIdentifier, for: indexPath)
            (cell as? CurrencyCell)?.viewModel = CurrencyCellViewModel(currency: currency)
            return cell
        }
        
    titleForHeaderInSection: { [weak self] _, section in
        guard let displayedCurrencies = self?.viewModel.displayedCurrencies.value[section].items else { return nil }
        if let searchText = self?.searchController.searchBar.text,
           !searchText.isEmpty && !displayedCurrencies.isEmpty {
            return "Top results"
        }
        
        if let headerTitleCharacter = displayedCurrencies.first?.code.first {
            return String(headerTitleCharacter)
        }
        
        return nil
    }
        return dataSource
    }
}

// MARK: SearchResultsUpdate
extension CurrenciesViewController {
    private func subscribeToSearchResultsUpdate() {
        searchController.searchBar.rx.text.orEmpty
            .subscribe(onNext: { [weak self] searchText in
                guard let self = self else { return }
                if searchText.isEmpty {
                    currenciesView.noSearchResultsVStack.isHidden = true
                    viewModel.displayedCurrencies.accept(
                        viewModel.availableCurrencies.alphabeticallyGroupedSections()
                    )
                    return
                }
                
                let filteredResults = viewModel.searchControllerManager.filteredResultsWith(searchText,
                                                                                            arrayToFilter: viewModel.availableCurrencies)
                viewModel.displayedCurrencies.accept(
                    [SectionOfCurrencies(items: filteredResults)]
                )

                if filteredResults.isEmpty {
                    currenciesView.noSearchResultsVStack.isHidden = false
                    currenciesView.noSearchResultsLabel.text = #"No results for "\#(searchText)""#
                } else {
                    currenciesView.noSearchResultsVStack.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx
            .cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                currenciesView.noSearchResultsVStack.isHidden = true
                viewModel.displayedCurrencies.accept(
                    viewModel.availableCurrencies.alphabeticallyGroupedSections()
                )
            })
            .disposed(by: disposeBag)
    }
}

// MARK: NotificationCenter Subscriptions
extension CurrenciesViewController {
    private func addNotificationCenterRxObservers() {
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.currenciesView.animateSearchResultsVStack(notification: notification)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.currenciesView.animateSearchResultsVStack(notification: notification)
            })
            .disposed(by: disposeBag)
    }
}

