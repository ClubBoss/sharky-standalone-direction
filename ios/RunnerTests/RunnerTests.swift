import Foundation
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  func testPracticeReminderKeepsLocalEveningAcrossClockChanges() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
    for (month, day, expectedHours) in [(3, 7, 19), (10, 31, 21)] {
      let now = try XCTUnwrap(calendar.date(from: DateComponents(
        year: 2026, month: month, day: day, hour: 22
      )))
      let evening = try XCTUnwrap(practiceReminderEvening(
        tomorrow: true, now: now, calendar: calendar
      ))
      let date = try XCTUnwrap(calendar.date(from: evening))
      XCTAssertEqual(evening.hour, 18)
      XCTAssertEqual(evening.minute, 0)
      XCTAssertEqual(date.timeIntervalSince(now), Double(expectedHours * 3600))
    }
  }
}
