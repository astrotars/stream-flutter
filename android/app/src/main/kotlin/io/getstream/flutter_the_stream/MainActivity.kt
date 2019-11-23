package io.getstream.flutter_the_stream

import android.os.Bundle
import com.fasterxml.jackson.databind.ObjectMapper

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant
import io.getstream.client.Client
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
      if (call.method == "getToken") {
        val token: String = getToken(call.arguments as String)
        result.success(token)
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
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getToken(user: String): String {
    val client =
      Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

    return client.frontendToken(user).toString();
  }

  private fun postMessage(user: String, token: String, message: String) {
    // todo: token is ignored since we don't have a way to use it via java lib
    val client =
      Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

    val feed = client.flatFeed("user", user)
    feed.addActivity(
      Activity.builder().actor(user).verb("post").`object`(UUID.randomUUID().toString()).extraField("message", message).build()
    ).join()
  }

  private fun getActivities(user: String, token: String): List<Activity> {
    // todo: token is ignored since we don't have a way to use it via java lib
    val client =
      Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

    return client.flatFeed("user", user).getActivities(Limit(25)).join()
  }

  private fun getTimeline(user: String, token: String): List<Activity> {
    // todo: token is ignored since we don't have a way to use it via java lib
    val client =
      Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

    return client.flatFeed("timeline", user).getActivities(Limit(25)).join()
  }

  private fun follow(user: String, token: String, userToFollow: String): Boolean {
    // todo: token is ignored since we don't have a way to use it via java lib
    val client =
      Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

    client.flatFeed("timeline", user).follow(client.flatFeed("user", userToFollow)).join()
    return true
  }
}
