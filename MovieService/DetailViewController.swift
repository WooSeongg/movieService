//
//  DetailViewController.swift
//  MovieCWS
//
//  Created by 미미밍 on 2022/05/31.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var movieName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "View Detail"

        
        let urlKorString = "https://search.naver.com/search.naver?where=nexearch&sm=top_hty&fbm=1&ie=utf8&query="+movieName
        let urlString = urlKorString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //let urlString = "https:m.cgv.co.kr/WebApp/Reservation/schedule.aspx?tc=&ymd=&src="
        
        guard let url = URL(string: urlString) else { return }
        
        
        let request = URLRequest(url:url)
        
        webView.load(request)
        
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
