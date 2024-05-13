//
//  File.swift
//  
//
//  Created by lambert on 2024/5/10.
//

import XCTest
import ComposableArchitecture

@testable import Models
@testable import SyncUpFormFeature

class SyncUpFormTests: XCTestCase {
  
  @MainActor
  func testAddAttendee() async {
    let store = TestStore(
      initialState: SyncUpFormLogic.State(
        syncUp: SyncUp(
          id: SyncUp.ID()
        )
      ),
      reducer: SyncUpFormLogic.init,
      withDependencies: {
        $0.uuid = .incrementing
      }
    )
    await store.send(.addAttendeeButtonTapped) { state in
      let attendee = Attendee(id: Attendee.ID(UUID(0)))
      state.focus = .attendee(attendee.id)
      state.syncUp.attendees.append(attendee)
    }
  }
  
  @MainActor
  func testRemoveFocusedAttendee() async {
    let attendee1 = Attendee(id: Attendee.ID())
    let attendee2 = Attendee(id: Attendee.ID())
    let store = TestStore(
      initialState: SyncUpFormLogic.State(
        focus: .attendee(attendee1.id),
        syncUp: SyncUp(
          id: SyncUp.ID(),
          attendees: [
            attendee1,
            attendee2
          ]
        )
      ),
      reducer: SyncUpFormLogic.init
    )
    await store.send(.onDeleteAttendees([0])) { state in
      state.focus = .attendee(attendee2.id)
      state.syncUp.attendees = [attendee2]
    }
  }
  
  @MainActor
  func testRemoveAttendee() async {
    let store = TestStore(
      initialState: SyncUpFormLogic.State(
        syncUp: SyncUp(
          id: SyncUp.ID(),
          attendees: [
            Attendee(id: Attendee.ID()),
            Attendee(id: Attendee.ID())
          ]
        )
      ),
      reducer: SyncUpFormLogic.init
    )
    
    await store.send(.onDeleteAttendees([0])) { state in
      state.syncUp.attendees.removeFirst()
    }
  }
}
