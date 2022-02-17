//
//  CategoryTabBar.swift
//  MyStock
//
//  Created by 家瑋 on 2022/1/26.
//

import UIKit


// MARK: - TitleTabItem
final class TitleTabItem: UIControl {
    public var text: String {
        didSet {
            titleLabel.text = text
        }
    }
    
    public var edgeInset: UIEdgeInsets = .zero
    
    public var textColor: UIColor = .lightGray {
        didSet {
            updateAppearance()
        }
    }
    
    public var selectedTextColor: UIColor = .black {
        didSet {
            updateAppearance()
        }
    }
    
    public var textFont: UIFont = .systemFont(ofSize: 15.0, weight: .regular) {
        didSet {
            updateAppearance()
        }
    }
    
    public var preferredSize: CGSize {
        let height = frame.size.height
        let labelSize = titleLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                       height: height - edgeInset.top - edgeInset.bottom))
        let targetSize = CGSize(width: labelSize.width + edgeInset.left + edgeInset.right,
                                height: labelSize.height + edgeInset.top + edgeInset.bottom)
        return targetSize
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        preferredSize
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        createItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createItem() {
        backgroundColor = .clear
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.text = text
        
        addSubview(titleLabel)
        updateItemLayout()
    }
    
    private func updateItemLayout() {
        let topCons = titleLabel.topAnchor.constraint(equalTo: self.topAnchor)
        let bottomCons = titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leadingCons = titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailingCons = titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        NSLayoutConstraint.activate([
            topCons, bottomCons, leadingCons, trailingCons
        ])
    }
    
    public func updateAppearance() {
        titleLabel.font = textFont
        titleLabel.textColor = isSelected ? selectedTextColor : textColor
    }
    
    public func fitPreferredSize() {
        frame.size = preferredSize
    }
}



// MARK: - CategoryTabBar
protocol CategoryTabBarDelegate: NSObjectProtocol {
    func tabBarDidSelectItem(tabBar: CategoryTabBar, title: String, index: Int)
}

class CategoryTabBar: UIView {
    
    // MARK: - Public var
    public weak var delegate: CategoryTabBarDelegate?
    
    public var defaultIndex: Int = 0 {
        didSet {
            scrollTo(index: defaultIndex, animation: false)
        }
    }
    
    private(set) var selectedIndex: Int = 0
    
    public var titles: [String] = [] {
        didSet {
            createItems(titles)
        }
    }
    
    public var barContentInset: UIEdgeInsets = .zero {
        didSet {
            updateItemsLayout()
            updateIndicatorLayout()
        }
    }
    
    public var itemContentInset: UIEdgeInsets = .zero {
        didSet {
            updateItemsAppearance()
            updateItemsLayout()
            updateIndicatorLayout()
        }
    }
    
    public var itemSpace: CGFloat = 8.0 {
        didSet {
            updateItemsLayout()
            updateIndicatorLayout()
        }
    }
    
    public var itemTextColor: UIColor = .lightGray {
        didSet {
            updateItemsAppearance()
        }
    }
    
    public var itemSelectedTextColor: UIColor = .white {
        didSet {
            updateItemsAppearance()
        }
    }
    
    public var itemTextFont: UIFont = .systemFont(ofSize: 15.0, weight: .regular) {
        didSet {
            updateItemsAppearance()
        }
    }
    
    public var indicatorColor: UIColor = .black {
        didSet {
            updateIndicatorAppearance()
        }
    }
    
    public var indicatorHeight: CGFloat = 3.0 {
        didSet {
            updateIndicatorAppearance()
        }
    }
    
    public var indicatorWidth: CGFloat = DynamicIndicatorWidth {
        didSet {
            updateIndicatorAppearance()
        }
    }
    
