//
//  ViewController.swift
//  PAC12
//
//  Created by Xavier De Leon on 8/17/21.
//

import UIKit
import SDWebImage
import AVFoundation
import AudioToolbox

final class VODCardCell: UITableViewCell {
    @IBOutlet weak var debugView: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var listOfSportsLabel: UILabel!
    @IBOutlet weak var listOfSchoolsLabel: UILabel!
    @IBOutlet weak var programImageView: UIImageView!
}

final class CardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    @IBOutlet weak var tableView: UITableView!

    private var sports = [Sport]()
    private var schools = [School]()
    private var vodPrograms = [Program]()

    private var currentPage = 0
    private var total = 0
    private var fetchInProgress = false
    private var vodsAvailableToDisplay = 100000 // 100K
    private var vodsDownloaded = 0
    private var shortAudioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadAlertSound()
        tableView.prefetchDataSource = self
        getData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vodPrograms.count > 0 {
            return vodsAvailableToDisplay
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCellID", for: indexPath) as! VODCardCell

        cell.debugView.isHidden = !NetworkService.shared.debuggingEnabled

        if isLoadingCell(for: indexPath) {
            // It would be better to have a visual indicator here that the cells are loading
            // but the quick and dirty method is simply to hide the cell elements since there
            // is nothing available to display.
            cell.cellView.isHidden = true

        } else {
            cell.cellView.isHidden = false
            let program = vodPrograms[indexPath.row]
            cell.titleLabel.text = program.title
            cell.durationLabel.text = formattedTimeLength(seconds: program.duration)

            cell.listOfSportsLabel.text = sportNames(for: program.sports)
            cell.listOfSchoolsLabel.text = schoolNames(for: program.schools)
            cell.cardNumberLabel.text = String(indexPath.row + 1)

            // Note we request images and may receive them out of order or even after the user has scrolled away
            // from the table view cell which requested that image. Or we may simply never receive the image.
            if let url = URL(string: program.emailImage) {
                let missingImage = UIImage(named: "Placeholder")
                cell.programImageView.sd_setImage(with: url, placeholderImage: missingImage, options: .refreshCached, completed: nil)
            } else {
                cell.imageView?.image = UIImage(named: "Missing Image")
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(withTitle: "Just An Assesssment", message: "Move along now. Nothing else here to see...")
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            getVideos()
        }
    }

    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= vodPrograms.count
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)

        return Array(indexPathsIntersection)
    }

    //MARK: Utility Functions

    private func calculateIndexPathsToReload(from newProgramsCount: Int) -> [IndexPath] {
        let startIndex = vodPrograms.count - newProgramsCount
        let endIndex = startIndex + newProgramsCount

        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }

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

    private func getData() {
        getSchools()
        getSports()
        getVideos()
    }

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
                self.showAlert(withTitle: "Error", message: "Unable to fetch videos: \(error)")
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
                        DispatchQueue.main.async {
                            let newIndexPathsToReload = self.calculateIndexPathsToReload(from: vods.programs.count)
                            let indexPathsToReload = self.visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
                            self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                        }
                    } else {
                        // First fetch of data so just display as norma.
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    //TODO: Validate pagination logic with error scenarios and update accordingly.
                    // This coe would actually remove any existing videos and I'm not sure that's what
                    // we want if we receive some pages and not others. The QA team couldn't properly
                    // validate one way or another with the given time constraints for the project.
                    self.vodPrograms = [Program]()

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    private func getSchools() {
        NetworkService.shared.fetchData(endPoint: .schools) { (schoolsData: SchoolsData?, error) in
            if let error = error {
                self.showAlert(withTitle: "Error", message: "Unable to fetch schools: \(error)")
                print("Error: \(error)")
            } else {
                if let schoolData = schoolsData {
                    self.schools = schoolData.schools
                } else {
                    self.schools = [School]()
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func getSports() {
        NetworkService.shared.fetchData(endPoint: .sports) { (sportsData: SportsData?, error) in
            if let error = error {
                self.showAlert(withTitle: "Error", message: "Unable to fetch sports: \(error)")
                print("Error: \(error)")
            } else {
                if let sportsData = sportsData {
                    self.sports = sportsData.sports
                } else {
                    self.sports = [Sport]()
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
