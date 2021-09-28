//
//  GMViewController.m
//  GMOpenSSL
//
//  Created by lifei on 07/12/2020.
//  Copyright (c) 2020 lifei. All rights reserved.
//

#import "GMViewController.h"
#include <openssl/md5.h>
#include <openssl/sha.h>
#import <openssl/evp.h>
#import "GMOpenSSL_Example-Swift.h"

@interface GMViewController ()

@end

@implementation GMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *orginStr = @"测试字符qwertyuio1234567890,./'";
    NSString *md5 = [self md5FromString:orginStr];
    NSString *sha256 = [self sha256FromString:orginStr];
    NSString *base64 = [self base64FromString:orginStr];
    
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendFormat:@"原始字符：%@\n", orginStr];
    [mStr appendFormat:@"MD5 值：%@\n", md5];
    [mStr appendFormat:@"SHA256 值：%@\n", sha256];
    [mStr appendFormat:@"BASE64 值：%@\n", base64];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    tmpLabel.numberOfLines = 0;
    tmpLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:tmpLabel];
    tmpLabel.text = mStr;
}

- (NSString *)md5FromString:(NSString *)string {
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSUTF8StringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[MD5_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    MD5(inStrg, lngth, result);

    unsigned int i;
    for (i = 0; i < MD5_DIGEST_LENGTH; i++) {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

- (NSString *)sha256FromString:(NSString *)string {
    unsigned char *inStrg = (unsigned char *) [[string dataUsingEncoding:NSUTF8StringEncoding] bytes];
    unsigned long lngth = [string length];
    unsigned char result[SHA256_DIGEST_LENGTH];
    NSMutableString *outStrg = [NSMutableString string];

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, inStrg, lngth);
    SHA256_Final(result, &sha256);

    unsigned int i;
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        [outStrg appendFormat:@"%02x", result[i]];
    }
    return [outStrg copy];
}

- (NSString *)base64FromString:(NSString *)string{
    BIO *mem = BIO_new(BIO_s_mem());
    BIO *b64 = BIO_new(BIO_f_base64());
    
    mem = BIO_push(b64, mem);

    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = stringData.length;
    void *buffer = (void *) [stringData bytes];
    int bufferSize = (int)MIN(length, INT_MAX);

    NSUInteger count = 0;

    BOOL error = NO;

    // Encode the data
    while (!error && count < length) {
        int result = BIO_write(mem, buffer, bufferSize);
        if (result <= 0) {
            error = YES;
        }
        else {
            count += result;
            buffer = (void *) [stringData bytes] + count;
            bufferSize = (int)MIN((length - count), INT_MAX);
        }
    }

    int flush_result = BIO_flush(mem);
    if (flush_result != 1) {
        return nil;
    }

    char *base64Pointer;
    NSUInteger base64Length = (NSUInteger) BIO_get_mem_data(mem, &base64Pointer);

    NSData *base64data = [NSData dataWithBytesNoCopy:base64Pointer length:base64Length freeWhenDone:NO];
    NSString *base64String = [[NSString alloc] initWithData:base64data encoding:NSUTF8StringEncoding];

    BIO_free_all(mem);
    return base64String;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    GMSwiftVC *gmVC = [[GMSwiftVC alloc] init];
    [self presentViewController:gmVC animated:YES completion:nil];
}


@end
