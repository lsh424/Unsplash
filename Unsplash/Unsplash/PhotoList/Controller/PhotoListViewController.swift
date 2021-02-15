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
    
    private lazy var collectionViewOffset: CGFloat = 0
    
    var photoOB = PhotoObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        photoOB.fetchPhotos {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
        
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK: UICollectionView Delegate and DataSource
extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoOB.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = nil
        cell.userNameLabel.text = nil
        cell.imageView.backgroundColor = .clear
        
        let photo = photoOB.photos[indexPath.item]
        cell.configure(with: photo)
        
        return cell
    }
    
    // 사진 사이즈 반환
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let photo = photoOB.photos[indexPath.item]
        
        let height = CGFloat(photo.height) * (collectionView.frame.width / CGFloat(photo.width))

        return CGSize(width: self.view.frame.width, height: CGFloat(height))
    }
    
    // 사진 업데이트
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == photoOB.photos.count - 15 {
            photoOB.nextPage += 1
            
            photoOB.updatePhotos { [weak self] (indexPaths) in
                DispatchQueue.main.async {
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
    
    // 사진 상세보기로 이동
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "PhotoDetailViewController") as? PhotoDetailViewController else {return}
        
        vc.photoOB = photoOB
        vc.indexPathItem = indexPath.item
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.hideTabBar()
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: ScrollView Delegate
extension PhotoListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            return
        }
        
        if collectionViewOffset > scrollView.contentOffset.y {
            self.tabBarController?.showTabBar()
        } else {
            self.tabBarController?.hideTabBar()
        }
        collectionViewOffset = scrollView.contentOffset.y
    }
}

// MARK: PhotoListViewDelegate
extension PhotoListViewController: PhotoListViewDelegate {
    func updateCollectionView(indexPath: IndexPath) {
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
}

