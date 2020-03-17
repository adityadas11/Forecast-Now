//
//  Connection.swift
//  Forecast Now
//
//  Created by Adi on 3/14/20.
//  Copyright © 2020 Adi. All rights reserved.
//

import UIKit

protocol ConnectionProtocol: NSObjectProtocol{
    
    func connectionSuccessWithData(_ responseData: Data)
    func connectionFailedWithError(_ errorMsg: String)
}

class Connection: NSObject{
    var errorCode = ""
    var apiKey = "460f4ddbcb1655e69bd998f38b70594d"
    
    var receivedData =  NSMutableData()
    weak var connectionDelegate:ConnectionProtocol?
    
    
    func connectToServerWithurlGetMethod(_ url: String, method:String) {
        let finalURL = url + apiKey
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let urlStr = URL(string: finalURL){
            let request = NSMutableURLRequest(url: urlStr)
            
            request.httpMethod = method
            
            let config = URLSessionConfiguration.default
            
            config.timeoutIntervalForRequest = 60.0
            
            config.timeoutIntervalForResource = 60.0
            
            let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request as URLRequest)
            
            task.resume()
        }
    }
  
}

extension Connection:URLSessionDelegate,URLSessionDataDelegate, URLSessionTaskDelegate{
    
    //MARK: - NSURLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
            DispatchQueue.main.async { () -> Void in
                if error == nil{
                    if self.connectionDelegate != nil{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: self.receivedData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                            
                            if self.errorCode != "200"{
                                guard let message = (result as AnyObject)["message"] as? String else{
                                    return
                                }
                                self.connectionDelegate?.connectionFailedWithError(message)
                                
                            }
                          
                            else{
                                self.connectionDelegate?.connectionSuccessWithData(self.receivedData as Data)
                            }
                        }
                        catch{
                             self.connectionDelegate?.connectionSuccessWithData(self.receivedData as Data)
                        }
                    }
                }
            }
    }
    //MARK: - NSURLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        receivedData = NSMutableData()
       
        
            if let httpResponse = response as? HTTPURLResponse {
                self.errorCode = "\(httpResponse.statusCode)"
            }
        
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }
}
