//
//  ViewController.swift
//  SyncAsyncImageLoading
//
//  Created by Jaehoon Lee on 2020/10/30.
//

import UIKit
import Alamofire
import Kingfisher
import Then

class ViewController: UIViewController {
    
    let urlStr = "http://www.ibiblio.org/wm/paint/auth/munch/munch.scream.jpg"
    
    

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 캐쉬 사용 안함
        URLSession.shared.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
    }

    // 동기식 네트워크 - UI가 블록됨
    @IBAction func loadImageSync(_ sender: Any) {
        imageView.image = nil

        if let url = URL(string: urlStr),
           let data = try? Data(contentsOf: url) {
            let image = UIImage(data: data)
            imageView.image = image
        }
    }
    
    // URLSession, Task를 이용한 비동기식 네트워크
    @IBAction func loadImageURLSession(_ sender: Any) {
        imageView.image = nil
        
        if let url = URL(string: urlStr) {

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("Task Start")
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                // 앱 UI 접근은 메인 쓰레드에서
                print("isMainThread", Thread.isMainThread)
                self.imageView.image = image
            }
            task.resume()
            print("After Resume")
        }
    }
    
    // URLSession, Task를 이용한 비동기식 네트워크 - MainThread에서 이미지 업데이트
    @IBAction func loadImageURLSessionUIMain(_ sender: Any) {
        imageView.image = nil
        
        if let url = URL(string: urlStr) {

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("Task Start")
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                // 앱 UI 접근은 메인 쓰레드에서
                DispatchQueue.main.async {
                    print("isMainThread", Thread.isMainThread)
                    self.imageView.image = image
                }
            }
            task.resume()
            print("After Resume")
        }
    }
    
    // 동기식 코드를 GCD를 이용해서 비동기 방식으로 실행하기
    @IBAction func loadImageByDispatchQueue(_ sender: Any) {
        imageView.image = nil
        
        DispatchQueue.global().async {
            if let url = URL(string: self.urlStr),
               let data = try? Data(contentsOf: url) {
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    // Alamofire를 이용해서 이미지 로딩
    @IBAction func loadImageByAlamofire(_ sender: Any) {
        imageView.image = nil
        
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        AF.request(request).responseData { (response) in
            if let data = response.data {
                // 메인 쓰레드에서 동작
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        }
    }
    
    // 이미지 라이브러리를 이용한 이미지 비동기 로딩
    @IBAction func loadImageByImageLoader(_ sender: Any) {
        imageView.image = nil
        Kingfisher.ImageCache.default.clearCache()
                
        if let url = URL(string: urlStr) {
            imageView.kf.setImage(with: url)
        }
    }

    /*
    let delayedResponseURL = "http://192.168.12.9:3000"
    let urlList = [
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/2560px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Meisje_met_de_parel.jpg/1920px-Meisje_met_de_parel.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/1449px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg/1076px-The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg"
    ]

    
    // 이미지 순차 다운로드와 변경
    @IBAction func showQueueExample1(_ sender: Any) {
        imageView.image = nil
        
        let queue = DispatchQueue(label: "my-queue")
        urlList.forEach { (item) in
            queue.async {
                print("start image download :", item)
                if let url = URL(string: item),
                   let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    print("finish image download :", item)
                    DispatchQueue.main.sync {
                        self.imageView.image = image
                    }
                    // 딜레이
                    Thread.sleep(forTimeInterval: 1)
                }
            }
        }
    }
    
    // DispatchQuque를 이용한 동시 실행 큐
    @IBAction func showQueueExample2(_ sender: Any) {
        let queue = DispatchQueue(label: "concurrent", attributes: .concurrent)
                
        queue.async {
            print("concurrent work1 started")
            Thread.sleep(forTimeInterval: 3)
            print("concurrent work1 finished")
        }
        queue.async {
            print("concurrent work2 started")
            Thread.sleep(forTimeInterval: 3)
            print("concurrent work2 finished")
        }
        queue.async {
            print("concurrent work3 started")
            Thread.sleep(forTimeInterval: 3)
            print("concurrent work3 finished")
        }
    }
    
    // DispatchQuque를 이용한 순차 실행 큐
    @IBAction func showQueueExample3(_ sender: Any) {
        let queue = DispatchQueue(label: "serial")
        
        queue.async {
            print("serial work1 started")
            Thread.sleep(forTimeInterval: 3)
            print("serial work1 finished")
        }
        queue.async {
            print("serial work2 started")
            Thread.sleep(forTimeInterval: 3)
            print("serial work2 finished")
        }
        queue.async {
            print("serial work3 started")
            Thread.sleep(forTimeInterval: 3)
            print("serial work3 finished")
        }
    }
    func asyncTask(taskNo: Int) {
        print("async task\(taskNo) started")
        AF.request(delayedResponseURL)
            .responseJSON { (response) in
                print("async task\(taskNo) done:", response)
            }
    }
    
    // 프라미스를 이용한 비동기 동작. Promise<RESULT-TYPE>
    func asyncTaskPromise(taskNo: Int) -> Promise<Int> {
        return Promise { (resolve, reject) in
            print("async task\(taskNo) started")
            AF.request(self.delayedResponseURL)
                .responseJSON { (response) in
                    if let error = response.error {
                        reject(error)
                        return
                    }
                    print("async task\(taskNo) done")
                    // 비동기 동작 결과 전달
                    resolve(taskNo)
                }
        }
    }
    
    func imageDownloadTask(urlStr: String) -> Promise<Data> {
        return Promise { resolve, reject in
            let url = URL(string: urlStr)!
            print("image download task started :", urlStr)
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    reject(error!)
                    return
                }
                print("image download task finished :", urlStr)
                resolve(data!)
            }.resume()
        }
    }
    
    // Then 모듈을 이용해서
    @IBAction func showQueueExample4(_ sender: Any) {
        imageDownloadTask(urlStr: urlList[0])
        .then { data -> Promise<Data> in
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            // 딜레이
            Thread.sleep(forTimeInterval: 1)

            return self.imageDownloadTask(urlStr: self.urlList[1])
        }
        .then { data -> Promise<Data> in
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            // 딜레이
            Thread.sleep(forTimeInterval: 1)

            return self.imageDownloadTask(urlStr: self.urlList[2])
        }
        .then { data -> Promise<Data> in
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            // 딜레이
            Thread.sleep(forTimeInterval: 1)
            return self.imageDownloadTask(urlStr: self.urlList[3])
        }
        .then { data -> Void in
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            // 딜레이
            print("Done!")
        }
        .onError { error in
            print("Error!")
        }
    }
    
    @IBAction func showQueueExample5() {
        DispatchQueue.global().async {
            let ret1 = try! await(self.imageDownloadTask(urlStr: self.urlList[0]))
            DispatchQueue.main.sync {
                self.imageView.image = UIImage(data: ret1)
            }
            Thread.sleep(forTimeInterval: 1)
            let ret2 = try! await(self.imageDownloadTask(urlStr: self.urlList[1]))
            DispatchQueue.main.sync {
                self.imageView.image = UIImage(data: ret2)
            }

            Thread.sleep(forTimeInterval: 1)
            let ret3 = try! await(self.imageDownloadTask(urlStr: self.urlList[2]))
            DispatchQueue.main.sync {
                self.imageView.image = UIImage(data: ret3)
            }

            Thread.sleep(forTimeInterval: 1)
            let ret4 = try! await(self.imageDownloadTask(urlStr: self.urlList[3]))
            DispatchQueue.main.sync {
                self.imageView.image = UIImage(data: ret4)
            }

            print("ret1 \(ret1), ret2: \(ret2), ret3: \(ret3), ret4: \(ret4)")
        }
    }
     */
}
