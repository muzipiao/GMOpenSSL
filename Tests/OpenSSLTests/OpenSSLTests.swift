import XCTest
@testable import OpenSSL

final class OpenSSLTests: XCTestCase {
    func testExample() throws {
        XCTAssertTrue(OPENSSL_VERSION_TEXT.lowercased().hasPrefix("openssl"), "OpenSSL 1.1.1t  7 Feb 2023")
        XCTAssertTrue(OPENSSL_VERSION_NUMBER > 1, "OpenSSL 版本大于1")
    }
    
    // 测试 SM2 生成KEY
    func testGenerateSm2Keys() {
        let group = EC_GROUP_new_by_curve_name(NID_sm2)
        XCTAssertNotNil(group, "NID_sm2 曲线存在")
        let key = EC_KEY_new()
        let setKeyRet = EC_KEY_set_group(key, group)
        XCTAssertTrue(setKeyRet != 0, "密钥对设置")
        let genKeyRet = EC_KEY_generate_key(key)
        XCTAssertTrue(genKeyRet != 0, "密钥对生成")
        let pubKey = EC_KEY_get0_public_key(key)
        let priKey = EC_KEY_get0_private_key(key)
        let pubChars = EC_POINT_point2hex(group, pubKey, EC_KEY_get_conv_form(key), nil);
        let priChars = BN_bn2hex(priKey)
        XCTAssertNotNil(pubChars, "公钥不为空")
        XCTAssertNotNil(priChars, "私钥不为空")
        guard let pubChars = pubChars, let priChars = priChars else { return }
        let pubStr = NSString(cString: pubChars, encoding: NSUTF8StringEncoding)
        let priStr = NSString(cString: priChars, encoding: NSUTF8StringEncoding)
        XCTAssertNotNil(pubStr, "公钥不为空")
        XCTAssertNotNil(priStr, "私钥不为空")
        debugPrint(pubStr ?? "")
        debugPrint(priStr ?? "")
        EC_GROUP_free(group)
        EC_KEY_free(key)
    }
}
