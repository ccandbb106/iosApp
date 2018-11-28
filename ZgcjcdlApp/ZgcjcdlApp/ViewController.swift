//
//  ViewController.swift
//  ZgcjcdlApp
//
//  Created by 长城 on 2018/11/19.
//  Copyright © 2018年 dhsr. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController ,WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate{
    var wkWebView = WKWebView()
    var navFlag = ""
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "storeUserInfo" {
            print("have catch the storeUserInfo message!!")
            let userInfo = message.body as! [String:String]
            UserDefaults.standard.set(userInfo["username"]!, forKey: "username")
            UserDefaults.standard.set(userInfo["pwd"]!, forKey: "password")
        }else if message.name == "changePwdSuccess" {
            print("have catch the changePwdSuccess message!!")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")
            
        }else{
            print("have catch the recharge message!!")
            let payMessage = message.body as! [String:Any]
            if payMessage["paySelected"] as! String == "支付宝" {
                let alert = UIAlertController(title: "提示", message: "支付宝充值成功!", preferredStyle: .alert)
                let action = UIAlertAction(title: "好的", style: .cancel) { (_) in
                    self.wkWebView.loadFileURL(NSURL.fileURL(withPath: Bundle.main.path(forResource: "recharge", ofType: "html", inDirectory: "APP")!), allowingReadAccessTo: NSURL.fileURL(withPath: Bundle.main.path(forResource: "recharge", ofType: "html", inDirectory: "APP")!))
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "提示", message: "微信充值成功!", preferredStyle: .alert)
                let action = UIAlertAction(title: "好的", style: .cancel) { (_) in
                    self.wkWebView.loadFileURL(NSURL.fileURL(withPath: Bundle.main.path(forResource: "recharge", ofType: "html", inDirectory: "APP")!), allowingReadAccessTo: NSURL.fileURL(withPath: Bundle.main.path(forResource: "recharge", ofType: "html", inDirectory: "APP")!))
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //register js func
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "storeUserInfo")
        config.userContentController.add(self, name: "changePwdSuccess")
        config.userContentController.add(self, name: "recharge")
        wkWebView = WKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-20), configuration: config)
       
        //check login status
        var path = ""
        if let _ = UserDefaults.standard.string(forKey: "username"), let _ = UserDefaults.standard.string(forKey: "password"){
            path = Bundle.main.path(forResource: "loading", ofType: "html", inDirectory: "APP")!
        }else{
            path = Bundle.main.path(forResource: "login", ofType: "html", inDirectory: "APP")!
        }
        
        let fileURL = NSURL.fileURL(withPath: path)
        wkWebView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        view.addSubview(wkWebView)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navFlag == "loading.html" {
            if let username = UserDefaults.standard.string(forKey: "username"), let password = UserDefaults.standard.string(forKey: "password"){
                wkWebView.evaluateJavaScript("dataJava('" + username + "','" + password + "')") { (response, error) in
                    if(!(error != nil)){
                        print("success,the logon response is:",response as Any)
                    }else{
                        print("failture,the logon info is:",error!.localizedDescription)
                    }
                }
            }else{
                let alert = UIAlertController(title: "提示", message: "账户信息获取异常，请重新登录.", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "关闭", style: .default) { (_) in
                    //clear userInfo
                    UserDefaults.standard.removeObject(forKey: "username")
                    UserDefaults.standard.removeObject(forKey: "password")
                    exit(0)
                }
                alert.addAction(btnOK)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.url?.absoluteString.contains("loading.html"))!{
            navFlag = "loading.html"
        }else{
            navFlag = ""
        }
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "好的", style: .cancel) { (_) in
            completionHandler()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "取消", style:.cancel) { (_) in
            completionHandler(false)
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        alert.addTextField { (_) in}
        let action = UIAlertAction(title: "确定", style: .default) { (_) in
            completionHandler(alert.textFields?.last?.text)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
}

