import ScrechKit

struct AppSummaryView: View {
    let application: Application

    var body: some View {
        HStack {
            AppIcon(application: application, width: 60)

            VStack(alignment: .leading) {
                Text(application.displayName)
                    .headline()
                Text(application.versionNumber.isNotEmpty ? "Version \(application.versionNumber)" : "")
                    .caption()
                Text(application.buildNumber.isNotEmpty ? "Build \(application.buildNumber)" : "")
                    .caption()
            }
        }
    }
}

#Preview {
    AppSummaryView(application: Application.default)
}
