//
//  SampleDataGenerator.swift
//  iOSMessup
//
//  Created by Rafael Serrano Gamarra on 17/11/26.
//

#if DEBUG
import Foundation

// MARK: - SeededGenerator

/// SplitMix64: a tiny deterministic generator, so the same seed always yields the same sample data.
nonisolated struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58_476D_1CE4_E5B9
        value = (value ^ (value >> 27)) &* 0x94D0_49BB_1331_11EB
        return value ^ (value >> 31)
    }
}

// MARK: - SampleDataGenerator

/// Builds several months of realistic, deterministic data relative to `now`, for Debug builds only.
/// The current month stops at `now`; nothing is generated in the future. Each month adds a salary, expenses and a
/// monthly contribution (plus occasional extra income/contribution), so the goal shows a partial progress.
enum SampleDataGenerator {
    struct Output {
        var expenses: [Expense]
        var incomes: [Income]
        var contributions: [Contribution]
        var goal: SavingGoal
    }

    private struct MiscPurchase {
        let name: String
        let category: Category
        let range: ClosedRange<Double>
    }

    private static let miscPurchases = [
        MiscPurchase(name: "Apple Store", category: .technology, range: 40...350),
        MiscPurchase(name: "Clothing Store", category: .fashion, range: 30...140),
        MiscPurchase(name: "Bookstore", category: .education, range: 12...45),
        MiscPurchase(name: "Movie Tickets", category: .entertainment, range: 14...40),
        MiscPurchase(name: "Pharmacy", category: .health, range: 8...45),
        MiscPurchase(name: "Donation", category: .charity, range: 10...50),
        MiscPurchase(name: "Pet Store", category: .family, range: 15...80)
    ]

    static func make(now: Date = .now,
                     calendar: Calendar = .current,
                     months: Int = 4,
                     seed: UInt64 = 42) -> Output {
        var rng = SeededGenerator(seed: seed)
        // Separate stream so contributions do not shift the expense/income sequence.
        var savingsRng = SeededGenerator(seed: seed &+ 1)
        var expenses: [Expense] = []
        var incomes: [Income] = []
        var contributions: [Contribution] = []
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)!.start

        for monthsAgo in (0..<months).reversed() {
            let monthStart = calendar.date(byAdding: .month, value: -monthsAgo, to: currentMonthStart)!
            let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count
            // Variable spending is spread over the days that have elapsed, so the latest days are not empty.
            let activeDays = monthsAgo == 0 ? calendar.component(.day, from: now) : daysInMonth
            func scaled(_ count: Int) -> Int {
                max(1, Int((Double(count) * Double(activeDays) / Double(daysInMonth)).rounded()))
            }

            /// Moment inside this month, or `nil` if it would be after `now`.
            func moment(day: Int, hour: Int) -> Date? {
                let date = calendar.date(byAdding: DateComponents(day: min(day, daysInMonth) - 1, hour: hour),
                                         to: monthStart)!
                return date <= now ? date : nil
            }

            func addExpense(_ name: String, _ amount: Double, day: Int, hour: Int,
                            _ category: Category, _ method: PaymentMethod) {
                guard let date = moment(day: day, hour: hour) else { return }
                expenses.append(Expense(name: name,
                                        amount: (amount * 100).rounded() / 100,
                                        date: date,
                                        paymentMethod: method,
                                        category: category))
            }

            func addIncome(_ concept: String, _ amount: Double, day: Int,
                           _ source: IncomeSource) {
                guard let date = moment(day: day, hour: 9) else { return }
                incomes.append(Income(concept: concept, amount: amount, date: date, source: source))
            }

            func addContribution(_ amount: Double, day: Int, _ note: String) {
                guard let date = moment(day: day, hour: 12) else { return }
                contributions.append(Contribution(amount: amount, date: date, note: note))
            }

            // Fixed monthly items.
            addIncome("Monthly Salary", 2100, day: 1, .salary)
            addContribution(Double(Int.random(in: 300...450, using: &savingsRng)), day: 5, "Monthly saving")
            addExpense("Rent", 650, day: 1, hour: 10, .home, .debitCard)
            addExpense("Gym Membership", 45, day: 3, hour: 19, .health, .debitCard)
            addExpense("Electricity", Double.random(in: 40...70, using: &rng), day: 5, hour: 11, .home, .debitCard)
            addExpense("Internet", 35, day: 7, hour: 11, .technology, .debitCard)
            addExpense("Streaming Service", 9.99, day: 12, hour: 20, .entertainment, .creditCard)

            // Variable spending.
            for _ in 0..<scaled(8) {
                addExpense(["Grocery Store", "Supermarket", "Bakery"].randomElement(using: &rng)!,
                           Double.random(in: 18...95, using: &rng),
                           day: Int.random(in: 1...activeDays, using: &rng),
                           hour: Int.random(in: 17...20, using: &rng),
                           .food, .debitCard)
            }
            for _ in 0..<scaled(4) {
                addExpense(["Restaurant", "Coffee Shop", "Takeaway"].randomElement(using: &rng)!,
                           Double.random(in: 8...55, using: &rng),
                           day: Int.random(in: 1...activeDays, using: &rng),
                           hour: Int.random(in: 12...22, using: &rng),
                           .food, [.cash, .creditCard, .debitCard].randomElement(using: &rng)!)
            }
            for _ in 0..<scaled(5) {
                addExpense(["Gas Station", "Metro Ticket", "Taxi"].randomElement(using: &rng)!,
                           Double.random(in: 6...60, using: &rng),
                           day: Int.random(in: 1...activeDays, using: &rng),
                           hour: Int.random(in: 7...21, using: &rng),
                           .transportation, [.cash, .creditCard].randomElement(using: &rng)!)
            }
            for _ in 0..<scaled(3) {
                let purchase = miscPurchases.randomElement(using: &rng)!
                addExpense(purchase.name,
                           Double.random(in: purchase.range, using: &rng),
                           day: Int.random(in: 1...activeDays, using: &rng),
                           hour: Int.random(in: 10...21, using: &rng),
                           purchase.category, [.creditCard, .debitCard, .paypal].randomElement(using: &rng)!)
            }

            // One trip, last month, so categories and totals are not flat.
            if monthsAgo == 1 {
                addExpense("Flight Tickets", 310, day: 14, hour: 15, .travel, .creditCard)
                addExpense("Hotel Booking", 420, day: 15, hour: 15, .travel, .creditCard)
            }

            // Extra income in some months.
            if monthsAgo % 2 == 1 {
                addIncome("Freelance Payment",
                           Double.random(in: 400...900, using: &rng).rounded(),
                           day: 15, .freelance)
            }
            if monthsAgo == 2 {
                addIncome("Gift", 120, day: 20, .gifts)
                addContribution(120, day: 21, "Gift saved")
            }
        }

        let goal = SavingGoal(name: "New Car",
                              completionDate: .fixed(calendar.date(byAdding: .month, value: 18, to: now)!),
                              amount: 15_000,
                              savingCategory: .assetPurchase)
        return Output(expenses: expenses, incomes: incomes, contributions: contributions, goal: goal)
    }
}
#endif
