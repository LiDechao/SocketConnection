//
//  ParamView.h
//  Socket
//
//  Created by mfw on 16/3/5.
//  Copyright © 2016年 mfw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParamView : UIView

@property (nonatomic, strong) UILabel *messageLbl;

@property (nonatomic, copy) void (^connectionBlock)(NSString *ip, NSString *port);
@property (nonatomic, copy) void (^sendMessageBlock)(NSString *message);

@end
