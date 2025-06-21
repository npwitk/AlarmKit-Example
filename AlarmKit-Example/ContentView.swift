//
//  ContentView.swift
//  AlarmKit-Example
//
//  Created by Nonprawich I. on 21/6/25.
//

// We need to request permission first! (also in the info.plist)

import AlarmKit
import AppIntents
import SwiftUI

struct ContentView: View {
    @State private var isAuthorized: Bool = false
    @State private var scheduleDate: Date = .now
    
    var body: some View {
        NavigationStack {
            Group {
                if isAuthorized {
                    AlarmView()
                } else {
                    Text("You need to allow alarms \nin Settings to use this app")
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .glassEffect()
                }
            }
            .navigationTitle("AlarmKit-Example")
        }
        .task {
            do {
                try await checkAndAuthorize()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private func AlarmView() -> some View {
        List {
            Section("Date & Time") {
                DatePicker("", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            
            Button("Set Alarm") {
                Task {
                    do {
                        try await setAlarm()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func setAlarm() async throws {
        /// AlarmID
        let id = UUID()
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "Open App", textColor: .white, systemImageName: "app.fill")
        
        /// Alert
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill"),
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        
        /// Presentation
        /// (can be configured with another secondary button)
        let presentation = AlarmPresentation(alert: alert)
        
        /// Attributes (requires the creation of a struct that conforms to AlarmMetaData protocol)
        /// This will provides additional data to the Alarm UI for Live Activities (Dynamic Island) or more.
        /// let attributes = AlarmAttributes(presentation: presentation, tintColor: .orange) there will be an error
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Schedule
        let schedule = Alarm.Schedule.fixed(scheduleDate) // Fixed date and time
        //        let schedule = Alarm.Schedule.Relative(time: T##Alarm.Schedule.Relative.Time, repeats: .weekly([.friday])) // Time-based and will repeat acoording to the given information
        
        /// Configuration
        let config = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: OpenAppIntent(id: id)
        )
        
        /// Adding alarm to the system
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
        print("Alarm is set successfully!")
    }
    
    private func checkAndAuthorize() async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            /// Requesting for authorization
            let status = try await AlarmManager.shared.requestAuthorization()
            isAuthorized = status == .authorized
        case .denied:
            isAuthorized = false
        case .authorized:
            isAuthorized = true
        @unknown default:
            fatalError("Fatal from checkAndAuthorize function")
        }
    }
}

#Preview {
    ContentView()
}

struct OpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Opens App"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false
    
    @Parameter
    var id: String
    
    init(id: UUID) {
        self.id = id.uuidString
    }
    
    init() { }
    
    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: id) {
            print(alarmID)
        }
        
        return .result()
    }
}
