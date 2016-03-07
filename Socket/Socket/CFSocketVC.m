//
//  SecondVC.m
//  Socket
//
//  Created by mfw on 16/3/4.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import "CFSocketVC.h"
#import "ParamView.h"
#import <Masonry/Masonry.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

CFSocketVC *g_viewPage;

@interface CFSocketVC () {
    CFSocketRef _socketRef;
}

@property (nonatomic, strong) ParamView *paramView;

@end

@implementation CFSocketVC

// socket 回掉函数
static void TCPClientConnectionCallBack(CFSocketRef socketRef, CFSocketCallBackType type, CFDataRef dataRef, const void *data, void *info) {
    NSLog(@"%s", info);
    CFSocketVC *client = (__bridge CFSocketVC *)info;
    if (dataRef) {
        NSLog(@"连接失败");
    } else {
        NSLog(@"连接成功");
        [client startReadMessageFromServer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_layoutSubviews];
}

- (void)createConnection:(NSString *)address {
    CFSocketContext socketContext = {
        0, // 结构体的版本，0
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL,
    };
    _socketRef = CFSocketCreate(kCFAllocatorDefault, // 为新对象分配内存，可以为nil
                                PF_INET, // 协议族，如果为0或者负数，则默认为PF_INET
                                SOCK_STREAM, // 套接字类型，如果协议族为PF_INET,则它会默认为SOCK_STREAM
                                IPPROTO_TCP, // 套接字协议，如果协议族是PF_INET且协议是0或者负数，它会默认为IPPROTO_TCP
                                kCFSocketConnectCallBack, // 触发回调函数的socket消息类型，具体见Callback Types
                                TCPClientConnectionCallBack, // 上面情况下触发的回调函数
                                &socketContext  // 一个持有CFSocket结构信息的对象，可以为nil
                                );
    if (_socketRef) {
        struct sockaddr_in sAddress;  // IPV4
        memset(&sAddress, 0, sizeof(sAddress));
        sAddress.sin_len = sizeof(sAddress);
        sAddress.sin_family = AF_INET;
        sAddress.sin_port = htons(6666);
        sAddress.sin_addr.s_addr = inet_addr(address.UTF8String);
        
        // 把sockaddr_in结构体中的地址转换为Data
        CFDataRef dataRef = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sAddress, sizeof(sAddress));
        CFSocketConnectToAddress(_socketRef, // 连接的socket
                                 dataRef, // CFDataRef类型的包含上面socket的远程地址的对象
                                 -1 // 连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，如果_socket消息类型为kCFSocketConnectCallBack，将会在连接成功或失败的时候在后台触发回调函数
                                 );
        CFRunLoopRef cRunloopRef = CFRunLoopGetCurrent(); // 获取当前线程的循环
        // 创建一个循环，但并没有真正加如到循环中，需要调用CFRunLoopAddSource
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);
        CFRunLoopAddSource(cRunloopRef, // 运行循环
                           sourceRef, // 增加的运行循环源, 它会被retain一次
                           kCFRunLoopCommonModes // 增加的运行循环源的模式
                           );
        CFRelease(sourceRef);
        NSLog(@"connect success");
        
    }
}

- (void)startReadMessageFromServer {
    dispatch_queue_t quere = dispatch_queue_create("readMessageFromServer", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(quere, ^{
        char buffer[255];
        while (recv(CFSocketGetNative(_socketRef), buffer, sizeof(buffer), 0)) {
            NSLog(@"%s", buffer);
        }
    });
}

#pragma mark - layout subviews

- (void)p_layoutSubviews {
    self.paramView = [ParamView new];
    self.paramView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.paramView];
    [self.paramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
        make.height.greaterThanOrEqualTo(@200);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.paramView.connectionBlock = ^(NSString *ip, NSString *port){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf createConnection:ip];
    };
    self.paramView.sendMessageBlock = ^(NSString *message) {
        NSLog(@"send---");
        __strong typeof(weakSelf) strongSelf = weakSelf;
        const char *data = message.UTF8String;
        send(CFSocketGetNative(strongSelf->_socketRef), data, strlen(data) + 1, 0);
        
//        if (strongSelf.paramView.messageField.text.length) {
//            NSString *msg = [strongSelf sendMessageToServer:strongSelf.paramView.messageField.text];
//            NSLog(@"%@", msg);
//        }
    };
}

@end
