import Testing
@testable import Control_Room

struct ThermalOverrideTests {
    @Test(arguments: [
        (ThermalState.nominal, 0),
        (ThermalState.fair, 10),
        (ThermalState.serious, 20),
        (ThermalState.critical, 30)
    ])
    func simulatorThermalLevel(state: ThermalState, expected: Int) {
        #expect(state.rawValue == expected)
    }

    @Test(arguments: [
        ("com.apple.system.thermalpressurelevel 0\n", 0),
        ("com.apple.system.thermalpressurelevel 30\n", 30),
        ("40\n", 40),
        ("  com.apple.system.thermalpressurelevel\t20 \n", 20)
    ])
    func parsedThermalValue(output: String, expected: Int) throws {
        #expect(try ThermalOverrideController.parseValue(output) == expected)
    }

    @Test(arguments: ["", "unrelated.notification 30", "error 1", "-1", "30 extra", "not a number"])
    func rejectedUnexpectedOutput(output: String) {
        #expect(throws: ThermalOverrideError.self) {
            try ThermalOverrideController.parseValue(output)
        }
    }
}
