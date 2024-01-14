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
        viewModel = CurrenciesViewModel(router: AppCoordinator().weakRouter)
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
        bindCurrenciesToTableView()
        subscribeToCancelBarButtonTap()
    }
    
    // MARK: - NavigationItem setup
    private func setUpNavigationItem() {
        viewController.navigationItem.title = "Currencies"
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel")
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.searchTextField.font = UIFont(name: Fonts.Lato.regular, size: 17)
        searchController.searchBar.searchTextField.accessibilityIdentifier = "searchTextField"
    }
    
    // MARK: - Subscriptions
    private func bindCurrenciesToTableView() {
        viewModel.currencies
            .bind(to: currenciesView.currenciesTableView.rx
                .items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
    
    private func subscribeToCancelBarButtonTap() {
        navigationItem.leftBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDataSource
extension CurrenciesViewController {
    private func tableViewDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfCurrencies> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCurrencies> { _, tableView, indexPath, currency in
            let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.reuseIdentifier, for: indexPath)
            (cell as? CurrencyCell)?.viewModel = CurrencyCellViewModel(currency: currency)
            return cell
        }
        
    titleForHeaderInSection: { _, section in
        guard let headerTitleCharacter = self.viewModel.currencies.value[section].items.first?.code.first else { return nil }
        return String(headerTitleCharacter)
    }
        return dataSource
    }
}

// MARK: UISearchResultsUpdating
extension CurrenciesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

