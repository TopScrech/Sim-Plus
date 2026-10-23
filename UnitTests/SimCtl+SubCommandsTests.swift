@testable import Control_Room
import Testing

struct SimCtlSubCommandsTests {
    @Test
    func testDeleteUnavailable() throws {
        let command: SimCtl.Command = .delete(.unavailable)
        let expectation = ["simctl", "delete", "unavailable"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testBoot() throws {
        let getSimulator: (String) -> Simulator = { buildVersion in
            let runtime = Runtime(buildversion: buildVersion, identifier: "made-up", version: "version", isAvailable: true, name: "iPhone 14")
            return Simulator(name: "iPhone 14", udid: "made-up-udid", state: .shutdown, runtime: runtime, deviceType: nil, dataPath: "fake-path")
        }
        let expectedArguments = ["simctl", "boot", "made-up-udid"]

        let command160: SimCtl.Command = .boot(simulator: getSimulator("16.0"))
        #expect(command160.arguments == expectedArguments)
        #expect(command160.environmentOverrides == nil)

        let command161: SimCtl.Command = .boot(simulator: getSimulator("16.1"))
        #expect(command161.arguments == expectedArguments)
        #expect(command161.environmentOverrides == ["SIMCTL_CHILD_SIMULATOR_RUNTIME_VERSION": "16.0"])
    }

    @Test
    func testRecordAVideo() throws {
        let command: SimCtl.Command = .io(deviceId: "device1", operation: .recordVideo(codec: .h264, url: "~/my-video.mov"))
        let expectation = ["simctl", "io", "device1", "recordVideo", "--codec=h264", "~/my-video.mov"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testScreenshot() throws {
        let command: SimCtl.Command = .io(deviceId: "device1", operation: .screenshot(type: .png, display: .internal, mask: .ignored, url: "~/my-image.png"))
        let expectation = ["simctl", "io", "device1", "screenshot", "--type=png", "--display=internal", "--mask=ignored", "~/my-image.png"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testlist() throws {
        let command: SimCtl.Command = .list()
        let expectation = ["simctl", "list"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testlistFilterSearchFlag() throws {
        let command: SimCtl.Command = .list(filter: .devicetypes, search: .string("search"), flags: [.json])
        let expectation = ["simctl", "list", "devicetypes", "search", "-j"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testOpenUrl() throws {
        let command: SimCtl.Command = .openURL(deviceId: "device1", url: "https://www.hackingwithswift.com")
        let expectation = ["simctl", "openurl", "device1", "https://www.hackingwithswift.com"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testAddMedia() throws {
        let command: SimCtl.Command = .addMedia(deviceId: "device1", mediaPaths: ["~/sample-1.jpg"])
        let expectation = ["simctl", "addmedia", "device1", "~/sample-1.jpg"]
        #expect(command.arguments == expectation)
    }

    @Test
    func testDefaultsForApp() throws {
        let command: SimCtl.Command = .spawn(deviceId: "device1", pathToExecutable: "defaults read", options: [.waitForDebugger])
        let expectation = ["simctl", "spawn", "-w", "device1", "defaults read"]
        #expect(command.arguments == expectation)
    }
}
