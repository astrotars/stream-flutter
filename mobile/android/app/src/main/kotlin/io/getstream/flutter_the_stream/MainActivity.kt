package io.getstream.flutter_the_stream

import android.os.Bundle
import com.fasterxml.jackson.databind.ObjectMapper
import com.getstream.sdk.chat.StreamChat
import com.getstream.sdk.chat.enums.FilterObject
import com.getstream.sdk.chat.enums.QuerySort
import com.getstream.sdk.chat.model.Event
import com.getstream.sdk.chat.model.ModelType
import com.getstream.sdk.chat.rest.Message
import com.getstream.sdk.chat.rest.User
import com.getstream.sdk.chat.rest.core.ChatChannelEventHandler
import com.getstream.sdk.chat.rest.interfaces.*
import com.getstream.sdk.chat.rest.request.ChannelQueryRequest
import com.getstream.sdk.chat.rest.request.ChannelWatchRequest
import com.getstream.sdk.chat.rest.request.QueryChannelsRequest
import com.getstream.sdk.chat.rest.response.ChannelState
import com.getstream.sdk.chat.rest.response.CompletableResponse
import com.getstream.sdk.chat.rest.response.MessageResponse
import com.getstream.sdk.chat.rest.response.QueryChannelsResponse

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.getstream.cloud.CloudClient
import io.getstream.core.models.Activity
import java.util.*
import io.getstream.core.options.Limit
import io.flutter.plugin.common.EventChannel


class MainActivity : FlutterActivity() {
  private val CHANNEL = "io.getstream/backend"
  private val API_KEY = "<API_KEY>"
  private val eventChannels: MutableMap<String, EventChannel> = mutableMapOf()

