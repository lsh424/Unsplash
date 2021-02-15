//
//  SearchViewController.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noSearchLabel: UILabel!
    
    private lazy var collectionViewOffset: CGFloat = 0
    
    private var searchKeyWords: [String] = []
    var photoOB = PhotoObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupSearchTableView()
        setupCollectionView()
        setupToolBar()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .white
        }
    }
    
    private func setupSearchTableView() {
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.sectionHeaderHeight = 50
        searchTableView.rowHeight = 50
        searchTableView.register(UINib(nibName: "SearchListHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: SearchListHeaderView.identifier)
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
    
    private func setupToolBar() {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 38)
        toolbar.barTintColor = UIColor(hex: "303030")
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let buttonImage = UIImage(named: "Hide")
        let hideKeybrd = UIBarButtonItem(image: buttonImage, style: .done, target: self, action: #selector(hideKeyboard))
        
        toolbar.setItems([flexibleSpace, hideKeybrd], animated: true)
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc func hideKeyboard(_ sender: Any){
        searchBar.resignFirstResponder()
    }
}

// MARK: UITableView Delegate and DataSource
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchKeyWords.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchListHeaderView.identifier) as? SearchListHeaderView else {return UIView()}
        
        headerView.clearButton.isHidden = true
        headerView.delegate = self
        
        if section == 0 {
            if searchKeyWords.isEmpty {
                headerView.headerLabel.text = "Trending"
            } else {
                headerView.headerLabel.text = "Recent"
                headerView.clearButton.isHidden = false
            }
        } else {
            headerView.headerLabel.text = "Trending"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return searchKeyWords.isEmpty ? 3 : min(searchKeyWords.count, 5)
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        cell.textLabel?.textColor = .white
        
        if indexPath.section == 0 && !searchKeyWords.isEmpty {
            cell.textLabel?.text = searchKeyWords[indexPath.row]
        } else {
            cell.textLabel?.text = "Trend \(indexPath.row + 1)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 && !searchKeyWords.isEmpty else { return }
        
        searchBar.text = searchKeyWords[indexPath.row]
        searchBarSearchButtonClicked(searchBar)
    }
}

// MARK: UICollectionView Delegate and DataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        cell.id = photo.id
        cell.configure(with: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let photo = photoOB.photos[indexPath.item]
        let height = CGFloat(photo.height) * (collectionView.frame.width / CGFloat(photo.width))
        
        return CGSize(width: self.view.frame.width, height: CGFloat(height))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == photoOB.photos.count - 15 {
            photoOB.nextPage += 1
            
            photoOB.updateSearchPhotos(with: searchBar.text!) { [weak self] (indexPaths) in
                DispatchQueue.main.async {
                    self?.collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
    
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
extension SearchViewController {
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

// MARK: UISearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let text = searchBar.text, !text.isEmpty else {return}
        
        searchTableView.isHidden = true
        collectionView.isHidden = false
        photoOB.photos.removeAll()
        collectionView.reloadData()
        
        if let searchTextIndex = searchKeyWords.firstIndex(of: text) {
            searchKeyWords.remove(at: searchTextIndex)
        }
        
        searchKeyWords.insert(text, at: 0)
        
        photoOB.searchPhotos(with: text) {
            DispatchQueue.main.async {
                if self.photoOB.photos.isEmpty {
                    self.noSearchLabel.isHidden = false
                } else {
                    self.noSearchLabel.isHidden = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text, text.isEmpty, collectionView.isHidden == false else {return}
        
        collectionView.isHidden = true
        searchTableView.isHidden = false
        searchTableView.reloadData()
        self.tabBarController?.showTabBar()
    }
}

extension SearchViewController: PhotoListViewDelegate, SearchTableViewDelegate {
    func updateCollectionView(indexPath: IndexPath) {
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func updateSearchTableView() {
        searchKeyWords.removeAll()
        searchTableView.reloadData()
    }
}

