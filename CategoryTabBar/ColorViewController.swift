//
//  ColorViewController.swift
//  CategoryTabBar
//
//  Created by 家瑋 on 2022/2/15.
//

import UIKit

class ColorViewController: UIViewController {
    
    private let color: UIColor
    
    init(_ color: UIColor) {
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = color
    }

}
