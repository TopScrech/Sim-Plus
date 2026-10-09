import SwiftUI

/// Shown when the app launches, while simulator data is being fetched from simctl.
struct LoadingView: View {
    var body: some View {
        Text("Fetching simulator list…")
            .padding()
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            .controlSize(.large)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
