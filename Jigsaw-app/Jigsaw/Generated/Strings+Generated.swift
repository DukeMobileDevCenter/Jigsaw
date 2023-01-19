// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Strings {
  public enum Onboarding {
    public enum Instruction {
      /// In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!
      public static let detailText = Strings.tr("Localizable", "Onboarding.instruction.detailText", fallback: "In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!")
      /// Localizable.strings
      ///   Jigsaw
      /// 
      ///   Created by Ruitong Su on 1/19/23.
      ///   Copyright © 2023 DukeMobileDevCenter. All rights reserved.
      public static let title = Strings.tr("Localizable", "Onboarding.instruction.title", fallback: "Welcome to Jigsaw Escape!")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
