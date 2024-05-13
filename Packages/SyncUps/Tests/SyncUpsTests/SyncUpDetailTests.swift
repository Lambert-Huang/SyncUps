//
//  File.swift
//  
//
//  Created by lambert on 2024/5/11.
//

import ComposableArchitecture
import Models
import XCTest
import SyncUpFormFeature

@testable import SyncUpDetailFeature

class SyncUpDetailTests: XCTestCase {
  
  @MainActor
  func testDelete() async {
    let syncUp = SyncUp(id: SyncUp.ID(), title: "Point-Free Morning Sync")
    let store = TestStore(
      initialState: SyncUpDetailLogic.State(syncUp: Shared(syncUp)),
      reducer: SyncUpDetailLogic.init
    )
    await store.send(.deleteButtonTapped) {
      $0.destination = .alert(.deleteSyncUp)
    }
    await store.send(.destination(.presented(.alert(.confirmButtonTapped)))) {
      $0.destination = nil
    }
  }
  
  @MainActor
  func testEdit() async {
    let syncUp = SyncUp(id: SyncUp.ID(), title: "Point-Free Morning Sync")
    let store = TestStore(
      initialState: SyncUpDetailLogic.State(syncUp: Shared(syncUp)),
      reducer: SyncUpDetailLogic.init
    )
    await store.send(.editButtonTapped) {
      $0.destination = .edit(SyncUpFormLogic.State(syncUp: syncUp))
    }
    
    var editedSyncUp = syncUp
    editedSyncUp.title = "Point-Free Evening Sync"
    await store.send(\.destination.edit.binding.syncUp, editedSyncUp) {
      $0.destination?.edit?.syncUp = editedSyncUp
    }
    
    await store.send(.doneEditButtonTapped) {
      $0.destination = nil
      $0.syncUp = editedSyncUp
    }
  }
}
