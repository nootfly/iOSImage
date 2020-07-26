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
    let child = SpinnerViewController()


    override func viewDidLoad() {
        super.viewDidLoad()

        addTable()
        addSearchController()
    }

    // MARK: - subviews

    func addTable()  {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        tableView.register(PhotoCell.self, forCellReuseIdentifier: Constants.CellIdentifier)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIConstants.Margin),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIConstants.Margin),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:UIConstants.Margin),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -UIConstants.Margin)
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

// MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text  else {
            Swift.debugPrint("searchText is empty")
            return
        }
        if searchText.count > 3 {
            showSpinnerView()
            viewModel.searchImages(query: searchText) { [weak self] error in
                if !error.isEmpty {
                    self?.showError()
                } else {
                    self?.tableView.reloadData()
                }

                self?.hideSpinnerView()
            }
        } else {
            viewModel.clear()
            self.tableView.reloadData()
        }
    }

    func showError() {
        let alertController = UIAlertController(title: "Oops!", message: "There was an error fetching photo details.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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

        handleImageDownload(cell, photoDetail, tableView, indexPath)

        return cell
    }
}

// MARK: - Image donwload

extension ViewController {
    fileprivate func handleImageDownload(_ cell: PhotoCell, _ photoDetail: PhotoDisplayModel, _ tableView: UITableView, _ indexPath: IndexPath) {
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



    // MARK: - operation management

    func suspendAllOperations() {
      viewModel.pendingOperations.downloadQueue.isSuspended = true
    }

    func resumeAllOperations() {
      viewModel.pendingOperations.downloadQueue.isSuspended = false
    }

    func loadImagesForOnscreenCells() {
      if let pathsArray = tableView.indexPathsForVisibleRows {

        let allPendingOperations = Set(viewModel.pendingOperations.downloadsInProgress.keys)


        var toBeCancelled = allPendingOperations
        let visiblePaths = Set(pathsArray)
        toBeCancelled.subtract(visiblePaths)


        var toBeStarted = visiblePaths
        toBeStarted.subtract(allPendingOperations)


        for indexPath in toBeCancelled {
            if let pendingDownload = viewModel.pendingOperations.downloadsInProgress[indexPath] {
            pendingDownload.cancel()
          }

          viewModel.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)

        }


        for indexPath in toBeStarted {
          let recordToProcess = viewModel.photos[indexPath.row]
          startOperations(for: recordToProcess, at: indexPath)
        }
      }
    }
}

  // MARK: - scrollview delegate methods

extension ViewController: UIScrollViewDelegate, UITableViewDelegate {

      func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

      suspendAllOperations()
    }

      func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

      if !decelerate {
        loadImagesForOnscreenCells()
        resumeAllOperations()
      }
    }

      func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

      loadImagesForOnscreenCells()
      resumeAllOperations()
    }
}

// MARK: - SpinnerViewController

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .gray)

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        //view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension ViewController {
    func showSpinnerView() {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func hideSpinnerView() {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
