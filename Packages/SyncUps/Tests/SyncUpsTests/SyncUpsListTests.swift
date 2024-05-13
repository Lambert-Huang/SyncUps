import XCTest
import ComposableArchitecture
@testable import Models
@testable import SyncUpsListFeature
@testable import SyncUpFormFeature

final class SyncUpsListTests: XCTestCase {
  
  @MainActor
  func testAddSyncUp_NonExhaustive() async {
    let store = TestStore(
      initialState: SyncUpsListLogic.State(),
      reducer: SyncUpsListLogic.init,
      withDependencies: { $0.uuid = .incrementing }
    )
    store.exhaustivity = .off(showSkippedAssertions: true)
    
    await store.send(.addSyncUpButtonTapped)
    
    let editedSyncUp = SyncUp(
      id: SyncUp.ID(UUID(0)),
      attendees: [
        Attendee(id: Attendee.ID(), name: "Blob"),
        Attendee(id: Attendee.ID(), name: "Blob Jr."),
      ],
      title: "Point-Free morning sync"
    )
    
    await store.send(\.addSyncUp.binding.syncUp, editedSyncUp)
    await store.send(.confirmAddButtonTapped) {
      $0.syncUps = [editedSyncUp]
    }
  }
  
  @MainActor
  func testAddSyncUp() async {
    let store = TestStore(initialState: SyncUpsListLogic.State(), reducer: SyncUpsListLogic.init, withDependencies: { $0.uuid = .incrementing })
    await store.send(.addSyncUpButtonTapped) { state in
      state.addSyncUp = SyncUpFormLogic.State(syncUp: SyncUp(id: SyncUp.ID(UUID(0))))
    }
    let editedSyncUp = SyncUp(
      id: SyncUp.ID(UUID(0)),
      attendees: [
        Attendee(id: Attendee.ID(), name: "Blob"),
        Attendee(id: Attendee.ID(), name: "Blob Jr."),
      ],
      title: "Point-Free morning sync"
    )
    await store.send(\.addSyncUp.binding.syncUp, editedSyncUp) { state in
      state.addSyncUp?.syncUp = editedSyncUp
    }
    await store.send(\.confirmAddButtonTapped) { state in
      state.addSyncUp = nil
      state.syncUps.append(editedSyncUp)
    }
  }
    
  @MainActor
  func testDeletion() async {
    let store = TestStore(
      initialState: SyncUpsListLogic.State(),
      reducer: SyncUpsListLogic.init
    )
    await store.send(.onDelete([0])) { state in
      state.syncUps = []
    }
  }
}
