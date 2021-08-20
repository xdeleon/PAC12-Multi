//
//  Schools.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import Foundation

struct SchoolsData: Codable {
    let schools: [School]
}

struct School: Codable {
    let id: Int
    let name: String
    let abbr: String
    let mascot: String
    let url: String
    let pac12: Bool
    let networks: [Network]
    let sports: [Network]
    let images: Images
    let imagesGrayscale: Images

    enum CodingKeys: String, CodingKey {
        case id, name, abbr, mascot, url, pac12, networks, sports, images
        case imagesGrayscale = "images_grayscale"
    }
}

struct Images: Codable {
    let large: String
    let medium: String
    let small: String
    let tiny: String
}

struct Network: Codable {
    let id: String
}
