//
//  main.m
//  wechaty-puppet-macOS
//
//  Created by MustangYM on 2020/12/21.
//

#import <Foundation/Foundation.h>
#import "NSObject+Hook.h"

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"++++++++ wechaty-puppet-macOS ++++++++");
    [NSObject hookWeChat];
}
