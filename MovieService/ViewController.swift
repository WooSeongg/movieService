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
    @IBOutlet weak var header: UIView!
    
    private var imgWorkItem: DispatchWorkItem?
    
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
        let openDt: String
    }
    //네이버영화 (포스터) 검색
    let naverMovieURL = "https://openapi.naver.com/v1/search/movie.json?query="
    var naverMovieData: [NaverData?] = []
    
    //네이버이미지 (배경) 검색
    let naverImgURL = "https://openapi.naver.com/v1/search/image?query="
    var naverImgData :[NaverData?] = []
    
    
    struct NaverData : Codable {
        let items : [items]
    }
    
    struct items : Codable {
        let image : String?
        let title : String?
        let link : String?
//        //let userRating : Int
//        enum name:String, CodingKey {
//            case image = "image"
//            case title = "title"
//            case link = "link"
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
            if (naverMovieData[indexPath.row]?.items[0].link == ""){
                moviePosterImgURL = nil//없는 데이터는 nil이 아닌 빈문자열을 반환하기 때문
            }
            else{
                moviePosterImgURL = naverMovieData[indexPath.row]?.items[0].link
            }
        }
        
        if(naverImgData.count > indexPath.row){
            
            if let data = naverImgData[indexPath.row]?.items {
                if(data.isEmpty){
                    movieMainImgURL = nil
                }
                else{
                    movieMainImgURL = naverImgData[indexPath.row]?.items[0].link
                }
            }
            else{
                movieMainImgURL = nil
            }
        }
        
        let movieName = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].movieNm
        cell.movieName.text = movieName
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        //총 관객 수
        if let audiAcc = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiAcc{
            cell.audiAccumulate.text = numberFormatter.string(for: Int(audiAcc))
        }
        else{
            cell.audiAccumulate.text = "0"
        }
           
        //일일관객 수
        if let audiCnt = movieData?.boxOfficeResult.dailyBoxOfficeList[indexPath.row].audiCnt{
            cell.movieDate.text = numberFormatter.string(for: Int(audiCnt))
        }
        else{
            cell.movieDate.text = "0"
        }
        //순위표시
        cell.rank.text = String(indexPath.row + 1) + "위"
        
        if let posterUrlString = moviePosterImgURL{

            let posterCacheKey = NSString(string:posterUrlString)
            let posterUrl = URL(string:posterUrlString)

            if let cacahePosterImage = ImageCacheManager.shared.object(forKey: posterCacheKey){//저장된 이미지가 있다면
                cell.posterImg.image = cacahePosterImage
            }
            else{
                DispatchQueue.global().async{
                    let data = try? Data(contentsOf: posterUrl!)

                    DispatchQueue.main.async{
                        let posterImage = UIImage(data:data!)
                        cell.posterImg.image = posterImage
                        ImageCacheManager.shared.setObject(posterImage!, forKey: posterCacheKey)//네트워크로 불러온 이미지 캐싱
                    }
                }
            }
            
        }
        else{
            cell.posterImg.image = UIImage(named: "NoImg")
            print("no poster")
        }
        
        if let mainUrlString = movieMainImgURL{
            let mainCacheKey = NSString(string:mainUrlString)
            let mainUrl = URL(string:mainUrlString)

            if let cacahemainImage = ImageCacheManager.shared.object(forKey: mainCacheKey){//저장된 이미지가 있다면
                cell.mainImg.image = cacahemainImage
            }
            else{
                DispatchQueue.global().async{
                    do{
                        let data = try Data(contentsOf: mainUrl!)

                        DispatchQueue.main.async{
                            let mainImage = UIImage(data:data)
                            cell.mainImg.image = mainImage
                            ImageCacheManager.shared.setObject(mainImage!, forKey: mainCacheKey)//네트워크로 불러온 이미지 캐싱
                        }
                    }
                    catch{
                        print("Data Error")
                        print(error)
                    }
                }
            }

        }
        else{
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
                let Serialqueue = DispatchQueue(label:"Serialqueue")
                
                //박스오피스 목록
                self.movieData = decodedData
                //이미지데이터 초기화
                self.naverImgData = Array()
                self.naverMovieData = Array()
                
                self.imgWorkItem = DispatchWorkItem{
                    for (arr) in decodedData.boxOfficeResult.dailyBoxOfficeList{
                        Serialqueue.async{
                            self.getNaverMovieData(stringURL: self.naverImgURL+"영화 "+arr.movieNm+" 포스터" ,openDt:arr.openDt)
                            self.getNaverImgData(movieName: arr.movieNm)
                        }
                    }
                }
                DispatchQueue.global().async(execute:self.imgWorkItem!)
                
                DispatchQueue.main.async{
                    self.table.reloadData()
                }
            }
            catch {
                print("MovieData Error")
                print(error)
            }
            print("getData is End")
        }
        task.resume()
    }
    
    //포스터 이미지 불러오기
    func getNaverMovieData(stringURL:String, openDt:String){
        
        let semaphore = DispatchSemaphore(value: 0)
        
        //네이버 영화검색 요청 url
        let urlString = stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //영화 목록은 제작년도를 기준으로 내림차순으로 검색되므로 openYear까지만 조건을 걸어도 원하는 영화를 찾을 수 있다
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
                
                
                //이미지 캐싱
                if decodedData.items.count > 0 { //이미지 링크를 불러왔을 때만 동작
                    if let imageUrlString = decodedData.items[0].link{
                        do{
                            let imageUrl = URL(string: imageUrlString)
                            let data = try Data(contentsOf: imageUrl!) //이미지 불러옴
                            let posterImage = UIImage(data:data)
                            let posterCacheKey = NSString(string:imageUrlString)
                            ImageCacheManager.shared.setObject(posterImage!, forKey: posterCacheKey)//네트워크로 불러온 이미지 캐싱
                            
                        }
                        catch{
                            print(error)
                        }
                    }
                }
                
                                
                //모든 이미지 링크가 다운로드 되었을 때 화면 새로고침
                if(self.movieData?.boxOfficeResult.dailyBoxOfficeList.count == self.naverMovieData.count){
                    DispatchQueue.main.async {
                        self.table.reloadData()
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            catch {
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
        
        let urlString = (naverImgURL+movieName+"스틸컷&display=1&filter=large").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
                
                //이미지 캐싱
                if decodedData.items.count > 0 {//이미지 링크를 불러왔을 때만 동작
                    if let imageUrlString = decodedData.items[0].link{
                        do{
                            let imageUrl = URL(string: imageUrlString)
                            let data = try Data(contentsOf: imageUrl!)
                            let mainImage = UIImage(data:data)
                            let mainCacheKey = NSString(string:imageUrlString)
                            ImageCacheManager.shared.setObject(mainImage!, forKey: mainCacheKey)//네트워크로 불러온 이미지 캐싱
                        }
                        catch{
                            print(error)
                        }
                    }
                }
                
                //모든 이미지링크가 다운로드 되었을 때 화면 새로고침
                if(self.movieData?.boxOfficeResult.dailyBoxOfficeList.count == self.naverImgData.count){
                    DispatchQueue.main.async {
                        self.table.reloadData()
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            catch{
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
        table.tableHeaderView = header
        self.navigationItem.title = "Box Office"
        //데이터 로드 전 터치 불가
        self.view.isUserInteractionEnabled = false
        
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
        
        //데이터 로딩 전엔 터치 불가 - 데이터가 덮어 쓰이는 문제 방지
        self.view.isUserInteractionEnabled = false
                
        //박스오피스 목록 초기화
        self.movieData = nil
        //이미지데이터 초기화
        self.naverImgData = Array()
        self.naverMovieData = Array()
        
        imgWorkItem?.cancel()
        
        let pickedDate = sender.date
        let today = DateFormatter()
        today.dateFormat = "yyyyMMdd"
        let resultDate = today.string(from: pickedDate)

        self.getData(date:resultDate)
    }
}

extension Date{
    func get(_ components:Calendar.Component, calendar:Calendar=Calendar.current) -> Int{
        return calendar.component(components, from: self)
    }
}

