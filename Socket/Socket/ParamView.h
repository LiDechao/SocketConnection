//
//  ParamView.h
//  Socket
//
//  Created by mfw on 16/3/5.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParamView : UIView

@property (nonatomic, strong) UITextField *ipField;
@property (nonatomic, strong) UITextField *portField;
@property (nonatomic, strong) UITextField *messageField;

@property (nonatomic, copy) void (^connectionBlock)();
@property (nonatomic, copy) void (^sendMessageBlock)(NSString *message);

@end
