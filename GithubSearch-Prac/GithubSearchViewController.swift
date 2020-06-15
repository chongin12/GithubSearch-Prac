//
//  GithubSearchViewController.swift
//  GithubSearch-Prac
//
//  Created by 정종인 on 2020/06/07.
//  Copyright © 2020 swmaestro10th. All rights reserved.
//

import Foundation
import UIKit

class GithubSearchViewController: UIViewController {
    private lazy var githubSearchView = GithubSearchView(controlBy: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        githubSearchView.setup()
        navigationItem.searchController = githubSearchView.searchController
        githubSearchView.reactor = GithubSearchViewReactor()
    }
    
    override func loadView() {
        self.view = githubSearchView
    }
    
}
