//
//  ViewController.m
//  Socket
//
//  Created by mfw on 16/2/22.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import "ViewController.h"
#import "ParamView.h"
#import <Masonry/Masonry.h>
#import <sys/socket.h> // socket相关
#import <netinet/in.h> // internet相关
#import <arpa/inet.h> // 地址解析协议相关

@interface ViewController ()

@property (nonatomic, strong) ParamView *paramView;
@property (nonatomic, assign) int clientSocket;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_layoutSubviews];
}

#pragma mark - core method

- (BOOL)connectionToServer:(NSString *)host port:(int)port {
    if (host.length <= 0 || port <= 0) {
        return NO;
    }
    /**
     *  Socket
     *
     *  @param AF_INET     协议域，AF_INET（IPV4的网络开发）
     *  @param SOCK_STREAM Socket 类型，SOCK_STREAM(TCP)/SOCK_DGRAM(UDP，报文)
     *  @param 0           IPPROTO_TCP，协议，如果输入0，可以根据第二个参数，自动选择协议
     *
     *  @return 是否成功生成Sorket
     */
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    if (self.clientSocket > 0) {
        NSLog(@"create socket success. The socket is %d", self.clientSocket);
    } else {
        NSLog(@"create socket failed");
    }
    
    /**
     *  Socket address, internet style.
     */
    struct sockaddr_in serverAddress;
    // 家族地址 IPV4 - 协议
    serverAddress.sin_family = AF_INET;
    // 端口;htons,将一个无符号短整型的主机数值转换为网络字节顺序
    serverAddress.sin_port = htons(port);
    // 将IP地址转化为internet address,__uint32_t
    serverAddress.sin_addr.s_addr = inet_addr(host.UTF8String);
    
    /**
     *  connect to the server
     *
     *  @param self.clientSocket 客户端socket
     *  @param sockaddr          指向数据结构sockaddr的指针，其中包括目的端口和IP地址,
     *                           服务器的"结构体"地址，C语言没有对象
     *
     *  @return 成功则返回0，失败返回-1
     */
    int result = connect(self.clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    
    return result;
}

- (NSString *)sendMessageToServer:(NSString *)message {
    /**
     *  实际copy到缓冲区的字节数
     *
     *  @param int              客户端socket
     *  @param const void *     要发送的数据的缓冲区(想要发送的数据)
     *  @param size_t           实际要发送的字节数
     *  @param int              发送方式标志，一般为0
     *
     *  @return 返回发送的字节数
     */
    ssize_t sendMessageLength = send(self.clientSocket, message.UTF8String, strlen(message.UTF8String), 0);
    NSLog(@"sendMessageLength=%ld", sendMessageLength);
    
    uint8_t buffer[1024];
    /**
     *  接收数据的长度
     *
     *  @param int               创建的socket
     *  @param void *            存放接收的数据的缓冲区
     *  @param size_t            buf的长度
     *  @param int               接收数据的标记 0，就是阻塞式，一直等待服务器的数据
     *
     *  @return f
     */
    
    //这里为同步操作，若服务端没有返回数据，会卡死
    ssize_t recvLength = recv(self.clientSocket, buffer, sizeof(buffer), 0);
    
    // 从buffer中读取服务器发回的数据
    // 按照服务器返回的长度，从 buffer 中，读取二进制数据，建立 NSData 对象
    NSData *data = [NSData dataWithBytes:buffer length:recvLength];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

- (int)disconnection {
    return close(self.clientSocket);
}

#pragma mark - layout subviews

- (void)p_layoutSubviews {
    self.paramView = [ParamView new];
    self.paramView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.paramView];
    [self.paramView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
        make.height.mas_equalTo(@250);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.paramView.connectionBlock = ^(NSString *ip, NSString *port){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        int res = [strongSelf connectionToServer:ip port:port.intValue];
        if (!res) {
            NSLog(@"connect success");
        } else {
            NSLog(@"connect success");
        }
    };
    self.paramView.sendMessageBlock = ^(NSString *message) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (message.length) {
            NSLog(@"send messsage = %@", message);
            NSLog(@"receive messsage = %@", [strongSelf sendMessageToServer:message]);
        }
    };
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view resignFirstResponder];
}

@end
