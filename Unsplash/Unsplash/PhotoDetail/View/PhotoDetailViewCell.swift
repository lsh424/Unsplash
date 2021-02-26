//
//  ImageDetailViewCell.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/11.
//

import UIKit

class PhotoDetailViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoDetailViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.delegate = self
    }
    
    func configure(with photo: Photo) {
        guard let url = URL(string: photo.urls.regular) else {
            return
        }
        
        NetworkManager.shared.downloadImage(imageURL: url) { [weak self] (result: Result<Data, NetworkError>) in
            switch result {
            case.success(let data):
                guard let strongSelf = self, self?.id == photo.id else {return}
                
                let image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                        strongSelf.imageView.image = image
                    }, completion: nil)
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
}

extension PhotoDetailViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionW = newWidth*scrollView.zoomScale > imageView.frame.width
                
                let left = 0.5 *
                    (conditionW ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionH = newHeight * scrollView.zoomScale > imageView.frame.height
                
                let top = 0.5 * (conditionH ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}
