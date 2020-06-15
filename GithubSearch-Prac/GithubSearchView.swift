//
//  GithubSearchView.swift
//  GithubSearch-Prac
//
//  Created by 정종인 on 2020/06/07.
//  Copyright © 2020 swmaestro10th. All rights reserved.
//

import Foundation
import UIKit
import ReactorKit
import SnapKit
import SafariServices

class GithubSearchView: UIView {
    weak var vc: GithubSearchViewController?
    
    init(controlBy viewController: GithubSearchViewController) {
        self.vc = viewController
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let baseView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    let tableView: UITableView = {
        let v = UITableView()
        v.verticalScrollIndicatorInsets.top = v.contentInset.top
        v.backgroundColor = .white
        return v
    }()
    
    let searchController: UISearchController = {
        let v = UISearchController(searchResultsController: nil)
        v.obscuresBackgroundDuringPresentation = false
        return v
    }()
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func setup() {
        setupUI()
        setBind()
    }
    
    private func setupUI() {
        addSubviews()
        setLayout()
    }
    
    private func setBind() {
        //delegate, datasource, register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func addSubviews() {
        self.addSubview(baseView)
        baseView.addSubview(backgroundView)
        backgroundView.addSubview(tableView)
    }
    
    private func setLayout() {
        baseView.snp.makeConstraints {
            $0.top.left.bottom.right.equalToSuperview()
        }
        backgroundView.snp.makeConstraints {
            $0.top.left.bottom.right.equalTo(safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints {
            $0.top.left.bottom.right.equalToSuperview()
        }
    }
}

extension GithubSearchView: View {
    func bind(reactor: GithubSearchViewReactor) {
        searchController.searchBar.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let `self` = self else { return false }
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            }
        .map { _ in Reactor.Action.loadNextPage }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self, weak reactor] indexPath in
                guard let `self` = self else { return }
                self.endEditing(true)
                self.tableView.deselectRow(at: indexPath, animated: false)
                guard let repo = reactor?.currentState.repos[indexPath.row] else { return }
                guard let url = URL(string: "https://github.com/\(repo)") else { return }
                let viewController = SFSafariViewController(url: url)
                self.searchController.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.repos }
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { indexPath, repo, cell in
                cell.textLabel?.text = repo
            }
            .disposed(by: disposeBag)
    }
}
