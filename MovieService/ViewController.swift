//
//  ViewController.swift
//  MovieCWS
//
//  Created by 미미밍 on 2022/05/25.
//

import UIKit
var name = ["aaa","bbb","ccc","eee"]

class ViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var movieURL = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=87741d73ccc1be83b6769245ea6e0aa1&targetDt="
    var movieData : MovieData?
    
    struct MovieData : Codable {
        let  boxOfficeResult : BoxOfficeResult
    }
    struct  BoxOfficeResult : Codable {
        let  dailyBoxOfficeList : [DailyBoxOfficeList]
    }
    struct  DailyBoxOfficeList : Codable {
        let movieNm : String
        let audiCnt : String
        let audiAcc : String
        let rank : String
    }
    
    var naverURL = "https://openapi.naver.com/v1/search/movie.json?query="
    var naverData: [NaverData?] = []
    
    struct NaverData : Codable {
        let items : [items]
    }
    
    struct items : Codable {
        let image : String
        let title : String
        //let userRating : Int
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        
        var movieImgURL:String? = nil
        if(naverData.count > indexPath.row){//서버에서 가져온 만큼의 이미지만 출력
            movieImgURL = naverData[indexPath.row]?.items[0].image
        }
        
        let movieName = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieNm
        cell.movieName.text = movieName
        //cell.movieDate.text = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let audiAcc = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc{
            cell.audiAccumulate.text = numberFormatter.string(for: Int(audiAcc))
        }else{
            cell.audiAccumulate.text = "0"
        }
                
        if let audiCnt = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt{
            cell.movieDate.text = numberFormatter.string(for: Int(audiCnt))
        }else{
            cell.audiAccumulate.text = "0"
        }

        cell.rank.text = String(indexPath.row + 1) + "위"
        cell.rank.clipsToBounds = true
        cell.rank.layer.cornerRadius = 15
        //cell.layer.cornerRadius = 15
        
        cell.mainImg.layer.cornerRadius = 18
        cell.mainImg.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        cell.mainFilter.layer.cornerRadius = 18
        cell.mainFilter.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        cell.bottomView.layer.cornerRadius = 18
        cell.bottomView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)
        cell.bottomView.layer.borderColor = UIColor.gray.cgColor
        cell.bottomView.layer.borderWidth = 0.5
        
        if let ss = movieName, let urlString = movieImgURL{
            //cell.posterImg.image = UIImage(named: ss) //프로젝트 이미지 사용
            let url = URL(string:urlString)
            DispatchQueue.global().async{
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async{
                    cell.posterImg.image = UIImage(data:data!)
                    cell.mainImg.image = UIImage(named: ss+"-1")
                }
            }
            
            print("yes Img")
        }else{
            print("no Img")
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.description)
    }
    
    func getData(){
        guard let url = URL(string: movieURL)else {return}
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            //print(JSONdata)
            //print(response!)
            //let dataString = String(data: JSONdata, encoding: .utf8)
            //print(dataString!)
            let decoder = JSONDecoder() //JSON데이터를 디코드하기 위해 JOSNDecoder객체생성
            do {
                let decodedData = try decoder.decode(MovieData.self, from: JSONdata) //.self:String.metatype임을 명시
                
                self.movieData = decodedData

                for (i, arr) in decodedData.boxOfficeResult.dailyBoxOfficeList.enumerated(){
                    DispatchQueue.global().sync{
                        self.getNaverData(movieName: arr.movieNm, index: i)
                    }
                }
                    
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
                
            }catch {
                print("MovieData Error")
                print(error)
            }
            
        }
        task.resume()
        
    }
    
    func getNaverData(movieName:String, index:Int){
        let urlString = (naverURL+movieName).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let semaphore = DispatchSemaphore(value: 0)
        guard let url = URL(string: urlString)else {return}
        var request = URLRequest(url:url)
        request.addValue("VpUcm2Ecojr_b1juJZ64", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("dAtQLI07Pa", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request){ (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            //print(JSONdata)
            //print(response!)
            //let dataString = String(data: JSONdata, encoding: .utf8)
            //print(dataString!)
            let decoder = JSONDecoder() //JSON데이터를 디코드하기 위해 JOSNDecoder객체생성
            
            do {
                let decodedData = try decoder.decode(NaverData.self, from: JSONdata) //.self:String.metatype임을 명시

                self.naverData.append(decodedData)

                semaphore.signal() //통신이 완료되어 다음 일을 진행할 수 있도록 열어둠
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
                
            }catch {
                print("naverError")
                print(error)
            }
        }
        task.resume()
        semaphore.wait() //task가 종료될 때 까지 대기
    }
    
    
    
    func makeYesterdayString() -> String {
        let y = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyMMdd"
        let day = dateF.string(from:y)
        return day
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? DetailViewController else {return}
        let myIndexPath = table.indexPathForSelectedRow!
        let row = myIndexPath.row
        dest.movieName = (movieData?.boxOfficeResult.dailyBoxOfficeList[row].movieNm)!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate  = self
        table.dataSource = self
        
        self.movieURL += makeYesterdayString() //api오류로 임시 주석처리
        self.getData()
        
    }


}

