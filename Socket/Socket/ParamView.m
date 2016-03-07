//
//  ParamView.m
//  Socket
//
//  Created by mfw on 16/3/5.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import "ParamView.h"
#import <Masonry/Masonry.h>

@interface ParamView ()

@property (nonatomic, strong) UITextField *ipField;
@property (nonatomic, strong) UITextField *portField;
@property (nonatomic, strong) UITextField *messageField;
@property (nonatomic, strong) UIButton *connectionBtn;
@property (nonatomic, strong) UIButton *sendBtn;

@end

@implementation ParamView

- (instancetype)init {
    if (self = [super init]) {
        [self p_layoutSubviews];
    }
    return self;
}

- (void)p_layoutSubviews {
    UILabel *tips = [UILabel new];
    tips.numberOfLines = 0;
    tips.backgroundColor = [UIColor orangeColor];
    tips.font = [UIFont systemFontOfSize:14];
    tips.text = @"可利用：nc -lk 端口号:始终监听本地计算机此端口的数据。\neg：nc -lk 6666；\n1、监听 6666端口;2、connettion；3、发送socket；服务器接收到socket；4、服务端send ：hello socket；";
    [self addSubview:tips];
    [tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.equalTo(self).with.offset(20);
        make.height.mas_equalTo(90);
    }];
    
    UIView *socketBgView = [UIView new];
    socketBgView.backgroundColor = [UIColor cyanColor];
    [self addSubview:socketBgView];
    [socketBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tips.mas_bottom).with.offset(10);
        make.left.and.right.equalTo(self);
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
    [self addSubview:sendBgView];
    [sendBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(socketBgView.mas_bottom).with.offset(20);
        make.left.and.right.equalTo(self);
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

- (void)connectToTheServer {
    if (self.connectionBlock) {
        self.connectionBlock(self.ipField.text, self.portField.text);
    }
}

- (void)sendMessageToServer {
    if (self.sendMessageBlock) {
        self.sendMessageBlock(self.messageField.text);
    }
}

@end
