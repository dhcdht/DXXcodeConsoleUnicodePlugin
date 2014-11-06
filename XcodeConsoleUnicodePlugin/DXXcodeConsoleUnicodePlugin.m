//
//  DXXcodeConsoleUnicodePlugin.m
//  DXXcodeConsoleUnicodePlugin
//
//  Created by dhcdht on 14-7-2.
//    Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "DXXcodeConsoleUnicodePlugin.h"

#import <objc/runtime.h>

static NSString *sConvertInConsoleEnableKey = @"kConvertInConsoleEnableKey";
static BOOL sIsConvertInConsoleEnabled;

static DXXcodeConsoleUnicodePlugin *sharedPlugin;

static IMP IMP_NSTextStorage_fixAttributesInRange = nil;

@implementation XcodeConsoleUnicode_NSTextStorage

- (void)fixAttributesInRange:(NSRange)aRange
{
    IMP_NSTextStorage_fixAttributesInRange(self, _cmd, aRange);
  
  if (sIsConvertInConsoleEnabled) {
    NSString *rangeString = [[self string] substringWithRange:aRange];
    
    NSString *convertStr = [DXXcodeConsoleUnicodePlugin convertUnicode:rangeString];
    if (![convertStr isEqualToString:rangeString] && convertStr) {
      
      //        NSDictionary *clearAttrs =[NSDictionary dictionaryWithObjectsAndKeys:
      //                                   [NSFont systemFontOfSize:0.001], NSFontAttributeName,
      //                                   [NSColor clearColor], NSForegroundColorAttributeName, nil];
      //
      //		[self addAttributes:clearAttrs range:aRange];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [DXXcodeConsoleUnicodePlugin addStringToConsole:convertStr];
      });
    }
  }
}

@end

@interface DXXcodeConsoleUnicodePlugin()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, strong) NSMenuItem *convertInConsoleItem;

@end

@implementation DXXcodeConsoleUnicodePlugin

IMP ReplaceInstanceMethod(Class sourceClass, SEL sourceSel, Class destinationClass, SEL destinationSel)
{
	if (!sourceSel || !sourceClass || !destinationClass)
	{
		NSLog(@"XcodeColors: Missing parameter to ReplaceInstanceMethod");
		return nil;
	}
	
	if (!destinationSel)
		destinationSel = sourceSel;
	
	Method sourceMethod = class_getInstanceMethod(sourceClass, sourceSel);
	if (!sourceMethod)
	{
		NSLog(@"XcodeColors: Unable to get sourceMethod");
		return nil;
	}
	
	IMP prevImplementation = method_getImplementation(sourceMethod);
	
	Method destinationMethod = class_getInstanceMethod(destinationClass, destinationSel);
	if (!destinationMethod)
	{
		NSLog(@"XcodeColors: Unable to get destinationMethod");
		return nil;
	}
	
	IMP newImplementation = method_getImplementation(destinationMethod);
	if (!newImplementation)
	{
		NSLog(@"XcodeColors: Unable to get newImplementation");
		return nil;
	}
	
	method_setImplementation(sourceMethod, newImplementation);
	
	return prevImplementation;
}

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
          
          self.convertInConsoleItem = [[NSMenuItem alloc] initWithTitle:@"ConvertUnicodeInConsole(Beta)"
                                                                        action:@selector(convertUnicodeInConsoleAction)
                                                                 keyEquivalent:@""];
          [self.convertInConsoleItem setTarget:self];
          [[menuItem submenu] addItem:self.convertInConsoleItem];
        }
        
        IMP_NSTextStorage_fixAttributesInRange = ReplaceInstanceMethod([NSTextStorage class], @selector(fixAttributesInRange:),
                                                                       [XcodeConsoleUnicode_NSTextStorage class], @selector(fixAttributesInRange:));
    }
  
  sIsConvertInConsoleEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:sConvertInConsoleEnableKey];
  if (sIsConvertInConsoleEnabled) {
    self.convertInConsoleItem.state = NSOnState;
  } else {
    self.convertInConsoleItem.state = NSOffState;
  }
  
    return self;
}

// Sample Action, for menu item:
- (void)convertAction
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *str = [DXXcodeConsoleUnicodePlugin convertUnicode:[pasteboard stringForType:@"public.utf8-plain-text"]];
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

- (void)convertUnicodeInConsoleAction
{
  BOOL convertInConsoleEnable = [[NSUserDefaults standardUserDefaults] boolForKey:sConvertInConsoleEnableKey];
  [[NSUserDefaults standardUserDefaults] setBool:!convertInConsoleEnable forKey:sConvertInConsoleEnableKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  sIsConvertInConsoleEnabled = !convertInConsoleEnable;
  if (sIsConvertInConsoleEnabled) {
    self.convertInConsoleItem.state = NSOnState;
  } else {
    self.convertInConsoleItem.state = NSOffState;
  }
}

//- (void)copyAndConvertAction
//{
//    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
//}

+ (NSString*)convertUnicode:(NSString*)aString
{
    NSString *formatString = [aString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    NSString *ret = [NSString stringWithCString:[formatString cStringUsingEncoding:[formatString smallestEncoding]]
                                       encoding:NSNonLossyASCIIStringEncoding];
    
    return ret;
}

+ (void)addStringToConsole:(NSString*)aString
{
    for (NSWindow *window in [NSApp windows]) {
        NSView *contentView = window.contentView;
        IDEConsoleTextView *console = [self consoleViewInMainView:contentView];
        if (console)
        {
            [console insertText:aString];
            
            break;
        }
    }
}

+ (IDEConsoleTextView *)consoleViewInMainView:(NSView *)mainView
{
    for (NSView *childView in mainView.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"IDEConsoleTextView")]) {
            return (IDEConsoleTextView *)childView;
        } else {
            NSView *v = [self consoleViewInMainView:childView];
            if ([v isKindOfClass:NSClassFromString(@"IDEConsoleTextView")]) {
                return (IDEConsoleTextView *)v;
            }
        }
    }
    
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
