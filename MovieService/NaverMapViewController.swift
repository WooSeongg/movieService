//
//  NaverMapViewController.swift
//  MovieService
//
//  Created by 미미밍 on 2022/08/10.
//

import UIKit
import WebKit

class NaverMapViewController: UIViewController {

    @IBOutlet weak var webKit: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "외부 앱 호출", message: "네이버앱에서 볼까요?", preferredStyle: .alert)
        
        let callMap = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let mapUrlKor = "nmap://search?query=영화관"
            let mapUrlString = mapUrlKor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            
            //호출 가능한 url인지 확인
            if let url = URL(string: mapUrlString), UIApplication.shared.canOpenURL(url){
                //아이폰 iOS 버전확인
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            }
            //네이버맵이 없으면 앱스토어 설치화면 이동
            else{
                //아이폰 iOS 버전확인
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(appStoreURL)
                }
            }
        }
        
        let NoButton = UIAlertAction(title: "No", style: .default, handler:nil)
        
        alert.addAction(NoButton)
        alert.addAction(callMap)
        

        present(alert,animated: true, completion: nil)
        
        let webUrlKor = "https://m.map.naver.com/search2/search.naver?query=영화관&sm=hty&style=v5#/map/1"
        let webUrlString = webUrlKor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let url = URL(string: webUrlString){
            let request = URLRequest(url: url)
            webKit.load(request)
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
