# 영화정보 제공 앱: CINEMA TREND
<p align="center">
  

 
</p>

<br>

## 프로젝트 소개 👩‍🏫

Open API를 활용해 일일 박스오피스 순위 및 영화 정보를 제공하는 앱입니다.<br>

<br>
<br>

## 스택 🔨

### 기술 스택
- 프로젝트 구조: MVC
- 인터페이스: Storyboard
- 사용한 Open API: KOBIS박스오피스, 네이버 이미지 검색, <s>네이버 영화 검색</s>
- URLSession
- NSCache
- Core Data

### 개발 환경
- OS: macOS Monterey(12.X)
- IDE: Xcode12

<br>

## 앱 구성

<br>

### 스크린샷

| **메인화면** | **영화 검색** | **영화관 검색** | 
| :------: | :------: | :------: | 
| ![image (6)](https://github.com/WooSeongg/movieService/assets/67594952/99c371e9-8504-4e56-862b-91f652735502) | ![4124](https://github.com/WooSeongg/movieService/assets/67594952/0e480bc2-f14d-494c-8ad6-dd54e0667492) |![444](https://github.com/WooSeongg/movieService/assets/67594952/324b1a2f-b97a-4914-9753-8d8f3b7ce495) |


<br>

### 개발 상세

#### API통신
- API에 필요한 데이터 모델링
- URLSession.dataTask로 데이터 요청
- JSONDecoder로 JSON데이터 파싱
- 네이버이미지 검색은 Serial타입 큐에 Sync방식으로 데이터 요청
- Semaphore적용

#### 화면 출력
- 파싱된 데이터 테이블뷰 출력
- 이미지 캐시 적용

<br>
<br>
