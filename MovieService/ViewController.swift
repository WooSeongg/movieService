//
//  ViewController.swift
//  MovieCWS
//
//  Created by 미미밍 on 2022/05/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
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
    
    let naverMovieURL = "https://openapi.naver.com/v1/search/movie.json?query="
    var naverMovieData: [NaverData?] = []
    
    let naverImgURL = "https://openapi.naver.com/v1/search/image?query="
    var naverImgData :[NaverData?] = []
    
    
    struct NaverData : Codable {
        let items : [items]
    }
    
    struct items : Codable {
        let image : String?
        let title : String?
        let link : String
//        //let userRating : Int
//        enum name:String, CodingKey {
//            case image = "image"
//            case title = "title"
//            case link = "link"
//            //case a = "a"
//        }
    }
    
   
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        
        var moviePosterImgURL:String? = nil
        var movieMainImgURL:String? = nil
        if(naverMovieData.count > indexPath.row){//서버에서 가져온 만큼의 이미지만 출력
            if (naverMovieData[indexPath.row]?.items[0].image == ""){
                moviePosterImgURL = nil//없는 데이터는 nil이 아닌 빈문자열을 반환하기 때문
            }else{
                moviePosterImgURL = naverMovieData[indexPath.row]?.items[0].image
            }
        }
        
        if(naverImgData.count > indexPath.row){
            
            if let data = naverImgData[indexPath.row]?.items {
                if(data.isEmpty){
                    movieMainImgURL = nil
                }else{
                    movieMainImgURL = naverImgData[indexPath.row]?.items[0].link
                }
            }else{
                movieMainImgURL = nil
            }
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
        
        if let posterUrlString = moviePosterImgURL{
            //cell.posterImg.image = UIImage(named: ss) //프로젝트 이미지 사용
            let posterCacheKey = NSString(string:posterUrlString)

            let posterUrl = URL(string:posterUrlString)

            if let cacahePosterImage = ImageCacheManager.shared.object(forKey: posterCacheKey){//저장된 이미지가 있다면
                cell.posterImg.image = cacahePosterImage
            }else{
                DispatchQueue.global().async{
                    let data = try? Data(contentsOf: posterUrl!)

                    DispatchQueue.main.async{
                        let posterImage = UIImage(data:data!)
                        cell.posterImg.image = posterImage
                        ImageCacheManager.shared.setObject(posterImage!, forKey: posterCacheKey)//네트워크로 불러온 이미지 캐싱
                    }
                }
            }
            
        }else{
            cell.posterImg.image = UIImage(named: "NoImg")
            
        }
        
        if let mainUrlString = movieMainImgURL{
            let mainCacheKey = NSString(string:mainUrlString)
            let mainUrl = URL(string:mainUrlString)

            if let cacahemainImage = ImageCacheManager.shared.object(forKey: mainCacheKey){//저장된 이미지가 있다면
                cell.mainImg.image = cacahemainImage
            }else{
                DispatchQueue.global().async{

                    do{
                        let data = try Data(contentsOf: mainUrl!)

                        DispatchQueue.main.async{
                            let mainImage = UIImage(data:data)
                            cell.mainImg.image = mainImage
                            ImageCacheManager.shared.setObject(mainImage!, forKey: mainCacheKey)//네트워크로 불러온 이미지 캐싱
                        }
                    }catch{
                        print("Data Error")
                        print(error)
                    }
                }
            }

        }else{
            cell.mainImg.image = UIImage(named: "NoImg")
            print("no main")
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.description)
    }
    
    func getData(date:String){
        
        guard let url = URL(string: movieURL+date)else {return}
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder() //JSON데이터를 디코드하기 위해 JOSNDecoder객체생성
            do {
                let decodedData = try decoder.decode(MovieData.self, from: JSONdata) //.self:String.metatype임을 명시
                
                //박스오피스 목록
                self.movieData = decodedData
                //이미지데이터 초기화
                self.naverImgData = Array()
                self.naverMovieData = Array()
                
                for (arr) in decodedData.boxOfficeResult.dailyBoxOfficeList{
                    DispatchQueue.global().sync{
                        self.getNaverMovieData(stringURL: self.naverMovieURL+arr.movieNm)
                        self.getNaverImgData(movieName: arr.movieNm)
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
    
    //포스터 이미지 불러오기
    func getNaverMovieData(stringURL:String){
        
        let semaphore = DispatchSemaphore(value: 0)
        
        //let year = "&yearfrom="+String(datePicker.date.get(.year)-3)+"&yearto="+String(datePicker.date.get(.year))
        let urlString = stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url:url)
        //헤더에 개인키 추가
        request.addValue("VpUcm2Ecojr_b1juJZ64", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("dAtQLI07Pa", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request){ (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder() //JSON데이터를 디코드하기 위해 JOSNDecoder객체생성
            
            do {
                let decodedData = try decoder.decode(NaverData.self, from: JSONdata) //.self:String.metatype임을 명시
                
                self.naverMovieData.append(decodedData)

                //다음 작업이 진행되도록 sync로 지정된 getNaverMovieData() 종료함
                //dataTask()는 백그라운드큐에서 동작하기 때문에 계속 진행됨
                semaphore.signal()
                
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
                
            }catch {
                print("naverMovieData Error")
                print(error)
            }
        }
        task.resume()
        semaphore.wait() //task가 종료될 때 까지 대기
    }
    
    //배경메인 이미지 불러오기
    func getNaverImgData(movieName:String){
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let urlString = (naverImgURL+movieName+"&display=1&filter=large").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString)else {return}
        var request = URLRequest(url:url)
        //헤더에 개인키 추가
        request.addValue("VpUcm2Ecojr_b1juJZ64", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("dAtQLI07Pa", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request){ (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder()
            
            do{
                let decodedData = try decoder.decode(NaverData.self, from: JSONdata) //.self:String.metatype임을 명시

                self.naverImgData.append(decodedData)

                //다음 작업이 진행되도록 sync로 지정된 getNaverImgData() 종료
                //dataTask()는 백그라운드큐에서 동작하기 때문에 계속 진행됨
                semaphore.signal()
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } catch{
                print("naverImgData Error")
                print(error)
            }
        }
        task.resume()
        semaphore.wait() //task가 종료될 때 까지 대기
    }
    
    //
    func makeYesterdayString() -> String {
        let y = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyMMdd"
        let day = dateF.string(from:y)
        print("day:\(day)")
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
        
        //영진위API최대 검색 가능 날짜로 Date 생성
        let minimumDateComponents = DateComponents(year: 2005, month:1, day:1)
        let minimumDate = Calendar.current.date(from: minimumDateComponents)
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()//당일 까지만 선택가능
        
        let yesterday = makeYesterdayString()
        self.getData(date:yesterday)
    }
    
    class ImageCacheManager {
        
        static let shared = NSCache<NSString, UIImage>()
        
        private init() {}
    }

    @IBAction func ChnagingDate(_ sender: UIDatePicker) {
        
        let pickedDate = sender.date
        let today = DateFormatter()
        today.dateFormat = "yyyyMMdd"
        let resultDate = today.string(from: pickedDate)

        self.getData(date:resultDate)
        
    }
    
}


