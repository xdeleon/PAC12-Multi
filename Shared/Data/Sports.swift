//
//  Sports.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import Foundation

struct SportsData: Codable {
    let sports: [Sport]
}

struct Sport: Codable {
    let id: Int
    let name: String
    let weight: Int
    let featured: Bool
    let featuredWeight: Int?
    let abbr, menuLabel, shortName: String
    let icon: Icon
    let hasScores, inSeason: Bool
    let defaultSeasonDisplayed: String
    let isVisible: Bool
    let url, schedule: String
    let standings, scores: String?
    let defaultDuration: Int
    let championship: Championship
    let hasContext, isWeekBased, sdp: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, weight, featured
        case featuredWeight = "featured_weight"
        case abbr
        case menuLabel = "menu_label"
        case shortName = "short_name"
        case icon
        case hasScores = "has_scores"
        case inSeason = "in_season"
        case defaultSeasonDisplayed = "default_season_displayed"
        case isVisible = "is_visible"
        case url, schedule, standings, scores
        case defaultDuration = "default_duration"
        case championship
        case hasContext = "has_context"
        case isWeekBased = "is_week_based"
        case sdp
    }
}

struct Championship: Codable {
    let title, eventURLTitle: String?
    let eventURL: String?

    enum CodingKeys: String, CodingKey {
        case title
        case eventURLTitle = "event_url_title"
        case eventURL = "event_url"
    }
}

struct Icon: Codable {
    let large, medium, small, tiny: String
}
