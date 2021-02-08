//
//  SearchViewController.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    var recentSearch: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarView.layer.cornerRadius = searchBarView.frame.width / 34
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.sectionHeaderHeight = 50
        searchTableView.rowHeight = 50
        
        recentSearch.append("seoul")
        recentSearch.append("newyork")
        
        searchTableView.register(UINib(nibName: "SearchListHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "searchListHeaderView")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentSearch.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "searchListHeaderView") as! SearchListHeaderView
        
        headerView.clearButton.isHidden = true
        
        if section == 0 {
            if recentSearch.isEmpty {
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
            return recentSearch.isEmpty ? 5 : recentSearch.count
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath)
        
        cell.textLabel?.text = "test \(indexPath.row)"
        cell.textLabel?.textColor = .white
        
        return cell
    }
}
