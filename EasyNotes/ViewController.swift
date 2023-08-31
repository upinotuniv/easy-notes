//
//  ViewController.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var personAccountImage: UIImageView!
    @IBOutlet weak var searchBar: SearchBarView!
    @IBOutlet weak var insertNotesButton: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var notesDataArray: [NotesData] = []
    private var filteredNotesDataArray: [NotesData] = []
    private var cancellables: Set<AnyCancellable> = []
    var cellColors: [IndexPath: UIColor] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        collectionView.register(NotesItemCVC.nib, forCellWithReuseIdentifier: NotesItemCVC.identifier)
        
        searchBar.searchTextField.delegate = self
        NotificationCenter.default.publisher(for: NSNotification.Name("dismissModal"))
                .sink { [weak self] _ in
                    self?.fetchDataAndRefreshCollectionView()
                }
                .store(in: &cancellables)
        
        setupAction()
        fetchDataAndRefreshCollectionView()
    }
    
    func setupAction() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(createNotes))
        insertNotesButton.isUserInteractionEnabled = true
        insertNotesButton.addGestureRecognizer(gesture)
    }
    
    @objc func createNotes() {
        let vc = BottomSheetRouter().showView()
        vc.modalPresentationStyle = .fullScreen
        vc.view.alpha = 0.0
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.5) {
                vc.view.alpha = 1.0
            }
        }
    }
    
    private func fetchDataAndRefreshCollectionView() {
        APIManager.shared.fetchData(path: "notes")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            }, receiveValue: { [weak self] (notesData: [NotesData]) in
                self?.notesDataArray = notesData
                self?.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    private func deleteNotes(at indexPath: IndexPath) {
        let notes: NotesData
        if !searchBar.searchTextField.text!.isEmpty {
            notes = filteredNotesDataArray[indexPath.item]
        } else {
            notes = notesDataArray[indexPath.item]
        }
        
        APIManager.shared.deleteData(path: "notes", id: notes.id)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error deleting data: \(error)")
                }
            }, receiveValue: { [weak self] message in
                print(message)
                self?.fetchDataAndRefreshCollectionView()
            })
            .store(in: &cancellables)
    }
}

// MARK: - Collection View Mapping Data

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func getRandomColor(for indexPath: IndexPath) -> UIColor {
        if let existingColor = cellColors[indexPath] {
            return existingColor
        }

        let red = CGFloat.random(in: 0.5...1.0)
        let green = CGFloat.random(in: 0.5...1.0)
        let blue = CGFloat.random(in: 0.5...1.0)
        let newColor = UIColor(red: red, green: green, blue: blue, alpha: 0.5)
        cellColors[indexPath] = newColor
        return newColor
    }
    
    private func showDeleteConfirmationAlert(for indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: "Delete Note",
            message: "Do you want to delete this note?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteNotes(at: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !searchBar.searchTextField.text!.isEmpty {
            return filteredNotesDataArray.count
        } else {
            return notesDataArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotesItemCVC.identifier, for: indexPath) as! NotesItemCVC
        
        let notes: NotesData
        if !searchBar.searchTextField.text!.isEmpty {
            notes = filteredNotesDataArray[indexPath.item]
        } else {
            notes = notesDataArray[indexPath.item]
        }
        
        let deleteAction: () -> Void = { [weak self] in
            self?.showDeleteConfirmationAlert(for: indexPath)
        }
        
        cell.backgroundColor = getRandomColor(for: indexPath)
        cell.layer.cornerRadius = 10
        cell.setupCell(titleNotes: notes.titleNote, detailNotes: notes.detailNote, deleteAction: deleteAction)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedNotes: NotesData
        let selectedColor = getRandomColor(for: indexPath)
        if !searchBar.searchTextField.text!.isEmpty {
            selectedNotes = filteredNotesDataArray[indexPath.item]
        } else {
            selectedNotes = notesDataArray[indexPath.item]
        }
        
        APIManager.shared.fetchDataByID(id: selectedNotes.id, path: "notes")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("API Error: \(error)")
                }
            }, receiveValue: { [weak self] notes in
                self?.presentBottomSheetView(with: notes, selectedNotes: selectedNotes, backgroundColor: selectedColor)
            })
            .store(in: &cancellables)
    }

    func presentBottomSheetView(with notes: NotesData, selectedNotes: NotesData, backgroundColor: UIColor) {
        let vc = BottomSheetRouter().showView()
        vc.modalPresentationStyle = .fullScreen
        vc.setupWithData(notes: notes)
        vc.presenter?.selectedNotes = selectedNotes
        vc.view.backgroundColor = backgroundColor
        
        vc.view.alpha = 0.0
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.5) {
                vc.view.alpha = 1.0
            }
        }
    }

}

// MARK: - Search Bar Functionality

extension ViewController: UITextFieldDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotesDataArray = notesDataArray.filter { notes in
            return notes.titleNote.localizedCaseInsensitiveContains(searchBar.searchTextField.text ?? "") ||
                   notes.detailNote.localizedCaseInsensitiveContains(searchBar.searchTextField.text ?? "")
        }
        collectionView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == searchBar.searchTextField {
            let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            filteredNotesDataArray = notesDataArray.filter { notes in
                return notes.titleNote.localizedCaseInsensitiveContains(searchText) ||
                       notes.detailNote.localizedCaseInsensitiveContains(searchText)
            }
            collectionView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchBar.searchTextField {
            textField.resignFirstResponder()
            performSearch()
            return true
        }
        return false
    }
    
    private func performSearch() {
        if let searchText = searchBar.searchTextField.text, !searchText.isEmpty {
            filteredNotesDataArray = notesDataArray.filter { notes in
                return notes.titleNote.localizedCaseInsensitiveContains(searchText) ||
                       notes.detailNote.localizedCaseInsensitiveContains(searchText)
            }
        } else {
            filteredNotesDataArray = []
        }
        collectionView.reloadData()
    }
}
