import Foundation
import SwiftUI

enum NavCommand: Equatable {
    case switchTab(Int)
    case push(AppRoute)
    case popToRoot
    case showAddSheet
    case setPath([AppRoute])
}

enum AppRoute: Hashable {
    case itemDetail(String)
}

final class AppCoordinator: ObservableObject {
    @Published var pendingCommand: NavCommand?

    func execute(_ commands: NavCommand...) {
        for (i, cmd) in commands.enumerated() {
            if i == 0 {
                pendingCommand = cmd
            } else {
                DispatchQueue.main.async {
                    self.pendingCommand = cmd
                }
            }
        }
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "prjpromax" else { return }
        switch url.host {
        case "home":
            execute(.switchTab(0), .popToRoot)
        case "items":
            execute(.switchTab(1), .popToRoot)
        case "item":
            let id = url.pathComponents.dropFirst().first ?? ""
            if !id.isEmpty {
                execute(.switchTab(1), .push(.itemDetail(id)))
            } else {
                execute(.switchTab(1), .popToRoot)
            }
        case "add":
            execute(.switchTab(1), .popToRoot, .showAddSheet)
        case "grid":
            execute(.switchTab(2), .popToRoot)
        case "components":
            execute(.switchTab(3))
        case "settings":
            execute(.switchTab(4))
        default:
            break
        }
    }
}
