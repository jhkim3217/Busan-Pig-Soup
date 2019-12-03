//
//  DetailViewController.swift
//  Thisisneverthat
//
//  Created by D7703_04 on 2019. 10. 17..
//  Copyright © 2019년 Y. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var idx: Int!                           // 자료의 index 상의 위치
    var addrList: [[String : String]]!      // plist로부터 가져온 모든 자료를 담고 있음
    let mgr = Manager()                     // Annotation을 간편하게 관리하기 위한 객체
    var locMgr = CLLocationManager()
    
    var targetLocation: CLLocationCoordinate2D!     // 현재 보여주고 있는 좌표 정보
    var detail: String!                             // 현재 보여주고 있는 주소
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locMgr.delegate = self
        
        locMgr.startUpdatingLocation()
        locMgr.requestAlwaysAuthorization()
        locMgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapView.showsUserLocation = true
        mapView.userLocation.title = "현재 위치"
        
        // Forward Geocoding
        let data = addrList[idx]
        let geocoder = CLGeocoder()
        
        self.title = data["title"]
        detail = data["detail"]
        
        // trailing closure
        geocoder.geocodeAddressString(data["detail"]!) { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks?.first
                
                // Geocoding된 좌표값을 클래스 멤버 변수에 저장한다.
                self.targetLocation = placemark!.location?.coordinate
                
                // 매니저 객체에 좌표 정보와 추후 메세지를 표시할 문자열 내용을 추가한다.
                self.mgr.append(
                    (placemark!.location?.coordinate.latitude)!,
                    (placemark!.location?.coordinate.longitude)!,
                    data["title"]!,
                    data["summary"]!,
                    data["msg"]!
                )
                
                // 매니저 객체로부터 Annotation들을 불러와 mapView에 추가한다.
                self.mapView.addAnnotations(self.mgr.getAnnos())
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
        // My Location일 경우에는 내 위치를 표시해야 하므로 예외처리를 해준다.
        if annotation.title == "현재 위치" {
            return mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        }
        
        // 그외 Annotation들에 대한 처리
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
        
        // AnnotationView에 이미지를 넣는다.
        view.image = UIImage.resize(image: UIImage(named: "pork.png")!, targetSize: CGSize(width: 35, height: 35))
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // 매니저 객체로부터 해당 주소에 대한 alert 객체를 가져와서 실행한다.
        present(mgr.getInfo(((view.annotation?.title)!)!), animated: true, completion: nil)
    }
    
//    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        // Map이 로드될 때 맨 첫 번째 AnnotationView를 선택해준다.
//        if let annotation = views.first?.annotation {
//            mapView.selectAnnotation(annotation, animated: true)
//        }
//    }
    
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
    
    // 네비게이션을 실행한다.
    @IBAction func btnNavigate(_ sender: Any) {
        let addressDictionary = [String(CNPostalAddressStreetKey) : detail]
        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        let placemark = MKPlacemark(coordinate: targetLocation, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(self.title!) - \(self.detail!)"
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
