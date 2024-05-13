//
//  File.swift
//
//
//  Created by lambert on 2024/5/11.
//

import ComposableArchitecture
import Models
import SwiftUI
import SyncUpFormFeature
import Utils

@Reducer
public struct SyncUpDetailLogic {
  public init() {}
  
  @Reducer(state: .equatable)
  public enum Destination {
    case alert(AlertState<Alert>)
    case edit(SyncUpFormLogic)
    
    @CasePathable
    public enum Alert {
      case confirmButtonTapped
    }
  }
  
  @ObservableState
  public struct State: Equatable {
    @Presents public var destination: Destination.State?
    @Shared public var syncUp: SyncUp
    public init(syncUp: Shared<SyncUp>) {
      self._syncUp = syncUp
    }
  }
  
  public enum Action {
    case cancelEditButtonTapped
    case deleteButtonTapped
    case destination(PresentationAction<Destination.Action>)
    case doneEditButtonTapped
    case editButtonTapped
    case meetingTapped(Meeting)
    case delegate(Delegate)
    case startMeeting
    
    public enum Delegate {
      case pushToMeeting(Meeting, SyncUp)
      case startMeeting(Shared<SyncUp>)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  
  public var body: some ReducerOf<Self> {
    Reduce {
      state,
        action in
      switch action {
      case .destination(.presented(.alert(.confirmButtonTapped))):
        @Shared(.fileStorage(.syncUps)) var syncUps: IdentifiedArrayOf<SyncUp> = []
        syncUps.remove(id: state.syncUp.id)
        return .run { _ in await dismiss() }
        
      case .destination:
        return .none
        
      case .cancelEditButtonTapped:
        state.destination = nil
        return .none
        
      case .deleteButtonTapped:
        state.destination = .alert(.deleteSyncUp)
        return .none
        
      case .doneEditButtonTapped:
        guard let editedSyncUp = state.destination?.edit?.syncUp else {
          return .none
        }
        state.syncUp = editedSyncUp
        state.destination = nil
        return .none
        
      case .editButtonTapped:
        state.destination = .edit(SyncUpFormLogic.State(syncUp: state.syncUp))
        return .none
        
      case let .meetingTapped(meeting):
        return .send(.delegate(.pushToMeeting(meeting, state.syncUp)))
        
      case .startMeeting:
        return .send(.delegate(.startMeeting(state.$syncUp)))
        
      default: return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}

public extension AlertState where Action == SyncUpDetailLogic.Destination.Alert {
  static let deleteSyncUp = Self {
    TextState("Delete?")
  } actions: {
    ButtonState(role: .destructive, action: .confirmButtonTapped) {
      TextState("Yes")
    }
    ButtonState(role: .cancel) {
      TextState("Nevermind")
    }
  } message: {
    TextState("Are you sure you want to delete this meeting?")
  }
}

public struct SyncUpDetailView: View {
  @Bindable var store: StoreOf<SyncUpDetailLogic>
  public init(store: StoreOf<SyncUpDetailLogic>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section {
        Button {
          store.send(.startMeeting)
        } label: {
          Label("Start Meeting", systemImage: "timer")
            .font(.headline)
            .foregroundColor(.accentColor)
        }
        HStack {
          Label("Length", systemImage: "clock")
          Spacer()
          Text(store.syncUp.duration.formatted(.units()))
        }
        
        HStack {
          Label("Theme", systemImage: "paintpalette")
          Spacer()
          Text(store.syncUp.theme.name)
            .padding(8)
            .foregroundStyle(store.syncUp.theme.accentColor)
            .background(store.syncUp.theme.mainColor.gradient)
            .cornerRadius(4)
        }
      } header: {
        Text("Sync-up Info")
      }
      
      if !store.syncUp.meettings.isEmpty {
        Section {
          ForEach(store.syncUp.meettings) { meeting in
//            NavigationLink(state: PathFeature.Path.State.meeting(meeting, syncUp: store.syncUp)) {
//              HStack {
//                Image(systemName: "calendar")
//                Text(meeting.date, style: .date)
//                Text(meeting.date, style: .time)
//              }
//            }
            Button {
              store.send(.meetingTapped(meeting))
            } label: {
              HStack {
                Image(systemName: "calendar")
                Text(meeting.date, style: .date)
                Text(meeting.date, style: .time)
              }
            }
          }
        } header: {
          Text("Past meetings")
        }
      }
      
      Section {
        ForEach(store.syncUp.attendees) { attendee in
          Label(attendee.name, systemImage: "person")
        }
      } header: {
        Text("Attendees")
      }
      
      Section {
        Button(role: .destructive) {
          store.send(.deleteButtonTapped)
        } label: {
          Text("Delete")
        }
      }
    }
    .toolbar {
      Button("Edit") {
        store.send(.editButtonTapped)
      }
    }
    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    .sheet(item: $store.scope(state: \.destination?.edit, action: \.destination.edit)) { editSyncUpStore in
      NavigationStack {
        SyncUpFormView(store: editSyncUpStore)
          .navigationTitle(store.syncUp.title)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                store.send(.cancelEditButtonTapped)
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Done") {
                store.send(.doneEditButtonTapped)
              }
            }
          }
      }
    }
    .navigationTitle(store.syncUp.title)
  }
}

#Preview {
  NavigationStack {
    SyncUpDetailView(
      store: Store(
        initialState: SyncUpDetailLogic.State(
          syncUp: Shared(SyncUp(
            id: SyncUp.ID(),
            attendees: [
              Attendee(id: Attendee.ID(), name: "Bob"),
              Attendee(id: Attendee.ID(), name: "Bob Jr."),
              Attendee(id: Attendee.ID(), name: "Bob Sr."),
            ],
            duration: .seconds(60 * 4),
            meettings: [
              Meeting(id: Meeting.ID(), date: Date.now, transcript: "Nice to see ya!"),
            ],
            theme: .lavender,
            title: "Point-Free Morning"
          )
          )
        ),
        reducer: SyncUpDetailLogic.init
      )
    )
  }
}
