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
    private var priceButtonsHStack = UIStackView()
    let askButton = UIButton(type: .system)
    let bidButton = UIButton(type: .system)
    let favoriteCurrenciesTableView = UITableView()
    let addCurrencyButton = UIButton()
    let shareButton = UIButton(type: .system)
    
    private let bottomLabelsVStack = UIStackView()
    private let lastUpdatedLabel = UILabel()
    let lastUpdatedSublabel = UILabel()
    
    let tapRecognizer = UITapGestureRecognizer()
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        insertSubview(elipseView, at: 0)
        setUpScrollView()
        setUpBottomLabelsVStack()
        setUpLabels()
        setUpWindowView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Overridden Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setPriceButtonsHStackSpacingForTraitCollection(traitCollection)
    }
    
    // MARK: - Subviews' setup
    private func setUpScrollView() {
        addSubview(scrollView)
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addGestureRecognizer(tapRecognizer)
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
        lastUpdatedSublabel.text = CharacterConstants.doubleHyphen
    }
    
    // MARK: - windowView Subviews' setup
    private func setUpWindowView() {
        scrollView.addSubview(windowView)
        setUpPriceButtonsHStack()
        setUpWindowViewButtons()
        setUpFavoriteCurrenciesTableView()
        addWindowSubviewsConstraints()
    }
    
    private func setUpPriceButtonsHStack() {
        windowView.addSubview(priceButtonsHStack)
        priceButtonsHStack.axis = .horizontal
        priceButtonsHStack.alignment = .fill
        priceButtonsHStack.distribution = .fillEqually
        setPriceButtonsHStackSpacingForTraitCollection(traitCollection)
    }
    
    private func setPriceButtonsHStackSpacingForTraitCollection(_ traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact &&
            traitCollection.verticalSizeClass == .regular {
            priceButtonsHStack.spacing = 44
        } else {
            priceButtonsHStack.spacing = 80
        }
    }
    
    private func setUpWindowViewButtons() {
        // Bid&Ask Buttons
        [bidButton, askButton].forEach { button in
            priceButtonsHStack.addArrangedSubview(button)
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
        favoriteCurrenciesTableView.showsVerticalScrollIndicator = false
        favoriteCurrenciesTableView.accessibilityIdentifier = "mainWindowViewTableView"
        favoriteCurrenciesTableView.register(FavoriteCurrencyCell.self,
                                             forCellReuseIdentifier: FavoriteCurrencyCell.reuseIdentifier)
    }
    
    // MARK: windowView Subviews' Constraints
    private func addWindowSubviewsConstraints() {
        priceButtonsHStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        favoriteCurrenciesTableView.snp.makeConstraints { make in
            make.top.equalTo(priceButtonsHStack.snp.bottom).offset(16)
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
            make.leading.equalTo(windowView.snp.leading).offset(8)
            make.top.lessThanOrEqualTo(scrollView.frameLayoutGuide).offset(64)
        }
        
        windowView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16).priority(999)
            make.centerX.equalToSuperview()
            make.width.equalTo(550).priority(999)
            make.top.equalToSuperview().offset(120)
            make.height.equalTo(390)
            make.top.greaterThanOrEqualTo(appNameLabel.snp.bottom).offset(16)
        }
        
        bottomLabelsVStack.snp.makeConstraints { make in
            make.top.equalTo(windowView.snp.bottom).offset(16)
            make.leading.equalTo(windowView.snp.leading).offset(4)
        }
    }
}

// MARK: Animations
extension MainView {
    func animatePriceButtonsTap(sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            sender.layer.backgroundColor = UIColor.dodgerBlue.cgColor
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) {
            // disable a button in the middle of animation duration so that the color smoothly changed from black to white
            sender.isEnabled = false
        }
        [bidButton, askButton].forEach { button in
            guard button != sender  else { return }
            UIView.animate(withDuration: 0.2) {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.isEnabled = true
            }
        }
    }
    
    func toggleScrollViewContentOffset(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
}
