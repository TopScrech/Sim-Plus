import Foundation
import Testing
@testable import Control_Room

struct StatusBarTimeTests {
    @Test(arguments: [
        ("UTC", "2007-01-09T08:41:00.000+00:00"),
        ("Europe/Amsterdam", "2007-01-09T09:41:00.000+01:00"),
        ("Asia/Kolkata", "2007-01-09T14:11:00.000+05:30")
    ])

    func formattedOverride(timeZoneIdentifier: String, expectedTime: String) throws {
        let timeZone = try #require(TimeZone(identifier: timeZoneIdentifier))
        let date = Date(timeIntervalSince1970: 1_168_332_060)
        let command = SimCtl.Command.statusBarTime(deviceId: "test-device", time: date, timeZone: timeZone)

        #expect(command.arguments == ["simctl", "status_bar", "test-device", "override", "--time", expectedTime])
    }
}
