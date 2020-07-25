//
//  ViewController.swift
//  PixabayImage
//
//  Created by Noot Fang on 25/7/20.
//  Copyright © 2020 Noot Fang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    let viewModel = ViewModel()


    override func viewDidLoad() {
        super.viewDidLoad()

        addTable()
        addSearchController()
    }

    func addTable()  {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        

        tableView.register(PhotoCell.self, forCellReuseIdentifier: Constants.CellIdentifier)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    func addSearchController() {

        searchController.searchResultsUpdater = self

        searchController.obscuresBackgroundDuringPresentation = false

        searchController.searchBar.placeholder = "Search images"

        navigationItem.searchController = searchController

        definesPresentationContext = true

    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text  else {
            Swift.debugPrint("searchText is empty")
            return
        }
        if searchText.count > 3 {
            viewModel.searchImages(query: searchText) { error in
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Table view data source

extension ViewController: UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photos.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {


        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()

        }

        let photoDetail = viewModel.photos[indexPath.row]

        cell.model = photoDetail

        if let indicator = cell.accessoryView as? UIActivityIndicatorView {
            switch (photoDetail.state) {
            case .failed, .downloaded :
                indicator.stopAnimating()
            case .new:
                indicator.startAnimating()
                if !tableView.isDragging && !tableView.isDecelerating {
                    startOperations(for: photoDetail, at: indexPath)
                }
            }
        }

        return cell
    }

    func startOperations(for photoRecord: PhotoDisplayModel, at indexPath: IndexPath) {
        switch (photoRecord.state) {
        case .new:
            startDownload(for: photoRecord, at: indexPath)
        default:
            print("do nothing")
        }
    }

    func startDownload(for photoRecord: PhotoDisplayModel, at indexPath: IndexPath) {

        guard viewModel.pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }


        let downloader = ImageDownloader(photoRecord)

        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }

            DispatchQueue.main.async {
                self.viewModel.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }

        viewModel.pendingOperations.downloadsInProgress[indexPath] = downloader

        viewModel.pendingOperations.downloadQueue.addOperation(downloader)
    }
}

