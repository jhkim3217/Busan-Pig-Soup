//
//  Anno.swift
//  Thisisneverthat
//
//  Created by D7703_04 on 2019. 10. 17..
//  Copyright © 2019년 Y. All rights reserved.
//

import MapKit

// 좌표 정보와 버튼을 클릭했을 때 alert에 포함될 내용을 담고 있는 자료형
class Anno: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(_ lat: Double, _ long: Double, _ title: String, _ subtitle: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
        self.subtitle = subtitle
    }
}

// Annotation들을 관리해주는 객체
class Manager: NSObject {
    var annos = [Anno]()
    var infos = [String : UIAlertController]()
    
    // 추가 함수
    func append(_ lat: Double, _ long: Double, _ title: String, _ subtitle: String, _ alert: UIAlertController) {
        annos.append(Anno(lat, long, title, subtitle))
        infos[title] = alert
    }
    
    // Overloading된 추가 함수
    func append(_ lat: Double, _ long: Double, _ title: String, _ subtitle: String, _ message: String = "") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        append(lat, long, title, subtitle, ac)
    }
    
    // Annotation 배열을 반환한다.
    func getAnnos() -> [MKAnnotation] {
        return annos
    }
    
    // 특정 타이틀을 키로하는 값(alert)을 반환한다. (Dictionary 이용)
    func getInfo(_ title: String) -> UIAlertController {
        return infos[title]!
    }
}
