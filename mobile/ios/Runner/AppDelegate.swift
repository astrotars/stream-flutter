import UIKit
import Flutter
import GetStream

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "io.getstream/backend",
                                           binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as!  Dictionary<String, String>
            if call.method == "postMessage" {
                do {
                    try self.postMessage(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_postMessage",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "getActivities" {
                do {
                    self.getActivities(args: args, result: result)
                    
                    result(true)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_getSeedPhrase",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "getTimeline" {
                do {
                    self.getTimeline(args: args)
                    
                    result(true)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_getSeedPhrase",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "follow" {
                do {
                    self.follow(args: args)
                    result(true)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_getSeedPhrase",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else {
                result(FlutterError.init(code: "IOS_EXCEPTION_NO_METHOD_FOUND",
                                         message: "no method found for: " + call.method,
                                         details: nil));
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func postMessage(args: Dictionary<String, String>, result: FlutterResult) {
        // let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        // let feed = client.flatFeed(feedSlug: "user", userId: args["user"]!)
        // let activity = Activity(actor: args["user"]!, verb: "post", object: "uuid", message: args["message"]!)
        // feed.add(activity)
        result(true)
    }
    
    private func getActivities(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        let feed = client.flatFeed(feedSlug: "user", userId: args["user"]!)
        feed.get(pagination: .limit(25)) { r in result(r) }
    }
    
    
    private func getTimeline(args: Dictionary<String, String>) {
        
    }
    
    private func follow(args: Dictionary<String, String>) {
        
    }
}
