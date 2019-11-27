package io.getstream.flutter_the_stream

import android.os.Bundle
import com.fasterxml.jackson.databind.ObjectMapper

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant
import io.getstream.client.Client
import io.getstream.cloud.CloudClient
import io.getstream.core.models.Activity
import java.util.*
import io.getstream.core.options.Limit
import org.json.JSONObject


class MainActivity : FlutterActivity() {
  private val CHANNEL = "io.getstream/backend"

  override fun onCreate(savedInstanceState: Bundle?) {

    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "postMessage") {
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
      } else {
        result.notImplemented()
      }
    }
  }

  private fun postMessage(user: String, token: String, message: String) {
    val client = CloudClient.builder("7mpbqgq2kbh6", token, user).build()

    val feed = client.flatFeed("user")
    feed.addActivity(
      Activity.builder().actor(user).verb("post").`object`(UUID.randomUUID().toString()).extraField(
        "message",
        message
      ).build()
    ).join()
  }

  private fun getActivities(user: String, token: String): List<Activity> {
    val client = CloudClient.builder("7mpbqgq2kbh6", token, user).build()

    return client.flatFeed("user").getActivities(Limit(25)).join()
  }

  private fun getTimeline(user: String, token: String): List<Activity> {
    val client = CloudClient.builder("7mpbqgq2kbh6", token, user).build()

    return client.flatFeed("timeline").getActivities(Limit(25)).join()
  }

  private fun follow(user: String, token: String, userToFollow: String): Boolean {
    val client = CloudClient.builder("7mpbqgq2kbh6", token, user).build()

    client.flatFeed("timeline").follow(client.flatFeed("user", userToFollow)).join()
    return true
  }
}
