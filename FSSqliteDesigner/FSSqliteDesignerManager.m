//
//  FSSqliteDesignerManager.m
//  FSSqliteDesigner
//
//  Created by fengsh on 7/7/15.
//  Copyright © 2015年 fengsh. All rights reserved.
//

#import "FSSqliteDesignerManager.h"
#import "FSXcodeWindowFrameDebug.h"
#import "FSViewListModel.h"
#import "FSDesignerView.h"

@interface FSSqliteDesignerManager()

@property (nonatomic, strong) NSBundle                              *bundle;
@property (nonatomic, strong) FSXcodeWindowFrameDebug               *debugVC;
@property (nonatomic, weak)   NSWindow                              *workspacewindow;
@property (nonatomic, strong) FSDesignerView                        *sqliteDesignView;
@property (nonatomic, weak)   id                                    ideEditorController;
@property (nonatomic, weak)   id                                    editorContextController;
@property (nonatomic, weak)   NSSplitView                           *debuggerSplitView;
@property (nonatomic, weak)   NSView                                *editorView;
@property (nonatomic, weak)   NSView                                *dubagToolsView;
@property (nonatomic, weak)   NSView                                *editorAutolayoutView;
//左边源码显示view
@property (nonatomic, weak)   NSOutlineView                         *navStructureView;
@property (nonatomic, weak)   NSView                                *IDENavigatorAreaView;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineSelectChange:) name:NSOutlineViewSelectionDidChangeNotification object:nil];
        
        
        
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
        
        actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"FSDesigerDebug"
                                                                action:@selector(FSDesigerDebug:)
                                                         keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
    
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask | NSMouseMovedMask  handler:^NSEvent * __nullable(NSEvent * __nonnull event) {
//        switch (event.type) {
//                            case NSLeftMouseDown:
//                                    [self toDoCheckIsSelectSqliteFolder];
//                                break;
//                            case NSMouseMoved:
//                
//                                break;
//                            default:
//                                break;
//                        }
//        return event;
//    }];

}

#pragma mark - 菜单处理
- (void)FSDesigerDebug:(NSMenuItem *)item
{
    if (!self.debugVC) {
        self.debugVC = [[FSXcodeWindowFrameDebug alloc]initWithWindowNibName:@"FSXcodeWindowFrameDebug"];
        self.debugVC.xcwindow = [NSApp keyWindow];
        [self.debugVC.window setContentMinSize:(NSMakeSize(600, 300))];
        [self.debugVC.window setContentMaxSize:(NSMakeSize(900, 500))];
        [self.debugVC.window setContentSize:(NSMakeSize(750, 400))];
    }
    
    [self.debugVC showWindow:self.debugVC];
}

