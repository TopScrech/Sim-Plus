import ScrechKit

struct PickersFormView: View {
    /// The user's settings for capturing
    @AppStorage("captureSettings") var captureSettings = CaptureSettings(imageFormat: .png, videoFormat: .h264, display: .internal, mask: .ignored, saveURL: .desktop)

    /// Whether the user wants us to render device bezels around their screenshots.
    /// Note: this requires a mask of alpha, so we enforce that when true.
    @AppStorage("renderChrome") var renderChrome = false
    @State private var showFileImporter = false

    var body: some View {
        Form {
            Section {
                Picker("Screenshot format", selection: $captureSettings.imageFormat) {
                    ForEach(SimCtl.IO.ImageFormat.allCases, id: \.self) { type in
                        Text(type.rawValue.uppercased()).tag(type)
                    }
                }

                Picker("Video format", selection: $captureSettings.videoFormat) {
                    ForEach(SimCtl.IO.VideoFormat.all, id: \.self) { item in
                        if item == .divider {
                            Divider()
                        } else {
                            Text(item.name).tag(item)
                        }
                    }
                }
            } header: {
                Label("Format", systemImage: "photo")
            }

            Section {
                Picker("Display", selection: $captureSettings.display) {
                    ForEach(SimCtl.IO.Display.allCases, id: \.self) { display in
                        Text(display.rawValue.capitalized).tag(display)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Mask", selection: $captureSettings.mask) {
                    ForEach(SimCtl.IO.Mask.allCases, id: \.self) { mask in
                        Text(mask.rawValue.capitalized).tag(mask)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(renderChrome)

                Toggle(isOn: $renderChrome.onChange(updateChromeSettings)) {
                    Text("Add device chrome to screenshots")
                    Text("Experimental. Requires the alpha mask.")
                }
            } header: {
                Label("Capture", systemImage: "iphone")
            }

            Section {
                LabeledContent("Save to") {
                    HStack {
                        Label {
                            Text(saveFolderName)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        } icon: {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: captureSettings.saveURL.url.path))
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .help(captureSettings.saveURL.url.path)

                        Button("Choose…") {
                            showFileImporter = true
                        }

                        if case .other = captureSettings.saveURL {
                            Button("Reset to Desktop") {
                                captureSettings.saveURL = .desktop
                            }
                        }
                    }
                }
            } header: {
                Label("Location", systemImage: "folder")
            }
        }
        .toggleStyle(.switch)
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.directory]) { result in
            if case .success(let url) = result {
                captureSettings.saveURL = .other(url)
            }
        }
    }

    /// A friendly name for the folder captures are saved to.
    private var saveFolderName: String {
        FileManager.default.displayName(atPath: captureSettings.saveURL.url.path)
    }

    private func updateChromeSettings() {
        if renderChrome {
            captureSettings.mask = .alpha
        }
    }
}

#Preview {
    PickersFormView()
}
