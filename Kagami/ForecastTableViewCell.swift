//
//  ForecastTableViewCell.swift
//  Kagami
//
//  Created by Annie Tung on 3/14/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit
import SnapKit

class ForecastTableViewCell: UITableViewCell {
    
    static let identifier: String = "forecast"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupView() {
        self.addSubview(dayLabel)
        self.addSubview(minLabel)
        self.addSubview(maxLabel)
        self.addSubview(minMaxSepLabel)
        self.addSubview(descriptionLabel)
        dayLabel.snp.makeConstraints { (label) in
            label.top.equalTo(self.snp.top).inset(8)
            label.centerX.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { (label) in
            label.top.equalTo(dayLabel.snp.bottom)
            label.centerX.equalToSuperview()
        }
        minMaxSepLabel.snp.makeConstraints { (label) in
            label.top.equalTo(descriptionLabel.snp.bottom)
            label.centerX.equalToSuperview()
        }
        minLabel.snp.makeConstraints { (label) in
            label.top.equalTo(descriptionLabel.snp.bottom)
            label.right.equalTo(minMaxSepLabel.snp.left)
        }
        maxLabel.snp.makeConstraints { (label) in
            label.top.equalTo(descriptionLabel.snp.bottom)
            label.left.equalTo(minMaxSepLabel.snp.right)
        }
    }
    
    lazy var minLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Code-Pro-Demo", size: 16)
        label.textColor = ColorPalette.accentColor
        return label
    }()
    
    lazy var maxLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Code-Pro-Demo", size: 16)
        label.textColor = ColorPalette.accentColor
        return label
    }()
    
    lazy var minMaxSepLabel: UILabel = {
        let label = UILabel()
        label.text = "/"
        label.font = UIFont(name: "Code-Pro-Demo", size: 16)
        label.textColor = ColorPalette.grayColor
        return label
    }()
    
    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Code-Pro-Demo", size: 18)
        label.textColor = ColorPalette.blackColor
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Code-Pro-Demo", size: 16)
        label.textColor = ColorPalette.grayColor
        return label
    }()
}
