//
//  File.swift
//
//
//  Created by lambert on 2024/5/13.
//

import ComposableArchitecture
import Models
import SwiftUI
import Utils

@Reducer
public struct RecordMeetingLogic {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init(syncUp: Shared<SyncUp>) {
      self._syncUp = syncUp
    }

    var secondsElapsed = 0
    var speakerIndex = 0
    @Shared var syncUp: SyncUp
    var transcript = ""
    @Presents var alert: AlertState<Action.Alert>?

    var durationRemaining: Duration {
      syncUp.duration - .seconds(secondsElapsed)
    }
  }

  public enum Action {
    case alert(PresentationAction<Alert>)
    case endMeetingButtonTapped
    case nextButtonTapped
    case onAppear
    case timerTick
    
    public enum Alert {
      case discardMeeting
      case saveMeeting
    }
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.date.now) var now
  @Dependency(\.uuid) var uuid

  public var body: some ReducerOf<Self> {
    Reduce {
      state,
      action in
      switch action {
      case .alert(.presented(.discardMeeting)):
        return .run { _ in await dismiss() }
        
      case .alert(.presented(.saveMeeting)):
        state.syncUp.meettings.insert(
          Meeting(id: Meeting.ID(uuid()), date: now, transcript: state.transcript),
          at: 0
        )
        return .run { _ in await dismiss() }
        
      case .alert:
        return .none
        
      case .endMeetingButtonTapped:
        state.alert = .endMeeting
        return .none
        
      case .nextButtonTapped:
        guard state.speakerIndex < state.syncUp.attendees.count - 1 else {
          state.alert = .endMeeting
          return .none
        }
        state.speakerIndex += 1
        state.secondsElapsed = state.speakerIndex * Int(state.syncUp.durationPerAttendee.components.seconds)
        return .none
        
      case .onAppear:
        return .run { send in
          for await _ in clock.timer(interval: .seconds(1)) {
            await send(.timerTick)
          }
        }
      case .timerTick:
        state.secondsElapsed += 1
        let secondsPerAttendee = Int(state.syncUp.durationPerAttendee.components.seconds)
        if state.secondsElapsed.isMultiple(of: secondsPerAttendee) {
          if state.secondsElapsed == state.syncUp.duration.components.seconds {
            state.syncUp.meettings.insert(
              Meeting(id: Meeting.ID(uuid()), date: now, transcript: state.transcript),
              at: 0
            )
            return .run { _ in await dismiss() }
          }
          state.speakerIndex += 1
        }
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public extension AlertState where Action == RecordMeetingLogic.Action.Alert {
  static var endMeeting: Self {
    Self {
      TextState("End meeting?")
    } actions: {
      ButtonState(action: .saveMeeting) {
        TextState("Save and end")
      }
      ButtonState(role: .destructive, action: .discardMeeting) {
        TextState("Discard")
      }
      ButtonState(role: .cancel) {
        TextState("Resume")
      }
    } message: {
      TextState("You are ending the meeting early. What would you like to do?")
    }
  }
}

public struct RecordMeetingView: View {
  @Bindable var store: StoreOf<RecordMeetingLogic>
  public init(store: StoreOf<RecordMeetingLogic>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 16)
        .fill(store.syncUp.theme.mainColor)
      VStack {
        MeetingHeaderView(
          secondsElapsed: store.secondsElapsed,
          durationRemaining: store.durationRemaining,
          theme: store.syncUp.theme
        )

        MeetingTimerView(
          syncUp: store.syncUp,
          speakerIndex: store.speakerIndex
        )
        
        MeetingFooterView(
          syncUp: store.syncUp,
          nextButtonTapped: {},
          speakerIndex: store.speakerIndex
        )
      }
    }
    .padding()
    .foregroundColor(store.syncUp.theme.accentColor)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("End Meeting") {
          store.send(.endMeetingButtonTapped)
        }
      }
    }
    .navigationBarBackButtonHidden()
    .onAppear { store.send(.onAppear) }
    .alert($store.scope(state: \.alert, action: \.alert))
  }
}

