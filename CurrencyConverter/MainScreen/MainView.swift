//
//  MainView.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

final class MainView: UIView {
    private let scrollView = ScrollView()
    private let elipseView = EllipseView()
    private let appNameLabel = UILabel()
    
    private let windowView = WindowView()
    private var priceButtonsHStack = UIStackView()
    let askButton = ConfigurationButton()
    let bidButton = ConfigurationButton()
    let favoriteCurrenciesTableView = UITableView()
    let addCurrencyButton = ConfigurationButton()
    let editButton = ConfigurationButton()
    let shareButton = ConfigurationButton()
    
    private let bottomLabelsVStack = UIStackView()
    private let lastUpdatedLabel = UILabel()
    let lastUpdatedSublabel = UILabel()
    
    let tapRecognizer = UITapGestureRecognizer()
    
    private var isWindowViewAnimationEnabled = false
    let isTableViewEditing = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    var visibleCells: [FavoriteCurrencyCell] {
        var cells: [FavoriteCurrencyCell] = []
            (0..<favoriteCurrenciesTableView.numberOfRows(inSection: 0)).forEach { row in
                guard let cell = favoriteCurrenciesTableView.cellForRow(at: IndexPath(row: row, section: 0)) as? FavoriteCurrencyCell else { return }
                cells.append(cell)
        }
        return cells
    }
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        insertSubview(elipseView, at: 0)
        setUpScrollView()
        setUpTapGestureRecognizer()
        setUpBottomLabelsVStack()
        setUpLabels()
        setUpWindowView()
        addConstraints()
        bindIsTableViewEditingToTableViewIsEditing()
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        super.init(coder: coder)
    }
    
    // MARK: - Overridden Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setPriceButtonsHStackSpacingForTraitCollection(traitCollection)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fitTableViewHeightToNumberOfRows(animated: true)
        toggleTableViewCellsIsEditing(animated: true, isTableViewEditing: isTableViewEditing.value)
        if !isWindowViewAnimationEnabled {
            isWindowViewAnimationEnabled = true
        }
    }
    
    // MARK: - Subviews' setup
    private func setUpScrollView() {
        addSubview(scrollView)
        scrollView.delaysContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
    }
    
    private func setUpTapGestureRecognizer() {
        scrollView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.cancelsTouchesInView = false
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
        lastUpdatedSublabel.text = Characters.doubleHyphen
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
            button.tintColor = .black
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
        addCurrencyButton.configuration?.imagePadding = 5
        
        // editButton
        windowView.addSubview(editButton)
        editButton.tintColor = .tintColor
        editButton.setTitle("Edit", for: .normal)
        editButton.titleLabel?.font = UIFont(name: Fonts.Lato.regular, size: 17)
        
        // shareButton
        windowView.addSubview(shareButton)
        shareButton.tintColor = .darkGray
        shareButton.configuration?.background = .clear()
        shareButton.configuration?.background.image = UIImage(systemName: "square.and.arrow.up")
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
            make.height.equalTo(70)
        }
        
        addCurrencyButton.snp.makeConstraints { make in
            make.top.equalTo(favoriteCurrenciesTableView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(addCurrencyButton.snp.bottom).offset(8)
            make.bottom.trailing.equalToSuperview().inset(16)
        }
        
        shareButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(16)
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
            make.top.greaterThanOrEqualTo(appNameLabel.snp.bottom).offset(16)
        }
        
        bottomLabelsVStack.snp.makeConstraints { make in
            make.top.equalTo(windowView.snp.bottom).offset(16)
            make.leading.equalTo(windowView.snp.leading).offset(4)
        }
    }

    // MARK: - Subscriptions
    private func bindIsTableViewEditingToTableViewIsEditing() {
        isTableViewEditing
            .bind(to: favoriteCurrenciesTableView.rx.isEditing)
            .disposed(by: disposeBag)
    }
}

// MARK: - Animations
extension MainView {
    // Bid & Ask Buttons
    func animatePriceButtonsTap(sender: UIButton) {
        sender.isEnabled = false
        UIView.animate(withDuration: 0.2) {
            sender.layer.backgroundColor = UIColor.dodgerBlue.cgColor
        }
        [bidButton, askButton].forEach { button in
            guard button != sender  else { return }
            button.isEnabled = true
            UIView.animate(withDuration: 0.1) {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    // TableView
    func fitTableViewHeightToNumberOfRows(animated: Bool) {
        let numberOfRows = favoriteCurrenciesTableView.numberOfRows(inSection: 0)
        let maxNumberOfCellsToFit: Int
        let numberOfCellsToPass: Int
        
        if traitCollection.verticalSizeClass == .compact {
            let zeroCellsWindowViewHeight = windowView.frame.height - favoriteCurrenciesTableView.frame.height
            maxNumberOfCellsToFit = Int((frame.height - zeroCellsWindowViewHeight) / favoriteCurrenciesTableView.rowHeight)
        } else {
            let zeroCellsViewBottomElementYCoordinate = bottomLabelsVStack.frame.origin.y + bottomLabelsVStack.frame.height - favoriteCurrenciesTableView.frame.height
            let viewHeight = frame.height - safeAreaInsets.top - 16
            maxNumberOfCellsToFit = Int((viewHeight - zeroCellsViewBottomElementYCoordinate) / favoriteCurrenciesTableView.rowHeight)
        }
        
        numberOfCellsToPass = isWindowViewAnimationEnabled ? min(numberOfRows, maxNumberOfCellsToFit) : numberOfRows
        
        favoriteCurrenciesTableView.snp.updateConstraints { make in
            make.height.equalTo(CGFloat(numberOfCellsToPass) * favoriteCurrenciesTableView.rowHeight)
        }
        
        guard isWindowViewAnimationEnabled else { return }
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.windowView.isShadowPathAnimationEnabled = true
        }
    }
    
    func toggleTableViewCellsIsEditing(animated: Bool, isTableViewEditing: Bool) {
        visibleCells.forEach { cell in
            cell.isEditingToggle(animated: animated, isTableViewEditing:  isTableViewEditing)
        }
    }
    
    func toggleTableViewIsEditing() {
        if favoriteCurrenciesTableView.isEditing {
            favoriteCurrenciesTableView.setEditing(false, animated: true)
            isTableViewEditing.accept(false)
            toggleTableViewCellsIsEditing(animated: true, isTableViewEditing: false)
        } else {
            endEditing(true)
            toggleTableViewCellsIsEditing(animated: true, isTableViewEditing: true)
            self.favoriteCurrenciesTableView.setEditing(true, animated: true)
            self.isTableViewEditing.accept(true)
        }
    }
    
    // ScrollView Offset
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
