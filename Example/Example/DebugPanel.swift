import SwiftUI

struct DebugPanel<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    @State private var collapsed = false

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            if !collapsed {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(.vertical, 4)
            }
        }
        .background(Color(white: 0.12).opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color(white: 0.35), lineWidth: 0.5)
        )
        .font(.system(size: 12, design: .monospaced))
        .foregroundStyle(.white)
    }

    private var titleBar: some View {
        HStack(spacing: 6) {
            Text(collapsed ? "▶" : "▼")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color(white: 0.6))
            Text(title)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color(white: 0.18))
        .contentShape(Rectangle())
        .onTapGesture { collapsed.toggle() }
    }
}

// MARK: - Row primitives

struct DebugRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            content()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
    }
}

struct DebugToggle: View {
    let label: String
    @Binding var value: Bool

    var body: some View {
        DebugRow {
            Toggle(isOn: $value) {
                Text(label)
                    .foregroundStyle(Color(white: 0.85))
            }
            .toggleStyle(DebugToggleStyle())
        }
    }
}

private struct DebugToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(configuration.isOn ? Color(red: 0.2, green: 0.6, blue: 1) : Color(white: 0.3))
                    .frame(width: 28, height: 14)
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
                    .offset(x: configuration.isOn ? 7 : -7)
                    .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