private struct MeetingHeaderView: View {
  let secondsElapsed: Int
  let durationRemaining: Duration
  let theme: Theme
  var body: some View {
    VStack {
      ProgressView(value: progress)
        .progressViewStyle(MeetingProgressViewStyle(theme: theme))
      HStack {
        VStack(alignment: .leading) {
          Text("Time Elaspsed")
            .font(.caption)
          Label(
            Duration.seconds(secondsElapsed).formatted(.units()),
            systemImage: "hourglass.bottomhalf.fill"
          )
        }
        Spacer()
        VStack(alignment: .trailing) {
          Text("Time Remaining")
            .font(.caption)
          Label(
            durationRemaining.formatted(.units()),
            systemImage: "hourglass.tophalf.fill"
          )
          .font(.body.monospacedDigit())
          .labelStyle(.trailingIcon)
        }
      }
    }
    .padding([.top, .horizontal])
  }

  private var totalDuration: Duration {
    .seconds(secondsElapsed) + durationRemaining
  }

  private var progress: Double {
    guard totalDuration > .seconds(0) else { return 0 }
    return Double(secondsElapsed) / Double(totalDuration.components.seconds)
  }
}

private struct MeetingProgressViewStyle: ProgressViewStyle {
  var theme: Theme

  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(theme.accentColor)
        .frame(height: 20)

      ProgressView(configuration)
        .tint(theme.mainColor)
        .frame(height: 12)
        .padding(.horizontal)
    }
  }
}

private struct MeetingTimerView: View {
  let syncUp: SyncUp
  let speakerIndex: Int
  var body: some View {
    Circle()
      .strokeBorder(lineWidth: 24)
      .overlay {
        VStack {
          Group {
            if speakerIndex < syncUp.attendees.count {
              Text(syncUp.attendees[speakerIndex].name)
            } else {
              Text("Someone")
            }
          }
          .font(.title)

          Text("is speaking")
          Image(systemName: "mic.fill")
            .font(.largeTitle)
            .padding(.top)
        }
        .foregroundStyle(syncUp.theme.accentColor)
      }
      .overlay {
        ForEach(Array(syncUp.attendees.enumerated()), id: \.element.id) { index, _ in
          if index < speakerIndex + 1 {
            SpeakerArc(totalSpeakers: syncUp.attendees.count, speakerIndex: index)
              .rotation(Angle(degrees: -90))
              .stroke(syncUp.theme.mainColor, lineWidth: 12)
          }
        }
      }
      .padding(.horizontal)
  }
}

private struct MeetingFooterView: View {
  let syncUp: SyncUp
  let nextButtonTapped: () -> Void
  let speakerIndex: Int
  var body: some View {
    VStack {
      HStack {
        if speakerIndex < syncUp.attendees.count - 1 {
          Text("Speaker \(speakerIndex + 1) of \(syncUp.attendees.count)")
        } else {
          Text("No more speakers.")
        }
        Spacer()
        Button(action: nextButtonTapped, label: {
          Image(systemName: "forward.fill")
        })
      }
    }
    .padding([.bottom, .horizontal])
  }
}

private struct SpeakerArc: Shape {
  let totalSpeakers: Int
  let speakerIndex: Int
  func path(in rect: CGRect) -> Path {
    let diameter = min(rect.width, rect.height) - 24
    let radius = diameter / 2
    let center = CGPoint(x: rect.midX, y: rect.midY)
    return Path { path in
      path.addArc(
        center: center,
        radius: radius,
        startAngle: startAngle,
        endAngle: endAngle,
        clockwise: false
      )
    }
  }

  private var degreesPerSpeaker: Double {
    360 / Double(totalSpeakers)
  }

  private var startAngle: Angle {
    Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1)
  }

  private var endAngle: Angle {
    Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1)
  }
}

#Preview {
  NavigationStack {
    RecordMeetingView(
      store: Store(
        initialState: RecordMeetingLogic.State(syncUp: .init(.mock)),
        reducer: RecordMeetingLogic.init
      )
    )
  }
}

