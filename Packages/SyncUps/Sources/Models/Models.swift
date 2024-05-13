//
//  File.swift
//  
//
//  Created by lambert on 2024/5/10.
//

import Foundation
import SwiftUI
import IdentifiedCollections
import Tagged

public struct SyncUp: Equatable, Identifiable, Codable {
  public let id: Tagged<Self, UUID>
  public var attendees: IdentifiedArrayOf<Attendee> = []
  public var duration: Duration
  public var meettings: IdentifiedArrayOf<Meeting> = []
  public var theme: Theme
  public var title: String
  public var durationPerAttendee: Duration {
    duration / attendees.count
  }
  public init(
    id: Tagged<Self, UUID>,
    attendees: IdentifiedArrayOf<Attendee> = [],
    duration: Duration = .seconds(60 * 3),
    meettings: IdentifiedArrayOf<Meeting> = [],
    theme: Theme = .bubblegum,
    title: String = ""
  ) {
    self.id = id
    self.attendees = attendees
    self.duration = duration
    self.meettings = meettings
    self.theme = theme
    self.title = title
  }
}

public struct Attendee: Equatable, Identifiable, Codable {
  public let id: Tagged<Self, UUID>
  public var name = ""
  public init(
    id: Tagged<Self, UUID>,
    name: String = ""
  ) {
    self.id = id
    self.name = name
  }
}

public struct Meeting: Equatable, Identifiable, Codable {
  public let id: Tagged<Self, UUID>
  public let date: Date
  public var transcript: String
  public init(
    id: Tagged<Self, UUID>,
    date: Date,
    transcript: String
  ) {
    self.id = id
    self.date = date
    self.transcript = transcript
  }
}

public enum Theme: String, CaseIterable, Equatable, Identifiable, Codable {
  public var id: Self { self }
  
  case bubblegum
  case buttercup
  case indigo
  case lavender
  case magenta
  case navy
  case orange
  case oxblood
  case periwinkle
  case poppy
  case purple
  case seafoam
  case sky
  case tan
  case teal
  case yellow


  public var accentColor: Color {
    switch self {
    case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan,
        .teal, .yellow:
      return .black
    case .indigo, .magenta, .navy, .oxblood, .purple:
      return .white
    }
  }


  public var mainColor: Color { Color(rawValue, bundle: .module) }


  public var name: String { rawValue.capitalized }
}

public extension SyncUp {
  static let mock = Self(
    id: SyncUp.ID(),
    attendees: [
      Attendee(id: Attendee.ID(), name: "Blob"),
      Attendee(id: Attendee.ID(), name: "Blob Jr"),
      Attendee(id: Attendee.ID(), name: "Blob Sr"),
      Attendee(id: Attendee.ID(), name: "Blob Esq"),
      Attendee(id: Attendee.ID(), name: "Blob III"),
      Attendee(id: Attendee.ID(), name: "Blob I"),
    ],
    duration: .seconds(60),
    meettings: [
      Meeting(
        id: Meeting.ID(),
        date: Date().addingTimeInterval(-60 * 60 * 24 * 7),
        transcript: """
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
          incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
          exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure \
          dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \
          Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt \
          mollit anim id est laborum.
          """
      )
    ],
    theme: .orange,
    title: "Design"
  )
}
