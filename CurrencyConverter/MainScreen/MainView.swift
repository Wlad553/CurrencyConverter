//
//  MainView.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit

final class MainView: UIView {
    let scrollView = ScrollView()
    private let elipseView = EllipseView()
    private let appNameLabel = UILabel()
    
    private let windowView = WindowView()
    private var windowHStack = UIStackView()
    let askButton = UIButton(type: .system)
    let bidButton = UIButton(type: .system)
    let favoriteCurrenciesTableView = UITableView()
    let addCurrencyButton = UIButton()
    let shareButton = UIButton(type: .system)
    
    private var selectedButton: UIButton {
        bidButton.isEnabled ? askButton : bidButton
    }
//    private let tapRecognizer = UITapGestureRecognizer()
    
    private let bottomLabelsVStack = UIStackView()
    let lastUpdatedLabel = UILabel()
    let lastUpdatedSublabel = UILabel()
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setUpElipseView()
        setUpScrollView()
        setUpBottomLabelsVStack()
        setUpLabels()
        setUpWindowView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    // MARK: - Overridden Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setWindowHStackSpacingForTraitCollection(traitCollection)
    }
    
    // MARK: - Subviews' setup
    private func setUpElipseView() {
        insertSubview(elipseView, at: 0)
    }
    
    private func setUpScrollView() {
        addSubview(scrollView)
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpBottomLabelsVStack() {
        scrollView.addSubview(bottomLabelsVStack)
        bottomLabelsVStack.axis = .vertical
        bottomLabelsVStack.alignment = .fill
        bottomLabelsVStack.distribution = .fill
        bottomLabelsVStack.spacing = 8
    }
    
    private func setUpLabels() {
        // appNameLabel
        scrollView.addSubview(appNameLabel)
        appNameLabel.text = "Currency Converter"
        appNameLabel.textColor = .white
        appNameLabel.font = UIFont(name: Fonts.Lato.black, size: 24)
        appNameLabel.accessibilityIdentifier = "appNameLabel"
        
        // lastUpdatedLabel & lastUpdatedSublabel
        [lastUpdatedLabel, lastUpdatedSublabel].forEach { label in
            bottomLabelsVStack.addArrangedSubview(label)
            label.font = UIFont(name: Fonts.Lato.regular, size: 14)
            label.textColor = .darkGray
            label.textAlignment = .left
        }
        
        // lastUpdatedLabel
        lastUpdatedLabel.text = "Last updated"
        
        // lastUpdatedSublabel
        lastUpdatedSublabel.text = "--"
    }
    
    // MARK: - windowView Subviews' setup
    private func setUpWindowView() {
        scrollView.addSubview(windowView)
        setUpWindowStackView()
        setUpWindowViewButtons()
        setUpFavoriteCurrenciesTableView()
        addWindowSubviewsConstraints()
    }
    
    private func setUpWindowStackView() {
        windowView.addSubview(windowHStack)
        windowHStack.axis = .horizontal
        windowHStack.alignment = .fill
        windowHStack.distribution = .fillEqually
        setWindowHStackSpacingForTraitCollection(traitCollection)
    }
    
    private func setWindowHStackSpacingForTraitCollection(_ traitCollection: UITraitCollection) {
            if traitCollection.horizontalSizeClass == .regular {
                windowHStack.spacing = 200
            } else if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .compact {
                windowHStack.spacing = 80
            } else {
                windowHStack.spacing = 44
            }
        }
    
    private func setUpWindowViewButtons() {
        // Bid&Ask Buttons
        [bidButton, askButton].forEach { button in
            windowHStack.addArrangedSubview(button)
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont(name: Fonts.Lato.regular, size: 18)
            button.setTitleColor(.white, for: .disabled)
            button.setTitleColor(.black, for: .normal)
        }
        
        // bidButton
        bidButton.setTitle("Bid", for: .normal)
        bidButton.isEnabled = false
        bidButton.layer.backgroundColor = UIColor.dodgerBlue.cgColor
        
        // askButton
        askButton.setTitle("Ask", for: .normal)
        askButton.setTitleColor(.black, for: .normal)
        askButton.layer.backgroundColor = UIColor.white.cgColor
        
        // addCurrencyButton
        windowView.addSubview(addCurrencyButton)
        addCurrencyButton.setTitle("Add Currency", for: .normal)
        addCurrencyButton.titleLabel?.font = UIFont(name: Fonts.Lato.regular, size: 17)
        addCurrencyButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        
        var addCurrencyButtonConfiguration = UIButton.Configuration.plain()
        addCurrencyButtonConfiguration.imagePadding = 5
        addCurrencyButton.configuration = addCurrencyButtonConfiguration
        
        // shareButton
        windowView.addSubview(shareButton)
        shareButton.tintColor = .darkGray
        shareButton.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
    }
    
    private func setUpFavoriteCurrenciesTableView() {
        windowView.addSubview(favoriteCurrenciesTableView)
        favoriteCurrenciesTableView.rowHeight = 70
        favoriteCurrenciesTableView.separatorStyle = .none
        favoriteCurrenciesTableView.allowsSelection = false
        favoriteCurrenciesTableView.alwaysBounceVertical = false
        favoriteCurrenciesTableView.accessibilityIdentifier = "mainWindowViewTableView"
        favoriteCurrenciesTableView.register(FavoriteCurrencyCell.self,
                                             forCellReuseIdentifier: FavoriteCurrencyCell.reuseIdentifier)
    }
    
    // MARK: windowView Subviews' Constraints
    private func addWindowSubviewsConstraints() {
        windowHStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        favoriteCurrenciesTableView.snp.makeConstraints { make in
            make.top.equalTo(windowHStack.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().priority(999)
            make.width.lessThanOrEqualTo(361)
        }
        
        addCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(favoriteCurrenciesTableView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(addCurrencyButton.snp.bottom).offset(8)
            make.trailing.bottom.equalToSuperview().inset(16)
            make.width.equalTo(32)
            make.height.equalTo(36)
        }
    }
    
    // MARK: - View Constraints
    private func addConstraints() {
        elipseView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(bottomLabelsVStack.snp.bottom).offset(16)
        }
        
        scrollView.frameLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(scrollView)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.lessThanOrEqualTo(scrollView.frameLayoutGuide).offset(64)
        }
        
        windowView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(120)
            make.height.equalTo(390)
            make.top.greaterThanOrEqualTo(appNameLabel.snp.bottom).offset(16)
        }
        
        bottomLabelsVStack.snp.makeConstraints { make in
            make.top.equalTo(windowView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
    }
}

// MARK: Animations
extension MainView {
    func buttonsUIUpdateAction(sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.layer.backgroundColor = UIColor.dodgerBlue.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // disable a button in the middle of animation duration so that the color smoothly changed from black to white
            sender.isEnabled = false
        }
        for button in [bidButton, askButton] {
            guard button != sender  else { continue }
            UIView.animate(withDuration: 0.2) {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.isEnabled = true
            }
        }
    }
}
