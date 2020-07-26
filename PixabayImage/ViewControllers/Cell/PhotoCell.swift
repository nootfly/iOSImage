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
        newImageView.clipsToBounds = true
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
        if memoryCache?.isCached(forKey: goodModel.imageURL) ?? false, let image = memoryCache?.value(forKey: goodModel.imageURL) {
            photoView.image = image.image
            goodModel.state = .downloaded
        } else {
            self.photoView.image = goodModel.image
        }
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

            photoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant:UIConstants.Margin),
            photoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoView.widthAnchor.constraint(equalToConstant: Constants.ImageWidth),
            photoView.heightAnchor.constraint(equalToConstant: Constants.ImageHeight),

            userLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 8),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Margin),

            tagsLabel.topAnchor.constraint(equalTo: userLabel.bottomAnchor),
            tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.Margin),
            tagsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.Margin),

        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
