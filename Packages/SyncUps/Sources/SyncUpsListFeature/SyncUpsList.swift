//
//  SyncUpsList.swift
//
//
//  Created by lambert on 2024/5/10.
//

import ComposableArchitecture
import Models
import SwiftUI
import SyncUpFormFeature
import Utils
import SyncUpDetailFeature

@Reducer
public struct SyncUpsListLogic {
  public init() {}
  @ObservableState
  public struct State: Equatable {
    @Presents var addSyncUp: SyncUpFormLogic.State?
    @Shared(.fileStorage(.syncUps)) public var syncUps: IdentifiedArrayOf<SyncUp> = []
    public init() {}
  }

  public enum Action {
    case addSyncUpButtonTapped
    case addSyncUp(PresentationAction<SyncUpFormLogic.Action>)
    case confirmAddButtonTapped
    case discardButtonTapped
    case onDelete(IndexSet)
    case syncUpTapped(SyncUp)
    case delegate(Delegate)
    case onAppear
    
    public enum Delegate {
      case pushToDetail(Shared<SyncUp>)
    }
  }

  @Dependency(\.uuid) var uuid
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addSyncUpButtonTapped:
        state.addSyncUp = SyncUpFormLogic.State(syncUp: SyncUp(id: SyncUp.ID(uuid())))
        return .none
        
      case .addSyncUp:
        return .none
        
      case .confirmAddButtonTapped:
        guard let newSyncUp = state.addSyncUp?.syncUp else {
          return .none
        }
        state.addSyncUp = nil
        state.syncUps.append(newSyncUp)
        return .none
        
      case .discardButtonTapped:
        state.addSyncUp = nil
        return .none
        
      case let .onDelete(indexSet):
        state.syncUps.remove(atOffsets: indexSet)
        return .none
        
      case let .syncUpTapped(syncUp):
        return .send(.delegate(.pushToDetail(state.$syncUps[id: syncUp.id]!)))
        
      case .onAppear:
//        let mockSyncUp = SyncUp(
//          id: SyncUp.ID(),
//          attendees: [
//            Attendee(id: Attendee.ID(), name: "Blob"),
//            Attendee(id: Attendee.ID(), name: "Blob Jr"),
//            Attendee(id: Attendee.ID(), name: "Blob Sr"),
//          ],
//          duration: .seconds(6),
//          meettings: [],
//          theme: .orange,
//          title: "Morning Sync"
//        )
//        state.syncUps.append(mockSyncUp)
        return .none
        
      default: return .none
      }
    }
    .ifLet(\.$addSyncUp, action: \.addSyncUp) {
      SyncUpFormLogic()
    }
  }
}

public struct SyncUpsListView: View {
  @Bindable var store: StoreOf<SyncUpsListLogic>
  public init(store: StoreOf<SyncUpsListLogic>) {
    self.store = store
  }
  public var body: some View {
    List {
      ForEach(store.$syncUps.elements) { $syncUp in
        Button {
          store.send(.syncUpTapped(syncUp))
        } label: {
          
          CardView(syncUp: syncUp)
        }
        .listRowBackground(syncUp.theme.mainColor)
      }
      .onDelete { indexSet in
        store.send(.onDelete(indexSet))
      }
    }
    .sheet(item: $store.scope(state: \.addSyncUp, action: \.addSyncUp)) { addSyncUpStore in
      NavigationStack {
        SyncUpFormView(store: addSyncUpStore)
          .navigationTitle("New sync-up")
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Discard") {
                store.send(.discardButtonTapped)
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Add") {
                store.send(.confirmAddButtonTapped)
              }
            }
          }
      }
    }
    .toolbar {
      Button {
        store.send(.addSyncUpButtonTapped)
      } label: {
        Image(systemName: "plus")
      }
    }
    .navigationTitle("Daily Sync-ups")
    .onAppear {
      store.send(.onAppear)
    }
  }
}

struct CardView: View {
  let syncUp: SyncUp
  var body: some View {
    VStack(alignment: .leading) {
      Text(syncUp.title)
        .font(.headline)
      Spacer()
      HStack {
        Label("\(syncUp.attendees.count)", systemImage: "person.3")
        Spacer()
        Label(syncUp.duration.formatted(.units()), systemImage: "clock")
          .labelStyle(.trailingIcon)
      }
      .font(.caption)
    }
    .padding()
    .foregroundStyle(syncUp.theme.accentColor)
  }
}

#Preview {
  NavigationStack {
    SyncUpsListView(
      store: Store(
        initialState: SyncUpsListLogic.State(),
        reducer: { SyncUpsListLogic()._printChanges() }
      )
    )
  }
}

