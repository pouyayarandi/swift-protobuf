// Sources/SwiftProtobuf/Message+FieldMask.swift - Message field mask extensions
//
// Copyright (c) 2014 - 2016 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/main/LICENSE.txt
//
// -----------------------------------------------------------------------------
///
/// Extend the Message types with FieldMask utilities.
///
// -----------------------------------------------------------------------------

import Foundation

extension Message {
  public static func isPathValid(
    _ path: String
  ) -> Bool {
    Self().hasPath(path: path)
  }

  internal func isPathValid(
    _ path: String
  ) -> Bool {
    hasPath(path: path)
  }
}

extension Message {
  public mutating func merge(
    to source: Self,
    fieldMask: Google_Protobuf_FieldMask
  ) throws {
    var copy = self
    var pathToValueMap: [String: Any?] = [:]
    for path in fieldMask.paths {
      pathToValueMap[path] = try source.get(path: path)
    }
    for (path, value) in pathToValueMap {
      try copy.set(path: path, value: value)
    }
    self = copy
  }
}

extension Message where Self: Equatable, Self: _ProtoNameProviding {
  @discardableResult
  public mutating func trim(
    fieldMask: Google_Protobuf_FieldMask
  ) -> Bool {
    if !fieldMask.isValid(for: Self.self) {
      return false
    }
    if fieldMask.paths.isEmpty {
      return false
    }
    var tmp = Self.init()
    do {
      try tmp.merge(to: self, fieldMask: fieldMask)
      let changed = tmp != self
      self = tmp
      return changed
    } catch {
      return false
    }
  }
}
