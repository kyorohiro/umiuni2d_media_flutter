#import "Umiuni2dMediaFlutterPlugin.h"
#import <AVFoundation/AVFoundation.h>

@implementation Umiuni2dMediaFlutterPlugin

- (id)init{
    self = [super init];
    self.players = [NSMutableDictionary dictionary];
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
    methodChannelWithName:@"umiuni2d_media"
    binaryMessenger:[registrar messenger]];
    Umiuni2dMediaFlutterPlugin* instance = [[Umiuni2dMediaFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *methodName = call.method;
    if(methodName == nil || [methodName length] == 0) {
        result(FlutterMethodNotImplemented);
    }

    if([methodName isEqualToString:@"getPath"]){
        result(NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0]);
        return;
    }

    NSArray *args = call.arguments;
    NSArray *playerId = args[0];



    if([methodName isEqualToString:@"load"]){
        NSString *path = args[1];
        NSError* error = nil;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.players[playerId] = player;

        if(!player) {
            result(@"{\"status\":\"failed\"}");
            return;
        } else {
            result(@"{\"status\":\"passed\"}");
            return;
        }
    } else {
        BOOL hasPlayerId = [[self.players allKeys] containsObject:playerId];
        if(false == hasPlayerId) {
            result(@"{\"status\":\"failed\"}");
            return;
        }
        AVAudioPlayer* player = self.players[playerId];
        if(!player) {
            result(@"{\"status\":\"failed\"}");
            return;
        }
        if([methodName isEqualToString:@"play"]){
            BOOL ret = [player play];
            if(!ret) {
                result(@"{\"status\":\"failed\"}");
            } else {
                result(@"{\"status\":\"passed\"}");
            }
            return;
        } else if([methodName isEqualToString:@"pause"]){
            [player pause];
            result(@"{\"status\":\"passed\"}");
            return;
        } else if([methodName isEqualToString:@"stop"]){
            [player stop];
            result(@"{\"status\":\"passed\"}");
            return;
        } else if([methodName isEqualToString:@"seek"]){
            NSNumber *num = args[1];
            player.currentTime = [num doubleValue];
            result(@"{\"status\":\"passed\"}");
            return;
        } else if([methodName isEqualToString:@"getCurentTime"]){
            result([NSString stringWithFormat:@"{\"status\":\"passed\", \"value\":%lf}", player.currentTime]);
            return;
        } else if([methodName isEqualToString:@"setVolume"]){
            NSArray *args = call.arguments;
            NSNumber *volume = args[1];
            NSNumber *interval = args[2];
            [player setVolume:[volume floatValue] fadeDuration:[interval doubleValue]];
            result(@"{\"status\":\"passed\"}");
            return;
        } else if([methodName isEqualToString:@"getVolume"]){
            result([NSString stringWithFormat:@"{\"status\":\"passed\", \"value\":%lf}", player.volume]);
            return;
        }
    }
    result(FlutterMethodNotImplemented);
}

@end
