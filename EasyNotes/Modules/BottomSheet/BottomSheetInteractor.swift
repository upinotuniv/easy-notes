// 
//  BottomSheetInteractor.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

import Foundation
import Combine

protocol BottomSheetInteractorDelegate: AnyObject {
    func dataUpdatedSuccessfully()
    func dataUpdateFailed(withError error: Error)
}

class BottomSheetInteractor {
    weak var delegate: BottomSheetInteractorDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    func updateData(id: Int, title: String, detail: String) {
        let entity = BottomSheetEntity(titleNote: title, detailNote: detail)
        
        APIManager.shared.putData(path: "notes", id: id, body: entity)
            .sink { completion in
                switch completion {
                case .finished:
                    self.delegate?.dataUpdatedSuccessfully()
                    NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
                case .failure(let error):
                    self.delegate?.dataUpdateFailed(withError: error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func createData(title: String, detail: String) {
        let entity = BottomSheetEntity(titleNote: title, detailNote: detail)
        
        APIManager.shared.postData(path: "notes", body: entity)
            .sink { completion in
                switch completion {
                case .finished:
                    self.delegate?.dataUpdatedSuccessfully()
                    NotificationCenter.default.post(name: NSNotification.Name("dismissModal"), object: nil)
                    print("Success")
                case .failure(let error):
                    self.delegate?.dataUpdateFailed(withError: error)
                    print(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
}
