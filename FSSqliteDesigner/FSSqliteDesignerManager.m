//
//  FSSqliteDesignerManager.m
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSSqliteDesignerManager.h"

@interface FSSqliteDesignerManager()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation FSSqliteDesignerManager

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static FSSqliteDesignerManager *sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            NSLog(@"FSSqliteERDesigner: Plugin loaded successfully");
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // Save reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationListener:) name:nil object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(splitViewDidResizeSubviews:) name:NSSplitViewDidResizeSubviewsNotification object:nil];
        
        //读取插件中的图标
        /*
         //preload our icons
         NSBundle *bundle = [NSBundle bundleForClass:self.class];
         _errorImage = [bundle imageForResource:@"XCBuildErrorIcon"];
         _warningImage = [bundle imageForResource:@"XCBuildWarningIcon"];
         _analyzerResultImage = [bundle imageForResource:@"XCBuildAnalyzerResultIcon"];
         _successImage = [bundle imageForResource:@"XCBuildSuccessIcon"];
         */
        

    }
    
    return self;
}

- (void)FSDesigerSettings:(NSMenuItem *)item
{
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Create menu item to open Browser under File:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"FSDesigerSettings"
                                                                action:@selector(FSDesigerSettings:)
                                                         keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)setViewBorderColor:(NSView *)v withColor:(NSColor *)clr withWitdh:(CGFloat)w
{
    v.wantsLayer = YES;
    v.layer.borderWidth = w;
    v.layer.borderColor = clr.CGColor;
}

#pragma mark - 遍历NSTabView
- (void)todoErgodicNSTabview:(NSView *)nstabview
{
    for (NSView *subItem in nstabview.subviews)
    {
        if ([subItem isKindOfClass:[NSClassFromString(@"DVTControllerContentView")class]])
        {
            //和NSTabView一样大
            NSLog(@"DVTControllerContentView.frame = %@",NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor redColor]withWitdh:1.0f];
            
            [self todoErgodicControllerContentViewInNSTabview:subItem];
        }
        else //未知的
        {
            NSLog(@"NSTabView 存在未知的 %@.frame = %@ ",subItem.className,NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor greenColor]withWitdh:4.0f];
        }
    }
}

#pragma mark - 遍历NSTabview -> DVTControllerContentView上的view
- (void)todoErgodicControllerContentViewInNSTabview:(NSView *)v
{
    for (NSView *subItem in v.subviews)
    {
        if ([subItem isKindOfClass:[NSClassFromString(@"DVTSplitView")class]])
        {
            //和NSTabView一样大
            NSLog(@"DVTSplitView.frame = %@",NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor redColor]withWitdh:1.0f];
            
            [self todoErgodicSpliteView:subItem];
        }
        else //未知的
        {
            NSLog(@"NSTabView 存在未知的 %@.frame = %@ ",subItem.className,NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor greenColor]withWitdh:4.0f];
        }
    }
}

#pragma mark - 遍历DVTControllerContentView->DVTSpliteView上的view
- (void)todoErgodicSpliteView:(NSView *)v
{
    for (NSView *subItem in v.subviews)
    {
        if ([subItem isKindOfClass:[NSClassFromString(@"DVTReplacementView")class]])
        {
            //和NSTabView一样大
            NSLog(@"DVTReplacementView.frame = %@",NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor blueColor]withWitdh:1.0f];
            
        }
        else //未知的
        {
            NSLog(@"NSTabView 存在未知的 %@.frame = %@ ",subItem.className,NSStringFromRect(subItem.frame));
            [self setViewBorderColor:subItem withColor:[NSColor greenColor]withWitdh:4.0f];
        }
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSWindow *window = [notification object];
    if ([window isKindOfClass:NSClassFromString(@"IDEWorkspaceWindow")]) {
        @try {
            NSWindowController *windowController = [window windowController];
            if ([windowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
                //id workspace = [windowController valueForKey:@"_workspace"];

            }
            
            NSLog(@"window.contentView.frame = %@",NSStringFromRect(window.contentView.frame));
            
            [self setViewBorderColor:window.contentView withColor:[NSColor redColor] withWitdh:1.0f];
            
            for (NSView *item in window.contentView.subviews) {
                if ([item isKindOfClass:[NSClassFromString(@"DVTTabBarEnclosureView")class]])
                {
                    //在整个IDE的最下面还未知是什么东东
                    NSLog(@"DVTTabBarEnclosureView.frame = %@",NSStringFromRect(item.frame));
                    [self setViewBorderColor:item withColor:[NSColor yellowColor]withWitdh:2.0f];
                }
                else if ([item isKindOfClass:[NSClassFromString(@"NSTabView")class]])
                {
                    //结论是NSTabView与ContentView一样大小，contentview add nstabview
                    NSLog(@"NSTabView.frame = %@",NSStringFromRect(item.frame));
                    [self setViewBorderColor:item withColor:[NSColor orangeColor]withWitdh:3.0f];
                    
                    [self todoErgodicNSTabview:item];
                }
                else //未知的
                {
                    NSLog(@"ContentView 存在未知的 %@.frame = %@ ",item.className,NSStringFromRect(item.frame));
                    [self setViewBorderColor:item withColor:[NSColor greenColor]withWitdh:4.0f];
                }
            }
        }
        @catch (NSException *exception) { }
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    NSString *clsname = [[NSApp mainWindow]className];
    
    @try {
        NSLog(@"notification = %@ , clsname = %@",notification.object,clsname);
        
        NSSplitView *sp = notification.object;
        
        NSArray *spitems = [sp valueForKey:@"_splitViewItems"];
        
        for (id item in  spitems) {
            NSString *identifier = [item valueForKey:@"_identifier"];
            if (identifier.length > 0)
            {
                if ([identifier isEqualToString:@"IDEEditor"]) {//374
                    
                }
                else if ([identifier isEqualToString:@"IDEDebuggerArea"])//226
                {
                    
                }
                else if ([identifier isEqualToString:@"IDEEditorArea"])
                {
                    
                }
            }
        }
        
        
        for (NSView *item in sp.subviews)
        {
            if ([item isKindOfClass:[NSClassFromString(@"DVTReplacementView") class]])
            {
                Class cls = [item valueForKey:@"_controllerClass"];
                if (NSClassFromString(@"IDENavigatorArea") == cls )
                {
                    
                }
                else if (NSClassFromString(@"IDEEditorArea") == cls )
                {
                    
                }
            }
        }
    }
    @catch (NSException *exception) { }
}

@end
