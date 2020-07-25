//
//  PhotoCell.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {

    var model: PhotoDisplayModel? {
        didSet {
            updateUI()
        }
    }

    lazy var photoView: UIImageView = {
        let newImageView = UIImageView()
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        newImageView.contentMode = .scaleAspectFit
        newImageView.layer.cornerRadius = 10.0
        return newImageView
    }()

    lazy var userLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false

        return newLabel
    }()

    lazy var tagsLabel: UILabel = {
        let newLabel = UILabel()
        newLabel.translatesAutoresizingMaskIntoConstraints = false

        return newLabel
    }()


    func updateUI() {
        guard let goodModel = model else {
            return
        }
        userLabel.text = "By \(goodModel.user)"
        tagsLabel.text = goodModel.tags
        photoView.image = goodModel.image
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(photoView)
        contentView.addSubview(userLabel)
        contentView.addSubview(tagsLabel)
        selectionStyle = .none


          if accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .gray)
            accessoryView = indicator
          }

        NSLayoutConstraint.activate([

            photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant:16),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Margin),
            photoView.widthAnchor.constraint(equalToConstant: 640),
            photoView.heightAnchor.constraint(equalToConstant: 400),

            userLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 8),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Margin),

            tagsLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 8),
            tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Margin),
            tagsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Margin),

        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
