//
//  NSObject+Hook.m
//  wechaty-puppet-macOS
//
//  Created by MustangYM on 2020/12/21.
//

#import "NSObject+Hook.h"
#import "YMSwizzledHelper.h"
#import "YMDeviceHelper.h"
#import "fishhook.h"
#import "PuppetHeader.h"

@implementation NSObject (Hook)
+ (void)hookWeChat
{
    SEL syncBatchAddMsgsMethod = LargerOrEqualVersion(@"2.3.22") ? @selector(FFImgToOnFavInfoInfoVCZZ:isFirstSync:) : @selector(OnSyncBatchAddMsgs:isFirstSync:);
    hookMethod(objc_getClass("MessageService"), syncBatchAddMsgsMethod, [self class], @selector(hook_receivedMsg:isFirstSync:));
    SEL hasWechatInstanceMethod = LargerOrEqualVersion(@"2.3.22") ? @selector(FFSvrChatInfoMsgWithImgZZ) : @selector(HasWechatInstance);
    hookClassMethod(objc_getClass("CUtility"), hasWechatInstanceMethod, [self class], @selector(hook_HasWechatInstance));
    hookClassMethod(objc_getClass("NSRunningApplication"), @selector(runningApplicationsWithBundleIdentifier:), [self class], @selector(hook_runningApplicationsWithBundleIdentifier:));    
    rebind_symbols((struct rebinding[2]) {
        { "NSSearchPathForDirectoriesInDomains", swizzled_NSSearchPathForDirectoriesInDomains, (void *)&original_NSSearchPathForDirectoriesInDomains },
        { "NSHomeDirectory", swizzled_NSHomeDirectory, (void *)&original_NSHomeDirectory }
    }, 2);
}

- (void)hook_receivedMsg:(NSArray *)msgs isFirstSync:(BOOL)arg2
{
    [msgs enumerateObjectsUsingBlock:^(AddMsg *addMsg, NSUInteger idx, BOOL * _Nonnull stop1) {
        
    }];
    [self hook_receivedMsg:msgs isFirstSync:arg2];
}

+ (BOOL)hook_HasWechatInstance
{
    return NO;
}

+ (NSArray *)hook_runningApplicationsWithBundleIdentifier:(id)arg1
{
    return @[];
}

#pragma mark - 替换 NSSearchPathForDirectoriesInDomains & NSHomeDirectory
static NSArray<NSString *> *(*original_NSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);

NSArray<NSString *> *swizzled_NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde) {
    NSMutableArray<NSString *> *paths = [original_NSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde) mutableCopy];
    NSString *sandBoxPath = [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
    
    [paths enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = [filePath rangeOfString:original_NSHomeDirectory()];
        if (range.length > 0) {
            NSMutableString *newFilePath = [filePath mutableCopy];
            [newFilePath replaceCharactersInRange:range withString:sandBoxPath];
            paths[idx] = newFilePath;
        }
    }];
    
    return paths;
}

static NSString *(*original_NSHomeDirectory)(void);

NSString *swizzled_NSHomeDirectory(void) {
    return [NSString stringWithFormat:@"%@/Library/Containers/com.tencent.xinWeChat/Data",original_NSHomeDirectory()];
}

@end
