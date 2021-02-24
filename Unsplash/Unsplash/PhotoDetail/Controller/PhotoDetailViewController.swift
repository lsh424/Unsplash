//
//  ImageDetailViewController.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/10.
//

import UIKit

protocol PhotoListViewDelegate: AnyObject {
    func updateCollectionView(indexPath: IndexPath)
}

class PhotoDetailViewController: UIViewController{
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: PhotoListViewDelegate?
    
    var indexPathItem: Int = 0
    var photoOB: PhotoObject!
    
    private var isFirstLayoutSubviews: Bool = true
    
    private lazy var informationView: InformationView = InformationView()
    private lazy var opaqueView: UIView = UIView()
    private lazy var currentContetnOffset: CGFloat = 0
    private var collectionViewOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupGestureRecognizer()
        setupUserName()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        ImageCacheManager.shared.cleanUpCache()
    }
    
    override func viewDidLayoutSubviews() {
        guard isFirstLayoutSubviews else { return }
        self.collectionView.setContentOffset(CGPoint(x: Int(self.collectionView.frame.width) * indexPathItem, y: 0), animated: false)
        self.currentContetnOffset = collectionView.contentOffset.x
        isFirstLayoutSubviews = false
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "PhotoDetailViewCell", bundle: nil), forCellWithReuseIdentifier: PhotoDetailViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
        self.collectionView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    }
    
    private func setupUserName() {
        self.userNameLabel.text = photoOB.photos[indexPathItem].user.username
    }
    
    @objc func drag(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        switch sender.state {
        case .began:
            collectionViewOriginalCenter = collectionView.center
            collectionView.isScrollEnabled = false
            delegate?.updateCollectionView(indexPath: IndexPath(item: indexPathItem, section: 0))
        case .changed:
            collectionView.center = CGPoint(x: collectionViewOriginalCenter.x + translation.x, y: collectionViewOriginalCenter.y + translation.y)
            self.view.alpha = (self.collectionView.frame.height - (translation.y / 3)) / self.collectionView.frame.height
        case .ended:
            if translation.y < self.collectionView.frame.height / 4 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.center = self.collectionViewOriginalCenter
                    self.view.alpha = 1
                })
                self.collectionView.isScrollEnabled = true
            } else {
                let newCenter = CGPoint(x: self.collectionViewOriginalCenter.x, y: self.collectionViewOriginalCenter.y + 20)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.collectionView.center = newCenter
                } completion: { (_) in
                    self.dismiss(animated: false, completion: nil)
                }
            }
        default:
            return
        }
    }
    
    @IBAction func didPressCloseButton(_ sender: UIButton) {
        delegate?.updateCollectionView(indexPath: IndexPath(item: indexPathItem, section: 0))
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
            self.view.alpha = 0
        } completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func didPressInfoButton(_ sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        opaqueView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        opaqueView.frame = self.view.frame
        
        informationView = InformationView()
        informationView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height * 0.40)
        
        let photoID = photoOB.photos[indexPathItem].id
        
        NetworkManager.shared.fetchPhotoInfo(photoID: photoID) { [weak self] (photoInfo) in
            DispatchQueue.main.async {
                self?.informationView.configure(with: photoInfo)
            }
        }
        
        window?.addSubview(opaqueView)
        window?.addSubview(informationView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeInfoView))
        opaqueView.addGestureRecognizer(tapGesture)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.opaqueView.alpha = 0.5
            self.informationView.frame = CGRect(x: 0, y: self.view.frame.height * 0.62, width: self.view.frame.width, height: self.view.frame.height * 0.40)
        })
    }
    
    @objc func removeInfoView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.opaqueView.alpha = 0
            self.informationView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height * 0.40)
        } completion: { (_) in
            self.informationView.removeFromSuperview()
            self.opaqueView.removeFromSuperview()
        }
    }
}

// MARK: UICollectionView Delegate and DataSource
extension PhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoOB.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoDetailViewCell.identifier, for: indexPath) as? PhotoDetailViewCell else {
            return UICollectionViewCell()
        }
        
        cell.imageView.image = nil
        cell.scrollView.zoomScale = 1.0
        
        let photo = photoOB.photos[indexPath.item]
        cell.id = photo.id
        cell.configure(with: photo)
        
        return cell
    }
    
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
}

// MARK: ScrollView Delegate
extension PhotoDetailViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x - currentContetnOffset) / self.collectionView.frame.width)
        
        if currentContetnOffset + self.collectionView.frame.width <= scrollView.contentOffset.x {
            self.indexPathItem += page
        } else if currentContetnOffset - self.collectionView.frame.width >= scrollView.contentOffset.x  {
            self.indexPathItem += page
        }
        
        self.userNameLabel.text = photoOB.photos[indexPathItem].user.username
        currentContetnOffset = scrollView.contentOffset.x
    }
}

// MARK: UIGestureRecognizer Delegate
extension PhotoDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, let cell = collectionView.visibleCells[0] as? PhotoDetailViewCell else {
            return false
        }

        let velocity = panGestureRecognizer.velocity(in: collectionView)
        let collectionViewWidth = self.collectionView.frame.width
        
        return (collectionView.contentOffset.x).remainder(dividingBy: collectionViewWidth) == 0 && abs(velocity.y) > abs(velocity.x) && cell.scrollView.zoomScale <= 1
    }
}
