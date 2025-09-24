//
//  ContentView.swift
//  3390App1
//
//  Created by Shane Wilkerson on 9/22/25.
//

import SwiftUI

// A single row in the table
struct HabitEntry: Identifiable, Codable {
    var id: UUID = UUID()         // unique id so List can loop
    var habit: String       // what the user typed
    var date: Date          // when it was added
}

private let habitsKey = "habits.v1"

struct ContentView: View {
    // the list of rows in the table
    @State private var entries: [HabitEntry] = []
    // the text the user is typing
    @State private var habitText: String = ""
    // used to show/hide the keyboard in a simple way
    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Title (blue/yellow theme)
                Text("Habit List")
                    .font(.title2).bold()
                    .foregroundColor(.yellow)

                // Header with two column titles + divider
                HStack(spacing: 0) {
                    Text("Habit")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Divider()
                        .frame(height: 20)
                        .background(Color.gray.opacity(0.5))

                    Text("Date")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // The “table” area
                List {
                    if entries.isEmpty {
                        // simple placeholder
                        HStack {
                            Text("No habits yet")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                    } else {
                        // one row per entry: left = habit, right = date
                        // one row per entry: left = habit, right = date, with a vertical line
                        ForEach(entries) { entry in
                            HStack(spacing: 0) {
                                // LEFT: habit text
                                Text(entry.habit)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.trailing, 8)      // space before the line

                                // vertical divider between columns
                                Divider()
                                    .frame(width: 1)            // thin line
                                    .background(Color.gray.opacity(0.3))

                                // RIGHT: date text
                                Text(dateString(from: entry.date))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 10)      // push date a bit right from the line
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )

                // Input area at the bottom: “Habit:”  [text field]  [Add]
                HStack(spacing: 12) {
                    Text("Habit:")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    TextField("e.g., Walked my dog", text: $habitText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .focused($textFieldIsFocused)
                        .onSubmit { textFieldIsFocused = false }
                        .frame(maxWidth: .infinity)        // <-- lets the button keep some space

                    Button("Add") {
                        let now = Date()
                        if !habitText.isEmpty {
                            entries.append(HabitEntry(habit: habitText, date: now))
                            saveHabits()
                            habitText = ""
                            textFieldIsFocused = false
                        }
                    }
                    // Simple, always-visible style (no “borderedProminent” dimming)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(habitText.isEmpty ? Color.yellow.opacity(0.5) : Color.yellow)
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(habitText.isEmpty)
                }
                .padding(.top, 8)
                .padding(.bottom, 14)   // <-- keeps it above the home indicator

            }
            .padding()
            .background(Color.blue)             // blue page background
            .navigationTitle("Habit Tracker")
            .onAppear { loadHabits() }
            .scrollDismissesKeyboard(.interactively) // dragging can hide keyboard
        }
    }

    // Simple date → string helper
    private func dateString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium   // e.g., Sep 23, 2025
        df.timeStyle = .short    // e.g., 10:17 PM
        return df.string(from: date)
    }
    
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
    }

    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([HabitEntry].self, from: data) {
            entries = decoded
            // keep your order rule (oldest at top)
            entries.sort { $0.date < $1.date }
        }
    }
}

#Preview {
    ContentView()
}




