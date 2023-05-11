//
//  AppDelegate.m
//  GMOpenSSL(iOSDemo)
//
//  Created by lifei on 2023/5/11.
//

#import "AppDelegate.h"
#import "GMDemoVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GMDemoVC *mainVC = [[GMDemoVC alloc]init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
