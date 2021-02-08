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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 상단 색상 gradient 처리
        gradientTopView.backgroundColor = .clear
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.gradientTopView.frame.width, height:
                                    self.gradientTopView.frame.height)
        gradient.locations = [0.0,1.0]
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        
        gradientTopView.layer.addSublayer(gradient)
        
        setupNavigationController()
    }
    
    func setupNavigationController() {
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
}

extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 200
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "testCell", for: indexPath)
        
        return cell
    }
}
