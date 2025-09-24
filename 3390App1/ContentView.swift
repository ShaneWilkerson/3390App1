//
//  ContentView.swift
//  3390App1
//
//  Created by Shane Wilkerson on 9/20/25.
//

import SwiftUI

// struct for each different habit entry
// Identifiable so each entry is different
// Added Codable for autosaving with jsonencoder
struct HabitEntry: Identifiable, Codable {
    var id: UUID = UUID()       // used xcode helper to fix 
    var habit: String       // string for whatever user types
    var date: Date
}

private let habitsKey = "habits.v1"

struct ContentView: View {
    // the list of rows in the table
    @State private var entries: [HabitEntry] = []
    // the text the user is typing
    @State private var habitText: String = ""
    // used to show/hide the keyboard in a simple way
    @FocusState private var textFieldIsFocused: Bool
    // For confirmation
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 12) {

                // Title
                Text("Habit List")
                    .font(.title2).bold()
                    .foregroundColor(.yellow)

                // Hstack for 2 columns
                HStack(spacing: 0) {
                    
                    // Left heading
                    Text("Habit")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center) //added .infinity to take all the space
                    
                    //Divide 2 hstack elemets
                    Divider()
                        .frame(height: 20)
                        .background(Color.black)

                    // Right heading
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // modifiers for the hstack
                
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // table grid
                List {
                    if entries.isEmpty {
                        // if HabitEntry list is empty
                        HStack {
                            // simple message if empty
                            Text("No habits yet")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                    } else {
                        
                        // For each habit entry, created hstack for left and right side
                        
                        ForEach(entries) { entry in
                            HStack(spacing: 0) {
                                // insert habit text
                                Text(entry.habit)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.trailing, 8)      // before the line

                                // divider
                                Divider()
                                    .frame(width: 1)
                                    .background(Color.black)

                                // insert date
                                Text(dateString(from: entry.date))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .padding(.leading, 10)      // push date a bit right from the line
                            }
                        }
                    }
                }
                // For the table
                .listStyle(.plain)
                    .overlay( RoundedRectangle(cornerRadius: 6) .stroke(Color.gray.opacity(0.4), lineWidth: 1) )

                // Habit adder and add button
                HStack(spacing: 12) {
                    Text("Habit:")
                        .font(.headline)
                        .foregroundColor(.yellow)

                    // TextField for editable text box with placeholder
                    // $habitText for @State var habitText
                    TextField("ex: Walked my dog", text: $habitText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)     // changes keyboard to done
                        // connects @FocusState var textFieldIsFocused: Bool
                        .focused($textFieldIsFocused)
                        .onSubmit { textFieldIsFocused = false } //dismiss keyboard
                        .frame(maxWidth: .infinity)        // <-- lets the button keep some space

                    // add button
                    Button("Add") {
                        let now = Date() // stores date in now
                        // make sure there's something typed
                        if !habitText.isEmpty {
                            entries.append(HabitEntry(habit: habitText, date: now))
                            saveHabits()    // saves code to User Default and to HabitEntry
                            habitText = ""      //clear after
                            textFieldIsFocused = false
                        }
                    }
                    
                    // style for section
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(habitText.isEmpty ? Color.yellow.opacity(0.5) : Color.yellow)
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(habitText.isEmpty)
                }
                .padding(.top, 8)
                .padding(.bottom, 14)
                
                // Clear All button
                Button("Clear All") { showClearConfirm = true } // @State var showClearConfirm
                .buttonStyle(.borderedProminent)    // bold button
                .tint(.red)                // tint to fill the background
                .foregroundColor(.white)
                .padding(.top, 4)
                // if tapped, confirmation appears, removes all entries if confirmed
                //
                .confirmationDialog("Delete all habits?", isPresented: $showClearConfirm, titleVisibility: .visible) {
                    Button("Delete All", role: .destructive) {
                        entries.removeAll()
                        saveHabits() //saves no entries if confirmed
                    }
                    Button("Cancel", role: .cancel) {} // cancel optioin
                }


            }
            .padding()
            .background(Color.blue)             // blue page background
            .navigationTitle("Habit Tracker")   // Very top title
            .onAppear { loadHabits() }
            .scrollDismissesKeyboard(.interactively) // hide keyboard if scroll
        }
    }

    // Helper function
    // Date to String
    private func dateString(from date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium   // Date
        df.timeStyle = .short    // Time
        return df.string(from: date)
    }
    
    // Another helper function
    // save habits when exiting to UserDefaults
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(entries) { // use try to safely try to save
            UserDefaults.standard.set(data, forKey: habitsKey) // key set above
        }
    }

    // Helper function again
    // loads on startup
    private func loadHabits() {
        // checks on the UserDefault data using the key
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           // put data back into the HabitEntry array
           let decoded = try? JSONDecoder().decode([HabitEntry].self, from: data) {
            entries = decoded
            // oldest at top
            entries.sort { $0.date < $1.date }
        }
    }
}

#Preview {
    ContentView()
}




