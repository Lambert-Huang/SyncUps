//
//  AppApp.swift
//  App
//
//  Created by Anderson  on 2024/3/26.
//

import SwiftUI
import ComposableArchitecture
import AppFeature

@main
struct SyncUpsApp: App {
	@MainActor
  static let store = Store(
    initialState: AppLogic.State(),
    reducer: { AppLogic()._printChanges() }
  )
	var body: some Scene {
		WindowGroup {
      NavigationStack {
        AppView(store: Self.store)
      }
		}
	}
}
