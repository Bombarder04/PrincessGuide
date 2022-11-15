//
//  CDSkillTableViewCell.swift
//  PrincessGuide
//
//  Created by zzk on 2018/4/20.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit
import Reusable

class CDSkillTableViewCell: UITableViewCell, Reusable {
    
    let skillIcon = IconImageView()
    
    let nameLabel = UILabel()
    
    let categoryLabel = UILabel()
    
    lazy var subtitleLabel = self.createSubTitleLabel(title: NSLocalizedString("Cast Time", comment: ""))
    
    let castTimeLabel = UILabel()
    
    let descLabel = UILabel()
    
    lazy var subtitleLabel2 = self.createSubTitleLabel(title: NSLocalizedString("Skill Detail", comment: ""))
    
    let actionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.textColor = Theme.dynamic.color.title
        categoryLabel.textColor = Theme.dynamic.color.caption
        castTimeLabel.textColor = Theme.dynamic.color.body
        descLabel.textColor = Theme.dynamic.color.body
        subtitleLabel.textColor = Theme.dynamic.color.title
        subtitleLabel2.textColor = Theme.dynamic.color.title
        actionLabel.textColor = Theme.dynamic.color.body
        
        contentView.addSubview(skillIcon)
        skillIcon.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.height.width.equalTo(64)
            make.top.equalTo(10)
        }
        
        categoryLabel.font = UIFont.scaledFont(forTextStyle: .title3, ofSize: 14)
        contentView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(skillIcon.snp.bottom)
            make.centerX.equalTo(skillIcon)
        }
        
        nameLabel.font = UIFont.scaledFont(forTextStyle: .title3, ofSize: 16)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(skillIcon.snp.right).offset(10)
            make.top.equalTo(10)
        }
        
        descLabel.font = UIFont.scaledFont(forTextStyle: .body, ofSize: 14)
        descLabel.numberOfLines = 0
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.right.equalTo(readableContentGuide)
        }
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.greaterThanOrEqualTo(descLabel.snp.bottom).offset(5)
            make.top.greaterThanOrEqualTo(categoryLabel.snp.bottom).offset(5)
        }
        
        castTimeLabel.font = UIFont.scaledFont(forTextStyle: .body, ofSize: 14)
        contentView.addSubview(castTimeLabel)
        castTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.equalTo(subtitleLabel.snp.bottom)
        }
        
        contentView.addSubview(subtitleLabel2)
        subtitleLabel2.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.equalTo(castTimeLabel.snp.bottom).offset(5)
        }
        
        contentView.addSubview(actionLabel)
        actionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.right.equalTo(readableContentGuide)
            make.top.equalTo(subtitleLabel2.snp.bottom)
            make.bottom.equalTo(-10)
        }
        actionLabel.font = UIFont.scaledFont(forTextStyle: .body, ofSize: 14)
        actionLabel.numberOfLines = 0
        actionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        selectionStyle = .none
    }
    
    private func createSubTitleLabel(title: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.scaledFont(forTextStyle: .title3, ofSize: 14)
        label.text = title
        return label
    }
    
    func configure(for skill: Skill, category: SkillCategory, property: Property, index: Int? = nil, isRF: Bool = false) {
        nameLabel.text = skill.base.name
        if let index = index {
            categoryLabel.text = "\(category.description) \(index)"
        } else {
            categoryLabel.text = "\(category.description)"
        }
        if isRF {
            categoryLabel.text = (categoryLabel.text ?? "") + "↑"
        }
        castTimeLabel.text = "\(skill.base.skillCastTime)s"
        descLabel.text = skill.base.description
        skillIcon.skillIconID = skill.base.iconType
        
        if skill.actions.count > 0 {
            actionLabel.attributedText = skill.actions.map {
                let parameter = $0.parameter
                let attributedContent = parameter.localizedDetailWithTags(of: CDSettingsViewController.Setting.default.skillLevel, property: property, textColor: Theme.dynamic.color.reversedBody, tagBorderColor: Theme.dynamic.color.tint, tagBackgroundColor: Theme.dynamic.color.tint)
                let tagAttachment = NSTextAttachment.makeAttachment(String(parameter.id % 100), textColor: actionLabel.textColor, backgroundColor: .clear, borderColor: actionLabel.textColor)
                let attributedText = NSMutableAttributedString()
                attributedText.append(NSAttributedString(attachment: tagAttachment))
                attributedText.append(NSAttributedString(string: " "))
                attributedText.append(attributedContent)
                return attributedText
                }.joined(separator: "\n")
        } else {
            actionLabel.text = NSLocalizedString("Do nothing.", comment: "")
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NSTextAttachment {
    static func makeAttachment(_ text: String, textColor: UIColor, backgroundColor: UIColor, borderColor: UIColor, minWidth: CGFloat = 25, font: UIFont = UIFont.scaledFont(forTextStyle: .body, ofSize: 12)) -> NSTextAttachment {
        let label = UILabel()
        label.lineBreakMode = .byClipping
        label.textAlignment = .center
        label.textColor = textColor
        label.layer.borderColor = borderColor.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 2
        label.layer.backgroundColor = backgroundColor.cgColor
        label.text = text
        label.font = font
        label.sizeToFit()
        label.bounds = CGRect(x: 0, y: 0, width: max(minWidth, label.bounds.size.width + 4), height: label.bounds.size.height)
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, UIScreen.main.scale)
        label.layer.allowsEdgeAntialiasing = true
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let attachment = NSTextAttachment()
        attachment.image = image
        let mid = font.descender + font.capHeight
        attachment.bounds = CGRect(x: 0.0, y: font.descender - image.size.height / 2 + mid + 2, width: image.size.width, height: image.size.height).integral
        return attachment
    }
}
