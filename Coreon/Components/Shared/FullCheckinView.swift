import SwiftUI

struct FullCheckinView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var energy = 5.0
    @State private var sleep = 5.0
    @State private var mood = 5.0
    @State private var soreness = 5.0
    @State private var stress = 5.0
    @State private var weight = ""
    @State private var notes = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    Text("Como está hoje?")
                        .font(CoreonFonts.bold(22))
                        .foregroundColor(CoreonColors.textPrimary)
                        .padding(.top, CoreonSpacing.lg)

                    VStack(spacing: CoreonSpacing.lg) {
                        CheckinSlider(label: "Energia", value: $energy, icon: "bolt.fill", color: CoreonColors.amber)
                        CheckinSlider(label: "Qualidade do sono", value: $sleep, icon: "moon.fill", color: CoreonColors.cyan)
                        CheckinSlider(label: "Humor", value: $mood, icon: "heart.fill", color: CoreonColors.rose)
                        CheckinSlider(label: "Dor muscular", value: $soreness, icon: "figure.flexibility", color: CoreonColors.violet)
                        CheckinSlider(label: "Nível de estresse", value: $stress, icon: "brain", color: CoreonColors.danger)
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                        CoreonLabeledField("Peso (kg) — opcional") {
                            CoreonTextField(placeholder: "70.5", text: $weight, keyboardType: .decimalPad, icon: "scalemass")
                        }
                        CoreonLabeledField("Notas") {
                            TextEditor(text: $notes)
                                .font(CoreonFonts.regular(15))
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(CoreonRadius.md)
                                .overlay(RoundedRectangle(cornerRadius: CoreonRadius.md).stroke(CoreonColors.border))
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    CoreonButton("Salvar check-in", isLoading: isSaving) {
                        Task { await save() }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                }
                .padding(.bottom, 40)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Check-in diário")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func save() async {
        guard let email = authManager.currentUser?.email else { return }
        isSaving = true; defer { isSaving = false }
        var data: [String: Any] = [
            "client_email": email,
            "checkin_date": ISO8601DateFormatter().string(from: Date()),
            "energy_level": Int(energy),
            "sleep_quality": Int(sleep),
            "mood": Int(mood),
            "muscle_soreness": Int(soreness),
            "stress_level": Int(stress)
        ]
        if let w = Double(weight.replacingOccurrences(of: ",", with: ".")) { data["weight"] = w }
        if !notes.isEmpty { data["notes"] = notes }
        let _: DailyCheckin? = try? await Base44Client.shared.entities("DailyCheckin").create(data)
        dismiss()
    }
}

private struct CheckinSlider: View {
    let label: String
    @Binding var value: Double
    let icon: String
    let color: Color

    var body: some View {
        CoreonCard(padding: 14) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                    Text(label)
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)
                    Spacer()
                    Text("\(Int(value))/10")
                        .font(CoreonFonts.bold(16))
                        .foregroundColor(color)
                }
                Slider(value: $value, in: 1...10, step: 1)
                    .accentColor(color)
            }
        }
    }
}

private let CoreonColors_rose = Color(hex: "#f43f5e")
extension CoreonColors {
    static let rose = Color(hex: "#f43f5e")
}
