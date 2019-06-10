//
//  RCTOrientationListener.m
//
//  Created by Julien Sierra on 29/10/15.
//

#import "RCTOrientationController.h"
#import <React/RCTBridge.h>

@implementation RCTOrientationController

@synthesize bridge = _bridge;

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    }
    return self;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*) getOrientationStr: (int) orientationNumber
{
    NSString *orientationStr;
    switch (orientationNumber) {
        case 0:
            orientationStr = @"PORTRAIT";
            break;
        case 1:
            orientationStr = @"LANDSCAPE LEFT";
            break;
        case 2:
            orientationStr = @"PORTRAIT UPSIDE DOWN";
            break;
        case 3:
            orientationStr = @"LANDSCAPE RIGHT";
            break;
        default:
            orientationStr = @"UNKNOWN";
            break;
    }
    return orientationStr;
}

- (void)orientationDidChange:(NSNotification *)notification
{
    [_bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange" body:[self getData]];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
    callback([self getData]);
}

-(NSArray*)getData{
    int deviceOrientation = [self getDeviceOrientationAsNumber];
    int applicationOrientation = [self getApplicationOrientationAsNumber];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceStr = [currentDevice model];
    
    NSArray *orientationArray = @[[self getOrientationStr : deviceOrientation], [self getOrientationStr : applicationOrientation], deviceStr, [self getDimensions]];
    return orientationArray;
}


-(NSDictionary*) getDimensions {
    CGRect sizeRect = [[UIScreen mainScreen] bounds];
    NSArray *keys = [NSArray arrayWithObjects:@"width", @"height", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithFloat:sizeRect.size.width], [NSNumber numberWithFloat:sizeRect.size.height], nil];
    NSDictionary *size = [NSDictionary dictionaryWithObjects:objects
                                                     forKeys:keys];
    return size;
}


-(int)getDeviceOrientationAsNumber{
    UIDevice *currentDevice = [UIDevice currentDevice];
    UIDeviceOrientation orientation = [currentDevice orientation];
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return 0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return 2;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return 1;
            break;
        case UIDeviceOrientationLandscapeRight:
            return 3;
            break;
        default:
            return 0;
            break;
    }
    
}

-(int)getApplicationOrientationAsNumber{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return 0;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return 3;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return 2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return 1;
            break;
        default:
            return 0;
            break;
    }

}

RCT_EXPORT_METHOD(rotate:(int)rotation)
{
    if(rotation>3||rotation<1)rotation = 0;
    NSNumber *value;
    int orientation = ([self getApplicationOrientationAsNumber] + rotation)%4;

    switch (orientation) {
        case 1:
            value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
            break;
        case 2:
            value = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
            break;
        case 3:
            value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
            break;
        case 0:
            value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            break;
            
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        [UIViewController attemptRotationToDeviceOrientation];
        
    });
}

@end
