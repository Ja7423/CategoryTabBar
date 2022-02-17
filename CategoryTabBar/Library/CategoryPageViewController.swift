//
//  CategoryPageViewController.swift
//  CategoryTabBar
//
//  Created by 家瑋 on 2022/2/9.
//

import UIKit

protocol CategoryPageViewControllerDataSource: NSObjectProtocol {
    func numberOfViewControllers(_ pageViewController: CategoryPageViewController) -> Int
    func pageViewController(_ pageViewController: CategoryPageViewController, viewControllerAt index: Int) -> UIViewController
}

protocol CategoryPageViewControllerDelegate: NSObjectProtocol {
    func pageViewController(_ pageViewController: CategoryPageViewController, selected index: Int)
    func pageViewController(_ pageViewController: CategoryPageViewController, didEnter viewController: UIViewController, index: Int)
}


class CategoryPageViewController: UIViewController {
    
    public weak var dataSource: CategoryPageViewControllerDataSource?
    public weak var delegate: CategoryPageViewControllerDelegate?
    
    private(set) var selectedIndex: Int = 0
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private var childs: Int = -1
    private var displayViewControllers: [Int : UIViewController] = [:]
    
    private var pageFrame: CGRect = .zero
    private var dragging: Bool = false
    private var previousOffset: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        calculatePageContent()
        loadContentViewController(selectedIndex)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard pageFrame != view.frame && view.window != nil else { return }
        pageFrame = view.frame
        calculatePageContent()
        updateViewControllersFrame()
    }
    
    // MARK: - Public
    public func setSelectedIndex(_ index: Int) {
        loadContentViewController(index)
        scrollTo(index: index, animation: true)
        selectedIndex = index
    }
    
    public func reloadPage() {
        childs = -1
        calculatePageContent()
        loadContentViewController(selectedIndex)
    }
    
    // MARK: - Private
    private func createViews() {
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func calculatePageContent() {
        guard let dataSource = dataSource else { return }
        if childs == -1 { childs = dataSource.numberOfViewControllers(self) }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(childs),
                                        height: scrollView.frame.size.height)
    }
    
    // MARK: - viewcontroller
    private func loadContentViewController(_ index: Int) {
        if displayViewControllers[index] == nil {
            guard let vc = initializeViewController(at: index) else { return }
            addViewController(vc, index: index)
        }
    }
    
    private func addViewController(_ viewController: UIViewController, index: Int) {
        displayViewControllers[index] = viewController
        
        addChild(viewController)
        viewController.didMove(toParent: self)
        scrollView.addSubview(viewController.view)
        let frame = contentFrame(index)
        viewController.view.frame = frame
    }
    
    private func viewController(at index: Int) -> UIViewController? {
        return displayViewControllers[index]
    }
    
    private func initializeViewController(at index: Int) -> UIViewController? {
        return dataSource?.pageViewController(self, viewControllerAt: index)
    }
    
    private func updateViewControllersFrame() {
        displayViewControllers.forEach { (key, vc) in
            let frame = contentFrame(key)
            vc.view.frame = frame
        }
    }
    
    // MARK: -
    private func contentFrame(_ index: Int) -> CGRect {
        let x = scrollView.frame.size.width * CGFloat(index)
        return CGRect(x: x, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
    }
    
    private func scrollTo(index: Int, animation: Bool) {
        let frame = contentFrame(index)
        scrollView.setContentOffset(CGPoint(x: frame.minX, y: 0), animated: animation)
    }
}


// MARK: - UIScrollViewDelegate
extension CategoryPageViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
        previousOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset
        guard currentOffset.x >= 0,
              currentOffset.x < scrollView.contentSize.width - scrollView.frame.size.width ,
              dragging else { return }
        let fingerLeft = scrollView.contentOffset.x > previousOffset.x
        let currentIndex = selectedIndex
        let nextPageIndex = fingerLeft ? currentIndex + 1 : currentIndex - 1
        
        guard nextPageIndex >= 0, nextPageIndex < childs else { return }
        loadContentViewController(nextPageIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        selectedIndex = index
        if let vc = viewController(at: index) {
            delegate?.pageViewController(self, didEnter: vc, index: index)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        selectedIndex = index
        if let vc = viewController(at: index) {
            delegate?.pageViewController(self, didEnter: vc, index: index)
        }
    }
}
