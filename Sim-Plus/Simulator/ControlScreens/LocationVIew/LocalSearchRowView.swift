import ScrechKit
import CoreLocation

struct LocalSearchRowView: View {
    @Binding var lastHoverId: UUID?
    @State private var isHovered = false
    let result: LocalSearchResult
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {

                Image(systemName: "mappin.circle.fill")
                    .symbolRenderingMode(.multicolor)
                        .title2()

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let subtitle = result.subtitle {
                        Text(subtitle)
                            .caption()
                            .secondary()
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
        .buttonStyle(.borderless)
        .frame(minHeight: 36)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isHovered ? .blue : .clear)
        .clipShape(.rect(cornerRadius: 8))
        .onChange(of: lastHoverId) {
            isHovered = lastHoverId == result.id
        }
    }
}
