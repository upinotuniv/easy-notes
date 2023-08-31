//
//  NotesData.swift
//  EasyNotes
//
//  Created by PRO M1 2020 8/256 on 29/08/23.
//

import Foundation

struct NotesData: Decodable, Encodable {
    let id: Int
    let titleNote: String
    let detailNote: String
}
