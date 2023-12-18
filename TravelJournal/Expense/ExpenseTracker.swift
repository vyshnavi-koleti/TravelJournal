import Foundation
import SwiftUI

class ExpenseTrackerViewModel: ObservableObject {
    @Published var expenses: [Expense] = []

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
    }

    func removeExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

    var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

struct Expense: Identifiable {
    let id = UUID()
    var category: String
    var amount: Double
    var date: Date
    var notes: String?
}




struct ExpenseTrackerView: View {
    @StateObject var viewModel = ExpenseTrackerViewModel()
    @State private var showingAddExpenseView = false

    var body: some View {
        ZStack {
            FootstepsBackgroundView()

            List {
                ForEach(viewModel.expenses) { expense in
                    VStack(alignment: .leading) {
                        Text(expense.category)
                            .font(.headline)
                        Text("Amount: \(expense.amount, specifier: "%.2f")")
                        Text("Date: \(expense.date, style: .date)")
                        if let notes = expense.notes, !notes.isEmpty {
                            Text("Notes: \(notes)")
                        }
                    }
                }
                .onDelete(perform: viewModel.removeExpense)
            }
            .navigationBarTitle("Expenses", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showingAddExpenseView = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddExpenseView) {
                AddExpenseView(viewModel: viewModel)
            }
        }
    }
}







struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseTrackerViewModel
    @State private var category = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var notes = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Category", text: $category)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Notes", text: $notes)

                Button("Save") {
                    guard let amountDouble = Double(amount), !category.isEmpty else {
                        return
                    }
                    let newExpense = Expense(category: category, amount: amountDouble, date: date, notes: notes)
                    viewModel.addExpense(newExpense)
                    presentationMode.wrappedValue.dismiss()
                }

            }
            .navigationBarTitle("Add Expense")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


