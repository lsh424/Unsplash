//
//  InformationView.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/12.
//

import UIKit

class InformationView: UIView {
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var makeInfoLabel: UILabel!
    private var focalLengthInfoLabel: UILabel!
    private var modelInfoLabel: UILabel!
    private var isoInfoLabel: UILabel!
    private var exposureInfoLabel: UILabel!
    private var dimensionsInfoLabel: UILabel!
    private var apertureInfoLabel: UILabel!
    private var publishedInfoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor(hex: "101110")
    }
    
    convenience init(frame: CGRect, with photoInfo: PhotoInfo) {
        self.init(frame: frame)
        configure(with: photoInfo)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let makeLabel = label(text: "Make")
        makeInfoLabel = label()
        let makeStackView = stackView(label1: makeLabel, label2: makeInfoLabel)
        
        let modelLabel = label(text: "Model")
        modelInfoLabel = label()
        let modelStackView = stackView(label1: modelLabel, label2: modelInfoLabel)
        
        let exposureLabel = label(text: "Exposure Time")
        exposureInfoLabel = label()
        let exposureStackView = stackView(label1: exposureLabel, label2: exposureInfoLabel)
        
        let apertureLabel = label(text: "Aperture")
        apertureInfoLabel = label()
        let apertureStackView = stackView(label1: apertureLabel, label2: apertureInfoLabel)
        
        let leftStackView = stackView(stackViews: [makeStackView, modelStackView, exposureStackView, apertureStackView])
        
        
        let focalLengthLabel = label(text: "Focal Length")
        focalLengthInfoLabel = label()
        let focalLenthStackView = stackView(label1: focalLengthLabel, label2: focalLengthInfoLabel)
        
        let isoLabel = label(text: "ISO")
        isoInfoLabel = label()
        let isoStackView = stackView(label1: isoLabel, label2: isoInfoLabel)
        
        let dimensionsLabel = label(text: "Dimensions")
        dimensionsInfoLabel = label()
        let dimensionsStackView = stackView(label1: dimensionsLabel, label2: dimensionsInfoLabel)
        
        let publishedLabel = label(text: "Published")
        publishedInfoLabel = label()
        let publishedStackView = stackView(label1: publishedLabel, label2: publishedInfoLabel)
        
        let rightStackView = stackView(stackViews: [focalLenthStackView, isoStackView, dimensionsStackView, publishedStackView])
        
        let infoLabel = label(text: "Info")
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.addSubview(leftStackView)
        self.addSubview(rightStackView)
        self.addSubview(line)
        self.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.widthAnchor.constraint(equalToConstant: 32),
            infoLabel.heightAnchor.constraint(equalToConstant: 20),
            infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            
            line.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
            
            leftStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            leftStackView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 20),
            leftStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55),
            leftStackView.trailingAnchor.constraint(equalTo: rightStackView.leadingAnchor, constant: -10),
            
            rightStackView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 20),
            rightStackView.leadingAnchor.constraint(equalTo: infoLabel.centerXAnchor, constant: 0),
            rightStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            rightStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -55)
        ])
    }
    
    private func label(text: String = "-") -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont(name: "Helvetica", size: 14)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func stackView(label1: UILabel, label2: UILabel) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label1, label2])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func stackView(stackViews: [UIStackView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: stackViews)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

extension InformationView {
    func configure(with photoInfo: PhotoInfo) {
        self.dimensionsInfoLabel.text = "\(photoInfo.width) x \(photoInfo.height)"
        self.apertureInfoLabel.text = photoInfo.exif.aperture ?? "-"
        self.exposureInfoLabel.text = photoInfo.exif.exposureTime ?? "-"
        self.focalLengthInfoLabel.text = photoInfo.exif.focalLength ?? "-"
        self.isoInfoLabel.text = photoInfo.exif.iso != nil ? String(photoInfo.exif.iso!) : "-"
        self.makeInfoLabel.text = photoInfo.exif.make ?? "-"
        self.modelInfoLabel.text = photoInfo.exif.model ?? "-"
        self.publishedInfoLabel.text = dateToString(date: photoInfo.createdAt)
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
