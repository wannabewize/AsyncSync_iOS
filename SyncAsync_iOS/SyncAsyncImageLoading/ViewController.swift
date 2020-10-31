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
    let delayedResponseURL = "http://192.168.12.9:3000"
    
    let urlStr = "http://www.ibiblio.org/wm/paint/auth/munch/munch.scream.jpg"
    
    let urlList = [
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/2560px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Meisje_met_de_parel.jpg/1920px-Meisje_met_de_parel.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/1449px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg",
        "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg/1076px-The_Kiss_-_Gustav_Klimt_-_Google_Cultural_Institute.jpg"
    ]
    

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 캐쉬 사용 안함
        URLSession.shared.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
    }

    @IBAction func loadImageSync(_ sender: Any) {
        imageView.image = nil

        if let url = URL(string: urlStr),
           let data = try? Data(contentsOf: url) {
            let image = UIImage(data: data)
            imageView.image = image
        }
    }
    
    @IBAction func loadImageAsync1(_ sender: Any) {
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
    @IBAction func loadImageAsync2(_ sender: Any) {
        imageView.image = nil
        
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)

        AF.request(request).responseData { (response) in
            if let data = response.data {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        }
    }
    
    @IBAction func loadImageAsync3(_ sender: Any) {
        imageView.image = nil
        Kingfisher.ImageCache.default.clearCache()
                
        if let url = URL(string: urlStr) {
            imageView.kf.setImage(with: url)
        }
    }
    
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
                    // 적당한 시간
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
    
    // Then 모듈을 이용해서
    @IBAction func showQueueExample4(_ sender: Any) {
        asyncTaskPromise(taskNo: 1)
        .then { (ret) -> Promise<Int> in
            print("task1 done with \(ret)")
            return self.asyncTaskPromise(taskNo: 2)
        }
        .then { (ret) -> Promise<Int> in
            print("task2 done with \(ret)")
            return self.asyncTaskPromise(taskNo: 3)
        }
        .then { (ret) -> Void in
            print("task3 done with \(ret)")
        }
        

    }
    
    @IBAction func showQueueExample5() {
        DispatchQueue.global().async {
            let ret1 = try! await(self.asyncTaskPromise(taskNo: 1))
            let ret2 = try! await(self.asyncTaskPromise(taskNo: 2))
            let ret3 = try! await(self.asyncTaskPromise(taskNo: 3))
            print("ret1 \(ret1), ret2: \(ret2), ret3: \(ret3)")
        }
    }
}
