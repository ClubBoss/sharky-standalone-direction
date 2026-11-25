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
  func testPracticeReminderUsesSelectedTimeAndSkipsTodayWhenNeeded() throws {
    let calendar = Calendar(identifier: .gregorian)
    let now = try XCTUnwrap(calendar.date(from: DateComponents(
      year: 2026, month: 11, day: 25, hour: 10
    )))
    let sameDay = try XCTUnwrap(practiceReminderEvening(
      tomorrow: false, now: now, calendar: calendar, hour: 12, minute: 30
    ))
    XCTAssertEqual(sameDay.day, 25)
    XCTAssertEqual(sameDay.hour, 12)
    XCTAssertEqual(sameDay.minute, 30)
    let practiced = try XCTUnwrap(practiceReminderEvening(
      tomorrow: true, now: now, calendar: calendar, hour: 12, minute: 30
    ))
    XCTAssertEqual(practiced.day, 26)
    let timePassed = try XCTUnwrap(practiceReminderEvening(
      tomorrow: false, now: now, calendar: calendar, hour: 9, minute: 15
    ))
    XCTAssertEqual(timePassed.day, 26)
    let alreadyReminded = try XCTUnwrap(practiceReminderEvening(
      tomorrow: false, now: now, calendar: calendar, hour: 12, minute: 30,
      lastReminderAt: now.addingTimeInterval(-3600)
    ))
    XCTAssertEqual(alreadyReminded.day, 26)
  }
}
