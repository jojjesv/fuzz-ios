
import Foundation
import UIKit

//  Mostly image cache.
public class Caches {
    /// Image cache with its URL.
    private static var cache = [String: UIImage]()
    
    public static func getImage(fromUrl url: String, callback: @escaping (UIImage?) -> Void) {
        if let img = cache[url] {
            callback(img)
            return
        }
        
        let url = URL(string: url)
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in
            
            DispatchQueue.main.async {
                if let e = error {
                    print(e)
                    callback(nil)
                    return
                }
            
                callback(UIImage(data: data!))
            }
        }
        task.resume()
    }
}
