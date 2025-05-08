//
//  ContentView.swift
//  CoreLocationTest
//
//  Created by kangdahye on 5/8/25.
//

import SwiftUI
import CoreLocation

// 🧱 로그 구조체 정의
struct LocationLog: Identifiable {
    let id = UUID()
    let timestamp: Date
    let location: CLLocation
    let hour: Int
    let weekday: Int
    let timeSlot: String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var locationLog: [LocationLog] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        DispatchQueue.main.async {
            self.location = latestLocation
            
            let now = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: now)
            let weekday = calendar.component(.weekday, from: now) // 일:1 ~ 토:7
            
            let timeSlot: String
            switch hour {
            case 6..<12:
                timeSlot = "오전"
            case 12..<18:
                timeSlot = "오후"
            case 18..<22:
                timeSlot = "저녁"
            default:
                timeSlot = "야간"
            }
            
            let log = LocationLog(
                timestamp: now,
                location: latestLocation,
                hour: hour,
                weekday: weekday,
                timeSlot: timeSlot
            )
            
            self.locationLog.append(log)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("📍 [\(formatter.string(from: now))] \(timeSlot)에 위치 업데이트: 위도 \(latestLocation.coordinate.latitude), 경도 \(latestLocation.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ 위치 업데이트 실패: \(error.localizedDescription)")
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("현재 위치:")
                .font(.headline)
            
            if let location = locationManager.location {
                Text("위도: \(location.coordinate.latitude)")
                Text("경도: \(location.coordinate.longitude)")
            } else {
                Text("위치 정보를 불러오는 중입니다...")
                    .foregroundColor(.gray)
            }

            Button("로그 확인") {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                for log in locationManager.locationLog {
                    print("🧾 \(formatter.string(from: log.timestamp)) (\(log.timeSlot), weekday \(log.weekday)) → \(log.location.coordinate.latitude), \(log.location.coordinate.longitude)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
