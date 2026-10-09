import ScrechKit

struct AboutView: View {
    var appName: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Control Room"
    }

    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }

    var appBuild: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1.0"
    }

    var copyright: String {
        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
        return copyright ?? "Copyright © 2023 Paul Hudson. All rights reserved."
    }

    let authors: [Author]

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSImage(named: NSImage.applicationIconName)!)
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .frame(64)

            Text("Control Room")
                .bold()

            Text("Version \(appVersion) (\(appBuild))")
                .caption()

            if authors.isNotEmpty {
                Text("Built thanks to the contributions of:")
                    .caption()

                // contributors
                CollectionView(authors, horizontalSpacing: 0, horizontalAlignment: .center, verticalSpacing: 0) { author in
                    Link("@\(author.login)", destination: author.htmlUrl)
                        .padding(2)
                }
                .caption()
            }

            Text(copyright)
                .caption()
        }
        .padding(20)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(authors: [])
    }
}
