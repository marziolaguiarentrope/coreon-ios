import SwiftUI

struct AutonomousNutritionView: View {
    @EnvironmentObject var autonomousVM: AutonomousViewModel
    @State private var showLogMeal = false

    var todayMeals: [MealRecord] {
        autonomousVM.mealLog.filter { Calendar.current.isDateInToday($0.loggedAt) }
    }

    var totalCalories: Int { todayMeals.compactMap { $0.calories }.reduce(0, +) }
    var totalProtein: Double { todayMeals.compactMap { $0.protein }.reduce(0, +) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.xl) {
                    // Daily summary
                    CoreonCard {
                        VStack(spacing: CoreonSpacing.md) {
                            HStack {
                                Text("Hoje")
                                    .font(CoreonFonts.semibold(16))
                                    .foregroundColor(CoreonColors.textPrimary)
                                Spacer()
                                Text(Date().formatted(date: .abbreviated, time: .omitted))
                                    .font(CoreonFonts.regular(13))
                                    .foregroundColor(CoreonColors.textMuted)
                            }

                            HStack(spacing: 0) {
                                NutritionStat(value: "\(totalCalories)", label: "kcal", color: CoreonColors.amber)
                                Divider().frame(height: 30)
                                NutritionStat(value: String(format: "%.0fg", totalProtein), label: "proteína", color: CoreonColors.primary)
                                Divider().frame(height: 30)
                                NutritionStat(value: "\(todayMeals.count)", label: "refeições", color: CoreonColors.cyan)
                            }
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)
                    .padding(.top, CoreonSpacing.md)

                    // Log meal buttons
                    HStack(spacing: 12) {
                        Button {
                            showLogMeal = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Registrar refeição")
                            }
                            .font(CoreonFonts.semibold(14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(CoreonColors.violet)
                            .cornerRadius(CoreonRadius.lg)
                        }
                    }
                    .padding(.horizontal, CoreonSpacing.xl)

                    // Today's meals
                    if !todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Refeições de hoje")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            ForEach(todayMeals) { meal in
                                MealCard(meal: meal)
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }

                    // All logs
                    if !autonomousVM.mealLog.filter({ !Calendar.current.isDateInToday($0.loggedAt) }).isEmpty {
                        VStack(alignment: .leading, spacing: CoreonSpacing.md) {
                            Text("Histórico")
                                .font(CoreonFonts.semibold(16))
                                .foregroundColor(CoreonColors.textPrimary)
                            ForEach(autonomousVM.mealLog.filter { !Calendar.current.isDateInToday($0.loggedAt) }.prefix(10)) { meal in
                                MealCard(meal: meal)
                            }
                        }
                        .padding(.horizontal, CoreonSpacing.xl)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(CoreonColors.background.ignoresSafeArea())
            .navigationTitle("Nutrição")
            .sheet(isPresented: $showLogMeal) {
                LogMealView { meal in
                    autonomousVM.logMeal(meal)
                }
            }
        }
    }
}

struct MealCard: View {
    let meal: MealRecord

    var body: some View {
        CoreonCard(padding: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(CoreonColors.amber.opacity(0.1))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 18))
                            .foregroundColor(CoreonColors.amber)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(CoreonFonts.semibold(14))
                        .foregroundColor(CoreonColors.textPrimary)
                    HStack(spacing: 8) {
                        if let cal = meal.calories { Text("\(cal) kcal").font(CoreonFonts.regular(12)).foregroundColor(CoreonColors.textMuted) }
                        if let prot = meal.protein { Text("P: \(String(format: "%.0f", prot))g").font(CoreonFonts.regular(12)).foregroundColor(CoreonColors.textMuted) }
                    }
                }

                Spacer()

                Text(meal.loggedAt.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 11))
                    .foregroundColor(CoreonColors.textMuted)
            }
        }
    }
}

private struct NutritionStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(CoreonFonts.bold(18)).foregroundColor(color)
            Text(label).font(.system(size: 11)).foregroundColor(CoreonColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LogMealView: View {
    let onSave: (MealRecord) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CoreonSpacing.lg) {
                    CoreonLabeledField("Nome da refeição *") {
                        CoreonTextField(placeholder: "Ex: Frango com batata", text: $name, icon: "fork.knife")
                    }
                    HStack(spacing: 12) {
                        CoreonLabeledField("Calorias (kcal)") {
                            CoreonTextField(placeholder: "300", text: $calories, keyboardType: .numberPad)
                        }
                        CoreonLabeledField("Proteína (g)") {
                            CoreonTextField(placeholder: "30", text: $protein, keyboardType: .decimalPad)
                        }
                    }
                    HStack(spacing: 12) {
                        CoreonLabeledField("Carbs (g)") {
                            CoreonTextField(placeholder: "40", text: $carbs, keyboardType: .decimalPad)
                        }
                        CoreonLabeledField("Gordura (g)") {
                            CoreonTextField(placeholder: "10", text: $fat, keyboardType: .decimalPad)
                        }
                    }
                    CoreonButton("Registrar refeição") {
                        let meal = MealRecord(
                            id: UUID().uuidString, name: name,
                            calories: Int(calories),
                            protein: Double(protein),
                            carbs: Double(carbs),
                            fat: Double(fat),
                            loggedAt: Date(), imageUrl: nil, source: "manual"
                        )
                        onSave(meal)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
                .padding(CoreonSpacing.xl)
            }
            .navigationTitle("Nova Refeição")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
        }
    }
}
