//
//  File.swift
//  
//
//  Created by lambert on 2024/5/11.
//

import ComposableArchitecture
import SwiftUI
import Models

@Reducer
public struct MeetingLogic {
  
}

public struct MeetingView: View {
  public let meeting: Meeting
  public let syncUp: SyncUp
  public init(meeting: Meeting, syncUp: SyncUp) {
    self.meeting = meeting
    self.syncUp = syncUp
  }
  public var body: some View {
    Form {
      Section {
        ForEach(syncUp.attendees) { attendee in
          Text(attendee.name)
        }
      } header: {
        Text("Attendees")
      }
      
      Section {
        Text(meeting.transcript)
      } header: {
        Text("Transcript")
      }
    }
    .navigationTitle(Text(meeting.date, style: .date))
  }
}

#Preview {
  MeetingView(meeting: SyncUp.mock.meettings[0], syncUp: .mock)
}