- (FSDesignerView *)sqliteDesignView
{
    if (!_sqliteDesignView) {
        _sqliteDesignView = [[FSDesignerView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        //_sqliteDesignView.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
    }
    return _sqliteDesignView;
}

#pragma mark - 调试获取区
- (void)getEditorAreaViewInWorkspaceWindow:(NSWindow *)workspacewindow
{
    if (!self.ideEditorController)
    {
        NSWindowController *windowController = [workspacewindow windowController];
        if ([windowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
            //id workspace = [windowController valueForKey:@"_workspace"];
            id workspacetabcontroller = [windowController valueForKey:@"_activeWorkspaceTabController"];
            NSSplitView *designArea = [workspacetabcontroller valueForKey:@"_designAreaSplitView"];
            
            for (NSView *item in designArea.subviews) {
                if ([item isKindOfClass:[NSClassFromString(@"DVTReplacementView")class]]) {
                    Class cls = [item valueForKey:@"_controllerClass"];
                    if ([NSClassFromString(@"IDEEditorArea")class] == cls)
                    {
                        id installedviewcontroller = [item valueForKey:@"_installedViewController"];
                        
                        self.ideEditorController = installedviewcontroller;
                        
                        //NSView *v = [installedviewcontroller valueForKey:@"_editorModeHostView"];
                        
                        self.debuggerSplitView = [installedviewcontroller valueForKey:@"_debuggerSplitView"];
                        
                        //获取调试单步，多步，断点调试view
                        NSView *debugv = [installedviewcontroller valueForKey:@"_debuggerBarBorderedView"];
                        //最后代码编辑区
                        id editorContext = [installedviewcontroller valueForKey:@"_lastActiveEditorContext"];
                        self.editorContextController = editorContext;
                        //带当前打开文件显示导航的视图
                        //NSView *navAndEditor = [editorContext valueForKey:@"_editorAndNavBarView"];
                        //获取文件显示导航区
                        //NSView *nav = [editorContext valueForKey:@"_navBar"];
                        
                        //id debugBar = [installedviewcontroller valueForKey:@"_activeDebuggerBar"];
                        self.dubagToolsView = debugv;
                        //代码或查看资源文件的编辑区
                        NSView *editorSourceView = [editorContext valueForKey:@"_editorBorderedView"];
                        self.editorView = editorSourceView;
                        
                        self.editorAutolayoutView = [installedviewcontroller valueForKey:@"_editorAreaAutoLayoutView"];
                        
                        if (![self.editorAutolayoutView.subviews containsObject:self.sqliteDesignView])
                        {
                            [self.editorAutolayoutView addSubview:self.sqliteDesignView];
                        }
                    }
                    else if ([NSClassFromString(@"IDENavigatorArea")class] == cls)
                    {
                        self.IDENavigatorAreaView = item;
                    }
                }
            }
        }
    }
}

//- (NSView *)designOfSqliteView
//{
//    NSBundle *bundle = [NSBundle bundleForClass:self.class];
//    NSMutableArray *nibs = [[NSMutableArray alloc]init];
//    BOOL ok = [bundle loadNibNamed:@"FSDesignContentView" owner:nil topLevelObjects:&nibs];
//    
//    if (ok)
//    {
//        return [nibs objectAtIndex:1];
//    }
//    
//    return nil;
//}

#pragma mark - 获取左边代码区
- (NSOutlineView *)findNavSourceArea
{
    @try {
        if (self.IDENavigatorAreaView) {
            if (!self.navStructureView) {
                id navAreacontroller = [self.IDENavigatorAreaView valueForKey:@"_installedViewController"];
                id repView = [navAreacontroller valueForKey:@"_replacementView"];
                id structureNav = [repView valueForKey:@"_installedViewController"];

                NSOutlineView *olv = [structureNav valueForKey:@"_outlineView"];
                self.navStructureView = olv;
            }
            return self.navStructureView;
        }
    }
    @catch (NSException *exception) {
        
    }
    return nil;
}

#pragma mark - 获取代码或查看资源文件的编辑区
- (NSView *)findResAndSourceTextAreaView
{
    @try {
        if (self.editorContextController) {
            return [self.editorContextController valueForKey:@"_editorBorderedView"];
        }
    }
    @catch (NSException *exception) {

    }

    return nil;
}

#pragma mark - 获取调试单步，多步，断点调试view
- (NSView *)fineDebugAreaView
{
    @try {
        if (self.ideEditorController) {
            return [self.ideEditorController valueForKey:@"_debuggerBarBorderedView"];
        }
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;
}

#pragma mark - 获取调试区和编辑区的splitview
- (NSSplitView *)findDebugAndEditorSplitView
{
    @try {
        if (self.ideEditorController) {
            return [self.ideEditorController valueForKey:@"_debuggerSplitView"];
        }
    }
    @catch (NSException *exception) {
        
    }
    
    return nil;
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSWindow *window = [notification object];
    if ([window isKindOfClass:NSClassFromString(@"IDEWorkspaceWindow")])
    {
        if (!self.workspacewindow) {
            self.workspacewindow = window;
        }
        
        @try {
            NSWindowController *windowController = [window windowController];
            if ([windowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")])
            {
                [self getEditorAreaViewInWorkspaceWindow:self.workspacewindow];
            }
        }
        @catch (NSException *exception) { }
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    @try {
            NSSplitView *sp = notification.object;
            
            if (sp == self.debuggerSplitView)
            {
                CGFloat y = self.dubagToolsView.hidden ? 0 : 29;
                CGSize s = self.editorAutolayoutView.frame.size;
                
                self.sqliteDesignView.frame = CGRectMake(0, y,s.width, s.height - 29 - y);
            }
    }
    @catch (NSException *exception) { }
}

#pragma mark - 点击判断
- (void)toDoCheckIsSelectSqliteFolder
{
//    @try {
//    }
//    @catch (NSException *exception) { }
}

- (void)notificationListener:(NSNotification *)notification
{
    @try {
        NSLog(@"========================= %@",notification);
    }
    @catch (NSException *exception) { }
}

- (void)outlineSelectChange:(NSNotification *)notification
{
    @try {
        NSOutlineView *outlineview = notification.object;
        if (outlineview == [self findNavSourceArea]) {
            id selectedItem = [outlineview itemAtRow:[outlineview selectedRow]];
            
            NSString *name = [selectedItem valueForKey:@"_name"];
            NSString *ext = [name pathExtension];
            
            if ([ext isEqualToString:@"sqlitemodeld"])
            {
                self.sqliteDesignView.hidden = NO;
                if (self.editorView) {
                    self.editorView.hidden = !self.sqliteDesignView.hidden;
                }
                
                NSArray * subitems = [selectedItem valueForKey:@"_subitems"];
                for (id item in subitems)
                {
                    id filepath = [item valueForKey:@"_watchedFilePath"];
                    NSURL *filepathURL = [filepath valueForKey:@"_fileURL"];
                    
                    NSLog(@"+++++++++ url = %@",filepathURL);
                    
                    //NSXMLParser
//                    NSError *parseError = nil;
//                    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:testXMLString error:&parseError];
                }
            }
            else
            {
                self.sqliteDesignView.hidden = YES;
                if (self.editorView) {
                    self.editorView.hidden = !self.sqliteDesignView.hidden;
                }
            }
        }
    }
    @catch (NSException *exception) { }
}


@end
