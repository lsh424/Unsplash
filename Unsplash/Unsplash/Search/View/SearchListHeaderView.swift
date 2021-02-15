//
//  SearchListHeaderView.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

protocol SearchTableViewDelegate: AnyObject {
    func updateSearchTableView()
}

class SearchListHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "SearchListHeaderView"
    
    weak var delegate: SearchTableViewDelegate?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBAction func didPressClearButton(_ sender: UIButton) {
        delegate?.updateSearchTableView()
    }
}
