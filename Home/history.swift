
import SwiftUI

struct HistoryView: View {
    let goal: Goal
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.deepBlue.ignoresSafeArea()
                
                if goal.history.isEmpty {
                    VStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondaryText)
                        
                        Text("No history yet")
                            .font(.system(size: 18))
                            .foregroundColor(.secondaryText)
                            .padding(.top)
                    }
                } else {
                    List {
                        ForEach(goal.history.sorted(by: { $0.date > $1.date })) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(formatDate(entry.date))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Text("+\(Int(entry.value))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.mintAccent)
                                }
                                
                                if !entry.note.isEmpty {
                                    Text(entry.note)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            .listRowBackground(Color.cardBlue)
                        }
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                }
            }
            .navigationTitle("Progress History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
