//
//  TableViewController.swift
//  Thisisneverthat
//
//  Created by D7703_04 on 2019. 10. 11..
//  Copyright © 2019년 Y. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    var addrList: [[String : String]] = []
    
    // MyData.plist에서 데이터를 가져와서 전역변수에 저장한다.
    func loadAddresses() {
        addrList.removeAll()
        let settingsURL: URL = Bundle.main.url(forResource: "MyData", withExtension: "plist")!
        do {
            let data = try Data(contentsOf: settingsURL)
            let decoder = PropertyListDecoder()
            
            typealias Settings = [[String: String]]
            var settings: Settings?
            settings = try decoder.decode(Settings.self, from: data)
            
            addrList = settings!
        } catch {
            // Handle error
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAddresses()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addrList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = addrList[indexPath.row]["title"]
        cell.detailTextLabel?.text = addrList[indexPath.row]["detail"]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // identifier에 따라 다른 View를 보여준다.
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailViewController
            let idx = tableView.indexPathForSelectedRow?.row
            vc.idx = idx
            vc.addrList = addrList
        } else if segue.identifier == "showAll" {
            let vc = segue.destination as! AllViewController
            vc.addrList = addrList
        }
    }
}

// Reference: https://gist.github.com/marcosgriselli/00ab6c68f48ccaeb110afc82786767ec
// Resize된 Image를 구하기 위해 extension 추가
extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIImage.resize(image: image, targetSize: scaledSize)
    }
}
