//
//  DXXcodeConsoleUnicodePlugin.h
//  DXXcodeConsoleUnicodePlugin
//
//  Created by dhcdht on 14-7-2.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "IDEKit.h"

@interface XcodeConsoleUnicode_NSTextStorage : NSTextStorage

- (void)fixAttributesInRange:(NSRange)aRange;

@end

@interface DXXcodeConsoleUnicodePlugin : NSObject

+ (NSString*)convertUnicode:(NSString*)aString;
+ (void)addStringToConsole:(NSString*)aString;
+ (void)replaceStringInRange:(NSRange)aRange verifyString:(NSString*)aVerifyString withString:(NSString*)aReplaceString andAttribute:(NSDictionary*)aAttributes;

@end