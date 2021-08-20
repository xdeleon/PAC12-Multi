//
//  PAC_12_DesktopApp.swift
//  PAC-12 Desktop
//
//  Created by Xavier De Leon on 8/19/21.
//

import SwiftUI

@main
struct PAC_12_DesktopApp: App {
    var body: some Scene {
        WindowGroup {
            CardsView().frame(minWidth: 600, idealWidth: 600, minHeight: 800, idealHeight: 800, maxHeight: 1600)
        }
    }
}
