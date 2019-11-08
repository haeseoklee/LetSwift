//
//  VenueView.swift
//  LetSwift
//
//  Created by BumMo Koo on 27/07/2019.
//  Copyright © 2019 Cleanios. All rights reserved.
//

import SwiftUI
import MapKit
import StoreKit

struct VenueView: View {
    let location: CLLocationCoordinate2D = .init(latitude: 37.468437, longitude: 127.039055)
    
    @State private var presentModal = false
    @State private var sheetView: AnyView?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    VenueMapView(location: location)
                        .modifier(RoundedMask())
                        .frame(height: 300)
                        .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 24) {
                        // Location
                        VStack(alignment: .leading, spacing: 16) {
                            HeadlineText("장소")
                            VStack(alignment: .leading) {
                                Text("양재 aT 센터 3층")
                                    .font(.subheadline)
                                Text("서울특별시 강남구 테헤란로7길 22")
                                    .font(.subheadline)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 16) {
                                    mapButton("Apple Map ↗︎", action: openAppleMap)
                                    mapButton("Google Maps ↗︎", action: openGoogle)
                                }
                                HStack(spacing: 16) {
                                    mapButton("Naver Map ↗︎", action: openNaver)
                                    mapButton("Kakao Map ↗︎", action: openKakao)
                                }
                            }
                        }
                        Divider()
                        
                        // Time
                        VStack(alignment: .leading, spacing: 16) {
                            HeadlineText("일시")
                            VStack(alignment: .leading) {
                                Text("11월 12일 화요일")
                                    .font(.subheadline)
                                Text("오전 9시부터 오후 5시까지")
                                    .font(.subheadline)
                            }
                            //                            Button(action: addToCalendar) {
                            //                                Text("Add to Calendar")
                            //                            }
                            //                            .font(.subheadline)
                        }
                        Divider()
                        
                        // Route
                        VStack(alignment: .leading, spacing: 16) {
                            HeadlineText("찾아오는 법")
                            VStack(alignment: .leading) {
                                Text("지하철")
                                    .font(.subheadline)
                                    .bold()
                                Text("신분당선 '양재시민의 숲'역에서 하차 후 4번 출구")
                                    .font(.subheadline)
                            }
                            VStack(alignment: .leading) {
                                Text("버스")
                                    .font(.subheadline)
                                    .bold()
                                Text("양재 aT 센터 주변 버스정류장 하차")
                                    .font(.subheadline)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 16) {
                                    mapButton("Apple Map ↗︎", action: openAppleMapRoute)
                                    mapButton("Google Maps ↗︎", action: openGoogleRoute)
                                }
                                HStack(spacing: 16) {
                                    mapButton("Naver Map ↗︎", action: openNaverRoute)
                                    mapButton("Kakao Map ↗︎", action: openKakaoRoute)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("장소")
            .sheet(isPresented: $presentModal) {
                //                EventEditViewController()
                self.sheetView
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            #if !DEBUG
            SKStoreReviewController.requestReview()
            #endif
        }
    }
    
    // MARK: - Body Builder
    private func mapButton(_ title: String, action: @escaping () -> Void) -> some View {
        return Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
        }
    }
    
    // MARK: - Action
    private func addToCalendar() {
        //        presentModal.toggle()
        //        let manager = CalendarManager()
        //        switch manager.authorizationStatus {
        //        case .authorized:
        //            manager.addConference2019()
        //        case .denied, .restricted:
        //            // TODO: Show error
        //            break
        //        case .notDetermined:
        //            manager.requestAccess { (granted, error) in
        //                self.addToCalendar()
        //            }
        //        @unknown default:
        //            #if DEBUG
        //            fatalError()
        //            #endif
        //        }
    }
    
    private func openAppleMap() {
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
        let placemark = MKPlacemark(coordinate: location)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = "서울특별시 강남구 테헤란로7길 22"
        mapItem.openInMaps(launchOptions: options)
    }
    
    private func openAppleMapRoute() {
        let placemark = MKPlacemark(coordinate: location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "서울특별시 강남구 테헤란로7길 22"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func openKakao() {
        guard let url = URL(string: "kakaomap://look?p=\(location.latitude),\(location.longitude)") else { return }
        UIApplication.shared.open(url, options: [:]) { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "https://map.kakao.com/?urlX=508680&urlY=1102413&urlLevel=3&itemId=17023403&q=aT%EC%84%BC%ED%84%B0%20%EC%A0%84%EC%8B%9C%EC%9E%A5&map_type=TYPE_MAP")!))
                self.presentModal.toggle()
            }
        }
    }
    
    private func openKakaoRoute() {
        guard let url = URL(string: "kakaomap://route?ep=\(location.latitude),\(location.longitude)&by=PUBLICTRANSIT") else { return }
        UIApplication.shared.open(url, options: [:]) { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "http://kko.to/PNXoNz20T")!))
                self.presentModal.toggle()
            }
        }
    }
    
    private func openNaverRoute() {
        let dname = "서울특별시 강남구 테헤란로7길 22".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "nmap://route/public?dlat=\(location.latitude)&dlng=\(location.longitude)&dname=\(dname)&appname=kr.codesquad.jk.letswift") else { return }
        UIApplication.shared.open(url, options: [:]) { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "https://map.naver.com/v5/directions/-/14141916.626133803,4504578.685869807,aT%EC%84%BC%ED%84%B0,11566332,PLACE_POI/-/transit?c=14141862.4354043,4504601.4848290,17,0,0,0,dh")!))
                self.presentModal.toggle()
            }
        }
    }
    
    private func openNaver() {
        let dname = "서울특별시 강남구 테헤란로7길 22".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "nmap://place?lat=\(location.latitude)&lng=\(location.longitude)&name=\(dname)&appname=kr.codesquad.jk.letswift") else { return }
        UIApplication.shared.open(url, options: [:]) { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "http://naver.me/xnGecPf4")!))
                self.presentModal.toggle()
            }
        }
    }
    
    private func openGoogle() {
        guard let url = URL(string:"comgooglemaps://?center=\(location.latitude),\(location.longitude)&zoom=14&views=traffic&q=\(location.latitude),\(location.longitude)") else { return }
        UIApplication.shared.open(url, options: [:]) { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "https://goo.gl/maps/MSZ251Xqzh3bFtWs5")!))
                self.presentModal.toggle()
            }
        }
    }
    
    private func openGoogleRoute() {
        guard let url = URL(string: "comgooglemaps://?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=transit") else { return }
        UIApplication.shared.open(url, options: [:])  { completed in
            if !completed {
                self.sheetView = AnyView(SafariView(url: URL(string: "https://www.google.co.kr/maps/dir//%EC%84%9C%EC%9A%B8%ED%8A%B9%EB%B3%84%EC%8B%9C+%EC%96%91%EC%9E%AC2%EB%8F%99+AT%EC%84%BC%ED%84%B0.%EC%96%91%EC%9E%AC%EA%BD%83%EC%8B%9C%EC%9E%A5/@37.468699,127.0372103,17z/data=!4m8!4m7!1m0!1m5!1m1!1s0x357ca12d3098759f:0x977e9d473d0172a0!2m2!1d127.039399!2d37.468699?hl=ko")!))
                self.presentModal.toggle()
            }
        }
    }
}

struct VenueInfo {
    let title: String
    let body: String
}

// MARK: - Preview
struct VenueView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VenueView()
            VenueView()
                .environment(\.colorScheme, .dark)
            VenueView()
                .environment(\.sizeCategory, .extraExtraExtraLarge)
        }
    }
}
