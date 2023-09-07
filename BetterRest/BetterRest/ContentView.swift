//
//  ContentView.swift
//  BetterRest
//
//  Created by Oluwapelumi Williams on 06/09/2023.
//

import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 10){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
            }
            .navigationTitle("Better Rest")
            // adding a trailing button to the navigation view using the toolbar modifier
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}


//struct ContentView: View {
//    @State private var sleepAmount = 8.0
//    @State private var wakeUp = Date.now
//
////    var components = DateComponents()
//
////    components.hour = 8
////    components.minute = 0
////    let date = Calendar.current.date(from: components) ?? Date.now
//
////    let components = Calendar.current.dateComponents([.hour, .minute], from: someDate)
////    let hour = components.hour ?? 0
////    let minute = components.minute ?? 0
//
//
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
//            Text("Hello, world!")
//            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...8, step: 0.25)
//            DatePicker("Please enter a date", selection: $wakeUp)
//                .labelsHidden()
//            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
//                .labelsHidden()
//            Text("Good")
//
//            // for date and time
//            Text(Date.now, format: .dateTime.hour().minute())
//            Text(Date.now, format: .dateTime.day().month().year())
//            Text(Date.now.formatted(date: .long, time: .shortened))
//
//        }
//        .padding()
//    }
//
//    func exampleDates() {
//        let tomorrow = Date.now.addingTimeInterval(86400)
//
//        let range = Date.now...tomorrow
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
