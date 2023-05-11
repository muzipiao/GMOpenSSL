//
//  GMOsxDemoVC.m
//  GMOpenSSL(OsxDemo)
//
//  Created by lifei on 2023/5/11.
//

#import "GMOsxDemoVC.h"
#import "OpenSSL/OpenSSL.h"

@interface GMOsxDemoVC ()

@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, strong) NSScrollView *scrollView;

@end

@implementation GMOsxDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    
    NSString *originStr = @"测试字符qwertyuio1234567890,./'";
    NSData *originData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *md5 = [self md5FromString:originStr];
    NSString *sha256 = [self sha256FromString:originStr];
    NSString *base64 = [self base64FromString:originStr];
    NSArray<NSString *> *sm2Keys = [self generateKey];
    NSString *sm3Hash = [self sm3HashWithData:originData];
    NSString *sm4Key = [self createSm4Key];
    NSData *sm4Data = [self sm4EcbEncryptData:originData key:sm4Key];
    NSString *sm4Hex = [self hexStringFromData:sm4Data];
    
    NSMutableString *mStr = [NSMutableString string];
    [mStr appendFormat:@"\n原始字符：\n%@", originStr];
    [mStr appendFormat:@"\nMD5结果：\n%@", md5];
    [mStr appendFormat:@"\nSHA256结果：\n%@", sha256];
    [mStr appendFormat:@"\nBase64结果：\n%@", base64];
    [mStr appendFormat:@"\n生成SM2公钥：\n%@", sm2Keys.firstObject];
    [mStr appendFormat:@"\n生成SM2私钥：\n%@", sm2Keys.lastObject];
    [mStr appendFormat:@"\nSM3哈希结果：\n%@", sm3Hash];
    [mStr appendFormat:@"\nSM4密钥Key：\n%@", sm4Key];
    [mStr appendFormat:@"\nSM4加密结果：\n%@", sm4Hex];
    self.textView.string = mStr;
}

// 创建视图
- (void)createUI {
    NSSize mainSize = self.view.frame.size;
    self.textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, mainSize.width, mainSize.height)];
    [self.view addSubview:self.textView];
    self.textView.backgroundColor = [NSColor whiteColor];
    self.textView.editable = NO;
    self.textView.textColor = [NSColor blackColor];
    [self.textView setMinSize:NSMakeSize(0.0, self.view.frame.size.height - 80)];
    [self.textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.textView setVerticallyResizable:YES];
    [self.textView setHorizontallyResizable:NO];
    [self.textView setAutoresizingMask:NSViewWidthSizable];
    [[self.textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.textView textContainer] setWidthTracksTextView:YES];
    [self.textView setFont:[NSFont systemFontOfSize:14]];
    [self.textView setEditable:NO];
    //NSScrollView
    self.scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, mainSize.width, mainSize.height)];
    [self.scrollView setBorderType:NSNoBorder];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.scrollView setDocumentView:self.textView];
    [self.view addSubview:self.scrollView];
}

// 测试 MD5
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

// 测试 SHA256
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

// 测试 Base64
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

// 测试 SM2
- (NSArray<NSString *> *)generateKey{
    NSMutableArray<NSString *> *mList = [NSMutableArray arrayWithCapacity:2];
    EC_GROUP *group = EC_GROUP_new_by_curve_name(NID_sm2); // 椭圆曲线
    EC_KEY *key = NULL; // 密钥对
    do {
        key = EC_KEY_new();
        if (!EC_KEY_set_group(key, group)) {
            break;
        }
        if (!EC_KEY_generate_key(key)) {
            break;
        }
        const EC_POINT *pub_key = EC_KEY_get0_public_key(key);
        const BIGNUM *pri_key = EC_KEY_get0_private_key(key);
        
        char *hex_pub = EC_POINT_point2hex(group, pub_key, EC_KEY_get_conv_form(key), NULL);
        char *hex_pri = BN_bn2hex(pri_key);
        
        NSString *publicKey = [NSString stringWithCString:hex_pub encoding:NSUTF8StringEncoding];
        NSString *priHex = [NSString stringWithCString:hex_pri encoding:NSUTF8StringEncoding];
        
        [mList addObject:publicKey];
        [mList addObject:priHex];
        
        OPENSSL_free(hex_pub);
        OPENSSL_free(hex_pri);
    } while (NO);
    
    if (group != NULL) EC_GROUP_free(group);
    EC_KEY_free(key);
    
    return mList.copy;
}

