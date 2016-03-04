//
//  ViewController.m
//  Socket
//
//  Created by mfw on 16/2/22.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <sys/socket.h> // socket相关
#import <netinet/in.h> // internet相关
#import <arpa/inet.h> // 地址解析协议相关

@interface ViewController ()

@property (nonatomic, strong) UITextField *ipField;
@property (nonatomic, strong) UITextField *portField;
@property (nonatomic, strong) UIButton *connectionBtn;
@property (nonatomic, strong) UITextField *messageField;
@property (nonatomic, strong) UIButton *sendBtn;

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
        NSLog(@"Socket create success %d", self.clientSocket);
    } else {
        NSLog(@"Socket create failed");
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

#pragma mark - button action

- (void)connectToTheServer {
    int res = [self connectionToServer:self.ipField.text port:self.portField.text.intValue];
    NSLog(@"%D", res);
}

- (void)sendMessageToServer {
    if (self.messageField.text.length) {
        NSString *msg = [self sendMessageToServer:self.messageField.text];
        NSLog(@"%@", msg);
    }
}

#pragma mark - layout subviews

- (void)p_layoutSubviews {
    UILabel *tips = [UILabel new];
    tips.numberOfLines = 0;
    tips.backgroundColor = [UIColor orangeColor];
    tips.font = [UIFont systemFontOfSize:14];
    tips.text = @"可利用：nc -lk 端口号:始终监听本地计算机此端口的数据。\neg：nc -lk 6666；\n1、监听 6666端口;2、connettion；3、发送socket；服务器接收到socket；4、服务端send ：hello socket；";
    [self.view addSubview:tips];
    [tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
        make.height.greaterThanOrEqualTo(@30);
    }];
    
    UIView *socketBgView = [UIView new];
    socketBgView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:socketBgView];
    [socketBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tips.mas_bottom).with.offset(10);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    self.ipField = [UITextField new];
    self.ipField.backgroundColor = [UIColor whiteColor];
    self.ipField.borderStyle = UITextBorderStyleRoundedRect;
    self.ipField.text = @"127.0.0.1";
    [socketBgView addSubview:self.ipField];
    [self.ipField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(socketBgView).with.offset(30);
        make.centerY.equalTo(socketBgView);
        make.width.greaterThanOrEqualTo(@100);
        make.height.mas_equalTo(40);
    }];
    
    self.portField = [UITextField new];
    self.portField.backgroundColor = [UIColor whiteColor];
    self.portField.borderStyle = UITextBorderStyleRoundedRect;
    self.portField.text = @"6666";
    [socketBgView addSubview:self.portField];
    [self.portField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ipField.mas_right).with.offset(10);
        make.centerY.equalTo(socketBgView);
        make.width.greaterThanOrEqualTo(@80);
        make.height.mas_equalTo(40);
    }];
    
    self.connectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.connectionBtn.backgroundColor = [UIColor whiteColor];
    self.connectionBtn.layer.cornerRadius = 5;
    [self.connectionBtn setTitle:@"connection" forState:UIControlStateNormal];
    [self.connectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectionBtn addTarget:self action:@selector(connectToTheServer) forControlEvents:UIControlEventTouchUpInside];
    [socketBgView addSubview:self.connectionBtn];
    [self.connectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(socketBgView).offset(-20);
        make.width.greaterThanOrEqualTo(@20);
        make.centerY.equalTo(socketBgView);
        make.height.mas_equalTo(40);
    }];
    
    UIView *sendBgView = [UIView new];
    sendBgView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:sendBgView];
    [sendBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(socketBgView.mas_bottom).with.offset(20);
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.backgroundColor = [UIColor whiteColor];
    self.sendBtn.layer.cornerRadius = 5;
    [self.sendBtn setTitle:@"send" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(sendMessageToServer) forControlEvents:UIControlEventTouchUpInside];
    [sendBgView addSubview:self.sendBtn];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sendBgView);
        make.right.and.left.equalTo(self.connectionBtn);
        make.height.mas_equalTo(40);
    }];
    
    self.messageField = [UITextField new];
    self.messageField.backgroundColor = [UIColor whiteColor];
    self.messageField.borderStyle = UITextBorderStyleRoundedRect;
    [sendBgView addSubview:self.messageField];
    [self.messageField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sendBgView).with.offset(30);
        make.centerY.equalTo(sendBgView);
        make.right.equalTo(self.sendBtn.mas_left).offset(-30);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view resignFirstResponder];
}

@end
