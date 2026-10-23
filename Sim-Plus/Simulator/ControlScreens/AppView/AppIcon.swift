import ScrechKit

struct AppIcon: View {
    let application: Application
    let width: CGFloat

    var body: some View {
        if let icon = application.icon {
            Image(nsImage: icon)
                .resizable()
                .clipShape(.rect(cornerRadius: width / 5))
                .frame(width)
        } else {
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: width / 5)
                        .stroke(Color.primary, style: StrokeStyle(lineWidth: 0.5, dash: [width / 20 + 1]))
                )
                .frame(width)
        }
    }
}

#Preview {
    AppIcon(application: Application.default, width: 100)
}
