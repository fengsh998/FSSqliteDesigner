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
#import "FSDesignerViewController.h"

@interface FSSqliteDesignerManager()

@property (nonatomic, strong) NSBundle                              *bundle;
@property (nonatomic, strong) FSXcodeWindowFrameDebug               *debugVC;
@property (nonatomic, weak)   NSWindow                              *workspacewindow;
@property (nonatomic, strong) FSDesignerView                        *sqliteDesignView;
@property (nonatomic, weak)   id                                    ideEditorController;
@property (nonatomic, weak)   id                                    editorContextController;
@property (nonatomic, weak)   id                                    ideEditorDocument;
@property (nonatomic, weak)   NSSplitView                           *debuggerSplitView;
@property (nonatomic, weak)   NSView                                *editorView;
@property (nonatomic, weak)   NSView                                *dubagToolsView;
@property (nonatomic, weak)   NSView                                *editorAutolayoutView;
//左边源码显示view
@property (nonatomic, weak)   NSOutlineView                         *navStructureView;
@property (nonatomic, weak)   NSView                                *IDENavigatorAreaView;
//sqliet designer view controller
@property (nonatomic, strong) FSDesignerViewController              *designVC;

@property (nonatomic, assign) BOOL                                  isSelectedSqlitemodel;

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
        
        NSBundle *bd = [NSBundle bundleForClass:self.class];
        self.designVC = [[FSDesignerViewController alloc]initWithNibName:@"FSDesignerViewController" bundle:bd];
        self.designVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        //读取插件中的图标
        /*
         //preload our icons
         NSBundle *bundle = [NSBundle bundleForClass:self.class];
         _errorImage = [bundle imageForResource:@"XCBuildErrorIcon"];
         _warningImage = [bundle imageForResource:@"XCBuildWarningIcon"];
         _analyzerResultImage = [bundle imageForResource:@"XCBuildAnalyzerResultIcon"];
         _successImage = [bundle imageForResource:@"XCBuildSuccessIcon"];
         */
        
        [self setupXCtemplateToOthers];
    }
    
    return self;
}

//按装模板到new->file->other 中会有SqliteModel
- (void)setupXCtemplateToOthers
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *developer = [path[0] stringByAppendingPathComponent:@"Developer"];
    NSString *xcode = [developer stringByAppendingPathComponent:@"Xcode"];
    NSString *Templates = [xcode stringByAppendingPathComponent:@"Templates"];
    NSString *fileTemplates = [Templates stringByAppendingPathComponent:@"File Templates"];
    
    NSString *xctempdir = [fileTemplates stringByAppendingPathComponent:@"SqliteModel/Sqlite Model Object.xctemplate"];
    NSString *modeldir = [xctempdir stringByAppendingPathComponent:@"___FILEBASENAME___.sqlitemodeld"];
    
    //创建模板所有的目录
    NSError *error = nil;
    BOOL ok = [[NSFileManager defaultManager]createDirectoryAtPath:modeldir withIntermediateDirectories:YES attributes:nil error:&error];
    if (!ok || error) {
        NSLog(@"模板路径创建失败。");
    }
    else
    {
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        //xctemp下的资源
        NSURL *icns = [bundle URLForResource:@"TemplateIcon" withExtension:@"icns"];
        NSURL *plist = [bundle URLForResource:@"TemplateInfo" withExtension:@"plist"];
        
        NSURL *desicns = [NSURL fileURLWithPath:[xctempdir stringByAppendingPathComponent:[icns lastPathComponent]]];
        NSURL *desplist = [NSURL fileURLWithPath:[xctempdir stringByAppendingPathComponent:[plist lastPathComponent]]];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:desicns.path])
        {
            ok = [[NSFileManager defaultManager]copyItemAtURL:icns toURL:desicns error:&error];
            if (!ok || error) {
                NSLog(@"copy 资源文件出错! error = %@",error);
            }
        }
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:desplist.path]) {
            ok = [[NSFileManager defaultManager]copyItemAtURL:plist toURL:desplist error:&error];
            if (!ok || error) {
                NSLog(@"copy 资源文件出错! error = %@",error);
            }
        }
        
        //sqlitemodeld下的资源
        NSURL *model = [bundle URLForResource:@"___FILEBASENAME___" withExtension:@"sqlitemodel"];
        NSURL *modelplist = [bundle URLForResource:@"version-model" withExtension:@"plist"];
        
        NSURL *desmodel = [NSURL fileURLWithPath:[modeldir stringByAppendingPathComponent:[model lastPathComponent]]];
        NSURL *desmodelpist = [NSURL fileURLWithPath:[modeldir stringByAppendingPathComponent:[modelplist lastPathComponent]]];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:desmodel.path])
        {
            ok = [[NSFileManager defaultManager]copyItemAtURL:model toURL:desmodel error:&error];
            if (!ok || error) {
                NSLog(@"copy 资源文件出错! error = %@",error);
            }
        }
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:desmodelpist.path]) {
            ok = [[NSFileManager defaultManager]copyItemAtURL:modelplist toURL:desmodelpist error:&error];
            if (!ok || error) {
                NSLog(@"copy 资源文件出错! error = %@",error);
            }
        }
    }
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
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask  handler:^NSEvent * __nullable(NSEvent * __nonnull event) {
        if((([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) && [[event charactersIgnoringModifiers] compare:@"s"] == 0) {
            if (self.designVC && self.designVC.designer && self.isSelectedSqlitemodel)
            {
                
                [self saveToDisk];
                //做了个投机取巧的方式
//                NSTextView *tv = [self getSourceCodeEditorView];
//                tv.string = @"test";
//                NSLog(@"tv ======= %@",tv);
                
                return nil;//拦截系统保存
            }
        }
        
        return event;
    }];
}

