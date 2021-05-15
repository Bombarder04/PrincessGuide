//
//  CDCommentTableViewCell.swift
//  PrincessGuide
//
//  Created by zzk on 2018/5/7.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit
import Reusable

protocol CDCommentTableViewCellDelegate: AnyObject {
    func doubleClick(on cdCommentTableViewCell: CDCommentTableViewCell)
}

class CDCommentTableViewCell: UITableViewCell, Reusable {

    let commentLabel = UILabel()
    
    let loadingIndicator = UIActivityIndicatorView()
        
    weak var delegate: CDCommentTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commentLabel.textColor = Theme.dynamic.color.body
        loadingIndicator.color = Theme.dynamic.color.indicator
        
        commentLabel.font = UIFont.scaledFont(forTextStyle: .body, ofSize: 14)
        contentView.addSubview(commentLabel)
        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.right.lessThanOrEqualTo(readableContentGuide)
        }
        commentLabel.numberOfLines = 0
        
        contentView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func handleDoubleTap(_ tap: UITapGestureRecognizer) {
        delegate?.doubleClick(on: self)
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(for text: String) {
        commentLabel.text = text
    }
    
}
