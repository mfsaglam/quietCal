import SwiftUI

// TODO: Replace with `.swipeActions` once the deployment target moves to iOS 27,
// which exposes swipeActionsContainer() for use outside List.
struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var revealed: Bool = false
    @State private var translation: CGFloat = 0

    private let deleteWidth: CGFloat = 76
    private let openThreshold: CGFloat = 38

    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    revealed = false
                }
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: deleteWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }
            .buttonStyle(.plain)
            .opacity(currentOffset < 0 ? I1 : 0)

            content()
                .background(Color(.systemBackground))
                .contentShape(Rectangle())
                .offset(x: currentOffset)
                .simultaneousGesture(swipeGesture)
                .onTapGesture {
                    if revealed {
                        withAnimation(.snappy(duration: 0.2)) {
                            revealed = false
                        }
                    }
                }
        }
        .clipped()
    }

    private var currentOffset: CGFloat {
        let base: CGFloat = revealed ? -deleteWidth : 0
        let combined = base + translation
        return min(0, max(-deleteWidth - 20, combined))
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    return
                }
                translation = value.translation.width
            }
            .onEnded { _ in
                let final = currentOffset
                withAnimation(.snappy(duration: 0.25)) {
                    revealed = final < -openThreshold
                    translation = 0
                }
            }
    }
}
