//
//  UITableViewCell+Badge.h
//
//  Created by XuNing on 16/1/6.
//  Copyright © 2016年 XuNing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XNBadgeView : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font; //default is systemFontOfSize:12.
@property (nonatomic, strong) UIColor *textColor; //default is white.
@property (nonatomic, strong) UIColor *badgeColor; //default is red.
@property (nonatomic, strong) NSNumber *cornerRadius; //default is half of height.
@property (nonatomic) BOOL forceCircular; //default is NO.

@end

@interface UITableViewCell (Badge)


//cell.badgeString = xxx; or cell.badgeView.text = xxx; both are OK :)
@property (nonatomic, strong, readonly) XNBadgeView *badgeView;

//Set to nil if you want to hide the badgeView temporarily.
@property (nonatomic, copy) NSString *badgeString;

@property (nonatomic, strong) UIFont *badgeFont;
@property (nonatomic, strong) UIColor *badgeTextColor;
@property (nonatomic, strong) UIColor *badgeColor;
@property (nonatomic, strong) NSNumber *badgeCornerRadius;

//Set to YES if you want a regular circle no matter the badgeString is. For example, when cell.badgeString = @": )".
@property (nonatomic) BOOL forceBadgeCircular;

@end
