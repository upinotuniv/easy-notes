//
//  SearchBarView.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 28/08/23.
//

import UIKit

class SearchBarView: UIView {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    private func setUpView() {
        let view = loadNib()
        view.frame = self.bounds
        self.addSubview(view)
    }
    
}
