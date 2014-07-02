//
//  DXXcodeConsoleUnicodePlugin.m
//  DXXcodeConsoleUnicodePlugin
//
//  Created by dhcdht on 14-7-2.
//    Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "DXXcodeConsoleUnicodePlugin.h"

static DXXcodeConsoleUnicodePlugin *sharedPlugin;

@interface DXXcodeConsoleUnicodePlugin()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation DXXcodeConsoleUnicodePlugin

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.
        
        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            
//            NSMenuItem *copyAndConvertItem = [[NSMenuItem alloc] initWithTitle:@"CopyAndConvertUnicode" action:@selector(copyAndConvertAction) keyEquivalent:@""];
//            [copyAndConvertItem setTarget:self];
//            [[menuItem submenu] addItem:copyAndConvertItem];
            
            NSMenuItem *convertItem = [[NSMenuItem alloc] initWithTitle:@"ConvertUnicode" action:@selector(convertAction) keyEquivalent:@"c"];
            [convertItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
            [convertItem setTarget:self];
            [[menuItem submenu] addItem:convertItem];
        }
    }
    return self;
}

// Sample Action, for menu item:
- (void)convertAction
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *str = [self convertUnicode:[pasteboard stringForType:@"public.utf8-plain-text"]];
//    NSString *str = [NSString stringWithFormat:@"%@", [pasteboard types]];
    /**
     *  "dyn.ah62d4rv4gu8y63n2nuuhg5pbsm4ca6dbsr4gnkduqf31k3pcr7u1e3basv61a3k",
     "NeXT smart paste pasteboard type",
     "com.apple.webarchive",
     "Apple Web Archive pasteboard type",
     "public.rtf",
     "NeXT Rich Text Format v1.0 pasteboard type",
     "public.utf8-plain-text",
     NSStringPboardType,
     "public.utf16-external-plain-text",
     "CorePasteboardFlavorType 0x75743136",
     "dyn.ah62d4rv4gk81n65yru",
     "CorePasteboardFlavorType 0x7573746C",
     "com.apple.traditional-mac-plain-text",
     "CorePasteboardFlavorType 0x54455854",
     "dyn.ah62d4rv4gk81g7d3ru",
     "CorePasteboardFlavorType 0x7374796C"
     */
    
//    [pasteboard setString:str forType:NSStringPboardType];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:str, nil];
    [alert runModal];
}

//- (void)copyAndConvertAction
//{
//    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
//}

- (NSString*)convertUnicode:(NSString*)aString
{
    NSString *ret = [NSString stringWithCString:[aString cStringUsingEncoding:[aString smallestEncoding]]
                                       encoding:NSNonLossyASCIIStringEncoding];
    
    return ret;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
