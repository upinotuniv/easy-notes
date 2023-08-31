// 
//  BottomSheetRouter.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

import UIKit

class BottomSheetRouter {
    
    func showView() -> BottomSheetView {
        let interactor = BottomSheetInteractor()
        let presenter = BottomSheetPresenter(interactor: interactor)
        let view = BottomSheetView(nibName: String(describing: BottomSheetView.self), bundle: nil)
        view.presenter = presenter
        return view
    }
    
}
