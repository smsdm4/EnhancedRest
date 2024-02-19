//
//  ContentView.swift
//  EnhancedRest
//
//  Created by Mojtaba Mirzadeh on 12/6/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    // MARK: - Views
    var body: some View {
        
        NavigationStack {
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents:  .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffe intake")
                        .font(.headline)
                    
                    Stepper("^[\(coffeAmount) cup](inflect: true)", value: $coffeAmount, in: 1...20)
                }
                
            } //Form
            .navigationTitle("Enhanced Rest")
            .toolbar {
                Button("Calculate", action: self.calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            
        } //NavigationStack
        
    }
    
    // MARK: - Helpers
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64((hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(coffeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your idealbedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted , time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
    
}

#Preview {
    ContentView()
}