- (void)saveToDisk
{
    if (self.designVC.structIsChanged) {
        [self.designVC todoSaveSetValue];
        [self.designVC.designer saveToFile:self.designVC.modelUrl];
        [self.designVC setIsChangedStruct:NO];
    }
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
        _sqliteDesignView.hidden = YES;
        
        [_sqliteDesignView.contentView addSubview:self.designVC.view];
        
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
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
//            if (!self.navStructureView) { //当切换时
                id navAreacontroller = [self.IDENavigatorAreaView valueForKey:@"_installedViewController"];
                id repView = [navAreacontroller valueForKey:@"_replacementView"];
                id structureNav = [repView valueForKey:@"_installedViewController"];

                NSOutlineView *olv = [structureNav valueForKey:@"_outlineView"];
                self.navStructureView = olv;
//            }
            return self.navStructureView;
        }
    }
    @catch (NSException *exception) {
        
    }
    return nil;
}

#pragma mark - 获取sourcecode editor view
- (NSTextView *)getSourceCodeEditorView
{
    self.ideEditorDocument = [[self.workspacewindow windowController] valueForKey:@"_lastObservedEditorDocument"];
    
    if (self.ideEditorDocument) {
        NSMutableSet *st = [self.ideEditorDocument valueForKey:@"_documentEditors"];
        if (st.count > 0) {
            id editor = st.allObjects[0];
            if ([editor isKindOfClass:[NSClassFromString(@"IDESourceCodeEditor") class]]) {
                id view = [editor valueForKey:@"_textView"];
                if ([view isKindOfClass:[NSTextView class]]) {
                    return view;
                }
            }
        }
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
    //NSLog(@"change = %@",notification);
    @try {
        NSOutlineView *outlineview = notification.object;
        if (outlineview == [self findNavSourceArea]) {
            id selectedItem = [outlineview itemAtRow:[outlineview selectedRow]];
            
            NSString *name = [selectedItem valueForKey:@"_name"];
            NSString *ext = [name pathExtension];
            
            NSURL *fileUrl = [selectedItem valueForKey:@"_fileURL"];

            if ([ext isEqualToString:@"sqlitemodeld"] || [ext isEqualToString:@"sqlitemodel"])
            {
                self.isSelectedSqlitemodel = YES;
                
                self.sqliteDesignView.hidden = NO;
                if (self.editorView) {
                    self.editorView.hidden = !self.sqliteDesignView.hidden;
                }
                
                //当打开时,第一次点击sqlitemodel，可能会为nil这里做一个补救
                if (!fileUrl)
                {
                    id parentitem = [outlineview parentForItem:selectedItem];
                    NSArray *fileitem = [parentitem valueForKey:@"_subitems"];
                    for (id filereference in fileitem)
                    {
                        id dvfilepath = [filereference valueForKey:@"_watchedFilePath"];
                        NSURL *tmp = [dvfilepath valueForKey:@"_fileURL"];
                        if (tmp && [[tmp lastPathComponent]isEqualToString:name])
                        {
                            fileUrl = tmp;
                            break;
                        }
                    }
                }
                
                NSURL *loadFileUrl = [fileUrl copy];
                
                if ([ext isEqualToString:@"sqlitemodeld"])
                {
                    fileUrl = [fileUrl URLByAppendingPathComponent:@"version-model.plist"];
                    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
                    NSString *mdname = dic[@"currentModelName"];
                    if (!mdname) {
                        mdname = [NSString stringWithFormat:@"%@.sqlitemodel",[name stringByDeletingPathExtension]];
                        
                        NSMutableDictionary *save = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [save setObject:mdname forKey:@"currentModelName"];
                        [save writeToURL:fileUrl atomically:YES];
                    }

                    loadFileUrl = [loadFileUrl URLByAppendingPathComponent:mdname];
                }
                
                if ([[loadFileUrl pathExtension] isEqualToString:@"sqlitemodel"]) {
                    
                    [self.designVC setModelUrl:loadFileUrl];
                }
            }
            else
            {
                ///有切换则先保存一下设置
                [self saveToDisk];
                
                //当未选中，且在编辑时则不让切换
                if (!selectedItem && !self.sqliteDesignView.hidden) {
                    return;
                }
                
                self.isSelectedSqlitemodel = NO;
                
                if (self.editorView) {
                    self.editorView.hidden = NO;
                }
                
                //处理切换时有闪烁问题
                [self performSelector:@selector(delayHidden) withObject:nil afterDelay:0.5];
                //self.sqliteDesignView.hidden = YES;
                
                [self.designVC setModelUrl:nil];
            }
        }
    }
    @catch (NSException *exception) { }
}

- (void)delayHidden
{
    self.sqliteDesignView.hidden = YES;
}


@end
