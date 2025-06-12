//
//  AppRouter.swift
//  ALP-MAD / MAC
//
//  Created by student on 22/05/25.
//

import SwiftUI

class AppRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to destination: any Hashable) {
        path.append(destination)
    }

    func navigateBack() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

extension AppRouter {
    static func initialView() -> some View {
        #if os(macOS)
        return AnyView(MacMainView()) // Ganti dengan view utama kamu untuk macOS
        #else
        return AnyView(SplashScreenView()) // View utama iOS kamu
        #endif
    }
}
