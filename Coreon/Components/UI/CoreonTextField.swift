import SwiftUI

struct CoreonTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var prefix: String? = nil
    var suffix: String? = nil
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CoreonColors.textMuted)
                    .frame(width: 20)
            }
            if let prefix = prefix {
                Text(prefix)
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(CoreonColors.textMuted)
            }
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(CoreonColors.textPrimary)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(CoreonColors.textPrimary)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            if let suffix = suffix {
                Text(suffix)
                    .font(CoreonFonts.regular(15))
                    .foregroundColor(CoreonColors.textMuted)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.white)
        .cornerRadius(CoreonRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: CoreonRadius.md)
                .stroke(CoreonColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Labeled Field
struct CoreonLabeledField<Content: View>: View {
    let label: String
    let required: Bool
    let content: Content

    init(_ label: String, required: Bool = false, @ViewBuilder content: () -> Content) {
        self.label = label
        self.required = required
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label)
                    .font(CoreonFonts.semibold(13))
                    .foregroundColor(CoreonColors.textSecondary)
                if required {
                    Text("*")
                        .font(CoreonFonts.semibold(13))
                        .foregroundColor(CoreonColors.danger)
                }
            }
            content
        }
    }
}
