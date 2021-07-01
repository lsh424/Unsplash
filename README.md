# Unsplash

Unsplash API를 이용해 만든 사진 뷰어 앱입니다.  
기존 Unsplash App UX/UI를 차용해 개발했습니다.  
이미지 검색, 이미지 리스트 보기, 이미지 상세 보기 기능을 제공합니다.


## 사진 & 사진 정보 보기

<img src="Images/Image1.png" width="25%" height="25%" > <img src="Images/Image2.png" width="25%" height="25%">  

<br>

## 사진 검색 

<img src="Images/Image3.png" width="25%" height="25%"> <img src="Images/Image4.png" width="25%" height="25%">

<br>

## 이미지 상세보기

<img src="Images/Image5.png" width="25%" height="25%"> <img src="Images/Image6.png" width="25%" height="25%">

<br>

### Network

Generic 사용을 통해 코드의 재사용성을 높이고자 했습니다. 

```swift
import Foundation

enum Router {
    case fetchPhotos(page: Int)
    case searchPhotos(page: Int, query: String)
    case fetchPhotoInfo(photoID: String)
    
    private var baseURL: String {
        return "https://api.unsplash.com"
    }
    
    private var path: String {
        switch self {
        case .fetchPhotos:
            return "/photos"
        case .searchPhotos:
            return "/search/photos"
        case .fetchPhotoInfo(let id):
            return "/photos/\(id)"
        }
    }
    
    var url: String {
        return baseURL + path
    }
    
    var parameters: [URLQueryItem] {
        let key = "q8f50ZiYg_QMLrq63eqBp71zXkSGJx_ILeIbZOAIxMg"
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "client_id", value: key))
        
        switch self {
        case .fetchPhotos(let page):
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "per_page", value: "30"))
            return queryItems
        case .searchPhotos(let page, let query):
            queryItems.append(URLQueryItem(name: "query", value: query))
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
            queryItems.append(URLQueryItem(name: "per_page", value: "30"))
            return queryItems
        case .fetchPhotoInfo:
            return queryItems
        }
    }
}
```

```swift
import Foundation

struct APIRequester {
    typealias Completion<T> = (Result<T, NetworkError>) -> Void
    typealias CompletionWithArray<T> = (Result<[T], NetworkError>) -> Void
    
    let router: Router
    
    init(with router: Router) {
        self.router = router
    }
    
    func request<T: Codable>(completion: @escaping Completion<T>) {
        var components = URLComponents(string: router.url)
        components?.queryItems = router.parameters
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601 // Date - iso8601 포맷
                
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch (let error){
                completion(.failure(.failedDecoding(error)))
            }
        }
        task.resume()
    }
    
    func request<T: Codable>(completion: @escaping CompletionWithArray<T>) {
        var components = URLComponents(string: router.url)
        components?.queryItems = router.parameters
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {return}
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode([T].self, from: data)
                completion(.success(result))
            } catch (let error){
                completion(.failure(.failedDecoding(error)))
            }
        }
        task.resume()
    }
}
```


<br>

#### 이미지 캐싱

```swift
    func downloadImage(imageURL: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        if let imageData = ImageCacheManager.shared.cachedImages.object(forKey: imageURL.absoluteString as NSString) {
            completion(.success(imageData as Data))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: imageURL) { (url, _, error) in
            guard let url = url, error == nil else {return}
            
            do {
                let data = try Data(contentsOf: url)
                ImageCacheManager.shared.cachedImages.setObject(data as NSData, forKey: imageURL.absoluteString as NSString)
                completion(.success(data))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
```


<br>
<br>

### Memory Management

Strong Reference Cycle로 인한 메모리 누수 방지

```swift
weak var delegate: PhotoListViewDelegate?
```

```swift
NetworkManager.shared.fetchPhotoInfo(photoID: photoID) { [weak self] (result: Result<PhotoInfo, NetworkError>) in
            switch result {
            case .success(let photoInfo):
                DispatchQueue.main.async {
                    self?.informationView.configure(with: photoInfo)
                }
            case .failure(let error):
                print(error.description)
            }
        }
```

<br>
<br>

### Gesture

PhotoDetailViewController는 스와이프를 통한 사진 넘기기, 핀치 제스처를 통한 사진 확대, 펜 제스처를 통한 dismiss등 다양한 제스처를 인지합니다.  
사용자 제스처의 x, y 방향 translation 속도와 이미지의 줌 상태, 그리고 컬렉션 뷰의 x축 기준 contentOffset 값 등 서로 인과관계가 있을 수 있는 속성들을 적절히 이용함으로써 사용자의 다양한 제스처를 구분하고 그에 맞는 기능을 제공할 수 있도록 구현했습니다. 

```swift
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, let cell = collectionView.visibleCells[0] as? PhotoDetailViewCell else {
            return false
        }
        
        let velocity = panGestureRecognizer.velocity(in: collectionView)
        let collectionViewWidth = self.collectionView.frame.width
        
        return (collectionView.contentOffset.x).remainder(dividingBy: collectionViewWidth) == 0 && abs(velocity.y) > abs(velocity.x) && cell.scrollView.zoomScale <= 1
    }
```

```swift
    @objc func drag(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        switch sender.state {
        case .began:
            collectionViewOriginalCenter = collectionView.center
            collectionView.isScrollEnabled = false
            delegate?.updateCollectionView(indexPath: IndexPath(item: indexPathItem, section: 0))
        case .changed:
            collectionView.center = CGPoint(x: collectionViewOriginalCenter.x + translation.x, y: collectionViewOriginalCenter.y + translation.y)
            self.view.alpha = (self.collectionView.frame.height - (translation.y / 3)) / self.collectionView.frame.height
        case .ended:
            if translation.y < self.collectionView.frame.height / 4 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.center = self.collectionViewOriginalCenter
                    self.view.alpha = 1
                })
                self.collectionView.isScrollEnabled = true
            } else {
                let newCenter = CGPoint(x: self.collectionViewOriginalCenter.x, y: self.collectionViewOriginalCenter.y + 20)
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.collectionView.center = newCenter
                } completion: { (_) in
                    self.dismiss(animated: false, completion: nil)
                }
            }
        default:
            return
        }
    }
```

<br>
<br>


## Requirements
iOS 10+

#### 이미지 제공: https://unsplash.com/developers
