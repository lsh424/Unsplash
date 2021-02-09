//
//  PhotoListViewController.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var gradientTopView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var page = 1
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 상단 색상 gradient 처리, 이 부분 개선, 따로 뷰로 만들자
        gradientTopView.backgroundColor = .clear
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.gradientTopView.frame.width, height:
                                    self.gradientTopView.frame.height)
        gradient.locations = [0.0,1.0]
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        
        gradientTopView.layer.addSublayer(gradient)
        
        NetworkManager.shared.fetchPhotos { [weak self](photos) in
            self?.photos = photos
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        setupNavigationController()
        setupCollectionView()
    }
    
    func setupNavigationController() {
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = nil
        cell.userNameLabel.text = nil
        cell.imageView.backgroundColor = .clear
        
        let photo = photos[indexPath.item]
        
        let photoID = photo.id
        cell.id = photoID
        
        print(photoID, cell.id, photoID == cell.id)
        
        cell.configure(with: photo)
        
        return cell
    }
    
    // 컬렉션뷰 셀 사이즈 반환
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let photo = photos[indexPath.row]
        
        let height = CGFloat(photo.height) * (collectionView.frame.width / CGFloat(photo.width))
        print(height)
        
        return CGSize(width: self.view.frame.width, height: CGFloat(height))
    }
    
    // 컬렉션뷰 업데이트
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == photos.count - 10 {
            page += 1
            
            NetworkManager.shared.fetchPhotos(page: page) { [weak self] (newPhotos) in
                
                self?.photos.append(contentsOf: newPhotos)
                
                let newPhotosCount = newPhotos.count
                let startIndex = (self?.photos.count)! - newPhotosCount
                let endIndex = startIndex + newPhotosCount
                var indexPaths = [IndexPath]()
                
                for index in startIndex..<endIndex {
                    indexPaths.append(IndexPath(item: index, section: 0))
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
}
