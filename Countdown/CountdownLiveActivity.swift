//
//  CountdownLiveActivity.swift
//  Countdown
//
//  Created by Nonprawich I. on 21/6/25.
//

import AlarmKit
import AppIntents
import SwiftUI
import WidgetKit

struct CountdownLiveActivity: Widget {
    /// Number formatter
    @State private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    /// Custom formatter for seconds only
    private func formatTimeRemaining(from date: Date) -> String {
        let now = Date()
        let timeInterval = date.timeIntervalSince(now)
        
        if timeInterval <= 0 {
            return "00:00"
        }
        
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CountDownAttribute>.self) { context in
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    switch context.state.mode {
                    case .countdown(let countdown):
                        Group {
                            Text(context.attributes.presentation.countdown?.title ?? "")
                                .font(.title3)
                            
                            // Use .timer style for live updates
                            Text(countdown.fireDate, style: .timer)
                                .font(.title2)
                                .monospacedDigit()
                        }
                    case .paused(let paused):
                        Group {
                            Text(context.attributes.presentation.paused?.title ?? "")
                                .font(.title3)
                            
                            Text(formatter.string(from: paused.totalCountdownDuration - paused.previouslyElapsedDuration) ?? "00:00")
                                .font(.title2)
                                .monospacedDigit()
                        }
                    case .alert(let alert):
                        Group {
                            Text(context.attributes.presentation.alert.title)
                                .font(.title3)
                            
                            Text("00:00")
                                .font(.title2)
                                .monospacedDigit()
                        }
                    @unknown default:
                        fatalError()
                    }
                }
                .lineLimit(1)
                
                Spacer(minLength: 0)
                
                let alarmID = context.state.alarmID
                /// Pause and Cancel Buttons
                Group {
                    if case .paused = context.state.mode {
                        Button(intent: AlarmActionIntent(id: alarmID, isCancel: false, isResume: true)) {
                            Image(systemName: "play.fill")
                        }
                        .tint(.orange)
                    } else {
                        Button(intent: AlarmActionIntent(id: alarmID, isCancel: false)) {
                            Image(systemName: "pause.fill")
                        }
                        .tint(.orange)
                    }
                    
                    Button(intent: AlarmActionIntent(id: alarmID, isCancel: true)) {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
               
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .font(.title)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        switch context.state.mode {
                        case .countdown:
                            Text(String(localized: context.attributes.presentation.countdown?.title ?? "Countdown"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        case .paused:
                            Text(String(localized: context.attributes.presentation.paused?.title ?? "Paused"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        case .alert:
                            Text(String(localized: context.attributes.presentation.alert.title))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        @unknown default:
                            Text("Timer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        switch context.state.mode {
                        case .countdown(let countdown):
                            Text(countdown.fireDate, style: .timer)
                                .font(.title)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        case .paused(let paused):
                            Text(formatter.string(from: paused.totalCountdownDuration - paused.previouslyElapsedDuration) ?? "00:00")
                                .font(.title)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        case .alert:
                            Text("00:00")
                                .font(.title)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        @unknown default:
                            Text("00:00")
                                .font(.title)
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }
                        
                        Text("remaining")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 20) {
                        let alarmID = context.state.alarmID
                        
                        if case .paused = context.state.mode {
                            Button(intent: AlarmActionIntent(id: alarmID, isCancel: false, isResume: true)) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Resume")
                                }
                                .font(.caption)
                                .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        } else {
                            Button(intent: AlarmActionIntent(id: alarmID, isCancel: false)) {
                                HStack {
                                    Image(systemName: "pause.fill")
                                    Text("Pause")
                                }
                                .font(.caption)
                                .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                        
                        Button(intent: AlarmActionIntent(id: alarmID, isCancel: true)) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Cancel")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    switch context.state.mode {
                    case .countdown(let countdown):
                        Text(countdown.fireDate, style: .timer)
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    case .paused(let paused):
                        Text(formatter.string(from: paused.totalCountdownDuration - paused.previouslyElapsedDuration) ?? "00:00")
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    case .alert:
                        Text("00:00")
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    @unknown default:
                        Text("00:00")
                            .font(.caption)
                            .fontWeight(.medium)
                            .monospacedDigit()
                    }
                }
            } compactTrailing: {
                Button(intent: AlarmActionIntent(id: context.state.alarmID, isCancel: true)) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } minimal: {
                Image(systemName: "timer")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
            .widgetURL(URL(string: "countdown://open"))
            .keylineTint(.orange)
        }
    }
}
