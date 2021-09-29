//
//  AppDelegate.m
//  GMOpenSSL
//
//  Created by lifei on 2021/9/29.
//

#import "AppDelegate.h"
#import "GMViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GMViewController *mainVC = [[GMViewController alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
