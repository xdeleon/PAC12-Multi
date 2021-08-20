//
//  Sports.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import Foundation

struct Videos: Codable {
    let programs: [Program]
    let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case programs
        case nextPage = "next_page"
    }
}

struct Program: Codable, Hashable, Equatable {
    let id: String
    let url: String
    let title: String
//    let shortTitle: String?
//    let programDescription: String
//    let locked: Bool
    let duration: Int
//    let pac12_Now: Bool
//    let publishedBy: PublishedBy
//    let contentTypes: [ContentType]
    let sports: [VideoSport]?
    let schools: [VideoSchool]?
//    let events: [Event]
//    let metatags: [Metatag]
//    let images: VideoImages
    let emailImage: String
//    let followOnVODID: String?
//    let manifestURL: String
//    let campaign: Campaign?
//    let adParams: AdParams?
//    let disableHighlightAlert: Bool
//    let playlists: [Int]?
//    let trendingRank: TrendingRank
//    let youtubeIDS: [String: String?]
//    let created, updated: Date

    enum CodingKeys: String, CodingKey {
        case id, url, title
//        case shortTitle = "short_title"
//        case programDescription = "description"
//        case locked
        case duration
//        case pac12_Now = "pac_12_now"
//        case publishedBy = "published_by"
//        case contentTypes = "content_types"
        case sports, schools
//        case events, metatags, images
        case emailImage = "email_image"
//        case followOnVODID = "follow_on_vod_id"
//        case manifestURL = "manifest_url"
//        case campaign
//        case adParams = "ad_params"
//        case disableHighlightAlert = "disable_highlight_alert"
//        case playlists
//        case trendingRank = "trending_rank"
//        case youtubeIDS = "youtube_ids"
//        case created, updated
    }
}

struct AdParams: Codable {
    let schools, sports: String?
}

enum Campaign: String, Codable {
    case newYorkLife = "new-york-life"
    case noAd = "no-ad"
}

struct ContentType: Codable {
    let type: TypeEnum
}

enum TypeEnum: String, Codable {
    case feature = "Feature"
    case highlights = "Highlights"
    case individualHighlight = "Individual Highlight"
    case interview = "Interview"
    case longFeature = "Long Feature"
    case pressConference = "Press conference"
    case recap = "Recap"
    case shortFeature = "Short Feature"
}

struct Event: Codable {
    let id: String
}

struct VideoImages: Codable {
    let uhd, hd1080, hd720, large: String
    let medium, small, tiny: String

    enum CodingKeys: String, CodingKey {
        case uhd
        case hd1080 = "hd_1080"
        case hd720 = "hd_720"
        case large, medium, small, tiny
    }
}

struct Metatag: Codable {
    let name: String
}

enum PublishedBy: String, Codable {
    case pac12Networks = "Pac-12 Networks"
}

struct VideoSchool: Codable, Hashable, Equatable  {
    let id: Int
    let homeTeam: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case homeTeam = "home_team"
    }
}

struct VideoSport: Codable, Hashable, Equatable  {
    let id: Int
}

struct TrendingRank: Codable {
    let shortRank, mediumRank, longRank: Int?

    enum CodingKeys: String, CodingKey {
        case shortRank = "short_rank"
        case mediumRank = "medium_rank"
        case longRank = "long_rank"
    }
}
