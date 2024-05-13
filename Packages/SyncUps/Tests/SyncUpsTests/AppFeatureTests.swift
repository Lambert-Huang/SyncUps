//
//  File.swift
//  
//
//  Created by lambert on 2024/5/13.
//

import ComposableArchitecture
import XCTest
import Models

@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  
  @MainActor
  func testDelete() async {
    let syncUp = SyncUp.mock
    @Shared(.fileStorage(.syncUps)) var syncUps = [syncUp]
    
    let store = TestStore(
      initialState: AppLogic.State(),
      reducer: AppLogic.init
    )
  }
}
