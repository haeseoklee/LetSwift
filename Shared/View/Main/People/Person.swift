//
//  Person.swift
//  LetSwift
//
//  Created by 신한섭 on 2020/11/23.
//

import Foundation

struct Person: Hashable, Identifiable {
    let id: UUID = UUID()
    let imageName: String
    let name: String
    let organization: String?
    let role: [String]
    let description: String
}

extension Person {
    static func makeOrganizer() -> [Person] {
        return [Person(imageName: "sample", name: "organizer", organization: nil, role: ["organizer"], description: "I'm organizer")]
    }
    
    static func makePanels() -> [Person] {
        return (1...4).map { return Person(imageName: "sample", name: "panel\($0)", organization: "organization\($0)", role: ["panel"], description: "I'm panel\($0)") }
    }
    
    static func makeStaff() -> [Person] {
        return (1...4).map { Person(imageName: "sample", name: "staff\($0)", organization: "organization\($0)", role: ["staff"], description: "I'm staff\($0)") }
    }
}
