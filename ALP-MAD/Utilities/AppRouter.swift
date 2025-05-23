//
//  AppRouter.swift
//  ALP-MAD
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
