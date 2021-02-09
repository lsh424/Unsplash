//
//  SearchListHeaderView.swift
//  Unsplash
//
//  Created by seunghwan Lee on 2021/02/08.
//

import UIKit

class SearchListHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "SearchListHeaderView"

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBAction func didPressClearButton(_ sender: UIButton) {
        print("Pressed")
    }
}
