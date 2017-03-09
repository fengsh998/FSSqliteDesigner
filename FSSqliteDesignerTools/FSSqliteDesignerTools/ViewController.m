//
//  ViewController.m
//  FSSqliteDesignerTools
//
//  Created by fengsh on 16/9/23.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "ViewController.h"

#import "FSDesignerView.h"
#import "FSDesignerViewController.h"
#import "FSExplorer.h"


@interface ViewController()<DragDropViewDelegate>
@property (nonatomic, strong)  FSDesignerViewController               *designVC;
@property (nonatomic, strong)  FSDesignerView                         *sqliteDesignView;
@property (nonatomic, strong)  FSExplorer                             *explorer;
@property (nonatomic, copy)    NSString                               *smtitle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSKeyedArchiver
    // Do any additional setup after loading the view.
    self.container.delegate = self;
    NSBundle *bd = [NSBundle bundleForClass:self.class];
    self.designVC = [[FSDesignerViewController alloc]initWithNibName:@"FSDesignerViewController" bundle:bd];
    self.designVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.container addSubview:self.sqliteDesignView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidResize:)
                                                 name:NSWindowDidResizeNotification
                                               object:nil];
    
    self.smtitle = NSApp.windows[0].title;
    
    [self toListenAppEvent];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)windowDidResize:(NSNotification *)notification
{
    self.sqliteDesignView.frame = self.container.bounds;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (FSDesignerView *)sqliteDesignView
{
    if (!_sqliteDesignView) {
        _sqliteDesignView = [[FSDesignerView alloc]initWithFrame:self.view.bounds];
        
        [_sqliteDesignView.contentView addSubview:self.designVC.view];
        
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_sqliteDesignView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.designVC.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_sqliteDesignView.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    }
    return _sqliteDesignView;
}

- (IBAction)onNewClicked:(id)sender {
    self.explorer = [[FSExplorer alloc]initWithWindowNibName:@"FSExplorer"];
    self.explorer.isCreate = YES;
    [self toPickPathView];
}

- (IBAction)onOpenClicked:(id)sender {
    self.explorer = [[FSExplorer alloc]initWithWindowNibName:@"FSExplorer"];
    self.explorer.isCreate = NO;
    [self toPickPathView];
}

- (void)toPickPathView
{
    [self.view.window beginSheet:self.explorer.window completionHandler:^(NSModalResponse returnCode) {
        switch (returnCode) {
            case NSModalResponseOK:
            {
                if (self.explorer.isCreate) {
                    NSURL *url = [self.explorer.pathURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlitemodeld",self.explorer.tfSaveName.stringValue]];
                    [self toCreateDBModel:url.path];
                    self.lbpath.stringValue = url.path;
                    self.smtitle = [url.path.lastPathComponent stringByDeletingPathExtension];
                } else {
                    self.smtitle = [[self.explorer.pathURL.path lastPathComponent]stringByDeletingPathExtension];
                    self.lbpath.stringValue = self.explorer.pathURL.path;
                    [self.designVC setModelUrl:[NSURL fileURLWithPath:self.explorer.pathURL.path]];
                }
            }
                break;
            case NSModalResponseCancel:
            {
                
            }
                break;
                
            default:
                break;
        }
        
        self.explorer = nil;
    }];
}

////打开目录位置
- (IBAction)onGoClicked:(id)sender {
    if (self.lbpath.stringValue.length > 0)
    {
        [[NSWorkspace sharedWorkspace] openFile:self.lbpath.stringValue];
    }
}

- (void)toCreateDBModel:(NSString *)fullpath
{
    NSError *error = nil;
    
    BOOL ok = [[NSFileManager defaultManager]createDirectoryAtPath:fullpath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!ok || error) {
        NSLog(@"模板路径创建失败。");
    }

    NSString *fileName = [[fullpath lastPathComponent] stringByDeletingPathExtension];
    NSString *modelName = [NSString stringWithFormat:@"%@.sqlitemodel",fileName];
    NSString *file = [fullpath stringByAppendingPathComponent:modelName];
    
    ok = [[NSFileManager defaultManager]createFileAtPath:file contents:nil attributes:nil];
    if (!ok)
    {
        NSLog(@"模板文件创建失败");
    }
    
    //创建版本plist文件
    NSDictionary *version = @{@"currentModelName":modelName};
    NSString *v = [fullpath stringByAppendingPathComponent:@"version-model.plist"];
    [version writeToFile:v atomically:YES];
    
    //加载model
    [self.designVC setModelUrl:[NSURL fileURLWithPath:file]];
}

- (void)toListenAppEvent
{
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask | NSMouseMovedMask  handler:^NSEvent * __nullable(NSEvent * __nonnull event) {
        
        if (event.type == NSEventTypeMouseMoved)
        {
            if (self.designVC && self.designVC.designer)
            {
                [self updateWindowTitleStatus:self.designVC.structIsChanged];
            }
            return event;
        }
        
        if((([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) && ([[event /*charactersIgnoringModifiers*/characters] compare:@"s"] == 0)) {
            if (self.designVC && self.designVC.designer)
            {
                if (self.designVC.structIsChanged) {
                    [self.designVC todoSaveSetValue];
                    [self.designVC.designer saveToFile:self.designVC.modelUrl];
                    [self.designVC setIsChangedStruct:NO];
                }
                
                [self updateWindowTitleStatus:self.designVC.structIsChanged];
                
                return nil;//拦截系统保存
            }
        }
        
        return event;
    }];
}

- (void)updateWindowTitleStatus:(BOOL)changed
{
    NSWindow *wnd = NSApp.windows[0];
    
    if (changed) {
        wnd.title = [NSString stringWithFormat:@"%@*",self.smtitle];
    } else {
        wnd.title = [NSString stringWithFormat:@"%@",self.smtitle];
    }
}

///拖拽结束
-(void)dragDropView:(FKDragDropView *)dropview FileList:(NSArray*)fileList
{
    NSString * path = fileList.lastObject;
    NSString * ext = path.pathExtension;
    if ([ext isEqualToString:@"sqlitemodeld"] || [ext isEqualToString:@"sqlitemodel"]) {
        
        if (self.designVC.structIsChanged) {
            NSLog(@"结构有改变，是否保存");
            
            NSAlert *alert = [[NSAlert alloc]init];
            [alert addButtonWithTitle:@"确定"];
            [alert addButtonWithTitle:@"取消"];
            [alert setMessageText:@"警告"];
            [alert setInformativeText:@"当前数据结构模型有改变,确认不保存吗？"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
                if(returnCode == NSAlertFirstButtonReturn) {
                    if ([ext isEqualToString:@"sqlitemodel"]) {
                        //直接打开
                        self.lbpath.stringValue = path;
                        [self.designVC setModelUrl:[NSURL fileURLWithPath:path]];
                    } else {
                        
                        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
                        
                        //            NSLog(@"1.Contents of %@:",path);
                        NSString *plist = nil;
                        NSString *tpath = nil;
                        while ((tpath = [dirEnum nextObject]) != nil)
                        {
                            @autoreleasepool {
                                NSString *extfile = tpath.pathExtension;
                                if ([extfile isEqualToString:@"plist"]) {
                                    plist = tpath;
                                    break;
                                }
                            }
                        }
                        
                        if (plist.length > 0) {
                            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:plist]];
                            
                            NSString *model = dic[@"currentModelName"];
                            
                            if (model.length > 0) {
                                NSString *modelpath = [path stringByAppendingPathComponent:model];
                                self.lbpath.stringValue = modelpath;
                                [self.designVC setModelUrl:[NSURL fileURLWithPath:modelpath]];
                            }
                            
                        }
                        
                    }
                    
                    [self updateWindowTitleStatus:NO];
                    
                } else if(returnCode == NSAlertSecondButtonReturn){
                    
                }
            }];
            
        } else {
        
            if ([ext isEqualToString:@"sqlitemodel"]) {
                //直接打开
                self.lbpath.stringValue = path;
                [self.designVC setModelUrl:[NSURL fileURLWithPath:path]];
            } else {
               
                NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
                
    //            NSLog(@"1.Contents of %@:",path);
                NSString *plist = nil;
                NSString *tpath = nil;
                while ((tpath = [dirEnum nextObject]) != nil)
                {
                    @autoreleasepool {
                        NSString *extfile = tpath.pathExtension;
                        if ([extfile isEqualToString:@"plist"]) {
                            plist = tpath;
                            break;
                        }
                    }
                }
                
                if (plist.length > 0) {
                    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:plist]];
                    
                    NSString *model = dic[@"currentModelName"];
                    
                    if (model.length > 0) {
                        path = [path stringByAppendingPathComponent:model];
                        self.lbpath.stringValue = path;
                        [self.designVC setModelUrl:[NSURL fileURLWithPath:path]];
                    }

                }
                    
            }
        }
    }
}


@end
