import UIKit
import Flutter
import GetStream
import StreamChatCore
import RxSwift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let appId: String = "<APP_ID>";
    let apiKey: String = "<API_KEY>";
    var feed: FlatFeed?; // this is necessary to ensure the callback fires, otherwise the reference may be GC'd
    var eventChannel: FlutterEventChannel?; // same
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "io.getstream/backend",
                                           binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as!  Dictionary<String, String>
            if call.method == "postMessage" {
                do {
                    try self!.postMessage(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_postMessage",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "setupChat" {
                do {
                    self!.setupChat(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_setupChat",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "setupChannel" {
                do {
                    self!.setupChannel(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_setupChannel",
                                             message: error.localizedDescription,
                                             details: nil))
                }
            } else if call.method == "postChatMessage" {
                do {
                    self!.postChatMessage(args: args, result: result)
                } catch let error {
                    result(FlutterError.init(code: "IOS_EXCEPTION_postChatMessage",
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
        let client = Client(apiKey: apiKey, appId: appId, token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "user")
        let activity = PostActivity(actor: User(id: args["user"]!), verb: "post", object: UUID().uuidString, message: args["message"]!)
        feed!.add(activity) {result in
            print("callback")
            print(result)
        }
        result(true)
    }
    
    private func setupChat(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        StreamChatCore.Client.config = .init(apiKey: apiKey, logOptions: .info)
        StreamChatCore.Client.shared.set(
            user: StreamChatCore.User(id: args["user"]!, name: args["user"]!),
            token: args["token"]!
        )
        result(true)
    }
    
    private func setupChannel(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let channelName = [args["user"]!, args["userToChatWith"]!].sorted().joined(separator: "-")
        let channel = Channel(type: ChannelType.messaging, id: channelName)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not type FlutterViewController")
        }
        eventChannel = FlutterEventChannel(name: "io.getstream/events/\(channelName)", binaryMessenger: controller.binaryMessenger)
        eventChannel!.setStreamHandler(ChatStreamHandler(channel: channel))
        
        result(channelName)
    }
    
    private func postChatMessage(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let channelName = [args["user"]!, args["userToChatWith"]!].sorted().joined(separator: "-")
        let channel = Channel(type: ChannelType.messaging, id: channelName)
        channel
            .send(message: Message(text: args["message"]!))
            .subscribe(onNext: { _ in
                result(true)
            }, onError: { err in
                print(err)
            })
    }
    
    private func getActivities(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        let client = Client(apiKey: apiKey, appId: appId, token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "user")
        self.feed!.get(typeOf: PostActivity.self, pagination: .limit(25)) { r in
            result(String(data: try! JSONEncoder().encode(try! r.get().results), encoding: .utf8)!)
        }
    }
    
    
    private func getTimeline(args: Dictionary<String, String>, result: @escaping FlutterResult) {
        print(args["token"]!)
        let client = Client(apiKey: apiKey, appId: appId, token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "timeline")
        self.feed!.get(typeOf: PostActivity.self, pagination: .limit(25)) { r in
            result(String(data: try! JSONEncoder().encode(try! r.get().results), encoding: .utf8)!)
        }
    }
    
    private func follow(args: Dictionary<String, String>) {
        let client = Client(apiKey: apiKey, appId: appId, token: args["token"]!)
        self.feed = client.flatFeed(feedSlug: "timeline")
        self.feed!.follow(toTarget: client.flatFeed(feedSlug: "user", userId: args["userToFollow"]!).feedId) { r in }
    }
}

final class PostActivity: EnrichedActivity<GetStream.User, String, DefaultReaction> {
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    var message: String
    
    init(actor: GetStream.User, verb: Verb, object: ObjectType, message: String) {
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

@objc class ChatStreamHandler: NSObject, FlutterStreamHandler {
    public let channel: Channel
    private let watch : Observable<ChannelResponse>
    
    init(channel: Channel) {
        self.channel = channel
        self.watch = channel.watch()
       
    }
    
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        channel.query(pagination: .messagesPageSize, options: .all).subscribe(onNext: { response in
            eventSink(String(data: try! JSONEncoder().encode(response.messages.map(self.formatMessage)), encoding: .utf8)!)
        })
        
        channel.onEvent(EventType.messageNew).subscribe(onNext: { event in
            if case .messageNew(let message, _, _, _, _) = event {
                eventSink(String(data: try! JSONEncoder().encode([self.formatMessage(message: message)]), encoding: .utf8)!)
            }
        })
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    private func formatMessage(message: Message) -> Dictionary<String, String> {
        return ["text": message.text, "userId": message.user.id]
    }
}
