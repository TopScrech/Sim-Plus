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

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon(application: Application.default, width: 100)
    }
}
