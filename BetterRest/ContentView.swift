//
//  ContentView.swift
//  BetterRest
//
//  Created by Jordan Haynes on 2/12/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    // All Private varibles needed for the app
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var selectionA = 2
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                wakeUpTime
                desiredAmountOfSleep
                dailyCoffeeIntake
                coffeeWarning
                energyLevel
                calculateButton
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    var wakeUpTime: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("When would you like to wake up?")
                .font(.title3)
                .bold()
            
            Spacer()
            
            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                .datePickerStyle(.automatic)
                .labelsHidden()
        }
    }
    var desiredAmountOfSleep: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("Desired amount of sleep?")
                .font(.title3)
            
            Spacer(minLength: 12.5)
            
            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                .font(.title3)
        }
    }
    var dailyCoffeeIntake: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text("Daily Coffee Intake?")
                .font(.title3)
            
            Spacer(minLength: 12.5)
            
            Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                .font(.title3)
        }
    }
    var coffeeWarning: some View {
        HStack {
            Spacer()
            switch coffeeAmount {
            case 1..<8:
                Text("Make sure to drink plenty of water!")
                    .foregroundColor(.green)
            case 8..<15:
                Text("That might be too much Coffee...")
                    .foregroundColor(.orange)
            default:
                Text("That's definitely a bit much...")
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    var energyLevel: some View {
        VStack {
            Text("Energy Level?")
                .font(.title2)
            
            Picker(selection: $selectionA, label: Text("Pick one:")) {
                Image(systemName: "tortoise.fill").tag(1)
                Image(systemName: "hare.fill").tag(2)
                Image(systemName: "bolt.fill").tag(3)
            }
            .pickerStyle(.segmented)
            
            switch selectionA {
            case 1:
                Text("Low energy")
            case 2:
                Text("High energy")
            case 3:
                Text("Extreme energy")
            default:
                Text("Nothing else should be possible")
                    .foregroundColor(.red)
            }
        }
    }
    var calculateButton: some View {
        Section {
            HStack {
                Spacer()
                Button(action: calculateBedtime) {
                    Label("Calculate", systemImage: "brain.head.profile")
                        .foregroundColor(.white)
                }
                .font(.title)
                .padding(12)
                .foregroundColor(.white)
                
                Spacer()
            }
            .background(.black)
            .clipShape(Capsule())
            .padding(5)
        }
    }
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7; components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    // Machine Learning Stuff
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
        ContentView()
            .preferredColorScheme(.light)
    }
}
