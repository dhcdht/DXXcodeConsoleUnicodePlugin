//
//  DXXcodeConsoleUnicodePlugin.m
//  DXXcodeConsoleUnicodePlugin
//
//  Created by dhcdht on 14-7-2.
//    Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "DXXcodeConsoleUnicodePlugin.h"

#import "IDEKit.h"
#import <objc/runtime.h>

#import "RegExCategories.h"


static NSString *sConvertInConsoleEnableKey = @"kConvertInConsoleEnableKey";
static BOOL sIsConvertInConsoleEnabled;

static DXXcodeConsoleUnicodePlugin *sharedPlugin;


static IMP IMP_IDEConsoleItem_initWithAdaptorType = nil;
@implementation XcodeConsoleUnicode_IDEConsoleItem

- (id)initWithAdaptorType:(id)arg1 content:(id)arg2 kind:(int)arg3
{
  id item = IMP_IDEConsoleItem_initWithAdaptorType(self, _cmd, arg1, arg2, arg3);
  
  if (sIsConvertInConsoleEnabled) {
    NSString *logText = [item valueForKey:@"content"];
    NSString *resultText = [DXXcodeConsoleUnicodePlugin convertUnicode:logText];
    [item setValue:resultText forKey:@"content"];
  }
  
  return item;
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
      
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(menuDidChange)
                                                   name:NSMenuDidChangeItemNotification
                                                 object:nil];
    });
  }
}

+ (void)menuDidChange
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSMenuDidChangeItemNotification
                                                object:nil];
  
  [sharedPlugin createMenu];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(menuDidChange)
                                               name:NSMenuDidChangeItemNotification
                                             object:nil];
}

- (void)createMenu
{
  NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
  if (menuItem && !self.convertInConsoleItem) {
    [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *convertItem = [[NSMenuItem alloc] initWithTitle:@"ConvertUnicode" action:@selector(convertAction) keyEquivalent:@"c"];
    [convertItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [convertItem setTarget:self];
    [[menuItem submenu] addItem:convertItem];
    
    self.convertInConsoleItem = [[NSMenuItem alloc] initWithTitle:@"ConvertUnicodeInConsole"
                                                           action:@selector(convertUnicodeInConsoleAction)
                                                    keyEquivalent:@""];
    [self.convertInConsoleItem setTarget:self];
    [[menuItem submenu] addItem:self.convertInConsoleItem];
    
    sIsConvertInConsoleEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:sConvertInConsoleEnableKey];
    if (sIsConvertInConsoleEnabled) {
      self.convertInConsoleItem.state = NSOnState;
    } else {
      self.convertInConsoleItem.state = NSOffState;
    }
  }
}

- (id)initWithBundle:(NSBundle *)plugin
{
  if (self = [super init]) {
    // reference to plugin's bundle, for resource acccess
    self.bundle = plugin;
    
    // Create menu items, initialize UI, etc.
    
    // Sample Menu Item:
    [self createMenu];
    
    IMP_IDEConsoleItem_initWithAdaptorType = ReplaceInstanceMethod(NSClassFromString(@"IDEConsoleItem"), @selector(initWithAdaptorType:content:kind:),
                                                                   [XcodeConsoleUnicode_IDEConsoleItem class], @selector(initWithAdaptorType:content:kind:));
  }
  
  return self;
}

// Sample Action, for menu item:
- (void)convertAction
{
  NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
  NSString *originString = [pasteboard stringForType:@"public.utf8-plain-text"];
  NSString *str = [DXXcodeConsoleUnicodePlugin convertUnicode:originString];
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
  
    if ([str length]) {
        str = originString;
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:@""
                                     defaultButton:nil
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSScrollView *scrollview = [[NSScrollView alloc] initWithFrame:[[alert.window contentView] bounds]];
    [scrollview setHasVerticalScroller:YES];
    NSTextView *textview = [[NSTextView alloc] initWithFrame:[[alert.window contentView] bounds]];
    [scrollview setDocumentView:textview];
    [textview setString:str];
    [alert setAccessoryView:scrollview];
    
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

+ (NSString*)convertUnicode:(NSString*)aString
{
  NSString *ret = [aString replace:RX(@"\\\\[uU]\\w{4}")
                         withBlock:^NSString *(NSString *match) {
                           return [NSString stringWithCString:[match cStringUsingEncoding:NSUTF8StringEncoding]
                                                     encoding:NSNonLossyASCIIStringEncoding];
                         }];
  
  return ret;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
