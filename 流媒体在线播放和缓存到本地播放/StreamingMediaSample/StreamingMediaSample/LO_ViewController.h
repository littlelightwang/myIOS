//
//  LO_ViewController.h
//  StreamingMediaSample
//
//  Created by 石云雷 on 14-6-20.
//  Copyright (c) 2014年 www.lanou3g.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "M3U8Handler.h"
#import "VideoDownloader.h"
#import "HTTPServer.h"

@interface LO_ViewController : UIViewController<M3U8HandlerDelegate,VideoDownloadDelegate>

@property (nonatomic, strong)HTTPServer * httpServer;
@property (nonatomic, strong)VideoDownloader *downloader;


@end
