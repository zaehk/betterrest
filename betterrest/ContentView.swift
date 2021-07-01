//
//  ContentView.swift
//  betterrest
//
//  Created by Borja Saez de Guinoa Vilaplana on 27/6/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = Date()
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            
            VStack{
            VStack(alignment: .leading) {
                Text("Sleep information")
                    .font(.largeTitle)
                
                Text("When do you want to wake up")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .accentColor(.black)
                    .labelsHidden()
                    
                Text("Desired sleep time")
                    .font(.headline)
                Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                    Text("\(sleepAmount, specifier: "%g") hours")
                }
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(value: $coffeeAmount, in: 1...20) {
                    Text("Cups of coffe: \(coffeeAmount)")
                }
                
            }
                Spacer()
                Button("Calculate", action: calculateBedTime)
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                    .background(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                    .foregroundColor(.black)
                    .font(.title3.bold())
            }
            
            
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
            .shadow(color: .gray, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .padding()
            
            
            .navigationBarTitle("BetterRest")
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
            
        }
    }
    
    func calculateBedTime(){
        do {
            let model = try SleepCalculator.init(configuration: MLModelConfiguration())
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60 //to seconds
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
            
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
