// 
//  BottomSheetPresenter.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

class BottomSheetPresenter {
    let interactor: BottomSheetInteractor
    private let router = BottomSheetRouter()
    
    var selectedNotes: NotesData?
    
    init(interactor: BottomSheetInteractor) {
        self.interactor = interactor
        self.interactor.delegate = self
    }
}

extension BottomSheetPresenter: BottomSheetInteractorDelegate {
    func dataUpdatedSuccessfully() {
        print("Data updated successfully!")
    }
    
    func dataUpdateFailed(withError error: Error) {
        print("Error updating data: \(error)")
    }
}

