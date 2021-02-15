//
//  ImageCell.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/09.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let identifier = "PhotoCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with photo: Photo) {
        self.userNameLabel.text = photo.user.username
        imageView.backgroundColor = UIColor(hex: photo.color)
        
        guard let url = URL(string: photo.urls.regular) else {
            return
        }
        
        NetworkManager.shared.downloadImage(imageURL: url) { [weak self] (data) in
            let image = UIImage(data: data)
            
            guard let strongSelf = self, self?.id == photo.id else {return}
            
            DispatchQueue.main.async {
                UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.imageView.image = image
                }, completion: nil)
            }
        }
    }
}
