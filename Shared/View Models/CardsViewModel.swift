//
//  CardsViewModel.swift
//  PAC-12 Multi
//
//  Created by Xavier De Leon on 8/19/21.
//

import SwiftUI
import AVFoundation
import AudioToolbox

final class CardsViewModel: ObservableObject {
    @Published var sports = [Sport]()
    @Published var schools = [School]()
    @Published var vodPrograms = [Program]()

    private var currentPage = 0
    private var total = 0
    private var fetchInProgress = false
    private var vodsAvailableToDisplay = 100000 // 100K
    private var vodsDownloaded = 0
    private var shortAudioPlayer: AVAudioPlayer?

    init() {
        getSchools()
        getSports()
        getVideos()
    }

    //MARK: Utility Functions

    private func formattedTimeLength(seconds: Int) -> String {
        var timeLength = "00:00"

        if seconds > 0 {
            let timeComponets = timeComponents(seconds: seconds)

            let hours = String(format: "%02d", timeComponets.hours)
            let minutes = String(format: "%02d", timeComponets.minutes)
            let seconds = String(format: "%02d", timeComponets.seconds)

            if timeComponets.hours > 0 {
                timeLength = hours + ":" + minutes + ":" + seconds
            } else {
                timeLength = minutes + ":" + seconds
            }
        }

        return timeLength
    }

    private func timeComponents(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        // Duration seems to include millisecond info because it's video content but we don't
        // need that precision of time in the display so lets throw away the milliseconds.
        let newSeconds = seconds / 1000
        return (newSeconds / 3600, (newSeconds % 3600) / 60, (newSeconds % 3600) % 60)
    }

    fileprivate func loadAlertSound() {
        do {
            if let bundle = Bundle.main.path(forResource: "alert", ofType: "mp3") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                let sound = try AVAudioPlayer(contentsOf: alertSound as URL)
                shortAudioPlayer = sound
            }
        } catch {
            print("Unable to load sound. Error: \(error)")
        }
    }

    //MARK: Data Access


    private func getVideos() {
        guard !fetchInProgress else {
            return
        }

        fetchInProgress = true

        // For debugging enable sound to play every time a call is made for more videos.
        if NetworkService.shared.debuggingEnabled {
            shortAudioPlayer?.play()
        }

        NetworkService.shared.fetchPageableData(endPoint: .vod, page: currentPage) { (newVideos: Videos?, error) in
            self.fetchInProgress = false

            if let error = error {
//                self.showAlert(withTitle: "Error", message: "Unable to fetch videos: \(error)")
                print("Error: \(error)")
            } else {
                if let vods = newVideos {
                    // We are paging data so let's add to the end of the list. In a none-paging
                    // system we'd just update results with completely new data.
                    self.currentPage += 1
                    self.total = vods.programs.count
                    self.vodsDownloaded += vods.programs.count
                    self.vodPrograms.append(contentsOf: vods.programs)

                    // If no more videos availavable to download in next batch
                    // set the videos available to show to what we already downloaded.
                    if vods.nextPage == .none {
                        self.vodsAvailableToDisplay = self.vodsDownloaded
                    }

                    if self.currentPage > 1 {
                        // Display updated data.
//                        DispatchQueue.main.async {
//                            let newIndexPathsToReload = self.calculateIndexPathsToReload(from: vods.programs.count)
//                            let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
//                            self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
//                        }
                    } else {
                        // First fetch of data so just display as norma.
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
                    }
                } else {
                    //TODO: Validate pagination logic with error scenarios and update accordingly.
                    // This coe would actually remove any existing videos and I'm not sure that's what
                    // we want if we receive some pages and not others. The QA team couldn't properly
                    // validate one way or another with the given time constraints for the project.
                    self.vodPrograms = [Program]()

//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
                }
            }
        }
    }

    private func getSchools() {
        NetworkService.shared.fetchData(endPoint: .schools) { (schoolsData: SchoolsData?, error) in
            if let error = error {
//                self.showAlert(withTitle: "Error", message: "Unable to fetch schools: \(error)")
                print("Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    if let schoolData = schoolsData {
                        self.schools = schoolData.schools
                    } else {
                        self.schools = [School]()
                    }
                }


//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
        }
    }

    private func getSports() {
        NetworkService.shared.fetchData(endPoint: .sports) { (sportsData: SportsData?, error) in
            if let error = error {
//                self.showAlert(withTitle: "Error", message: "Unable to fetch sports: \(error)")
                print("Error: \(error)")
            } else {
                DispatchQueue.main.async {
                    if let sportsData = sportsData {
                        self.sports = sportsData.sports
                    } else {
                        self.sports = [Sport]()
                    }
                }


//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
        }
    }

    private func sportNames(for videoSports: [VideoSport]?) -> String {
        guard let videoSports = videoSports else { return "<no sports>" }

        var sportNames = [String]()

        for videoSport in videoSports {
            let sportName = sportForID(videoSport.id)
            sportNames.append(sportName)
        }

        return sportNames.joined(separator: ", ")
    }

    private func schoolNames(for videoSchools: [VideoSchool]?) -> String {
        guard let videoSchools = videoSchools else { return "<no schools>" }
        var sportNames = [String]()

        for videoSchool in videoSchools {
            let sportName = schoolForID(videoSchool.id)
            sportNames.append(sportName)
        }

        return sportNames.joined(separator: ", ")
    }

    private func schoolForID(_ id: Int) -> String {
        let matchingSchools = schools.filter{ $0.id == id }
        let schoolName = matchingSchools.count > 0 ? matchingSchools[0].name : "<\(String(id))>"

        return schoolName
    }

    private func sportForID(_ id: Int) -> String {
        let matchingSports = sports.filter{ $0.id == id }
        let sportName = matchingSports.count > 0 ? matchingSports[0].name : "<\(String(id))>"

        return sportName
    }


}
