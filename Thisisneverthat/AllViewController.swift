//
//  AllViewController.swift
//  Thisisneverthat
//
//  Created by D7703_04 on 2019. 10. 17..
//  Copyright © 2019년 Y. All rights reserved.
//

import UIKit
import MapKit

class AllViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var addrList: [[String : String]]!
    let mgr = Manager()
    var locMgr = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    // 재귀 호출을 이용한 여러개의 주소를 Geocoding해주는 재귀함수
    func geoCode(addresses: [String], results: [CLPlacemark] = [], completion: @escaping ([CLPlacemark]) -> Void ) {
        guard let address = addresses.first else {
            completion(results)
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            var updatedResults = results
            
            if let placemark = placemarks?.first {
                updatedResults.append(placemark)
            }
            
            let remainingAddresses = Array(addresses[1..<addresses.count])
            self.geoCode(addresses: remainingAddresses, results: updatedResults, completion: completion)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 돼지국밥 지도"
        mapView.delegate = self
        locMgr.delegate = self
        
        locMgr.startUpdatingLocation()
        locMgr.requestAlwaysAuthorization()
        locMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapView.showsUserLocation = true
        mapView.userLocation.title = "현재 위치"
        
        // Geocoding을 여러번 해야 하므로 재귀 함수를 이용한다.
        var addresses: [String] = []
        for i in addrList {
            addresses.append(i["detail"]!)
        }
        
        geoCode(addresses: addresses) { results in
            for i in 0..<results.count {
                self.mgr.append(
                    results[i].location!.coordinate.latitude,
                    results[i].location!.coordinate.longitude,
                    self.addrList[i]["title"]!,
                    self.addrList[i]["summary"]!,
                    self.addrList[i]["msg"]!
                )
            }

            self.mapView.addAnnotations(self.mgr.getAnnos())
        }
    }
    
    // AnnotationView 설정을 위해 Delegate 함수를 정의한다.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        if annotation.title == "현재 위치" {
            return mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        }
        
        var view: MKAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            let detailBtn = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = detailBtn
        }
        view.image = UIImage.resize(image: UIImage(named: "pork.png")!, targetSize: CGSize(width: 30, height: 30))
        return view
    }
    
    // AnnotationView에서 버튼 클릭시 alert 출력을 위해 정의한다.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        present(mgr.getInfo(((view.annotation?.title)!)!), animated: true, completion: nil)
    }
    
    // 현재 위치가 업데이트될 때마다 지도의 Region을 지정하여 내 위치가 중간에 있도록 한다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLoc = locations[0]
        print(userLoc)
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: userLoc.coordinate.latitude , longitude: userLoc.coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        )
        
        mapView.setRegion(region, animated: true)
    }
}
