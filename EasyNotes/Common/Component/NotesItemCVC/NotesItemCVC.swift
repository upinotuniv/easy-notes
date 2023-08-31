//
//  NotesItemCVC.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 29/08/23.
//

import UIKit

class NotesItemCVC: UICollectionViewCell {
    
    @IBOutlet weak var titleNotesLabel: UILabel!
    @IBOutlet weak var detailNotesLabel: UILabel!
    @IBOutlet weak var trashButton: UIImageView!
    @IBOutlet weak var container: UIView!
    
    var deleteAction: (() -> Void)?
    
    static let identifier = String(describing: NotesItemCVC.self)
    static let nib =  {
        UINib(
            nibName: identifier,
            bundle: nil
        )
    }()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension NotesItemCVC {
    func setupCell(titleNotes: String, detailNotes: String, deleteAction: @escaping () -> Void) {
        
        titleNotesLabel.text = titleNotes
        detailNotesLabel.text = detailNotes

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(trashButtonTapped))
        trashButton.isUserInteractionEnabled = true
        trashButton.addGestureRecognizer(tapGesture)
        self.deleteAction = deleteAction
        
        setupView()
        
    }
    
    @objc private func trashButtonTapped() {
        deleteAction?()
    }
    
    func setupView() {
        titleNotesLabel.textAlignment = .left
        detailNotesLabel.textAlignment = .left
    }

}