    public weak var coordinatingScrollView: UIScrollView? {
        didSet {
            if let coordinatingScrollView = coordinatingScrollView {
                addScrollViewObserver(coordinatingScrollView)
            }
            else {
                removeScrollViewObserver()
            }
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateItemsLayout()
            updateIndicatorLayout()
            scrollTo(index: selectedIndex, animation: false)
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateItemsLayout()
            updateIndicatorLayout()
            scrollTo(index: selectedIndex, animation: false)
        }
    }
    
    // MARK: - Private var
    private lazy var tabBarScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private lazy var indicator: UIView = {
        let indicator = UIView()
        return indicator
    }()
    
    private weak var selectedItem: TitleTabItem?
    private var items: [TitleTabItem] = []
    private var observers: [NSKeyValueObservation] = []
    
    
    // MARK: -
    convenience init(titles: [String]) {
        self.init(titles: titles, frame: .zero)
    }
    
    convenience init(titles: [String], frame: CGRect) {
        self.init(frame: frame)
        self.titles = titles
        createItems(titles)
    }
    
    override init(frame: CGRect) {
        selectedIndex = defaultIndex
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public func addTitles(_ titles: [String]) {
        titles.forEach({ addTitle($0) })
    }
    
    public func addTitle(_ title: String) {
        addItem(title)
        updateItemsLayout()
    }
    
    // MARK: - Private
    private func createViews() {
        addSubview(tabBarScrollView)
        tabBarScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tabBarScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        tabBarScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        tabBarScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        tabBarScrollView.addSubview(indicator)
        indicator.frame = CGRect(x: 0, y: 0, width: 0, height: indicatorHeight)
        indicator.isHidden = true
    }
    
    // MARK: Item
    private func createItems(_ titles: [String]) {
        cleanItems()
        
        titles.forEach({ addItem($0) })
        updateItemsLayout()
        updateIndicatorLayout()
        updateIndicatorAppearance()
        scrollTo(index: defaultIndex, animation: false)
    }
    
    private func addItem(_ title: String) {
        let item = TitleTabItem(text: title)
        item.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
        setItemAppearance(item)
        items.append(item)
    }
    
    private func cleanItems() {
        items.forEach({ $0.removeFromSuperview() })
        items.removeAll()
    }
    
    private func updateItemsLayout() {
        guard items.count > 0 else { return }
        tabBarScrollView.layoutIfNeeded()
        
        var x: CGFloat = barContentInset.left
        for item in items {
            item.frame = CGRect(x: x,
                                y: barContentInset.top,
                                width: item.preferredSize.width,
                                height: self.frame.size.height - barContentInset.top - barContentInset.bottom)
            if item.superview == nil {
                tabBarScrollView.addSubview(item)
            }
            
            x = item.frame.maxX + itemSpace
        }
        x += barContentInset.right
        tabBarScrollView.contentSize = CGSize(width: x, height: tabBarScrollView.frame.size.height)
    }
    
    private func scrollItem(_ item: TitleTabItem, animation: Bool) {
        let maxOffsetX = tabBarScrollView.contentSize.width - self.frame.size.width
        let newOffsetX = item.frame.minX - self.bounds.size.width / 2.0 + item.frame.size.width / 2.0;
        
        if newOffsetX < 0 {
            tabBarScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animation)
        }
        else if newOffsetX > maxOffsetX {
            tabBarScrollView.setContentOffset(CGPoint(x: maxOffsetX, y: 0), animated: animation)
        }
        else {
            tabBarScrollView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: animation)
        }
    }
    
    private func updateItemsAppearance() {
        items.forEach({ setItemAppearance($0) })
    }
    
    private func setItemAppearance(_ item: TitleTabItem) {
        item.textColor = itemTextColor
        item.selectedTextColor = itemSelectedTextColor
        item.textFont = itemTextFont
        item.edgeInset = itemContentInset
    }
    
    // MARK: Select item
    @objc private func didSelectItem(_ item: TitleTabItem) {
        guard let index = items.firstIndex(of: item) else { return }
        scrollTo(index: index, animation: true)
        delegate?.tabBarDidSelectItem(tabBar: self, title: item.text, index: index)
    }
    
    private func scrollTo(index: Int, animation: Bool) {
        guard index < items.count else { return }
        let item = items[index]
        scrollItem(item, animation: animation)
        scrollIndicator(to: index, animation: animation)
        
        selectedItem?.isSelected = false
        item.isSelected = true
        selectedItem = item
        
        selectedIndex = index
    }
    
    // MARK: Indicator
    private func updateIndicatorLayout() {
        guard items.count > 0 else {
            indicator.isHidden = true
            return
        }
        
        indicator.isHidden = false
        indicator.frame = indicatorFrame(at: selectedIndex)
    }
    
    private func updateIndicatorAppearance() {
        indicator.backgroundColor = indicatorColor
    }
    
    private func indicatorFrame(at itemIndex: Int) -> CGRect {
        let item = items[itemIndex]
        let height = indicatorHeight
        let width = indicatorWidth == DynamicIndicatorWidth ? item.frame.size.width : indicatorWidth
        let x = indicatorWidth == DynamicIndicatorWidth ? item.frame.minX : item.frame.midX - indicatorWidth / 2
        let y = max(0.0, self.frame.size.height - height - barContentInset.bottom)
        let frame = CGRect(x: x, y: y, width: width, height: height)
        return frame
    }
    
    private func scrollIndicator(to index: Int, animation: Bool) {
        let newFrame = indicatorFrame(at: index)
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                self.indicator.frame = newFrame
            })
        }
        else {
            indicator.frame = newFrame
        }
    }
}

