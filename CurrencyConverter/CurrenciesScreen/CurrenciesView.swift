//
//  CurrenciesView.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import UIKit

final class CurrenciesView: UIView {
    let currenciesTableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let noSearchResultsStackView = UIStackView()
    let noSearchResultsSublabel = UILabel()
    let noSearchResultsImageView = UIImageView()
    let noSearchResultsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setUpCurrenciesTableView()
        setUpNoSearchResultsStackView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        super.init(coder: coder)
    }
    
    private func setUpCurrenciesTableView() {
        addSubview(currenciesTableView)
        currenciesTableView.separatorStyle = .singleLine
        currenciesTableView.sectionHeaderHeight = 18
        currenciesTableView.sectionFooterHeight = 17
        currenciesTableView.accessibilityIdentifier = "mainWindowViewTableView"
        currenciesTableView.setContentOffset(CGPoint(x: 0, y: -56), animated: false)
        currenciesTableView.register(CurrencyCell.self,
                                             forCellReuseIdentifier: CurrencyCell.reuseIdentifier)
    }
    
    private func setUpNoSearchResultsStackView() {
        noSearchResultsImageView.image = UIImage(systemName: "magnifyingglass")
        noSearchResultsImageView.contentMode = .scaleAspectFit
        noSearchResultsImageView.tintColor = .systemGray
        noSearchResultsImageView.accessibilityIdentifier = "magnifyingGlass"
        
        noSearchResultsLabel.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        noSearchResultsLabel.numberOfLines = 0
        noSearchResultsLabel.textAlignment = .center
        noSearchResultsLabel.accessibilityIdentifier = "noSearchResultsLabel"
        
        noSearchResultsSublabel.font = UIFont.systemFont(ofSize: 14)
        noSearchResultsSublabel.textColor = noSearchResultsImageView.tintColor
        noSearchResultsSublabel.text = "Check the spelling or try a new search"
        noSearchResultsSublabel.accessibilityIdentifier = "noSearchResultsLabelSublabel"
        
        [noSearchResultsImageView, noSearchResultsLabel, noSearchResultsSublabel].forEach { view in
            noSearchResultsStackView.addArrangedSubview(view)
        }
        
        addSubview(noSearchResultsStackView)
        noSearchResultsStackView.isHidden = true
        noSearchResultsStackView.axis = .vertical
        noSearchResultsStackView.spacing = 8
        noSearchResultsStackView.distribution = .equalSpacing
        noSearchResultsStackView.alignment = .center
    }
    
    private func addConstraints() {
        currenciesTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        noSearchResultsImageView.snp.makeConstraints { make in
            make.height.equalTo(64)
            make.width.equalTo(48)
        }
        
        noSearchResultsStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
