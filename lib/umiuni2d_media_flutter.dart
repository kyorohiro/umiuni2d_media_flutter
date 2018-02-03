import 'dart:async';
import 'package:flutter/services.dart' as service;
import 'dart:io';


class Umiuni2dMedia {
  static const service.MethodChannel _channel = const service.MethodChannel('umiuni2d_media');
  static service.MethodChannel get channel => _channel;

  Future<String> platformVersion() async {
    return _channel.invokeMethod('getPlatformVersion');
  }

  Future<String> getPath() async {
    return _channel.invokeMethod('getPath');
  }

  Future<String> getAssetPath(String key) async {
    String path = (await getPath()).replaceAll(new RegExp(r"/$"), "");
    String keyPath = (path).replaceAll(new RegExp(r"^/"), "");
    return path + "/assets/" + key;
  }

  Future<String> prepareAssetPath(String key) async {
    String path = await getAssetPath(key);
    String dir = path.replaceAll(new RegExp(r"/[^/]*$"), path);
    await (new Directory(dir)).create(recursive: true);
    return path;
  }
  Future<Umiuni2dMedia> setupFromAssets(String key) async {
    String outputPath = await prepareAssetPath(key);
    print("=TEST="+outputPath);
    service.AssetBundle bundle =  (service.rootBundle != null) ? service.rootBundle : new service.NetworkAssetBundle(new Uri.directory(Uri.base.origin));
    service.ByteData data = await bundle.load(key);
    File output = new File(outputPath);
    await output.writeAsBytes(data.buffer.asUint8List(),flush: true);
    return this;
  }
  Map<String, Umiuni2dAudio> _audioMap = {};
  Future<Umiuni2dAudio> load(String id, String key) async {
    String path = await getAssetPath(key);
    Umiuni2dAudio ret =  new Umiuni2dAudio(id, path);
    await ret.load();
    _audioMap[id] = ret;
    return ret;
  }

  Umiuni2dAudio getAudio(String id) {
    return _audioMap[id];
  }
}


class Umiuni2dAudio {
  String _id;
  String _path;

  String get id => _id;
  String get path => _path;
  Umiuni2dAudio(String id, String path){
    this._id = id;
    this._path = path;
  }

  Future<String> load() async {
    return  await Umiuni2dMedia._channel.invokeMethod('load',[_id, _path]);
  }

  Future<String> play() async {
    return await Umiuni2dMedia._channel.invokeMethod('play',[_id]);
  }

  Future<String> pause() async {
    return Umiuni2dMedia.channel.invokeMethod('pause',[_id]);
  }

  Future<String> stop() async {
    return Umiuni2dMedia.channel.invokeMethod('stop',[_id]);
  }

  Future<String> seek(double currentTime) async {
    return Umiuni2dMedia.channel.invokeMethod('seek',[_id,currentTime]);
  }

  Future<num> getCurentTime() async {
    return Umiuni2dMedia.channel.invokeMethod('getCurentTime',[_id]);
  }

  Future<num> setVolume(num volume, num interval) async {
    return Umiuni2dMedia.channel.invokeMethod('setVolume',[_id, volume, interval]);
  }

  Future<num> getVolume() async {
    return Umiuni2dMedia.channel.invokeMethod('getVolume',[_id]);
  }
}