//
//  CustomizeWeatherViewController.swift
//  Kagami
//
//  Created by Annie Tung on 3/5/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit

class CustomizeWeatherViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Weather"
        self.navigationController?.navigationBar.barTintColor = ColorPalette.accentColor
        var isSelected: Bool
        
        setupHierarchy()
        setupConstraints()
        setupBlurEffect()
        setupOverlayView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.alpha = 0
    }
    
    // MARK: - Set up Hierarchy & Constraints
    
    func setupHierarchy() {
        view.addSubview(backgroundImage)
    }
    
    func setupConstraints() {
        backgroundImage.snp.makeConstraints { (view) in
            view.top.bottom.left.right.equalToSuperview()
        }
    }
    
    func setupOverlayView() {
        // over lay view
        view.addSubview(cardView)
        cardView.snp.makeConstraints { (view) in
            view.centerX.centerY.equalToSuperview()
            view.height.equalTo(self.view).multipliedBy(0.4)
            view.width.equalTo(self.view).multipliedBy(0.6)
        }
        // label
        cardView.addSubview(locationLabel)
        locationLabel.snp.makeConstraints { (view) in
            view.top.equalTo(cardView.snp.top).inset(20)
            view.centerX.equalTo(cardView.snp.centerX)
        }
        // icon
        cardView.addSubview(weatherIcon)
        weatherIcon.snp.makeConstraints { (view) in
            view.top.equalTo(locationLabel.snp.bottom).offset(10)
            view.centerX.equalTo(cardView.snp.centerX)
        }
        // buttons
        cardView.addSubview(fahrenheitButton)
        fahrenheitButton.snp.makeConstraints { (view) in
            view.top.equalTo(cardView)
            view.trailing.equalTo(cardView).inset(5)
        }
        cardView.addSubview(celsiusButton)
        celsiusButton.snp.makeConstraints { (view) in
            view.top.equalTo(cardView)
            view.trailing.equalTo(fahrenheitButton.snp.leading).inset(5)
        }
    }
    
    // MARK: - Methods
    
    func setupBlurEffect() {
        let blur = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blur)
        blurEffectView.frame = self.view.bounds
        backgroundImage.addSubview(blurEffectView)
    }
    
    func switchToFahrenheit() {
        celsiusButton.isHighlighted = false
        fahrenheitButton.isHighlighted = true
        print("fahrenheit")
    }
    
    func switchToCelcius() {
        celsiusButton.isHighlighted = true
        fahrenheitButton.isHighlighted = false
        print("celcius")
    }
    
    // MARK: - Lazy Instances
    
    lazy var backgroundImage: UIImageView = {
        let image = UIImage(named: "weather-background")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var weatherIcon: UIImageView = {
        let image = UIImage(named: "sunny")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var cardView: UIView = {
        let card = UIView()
        card.layer.cornerRadius = 9
        card.backgroundColor = .white
        return card
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "New York"
        return label
    }()
    
    lazy var fahrenheitButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        button.setTitle("℉", for: .normal)
        button.addTarget(self, action: #selector(switchToFahrenheit), for: .touchUpInside)
        button.setTitleColor(ColorPalette.blackColor, for: .normal)
        button.setTitleColor(ColorPalette.grayColor, for: .highlighted)
        return button
    }()
    
    lazy var celsiusButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        button.setTitle("℃", for: .normal)
        button.addTarget(self, action: #selector(switchToCelcius), for: .touchUpInside)
        button.setTitleColor(ColorPalette.blackColor, for: .normal)
        button.setTitleColor(ColorPalette.grayColor, for: .highlighted)
        return button
    }()
}