// 测试 SM3
- (nullable NSString *)sm3HashWithData:(NSData *)plainData{
    if (plainData.length == 0) {
        return nil;
    }
    // 原文
    uint8_t *pData = (uint8_t *)plainData.bytes;
    // 摘要结果
    SM3_CTX ctx;
    unsigned char output[SM3_DIGEST_LENGTH];
    memset(output, 0, SM3_DIGEST_LENGTH);
    do {
        if (!sm3_init(&ctx)) {
            break;
        }
        size_t pDataLen = plainData.length;
        if (!sm3_update(&ctx, pData, pDataLen)) {
            break;
        }
        if (!sm3_final(output, &ctx)) {
            break;
        }
        memset(&ctx, 0, sizeof(SM3_CTX));
    } while (NO);
    // 转为 16 进制
    NSMutableString *digestStr = [NSMutableString stringWithCapacity:SM3_DIGEST_LENGTH];
    for (NSInteger i = 0; i < SM3_DIGEST_LENGTH; i++) {
        NSString *subStr = [NSString stringWithFormat:@"%X",output[i]&0xff];
        if (subStr.length == 1) {
            [digestStr appendFormat:@"0%@", subStr];
        }else{
            [digestStr appendString:subStr];
        }
    }
    return digestStr;
}

// 生成 SM4 密钥
- (nullable NSString *)createSm4Key {
    NSInteger len = SM4_BLOCK_SIZE;
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:(len * 2)];
    
    uint8_t bytes[len];
    int status = SecRandomCopyBytes(kSecRandomDefault, (sizeof bytes)/(sizeof bytes[0]), &bytes);
    if (status == errSecSuccess) {
        for (int i = 0; i < (sizeof bytes)/(sizeof bytes[0]); i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xff];///16进制数
            if (hexStr.length == 1) {
                [result appendFormat:@"0%@", hexStr];
            }else{
                [result appendString:hexStr];
            }
        }
        return result.copy;
    }
    return @"";
}

// SM4 加密
- (nullable NSData *)sm4EcbEncryptData:(NSData *)plainData key:(NSString *)key{
    if (plainData.length == 0 || key.length != SM4_BLOCK_SIZE * 2) {
        return nil;
    }
    
    uint8_t *plain_obj = (uint8_t *)plainData.bytes;
    size_t plain_obj_len = plainData.length;
    
    // 计算填充长度
    int pad_en = SM4_BLOCK_SIZE - plain_obj_len % SM4_BLOCK_SIZE;
    size_t result_len = plain_obj_len + pad_en;
    // PKCS7 填充
    uint8_t *p_text = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    memcpy(p_text, plain_obj, plain_obj_len);
    memset(p_text + plain_obj_len, pad_en, pad_en);
    
    uint8_t *result = (uint8_t *)OPENSSL_zalloc((int)(result_len + 1));
    int group_num = (int)(result_len / SM4_BLOCK_SIZE);
    // 密钥 key Hex 转 uint8_t
    NSData *kData = [self dataFromHexString:key];
    uint8_t *k_text = (uint8_t *)kData.bytes;
    SM4_KEY sm4Key;
    SM4_set_key(k_text, &sm4Key);
    // 循环加密
    for (NSInteger i = 0; i < group_num; i++) {
        uint8_t block[SM4_BLOCK_SIZE];
        memcpy(block, p_text + i * SM4_BLOCK_SIZE, SM4_BLOCK_SIZE);
        
        SM4_encrypt(block, block, &sm4Key);
        memcpy(result + i * SM4_BLOCK_SIZE, block, SM4_BLOCK_SIZE);
    }
    
    NSData *cipherData = [NSData dataWithBytes:result length:result_len];
    
    OPENSSL_free(p_text);
    OPENSSL_free(result);
    
    return cipherData;
}

// 将十六进制字符串转换为NSData类型数据
- (nullable NSData *)dataFromHexString:(NSString *)hexStr{
    if (!hexStr || hexStr.length < 2) {
        return nil;
    }
    long buf_len = 0;
    uint8_t *tmp_buf = OPENSSL_hexstr2buf(hexStr.UTF8String, &buf_len);
    NSData *tmpData = [NSData dataWithBytes:tmp_buf length:buf_len];
    OPENSSL_free(tmp_buf);
    return tmpData;
}

// 将NSData类型数据转换为十六进制字符串
- (nullable NSString *)hexStringFromData:(NSData *)data{
    if (!data || data.length == 0) {
        return nil;
    }
    char *tmp = OPENSSL_buf2hexstr((uint8_t *)data.bytes, data.length);
    NSString *tmpHex = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    tmpHex = [tmpHex stringByReplacingOccurrencesOfString:@":" withString:@""];
    OPENSSL_free(tmp);
    return tmpHex;
}


@end
