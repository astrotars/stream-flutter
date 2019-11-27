import UIKit
import Flutter
import GetStream

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var feed: FlatFeed?;
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "io.getstream/backend",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            print("platform call")
            print(call.method)
            print(call.arguments)
            let args = call.arguments as!  Dictionary<String, String>
            if call.method == "postMessage" {
                do {
                    try self!.postMessage(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_postMessage",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "getActivities" {
                do {
                    self!.getActivities(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_getActivities",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "getTimeline" {
                do {
                    self!.getTimeline(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_getTimeline",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "follow" {
                do {
                    self!.follow(args: args)
                    result(true)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_follow",
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
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        let feed = client.flatFeed(feedSlug: "user")
        let activity = EnrichedActivity<String, String, DefaultReaction>(actor: args["user"]!, verb: "post", object: "uuid")
        feed!.add(activity) {result in
            print("callback")
            print(result)
        }
        result(true)
    }
    
    private func getActivities(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        let feed = client.flatFeed(feedSlug: "user", userId: args["user"]!)
        feed.get(pagination: .limit(25)) { r in result(r) }
        result("[]")
    }
    
    
    private func getTimeline(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        print(args["token"]!)
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "timeline")
        self.feed!.get(typeOf: EnrichedActivity<String, String, DefaultReaction>.self, pagination: .limit(25)) { r in
            print("print result")
            if case .success(let response) = r {
                print("success")
                print(response)
                
                result(String(data: try! JSONEncoder().encode(response.results), encoding: .utf8)!)
                
            }
            if case .failure(let err) = r {
                print(err.description)
                print(err.failureReason)
            }
        }
    }
    
    private func follow(args: Dictionary<String, String>) {
        
    }
}
