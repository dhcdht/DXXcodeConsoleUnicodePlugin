//
//  DXXcodeConsoleUnicodePlugin.h
//  DXXcodeConsoleUnicodePlugin
//
//  Created by dhcdht on 14-7-2.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface XcodeConsoleUnicode_IDEConsoleItem : NSObject

- (id)initWithAdaptorType:(id)arg1 content:(id)arg2 kind:(int)arg3;

@end


@interface DXXcodeConsoleUnicodePlugin : NSObject

+ (NSString*)convertUnicode:(NSString*)aString;

@end
