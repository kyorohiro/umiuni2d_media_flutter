import 'dart:async';
import 'package:flutter/services.dart' as service;
import 'package:umiuni2d_media/umiuni2d_media.dart' as umi;
import 'dart:io';
import 'dart:convert' as conv;


class MediaManager extends umi.MediaManager{
  static const service.MethodChannel _channel = const service.MethodChannel('umiuni2d_media');
  static service.MethodChannel get channel => _channel;

  String _assetsRoot;
  String get assetsRoot => _assetsRoot;

  set assetsRoot(String v) {
    v = v.replaceAll(new RegExp(r"/$"), "");
    v = v.replaceAll(new RegExp(r"^/"), "");
    _assetsRoot = v;
  }

  MediaManager(String assetsRoot) {
    this.assetsRoot = assetsRoot;
  }

  Future<String> getPath() async {
    return _channel.invokeMethod('getPath');
  }

  Future<String> getAssetPath(String key) async {
    String p = (await getPath()).replaceAll(new RegExp(r"/$"), "");
    String k = key.replaceAll(new RegExp(r"^/"), "");
    return p + "/"+this.assetsRoot+"/" + k;
  }

  Future<String> _prepareAssetPath(String key) async {
    String path = await getAssetPath(key);
    String dir = path.replaceAll(new RegExp(r"/[^/]*$"), path);
    await (new Directory(dir)).create(recursive: true);
    return path;
  }

  @override
  Future<MediaManager> setupMedia(String key) async {
    String outputPath = await _prepareAssetPath(key);
    service.AssetBundle bundle =  (service.rootBundle != null) ? service.rootBundle : new service.NetworkAssetBundle(new Uri.directory(Uri.base.origin));
    service.ByteData data = await bundle.load("/"+this.assetsRoot+"/"+key);
    File output = new File(outputPath);
    await output.writeAsBytes(data.buffer.asUint8List(),flush: true);
    return this;
  }

  Map<String, AudioPlayer> _audioMap = {};

  @override
  Future<AudioPlayer> loadAudioPlayer(String id, String key) async {
    print("call load Au 1");
    AudioPlayer player = await createAudioPlayer(id, key);
    print("call load Au 2");
    await player.prepare();
    return player;
  }

  @override
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

  @override
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

  @override
  Future<AudioPlayer> prepare() async {
    String resultSrc = await MediaManager._channel.invokeMethod('load',[_id, _path]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<AudioPlayer> play() async {
    String resultSrc = await MediaManager._channel.invokeMethod('play',[_id]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<AudioPlayer> pause() async {
    String resultSrc = await MediaManager.channel.invokeMethod('pause',[_id]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<AudioPlayer> stop() async {
    String resultSrc = await MediaManager.channel.invokeMethod('stop',[_id]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<AudioPlayer> seek(double currentTime) async {
    if(currentTime < 0.0) {
      currentTime = 0.0;
    }
    String resultSrc = await MediaManager.channel.invokeMethod('seek',[_id,currentTime]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<double> getCurrentTime() async {
    return MediaManager.channel.invokeMethod('getCurentTime',[_id]);
  }

  @override
  Future<AudioPlayer> setVolume(double volume) async {
    if(volume < 0) {
      volume = 0.0;
    }
    String resultSrc = await MediaManager.channel.invokeMethod('setVolume',[_id, volume, 0.1]);
    Map<String,String> resultObj = conv.JSON.decode(resultSrc);
    if(resultObj["status"] != "passed") {
      throw resultSrc;
    }
    return this;
  }

  @override
  Future<double> getVolume() async {
    return MediaManager.channel.invokeMethod('getVolume',[_id]);
  }
}