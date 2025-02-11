import Foundation

// Глобальная переменная для хранения URL для валидации
//var urlForValidation = "https://shorturl.at/KSwvK"  // Замените на фактический URL

class NetworkManager: NSObject, URLSessionDelegate {
    
    // Метод для выполнения запроса и получения финального URL
    func fetchFinalURL(from sourceURL: URL, completion: @escaping (URL?) -> Void) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let dataTask = session.dataTask(with: sourceURL) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, let redirectedURL = httpResponse.url {
                completion(redirectedURL)
            } else {
                completion(nil)
            }
        }
        dataTask.resume()
    }
    
    // Обработчик редиректа
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(request)
    }
    
    // Статический метод для проверки валидности URL
    static func isURLValid() async -> Bool {
        // Используем глобальную переменную urlForValidation
        if let encodedURLString = urlForValidation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let finalURL = URL(string: encodedURLString) {
            
            let manager = NetworkManager()
            
            return await withCheckedContinuation { continuation in
                manager.fetchFinalURL(from: finalURL) { redirectedURL in
                    DispatchQueue.main.async {
                        if let finalHost = redirectedURL?.host {
                            continuation.resume(returning: finalHost.contains("google"))
                        } else {
                            continuation.resume(returning: false)
                        }
                    }
                }
            }
        } else {
            return false
        }
    }
}

// Функция обновления состояния с учётом проверки URL
//func refreshContent() {
//    if isUpdateNeeded {
//        // Отображаем экран загрузки
//        Task {
//            let isValid = await NetworkManager.isURLValid()
//            if !isValid {
//                currentVerse = 1
//                isUpdateNeeded = false
//                isLoading = false
//            } else {
//                currentVerse = 0
//                isUpdateNeeded = false
//                isLoading = false
//            }
//        }
//    } else {
//        isLoading = false
//    }
//}
