import ComposableArchitecture
import SwiftUI
import SyncUpsListFeature
import SyncUpDetailFeature
import MeetingFeature
import Models
import Utils
import RecordMeetingFeature

@Reducer
public struct AppLogic {
  
	public init() {}
  
  @ObservableState
	public struct State: Equatable {
    public init() {}
    public var path = StackState<AppLogic.Path.State>()
    public var syncUpsList = SyncUpsListLogic.State()
	}
	public enum Action {
    case path(StackActionOf<AppLogic.Path>)
    case syncUpsList(SyncUpsListLogic.Action)
	}
	public var body: some ReducerOf<Self> {
    Scope(state: \.syncUpsList, action: \.syncUpsList) {
      SyncUpsListLogic()
    }
		Reduce { state, action in
			switch action {
      case let .path(.element(_, .detail(.delegate(.pushToMeeting(meeting, syncUp))))):
        state.path.append(.meeting(meeting, syncUp: syncUp))
        return .none
        
      case let .path(.element(_, .detail(.delegate(.startMeeting(syncUp))))):
        state.path.append(.record(RecordMeetingLogic.State(syncUp: syncUp)))
        return .none
        
      case .path:
        return .none
        
      case let .syncUpsList(.delegate(.pushToDetail(syncUp))):
        state.path.append(.detail(SyncUpDetailLogic.State(syncUp: syncUp)))
        return .none
        
      default: return .none
			}
		}
    .forEach(\.path, action: \.path)
	}
  
  @Reducer(state: .equatable)
  public enum Path {
    case detail(SyncUpDetailLogic)
    case meeting(Meeting, syncUp: SyncUp)
    case record(RecordMeetingLogic)
  }
}

public struct AppView: View {
	@Bindable var store: StoreOf<AppLogic>
	public init(store: StoreOf<AppLogic>) {
		self.store = store
	}
	public var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path)
    ) {
      SyncUpsListView(
        store: store.scope(state: \.syncUpsList, action: \.syncUpsList)
      )
    } destination: { store in
      switch store.case {
      case let .detail(detailStore):
        SyncUpDetailView(store: detailStore)
      case let .meeting(meeting, syncUp: syncUp):
        MeetingView(meeting: meeting, syncUp: syncUp)
      case let .record(recordMeetingStore):
        RecordMeetingView(store: recordMeetingStore)
      }
    }
	}
}
