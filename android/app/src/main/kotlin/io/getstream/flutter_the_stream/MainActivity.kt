package io.getstream.flutter_the_stream

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant
import io.getstream.client.Client



class MainActivity : FlutterActivity() {
    private val CHANNEL = "io.getstream/backend"

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getToken") {
                val token: String = getToken(call.arguments as String)
                result.success(token)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getToken(user: String): String {
        val client = Client.builder("7mpbqgq2kbh6", "uztrsbj2azvhxvcu2272dr8g4w4gj95ey3ayqvr9ewexvd6vd7bhgwjgnseq2wr7").build()

        return client.frontendToken(user).toString();
    }
}
