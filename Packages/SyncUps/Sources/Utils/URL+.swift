//
//  File.swift
//  
//
//  Created by lambert on 2024/5/11.
//

import Foundation

public extension URL {
  static let syncUps = Self.documentsDirectory.appending(component: "sync-ups.json")
}
