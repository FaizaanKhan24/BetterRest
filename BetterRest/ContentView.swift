//
//  ContentView.swift
//  BetterRest
//
//  Created by Faizaan Khan on 11/19/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form{
                Section(){
                    DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        
                } header: {
                    Text("When do you want wake up?")
                }
                
                Section(){
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                }
                
                Section(){
                    Picker("Daily Coffee intake", selection: $coffeeAmount){
                        Text("1 cup")
                        
                        ForEach(2...20, id: \.self){
                            Text("\($0) cups")
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                }
                
                Section(){
                    Text(calculateBedTime())
                        .font(.largeTitle)
                } header: {
                    Text("Ideal bedtime")
                }
            }
            .navigationTitle("Better Rest")
        }
    }
    
    func calculateBedTime() -> String{
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch{
            return "Sorry there seem to be a problem"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
