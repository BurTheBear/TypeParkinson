import SwiftUI

#if os(iOS)
import UIKit
#endif

/// iOS only lets people add a keyboard themselves, in Settings.
struct EnableView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openURL) private var openURL
    @State private var tryText = ""

    var body: some View {
        Page {
            Heading(kicker: "Last step",
                    title: "Use it in every app.",
                    subtitle: "The TypeParkinson keyboard works in any app that uses the system keyboard. iOS asks you to switch it on yourself.")

            VStack(alignment: .leading, spacing: 12) {
                step(1, "Open Settings, tap Keyboards, and turn on TypeParkinson.")
                step(2, "Leave “Allow Full Access” off — TypeParkinson doesn’t need it.")
                step(3, "In any text field, tap the globe key until TypeParkinson appears.")
            }

            #if os(iOS)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            .buttonStyle(.secondary())
            #endif

            VStack(alignment: .leading, spacing: 8) {
                Text("Try it here").font(Theme.serif(.body, weight: .semibold))
                TextField("Tap here, then the globe key", text: $tryText, axis: .vertical)
                    .font(Theme.serif(.title3))
                    .lineLimit(2...4)
                    .padding(14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }

            FootNote("iOS warns that any keyboard could collect what you type. Without Full Access, the TypeParkinson keyboard can’t send anything anywhere, and it never saves what you type.")
        } footer: {
            Button(model.isSetupComplete ? "Done" : "Finish setup") { model.finishSetup() }.buttonStyle(.primary)
        }
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text("\(number)").font(Theme.serif(.body, weight: .semibold)).foregroundStyle(Theme.accent)
            Text(text).font(Theme.serif(.body)).fixedSize(horizontal: false, vertical: true)
        }
    }
}
