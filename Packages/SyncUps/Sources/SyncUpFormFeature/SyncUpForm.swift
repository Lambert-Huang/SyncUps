
//
//  File.swift
//
//
//  Created by lambert on 2024/5/10.
//

import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct SyncUpFormLogic {
  public init() {}
  @ObservableState
  public struct State: Equatable {
    var focus: Field?
    public var syncUp: SyncUp
    public enum Field: Hashable {
      case attendee(Attendee.ID)
      case title
    }
    public init(focus: Field? = .title, syncUp: SyncUp) {
      self.focus = focus
      self.syncUp = syncUp
    }
  }

  public enum Action: BindableAction {
    case addAttendeeButtonTapped
    case binding(BindingAction<State>)
    case onDeleteAttendees(IndexSet)
  }
  
  @Dependency(\.uuid) var uuid

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .addAttendeeButtonTapped:
        let attendee = Attendee(id: Attendee.ID(uuid()))
        state.syncUp.attendees.append(attendee)
        state.focus = .attendee(attendee.id)
        return .none

      case .binding:
        return .none

      case let .onDeleteAttendees(indexSet):
        guard let firstDeletedIndex = indexSet.first else {
          return .none
        }
        let firstDeletedAttendee = state.syncUp.attendees[firstDeletedIndex]
        state.syncUp.attendees.remove(atOffsets: indexSet)
        if state.syncUp.attendees.isEmpty {
          state.syncUp.attendees.append(
            Attendee(id: Attendee.ID(uuid()))
          )
        }
        guard state.focus == .attendee(firstDeletedAttendee.id) else {
          return .none
        }
        let index = min(firstDeletedIndex, state.syncUp.attendees.count - 1)
        state.focus = .attendee(state.syncUp.attendees[index].id)
        return .none
      }
    }
  }
}

public struct SyncUpFormView: View {
  @Bindable var store: StoreOf<SyncUpFormLogic>
  @FocusState var focus: SyncUpFormLogic.State.Field?
  
  public init(store: StoreOf<SyncUpFormLogic>) {
    self.store = store
  }

  public var body: some View {
    Form {
      Section {
        TextField("Title", text: $store.syncUp.title)
          .focused($focus, equals: .title)
          
        HStack {
          Slider(value: $store.syncUp.duration.minutes, in: 3 ... 10, step: 1) {
            Text("Length")
          }
          Spacer()
          Text(store.syncUp.duration.formatted(.units()))
        }
        ThemePicker(selection: $store.syncUp.theme)
      } header: {
        Text("Sync-up Info")
      }
      Section {
        ForEach($store.syncUp.attendees) { $attendee in
          TextField("Name", text: $attendee.name)
            .focused($focus, equals: .attendee(attendee.id))
        }
        .onDelete { indices in
          store.send(.onDeleteAttendees(indices))
        }
        
        Button("New attendee") {
          store.send(.addAttendeeButtonTapped)
          focus = .attendee(store.syncUp.attendees.last!.id)
        }
      } header: {
        Text("Attendees")
      }
    }
    .bind($store.focus, to: $focus)
  }
}

struct ThemePicker: View {
  @Binding var selection: Theme
  var body: some View {
    Picker("Theme", selection: $selection) {
      ForEach(Theme.allCases) { theme in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(theme.mainColor)
          Label(theme.name, systemImage: "paintpalette")
            .padding(4)
        }
        .foregroundColor(theme.accentColor)
        .fixedSize(horizontal: false, vertical: true)
        .tag(theme)
      }
    }
  }
}

#Preview {
  SyncUpFormView(
    store: Store(
      initialState: SyncUpFormLogic.State(
        syncUp: SyncUp(
          id: SyncUp.ID(),
          attendees: [
            Attendee(id: Attendee.ID(), name: "Bob"),
            Attendee(id: Attendee.ID(), name: "Bob Jr")
          ],
          title: "Point Free Morning SyncUp"
        )
      ),
      reducer: SyncUpFormLogic.init
    )
  )
}

private extension Duration {
  var minutes: Double {
    get { Double(components.seconds / 60) }
    set { self = .seconds(newValue * 60) }
  }
}
