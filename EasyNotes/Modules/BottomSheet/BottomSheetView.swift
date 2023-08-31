// 
//  BottomSheetView.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

import UIKit
import Combine

class BottomSheetView: UIViewController, BottomSheetInteractorDelegate {
    
    var presenter: BottomSheetPresenter?
    var interactor: BottomSheetInteractor?
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var titleNotesTextField: UITextField!
    @IBOutlet weak var saveButton: UIImageView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var dateTodayLabel: UILabel!
    
    private var titleNotes: String = ""
    private var detailNotes: String = ""

    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAction()
        setupView()
        setupSaveButtonAction()
        setupDateTodayLabel()
    }
    
    func setupDateTodayLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        dateTodayLabel.text = formattedDate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupView() {
        notesTextView?.text = "Write some text..."
        notesTextView?.font = UIFont(name: "Poppins-Regular", size: 14)
        notesTextView?.textColor = UIColor(named: "AccentColor")
        
        titleNotesTextField.textColor = UIColor(named: "AccentColor")
        dateTodayLabel?.textColor = UIColor(named: "AccentColor")
        dateTodayLabel?.font = UIFont(name: "Poppins-Medium", size: 12)
        
        titleNotesTextField?.text = titleNotes
        notesTextView?.text = detailNotes
    }
    
    func setupAction() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backToHome))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(gesture)
    }
    
    @objc func backToHome() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0.0
        }) { _ in
            self.dismiss(animated: false) {
                NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
            }
        }
    }
    
    func setupSaveButtonAction() {
        saveButton.isUserInteractionEnabled = true
        saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped)))
    }
    
    @objc func saveButtonTapped() {
        handleSaveButtonTap()
    }
    
    func dataUpdatedSuccessfully() {
        print("Data updated successfully!")
        NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
    }
    
    func dataUpdateFailed(withError error: Error) {
        print("Error updating data: \(error)")
    }
    
    func handleSaveButtonTap() {
        guard let titleNote = titleNotesTextField.text,
              let detailNote = notesTextView.text else {
            return
        }

        if let selectedNotes = presenter?.selectedNotes {
            self.presenter?.interactor.updateData(id: selectedNotes.id, title: titleNote, detail: detailNote)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 0.0
            }) { _ in
                self.dismiss(animated: false) {
                    NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
                }
            }
        } else {
            self.presenter?.interactor.createData(title: titleNote, detail: detailNote)
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 0.0
            }) { _ in
                self.dismiss(animated: false) {
                    NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
                }
            }
        }
    }
    
    func setupWithData(notes: NotesData) {
        titleNotes = notes.titleNote
        detailNotes = notes.detailNote
    }

}
