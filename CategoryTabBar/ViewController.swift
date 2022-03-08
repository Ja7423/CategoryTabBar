//
//  ViewController.swift
//  CategoryTabBar
//
//  Created by 家瑋 on 2022/2/7.
//

import UIKit

struct ColorModel {
    var title: String
    var color: UIColor
}

class ViewController: UIViewController {
    
    weak var tabBar: CategoryTabBar?
    weak var pageController: CategoryPageViewController?
    var testData: [ColorModel] = []
    let defaultIndex: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testData = demoData()
        view.backgroundColor = .black
        demo1()
        pageDemo()
        
//        demo4()
//        pageDemo2()
        
        tabBar?.coordinatingScrollView = pageController?.scrollView
        
        let naviLeftItem = UIBarButtonItem(title: "-", style: .done, target: self, action: #selector(clickMinus(_:)))
        navigationItem.leftBarButtonItem = naviLeftItem
        let naviRightItem = UIBarButtonItem(title: "+", style: .done, target: self, action: #selector(clickAdd(_:)))
        navigationItem.rightBarButtonItem = naviRightItem
    }
    
    // MARK: -
    func demo1() {
        let titles = testData.map({ $0.title })
        let tabBar = CategoryTabBar(titles: titles)
        tabBar.delegate = self
        tabBar.itemSpace = 10
        tabBar.itemContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tabBar.barContentInset = UIEdgeInsets(top: 5, left: 20, bottom: 10, right: 10)
        tabBar.itemTextColor = .systemGreen
        tabBar.itemSelectedTextColor = .systemYellow
        tabBar.indicatorColor = .systemYellow
        view.addSubview(tabBar)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            tabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            tabBar.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        self.tabBar = tabBar
    }
    
    func demo2() {
        let titles = testData.map({ $0.title })
        let tabBar = CategoryTabBar(titles: titles)
        tabBar.delegate = self
        tabBar.itemSelectedTextColor = .systemRed
        tabBar.indicatorColor = .systemYellow
        tabBar.indicatorWidth = 10
        tabBar.indicatorHeight = 5
        view.addSubview(tabBar)
        tabBar.frame = CGRect(x: 0, y: 150, width: 250, height: 60)
        
        self.tabBar = tabBar
    }
    
    func demo3() {
        let titles = testData.map({ $0.title })
        let width: CGFloat = 250
        let x: CGFloat = UIScreen.main.bounds.size.width - width
        let tabBar = CategoryTabBar(titles: titles, frame: CGRect(x: x, y: 150, width: width, height: 60))
        tabBar.delegate = self
        tabBar.indicatorColor = .systemYellow
        tabBar.defaultIndex = 2
        tabBar.itemContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tabBar.itemSpace = 16
        view.addSubview(tabBar)
        
        self.tabBar = tabBar
    }
    
    func demo4() {
        let titles = testData.map({ $0.title })
        let tabBar = CategoryTabBar(frame: CGRect(x: 0, y: 150, width: 250, height: 60))
        tabBar.delegate = self
//        tabBar.indicatorColor = .systemYellow
        tabBar.itemSelectedTextColor = .systemIndigo
        tabBar.defaultIndex = 6
        tabBar.barContentInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10)
        tabBar.titles = titles
        view.addSubview(tabBar)
        
        self.tabBar = tabBar
    }
    
    // MARK: -
    func pageDemo() {
        let pageVC = CategoryPageViewController()
        pageVC.dataSource = self
        pageVC.delegate = self
        
        pageVC.willMove(toParent: self)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: self.tabBar!.bottomAnchor, constant: 0),
            pageVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            pageVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            pageVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
        pageVC.didMove(toParent: self)
        
//        pageVC.dataSource = self
//        pageVC.reloadPage()
        self.pageController = pageVC
    }
    
    func pageDemo2() {
        let pageVC = CategoryPageViewController()
        pageVC.dataSource = self
        pageVC.delegate = self
        
        pageVC.willMove(toParent: self)
        addChild(pageVC)
        pageVC.view.frame = view.bounds
        view.addSubview(pageVC.view)
        pageVC.view.frame = CGRect(x: 0,
                                   y: tabBar!.frame.maxY,
                                   width: view.frame.size.width,
                                   height: view.frame.size.height - tabBar!.frame.maxY)
        pageVC.didMove(toParent: self)
        
//        pageVC.dataSource = self
//        pageVC.reloadPage()
        self.pageController = pageVC
    }
    
    // MARK: -
    func demoData() -> [ColorModel] {
        return [ColorModel(title: "Item 1", color: .systemRed),
                ColorModel(title: "C1", color: .systemGreen),
                ColorModel(title: "Item 2", color: .systemBlue),
                ColorModel(title: "Item AAA", color: .systemIndigo),
                ColorModel(title: "Item bb", color: .systemGray),
                ColorModel(title: "DDDD", color: .systemBrown),
                ColorModel(title: "E", color: .systemPink),
                ColorModel(title: "FF23", color: .systemGray2),
                ColorModel(title: "99999999", color: .systemTeal),
                ColorModel(title: "ZZ123", color: .systemPurple)]
    }
    
    // MARK: -
    @IBAction func clickMinus(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func clickAdd(_ sender: UIBarButtonItem) {
        let random = Int.random(in: 0...10)
        let newItem = ColorModel(title: "New Item \(random)", color: .systemBrown)
        testData.append(newItem)
        
        tabBar?.addTitle(newItem.title)
        pageController?.reloadPage()
    }
}

// MARK: - CategoryTabBarDelegate
extension ViewController: CategoryTabBarDelegate {
    func tabBarDidSelectItem(tabBar: CategoryTabBar, title: String, index: Int) {
        print("\(#function) -> \(title)(\(index))")
        self.pageController?.setSelectedIndex(index)
    }
}

// MARK: - CategoryPageViewControllerDataSource
extension ViewController: CategoryPageViewControllerDataSource {
    func numberOfViewControllers(_ pageViewController: CategoryPageViewController) -> Int {
        return testData.count
    }
    
    func pageViewController(_ pageViewController: CategoryPageViewController, viewControllerAt index: Int) -> UIViewController {
        print("\(#function) -> \(index)")
        let color = testData[index].color
        return ColorViewController(color)
    }
}

// MARK: - CategoryPageViewControllerDelegate
extension ViewController: CategoryPageViewControllerDelegate {
    func pageViewController(_ pageViewController: CategoryPageViewController, selected index: Int) {
        print("\(#function) -> \(index)")
    }
    
    func pageViewController(_ pageViewController: CategoryPageViewController, didEnter viewController: UIViewController, index: Int) {
        print("\(#function) -> \(index)")
    }
}
