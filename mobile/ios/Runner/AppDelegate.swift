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
        self.feed = client.flatFeed(feedSlug: "user")
        let activity = PostActivity(actor: User(id: args["user"]!), verb: "post", object: UUID().uuidString, message: args["message"]!)
        feed!.add(activity) {result in
            print("callback")
            print(result)
        }
        result(true)
    }
    
    private func getActivities(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "user")
        self.feed!.get(typeOf: PostActivity.self, pagination: .limit(25)) { r in
            result(String(data: try! JSONEncoder().encode(try! r.get().results), encoding: .utf8)!)
        }
    }
    
    
    private func getTimeline(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        print(args["token"]!)
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "timeline")
        self.feed!.get(typeOf: PostActivity.self, pagination: .limit(25)) { r in
            result(String(data: try! JSONEncoder().encode(try! r.get().results), encoding: .utf8)!)
        }
    }
    
    private func follow(args: Dictionary<String, String>) {
        let client = Client(apiKey: "7mpbqgq2kbh6", appId: "64414", token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "timeline")
        self.feed!.follow(toTarget: client.flatFeed(feedSlug: "user", userId: args["userToFollow"]!).feedId) { r in }
    }
}

final class PostActivity: EnrichedActivity<User, String, DefaultReaction> {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    var message: String

    init(actor: User, verb: Verb, object: ObjectType, message: String) {
        self.message = message
        super.init(actor: actor, verb: verb, object: object)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        try super.init(from: decoder)
    }
    
    required init(actor: ActorType, verb: Verb, object: ObjectType, foreignId: String? = nil, time: Date? = nil, feedIds: FeedIds? = nil, originFeedId: FeedId? = nil) {
        fatalError("init(actor:verb:object:foreignId:time:feedIds:originFeedId:) has not been implemented")
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try super.encode(to: encoder)
    }
}