private extension CategoryTabBar {
    func addScrollViewObserver(_ scrollView: UIScrollView) {
        removeScrollViewObserver()
        let observer = scrollView.observe(\.contentOffset, options: [.old, .new]) { [weak self] scrollView, value in
            self?.handleContentOffset(scrollView: scrollView)
        }
        self.observers.append(observer)
    }
    
    func removeScrollViewObserver() {
        observers.forEach({ $0.invalidate() })
        observers.removeAll()
    }
    
    func handleContentOffset(scrollView: UIScrollView) {
        let startX = CGFloat(selectedIndex) * scrollView.frame.size.width
        let contentOffset = scrollView.contentOffset
        let scrollProgress = (contentOffset.x - startX) / scrollView.frame.size.width
        let pageCount = Int(scrollView.contentSize.width / scrollView.frame.size.width)
//        print("handleContentOffset: startX: \(startX), \(contentOffset), scrollProgress: \(scrollProgress)")
        
        if abs(scrollProgress) == 1.0 || abs(scrollProgress) == 0 {
            let index = Int(contentOffset.x / scrollView.frame.size.width)
            scrollTo(index: index, animation: true)
            return
        }
        
        if contentOffset.x <= 0 {
            scrollTo(index: 0, animation: true)
            return
        }
        
        let maxX = scrollView.contentSize.width - scrollView.frame.size.width
        if contentOffset.x >= maxX {
            scrollTo(index: pageCount - 1, animation: true)
            return
        }
        
        let toRight = contentOffset.x > startX
        let i = Int(contentOffset.x / scrollView.frame.size.width)
        let fromIndex = toRight ? i : i + 1
        let toIndex = toRight ? fromIndex + 1 : fromIndex - 1
//        print("i : \(i), fromIndex: \(fromIndex), toIndex: \(toIndex)")
        
        let fromFrame = indicatorFrame(at: fromIndex)
        let toFrame = indicatorFrame(at: toIndex)
        let dx = (toFrame.origin.x - fromFrame.origin.x) * abs(scrollProgress)
        let dw = (toFrame.size.width - fromFrame.size.width) * abs(scrollProgress)
        let newFrame = CGRect(x: fromFrame.origin.x + dx,
                              y: fromFrame.origin.y,
                              width: fromFrame.size.width + dw,
                              height: fromFrame.size.height)
        indicator.frame = newFrame
    }
}

let DynamicIndicatorWidth: CGFloat = 0.0
