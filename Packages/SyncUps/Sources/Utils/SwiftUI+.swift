//
//  File.swift
//  
//
//  Created by lambert on 2024/5/13.
//

import SwiftUI

public struct TrailingIconLabelStyle: LabelStyle {
  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.title
      configuration.icon
    }
  }
}

public extension LabelStyle where Self == TrailingIconLabelStyle {
  static var trailingIcon: Self { Self() }
}
