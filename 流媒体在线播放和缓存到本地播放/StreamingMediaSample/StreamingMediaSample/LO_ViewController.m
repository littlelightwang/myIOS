//
//  LO_ViewController.m
//  StreamingMediaSample
//
//  Created by 石云雷 on 14-6-20.
//  Copyright (c) 2014年 www.lanou3g.com. All rights reserved.
//

#import "LO_ViewController.h"

@interface LO_ViewController ()

@end

@implementation LO_ViewController

-(void)dealloc
{
    [self.downloader release];
    self.downloader = nil;
    [self.httpServer release];
    self.httpServer = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //打开本地服务器
    [self openHttpServer];

}

- (void)openHttpServer
{
    
    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];  // 设置服务类型
    [self.httpServer setPort:12345]; // 设置服务器端口
    
    // 获取本地Documents路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    
    // 获取本地Documents路径下downloads路径
    NSString *webPath = [pathPrefix stringByAppendingPathComponent:kPathDownload];
    NSLog(@"-------------\nSetting document root: %@\n", webPath);
	
    // 设置服务器路径
	[self.httpServer setDocumentRoot:webPath];
    NSError *error;
    
	if(![self.httpServer start:&error])
	{
        NSLog(@"-------------\nError starting HTTP Server: %@\n", error);
	}
}


#pragma mark ----------在线流媒体播放----------
- (IBAction)playStreamingMedia:(id)sender {
    
    // 优酷视频m3u8新地址格式如下:http://pl.youku.com/playlist/m3u8?vid=XNzIwMDE5NzI4&type=mp4
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://pl.youku.com/playlist/m3u8?vid=XNzIwMDE5NzI4&type=mp4"];
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self.view addSubview:player.view];
    
    [self presentMoviePlayerViewControllerAnimated:player];
    
    
}

#pragma mark ----------视频下载----------
- (IBAction)downloadStreamingMedia:(id)sender {
    
    M3U8Handler *handler = [[M3U8Handler alloc] init];
    handler.delegate = self;
    // 解析m3u8视频地址
    [handler praseUrl:[NSString stringWithFormat:@"http://pl.youku.com/playlist/m3u8?vid=XNzIwMDE5NzI4&type=mp4"]];
    [handler release];
    
    // 开启网络指示器
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark ----------播放本地缓存视频----------
- (IBAction)playVideoFromLocal:(id)sender {
    
    NSString * playurl = [NSString stringWithFormat:@"http://127.0.0.1:12345/XNzIwMDE5NzI4/movie.m3u8"];
    NSLog(@"本地视频地址-----%@", playurl);
    
    // 获取本地Documents路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    
    // 获取本地Documents路径下downloads路径
    NSString *localDownloadsPath = [pathPrefix stringByAppendingPathComponent:kPathDownload];
    
    // 获取视频本地路径
    NSString *filePath = [localDownloadsPath stringByAppendingPathComponent:@"XNzIwMDE5NzI4/movie.m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断视频是否缓存完成，如果完成则播放本地缓存
    if ([fileManager fileExistsAtPath:filePath]) {
        MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString: playurl]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        [playerViewController release];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"当前视频未缓存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    
    
    
}

#pragma mark --------------视频解析完成----------------
-(void)praseM3U8Finished:(M3U8Handler*)handler
{
    handler.playlist.uuid = @"XNzIwMDE5NzI4";
    self.downloader = [[VideoDownloader alloc]initWithM3U8List:handler.playlist];
    self.downloader.delegate = self;
    [self.downloader startDownloadVideo];
}

#pragma mark --------------视频解析失败----------------
-(void)praseM3U8Failed:(M3U8Handler*)handler
{
    NSLog(@"failed -- %@",handler);
}

#pragma mark --------------视频下载完成----------------
-(void)videoDownloaderFinished:(VideoDownloader*)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [request createLocalM3U8file];
    NSLog(@"----------视频下载完成-------------");
    
}

#pragma mark --------------视频下载失败----------------
-(void)videoDownloaderFailed:(VideoDownloader*)request
{
    NSLog(@"----------视频下载失败-----------");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
