package net.umiuni2d.umiuni2dmediaflutter;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Umiuni2dMediaFlutterPlugin
 */
public class Umiuni2dMediaFlutterPlugin implements MethodCallHandler {
  private final Registrar mRegistrar;
  private Map<String,MediaPlayer> mMediaPlayer;
  private float mVolume = 0.0f;

  Umiuni2dMediaFlutterPlugin(Registrar registrar){
    mMediaPlayer = new HashMap<>();
    mRegistrar = registrar;
    AudioManager am = (AudioManager)registrar.activity().getSystemService(Context.AUDIO_SERVICE);
    int volumeLevel = am.getStreamVolume(AudioManager.STREAM_MUSIC);
    int maxVolume = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
    mVolume = volumeLevel/maxVolume;
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "umiuni2d_media");
    channel.setMethodCallHandler(new Umiuni2dMediaFlutterPlugin(registrar));

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String methodName = call.method;
    if(methodName == "" || methodName == null) {
      return;
    }

    if (call.method.equals("getPath")) {
      result.success(mRegistrar.context().getFilesDir().getPath());
      return;
    }

    List args = (List)call.arguments;
    String key = (String) args.get(0);
    MediaPlayer player = null;
    if(mMediaPlayer.containsKey(key)) {
      player = mMediaPlayer.get(key);
    }
    android.util.Log.v("TEST", ""+key);
    if(call.method.equals("load")) {
      if(player != null) {
        player.stop();
        player.release();
      }
      try {
        String path = (String) args.get(1);
        player = new MediaPlayer();///.create(mRegistrar.activity().getApplicationContext(), Uri.fromFile(new File(path)));
        mMediaPlayer.put(key, player);
        player.setDataSource(path);
        android.util.Log.v("TEST", path);
        player.prepare();
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    }

    if(call.method.equals("play")) {
      try {
        player.start();
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("pause")) {
      try {
        player.pause();
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("stop")) {
      try {
        player.stop();
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("seek")) {
      try {
        double v = ((Number)args.get(1)).doubleValue();
        v = v*1000;
        player.seekTo((int)v);
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("getCurentTime")) {
      try {
        int v = player.getCurrentPosition();
        result.success(((double)v)/1000.0);
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("setVolume")) {
      try {
        float volume = ((Number)args.get(1)).floatValue();
        mVolume = volume;
        player.setVolume(mVolume, mVolume);
        result.success("{\"status\":\"passed\"}");
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    } else if(call.method.equals("getVolume")) {
      try {
        result.success(mVolume);
      } catch(Exception e) {
        result.success("{\"status\":\"failed\"}");
      }
      return;
    }
    result.notImplemented();
  }
}