  override fun onCreate(savedInstanceState: Bundle?) {

    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "setupChat") {
        setupChat(
          call.argument<String>("user")!!,
          call.argument<String>("token")!!
        )
        result.success(true)
      } else if (call.method == "postMessage") {
        postMessage(
          call.argument<String>("user")!!,
          call.argument<String>("token")!!,
          call.argument<String>("message")!!
        )
        result.success(true)
      } else if (call.method == "getActivities") {
        val activities = getActivities(
          call.argument<String>("user")!!,
          call.argument<String>("token")!!
        )
        result.success(ObjectMapper().writeValueAsString(activities))
      } else if (call.method == "getTimeline") {
        val activities = getTimeline(
          call.argument<String>("user")!!,
          call.argument<String>("token")!!
        )
        result.success(ObjectMapper().writeValueAsString(activities))
      } else if (call.method == "follow") {
        follow(
          call.argument<String>("user")!!,
          call.argument<String>("token")!!,
          call.argument<String>("userToFollow")!!
        )
        result.success(true)
      } else if (call.method == "postChatMessage") {
        postChatMessage(
          result,
          call.argument<String>("user")!!,
          call.argument<String>("userToChatWith")!!,
          call.argument<String>("message")!!,
          call.argument<String>("token")!!
        )
      } else if (call.method == "postChannelMessage") {
        postChannelMessage(
          result,
          call.argument<String>("channelId")!!,
          call.argument<String>("message")!!
        )
      } else if (call.method == "setupPrivateChannel") {
        setupPrivateChannel(
          result,
          call.argument<String>("user")!!,
          call.argument<String>("userToChatWith")!!,
          call.argument<String>("token")!!
        )
      } else if (call.method == "setupChannel") {
        setupChannel(
          result,
          call.argument<String>("channelId")!!
        )
      } else if (call.method == "getChannels") {
        getChannels(result)
      } else {
        result.notImplemented()
      }
    }
  }

  private fun setupChat(user: String, token: String) {
    StreamChat.init(API_KEY, applicationContext)
    val client = StreamChat.getInstance(this.application)
    client.disconnect() // todo: document this in previous posts
    client.setUser(User(user), token)
  }

  private fun postMessage(user: String, token: String, message: String) {
    val client = CloudClient.builder(API_KEY, token, user).build()

    val feed = client.flatFeed("user")
    feed.addActivity(
      Activity
        .builder()
        .actor("SU:${user}")
        .verb("post")
        .`object`(UUID.randomUUID().toString())
        .extraField("message", message)
        .build()
    ).join()
  }

  private fun getActivities(user: String, token: String): List<Activity> {
    val client = CloudClient.builder(API_KEY, token, user).build()

    return client.flatFeed("user").getActivities(Limit(25)).join()
  }

  private fun getTimeline(user: String, token: String): List<Activity> {
    val client = CloudClient.builder(API_KEY, token, user).build()

    return client.flatFeed("timeline").getActivities(Limit(25)).join()
  }

  private fun follow(user: String, token: String, userToFollow: String): Boolean {
    val client = CloudClient.builder(API_KEY, token, user).build()

    client.flatFeed("timeline").follow(client.flatFeed("user", userToFollow)).join()
    return true
  }

  private fun getChannels(result: MethodChannel.Result) {
    val client = StreamChat.getInstance(application)
    client.queryChannels(QueryChannelsRequest(FilterObject(hashMapOf("type" to ModelType.channel_livestream)), QuerySort()), object : QueryChannelListCallback {
      override fun onSuccess(response: QueryChannelsResponse) {
        result.success(ObjectMapper().writeValueAsString(response.channels.map { it.id }))
      }

      override fun onError(errMsg: String?, errCode: Int) {
        // handle errors
      }
    })
  }

  private fun setupPrivateChannel(result: MethodChannel.Result, user: String, userToChatWith: String, token: String) {
    val application = this.application
    val channelId = listOf(user, userToChatWith).sorted().joinToString("-")
    var subId: Int? = null
    val client = StreamChat.getInstance(application)
    val channel = client.channel(ModelType.channel_messaging, channelId, hashMapOf<String, Any>("members" to listOf(user, userToChatWith)))
    val eventChannel = EventChannel(flutterView, "io.getstream/events/${channelId}")

    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(listener: Any, eventSink: EventChannel.EventSink) {
        channel.query(ChannelQueryRequest().withMessages(25).withWatch(), object : QueryChannelCallback {
          override fun onSuccess(response: ChannelState) {
            eventSink.success(ObjectMapper().writeValueAsString(response.messages))
          }

          override fun onError(errMsg: String, errCode: Int) {
            eventSink.error(errCode.toString(), errMsg, null)
          }
        })

        subId = channel.addEventHandler(object : ChatChannelEventHandler() {
          override fun onMessageNew(event: Event) {
            eventSink.success(ObjectMapper().writeValueAsString(listOf(event.message)))
          }
        })
      }

      override fun onCancel(listener: Any) {
        channel.stopWatching(object : CompletableCallback {
          override fun onSuccess(response: CompletableResponse?) {
          }

          override fun onError(errMsg: String, errCode: Int) {
            // handle errors
          }
        })
        channel.removeEventHandler(subId)
        eventChannels.remove(channelId)
      }
    })

    eventChannels[channelId] = eventChannel

    result.success(channelId)
  }

  private fun setupChannel(result: MethodChannel.Result, channelId: String) {
    val application = this.application
    var subId: Int? = null
    val client = StreamChat.getInstance(application)
    val channel = client.channel(ModelType.channel_livestream, channelId)
    val eventChannel = EventChannel(flutterView, "io.getstream/events/${channelId}")

    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(listener: Any, eventSink: EventChannel.EventSink) {
        channel.query(ChannelQueryRequest().withMessages(25).withWatch(), object : QueryChannelCallback {
          override fun onSuccess(response: ChannelState) {
            eventSink.success(ObjectMapper().writeValueAsString(response.messages))
          }

          override fun onError(errMsg: String, errCode: Int) {
            // handle errors
          }
        })

        subId = channel.addEventHandler(object : ChatChannelEventHandler() {
          override fun onMessageNew(event: Event) {
            eventSink.success(ObjectMapper().writeValueAsString(listOf(event.message)))
          }
        })
      }

      override fun onCancel(listener: Any) {
        channel.stopWatching(object : CompletableCallback {
          override fun onSuccess(response: CompletableResponse?) {
          }

          override fun onError(errMsg: String, errCode: Int) {
            // handle errors
          }
        })
        channel.removeEventHandler(subId)
        eventChannels.remove(channelId)
      }
    })

    eventChannels[channelId] = eventChannel

    result.success(channelId)
  }

  private fun postChatMessage(result: MethodChannel.Result, user: String, userToChatWith: String, message: String, token: String) {
    val client = StreamChat.getInstance(this.application)
    val channelId = listOf(user, userToChatWith).sorted().joinToString("-")
    val channel = client.channel(ModelType.channel_messaging, channelId, hashMapOf<String, Any>("members" to listOf(user, userToChatWith)))
    val streamMessage = Message()
    streamMessage.text = message
    channel.sendMessage(streamMessage, object : MessageCallback {
      override fun onSuccess(response: MessageResponse?) {
        result.success(true)
      }

      override fun onError(errMsg: String?, errCode: Int) {
        // handle errors
      }
    })
  }

  private fun postChannelMessage(result: MethodChannel.Result, channelId: String, message: String) {
    val client = StreamChat.getInstance(this.application)
    val channel = client.channel(ModelType.channel_livestream, channelId)
    val streamMessage = Message()
    streamMessage.text = message
    channel.sendMessage(streamMessage, object : MessageCallback {
      override fun onSuccess(response: MessageResponse?) {
        result.success(true)
      }

      override fun onError(errMsg: String?, errCode: Int) {
        // handle errors
      }
    })
  }
}
