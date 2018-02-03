import 'dart:async';
import 'package:flutter/services.dart' as service;
import 'package:umiuni2d_media/umiuni2d_media.dart' as umi;
import 'dart:io';


class MediaManager extends umi.MediaManager{
  static const service.MethodChannel _channel = const service.MethodChannel('umiuni2d_media');
  static service.MethodChannel get channel => _channel;

  String assetsRoot;
  MediaManager(this.assetsRoot) {
  }
  Future<String> getPath() async {
    return _channel.invokeMethod('getPath');
  }

  Future<String> getAssetPath(String key) async {
    String path = (await getPath()).replaceAll(new RegExp(r"/$"), "");
    String keyPath = (path).replaceAll(new RegExp(r"^/"), "");
    String assets = assetsRoot.replaceAll(new RegExp(r"/$"), "");
    assets = assets.replaceAll(new RegExp(r"^/"), "");
    return path + "/"+assets+"/" + key;
  }

  Future<String> _prepareAssetPath(String key) async {
    String path = await getAssetPath(key);
    String dir = path.replaceAll(new RegExp(r"/[^/]*$"), path);
    await (new Directory(dir)).create(recursive: true);
    return path;
  }

  Future<MediaManager> setupMedia(String key) async {
    String outputPath = await _prepareAssetPath(key);
    print("=TEST="+outputPath);
    service.AssetBundle bundle =  (service.rootBundle != null) ? service.rootBundle : new service.NetworkAssetBundle(new Uri.directory(Uri.base.origin));
    service.ByteData data = await bundle.load(key);
    File output = new File(outputPath);
    await output.writeAsBytes(data.buffer.asUint8List(),flush: true);
    return this;
  }

  Map<String, AudioPlayer> _audioMap = {};
  Future<AudioPlayer> loadAudioPlayer(String id, String key) async {
    AudioPlayer player = await createAudioPlayer(id, key);
    player.prepare();
    return player;
  }

  Future<AudioPlayer> createAudioPlayer(String id, String key) async {
    String path = await getAssetPath(key);
    File f = new File(path);
    if(false == await f.exists()) {
      setupMedia(key);
    }
    AudioPlayer ret =  new AudioPlayer(id, path);
    _audioMap[id] = ret;
    return ret;
  }

  AudioPlayer getAudioPlayer(String id) {
    return _audioMap[id];
  }
}


class AudioPlayer extends umi.AudioPlayer  {
  String _id;
  String _path;

  String get playerId => _id;
  String get url => _path;

  AudioPlayer(String id, String path){
    this._id = id;
    this._path = path;
  }

  Future<AudioPlayer> prepare() async {
    await MediaManager._channel.invokeMethod('load',[_id, _path]);
    return this;
  }

  Future<AudioPlayer> play() async {
    await MediaManager._channel.invokeMethod('play',[_id]);
    return this;
  }

  Future<AudioPlayer> pause() async {
    await MediaManager.channel.invokeMethod('pause',[_id]);
    return this;
  }

  Future<AudioPlayer> stop() async {
    await MediaManager.channel.invokeMethod('stop',[_id]);
    return this;
  }

  Future<AudioPlayer> seek(double currentTime) async {
    if(currentTime < 0.0) {
      currentTime = 0.0;
    }
    await MediaManager.channel.invokeMethod('seek',[_id,currentTime]);
    return this;
  }

  Future<double> getCurrentTime() async {
    return MediaManager.channel.invokeMethod('getCurentTime',[_id]);
  }

  Future<AudioPlayer> setVolume(double volume) async {
    if(volume < 0) {
      volume = 0.0;
    }
    await MediaManager.channel.invokeMethod('setVolume',[_id, volume, 0.1]);
    return this;
  }

  Future<double> getVolume() async {
    return MediaManager.channel.invokeMethod('getVolume',[_id]);
  }
}