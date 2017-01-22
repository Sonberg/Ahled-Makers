//
//  UITableViewCell+Badge.m
//
//  Created by XuNing on 16/1/6.
//  Copyright © 2016年 XuNing. All rights reserved.
//

#import "UITableViewCell+Badge.h"
#import <objc/runtime.h>

@implementation XNBadgeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.badgeColor = [UIColor redColor];
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:12];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self setNeedsDisplay];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    _badgeColor = badgeColor;
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self setNeedsDisplay];
}

- (void)setCornerRadius:(NSNumber *)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setForceCircular:(BOOL)forceCircular {
    _forceCircular = forceCircular;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font}];
    
    CALayer *badgeLayer = [CALayer layer];
    badgeLayer.frame = rect;
    badgeLayer.backgroundColor = self.badgeColor.CGColor;
    if (self.forceCircular) {
        badgeLayer.cornerRadius = rect.size.height / 2;
    } else {
        badgeLayer.cornerRadius = self.cornerRadius ? self.cornerRadius.floatValue : rect.size.height / 2;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    [badgeLayer renderInContext:context];
    CGContextRestoreGState(context);
    
    [self.text drawAtPoint:CGPointMake((rect.size.width - textSize.width) / 2,
                                       (rect.size.height - textSize.height) / 2)
           withAttributes:@{
                            NSFontAttributeName : self.font,
                            NSForegroundColorAttributeName : self.textColor
                            }];
}

@end



static const CGFloat badgeHorizPadding = 13;
static const CGFloat badgeVertPadding = 50;

@interface UITableViewCell ()
@property(nonatomic, strong) NSMutableArray *resizeLabels;
@end

@implementation UITableViewCell (Badge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getInstanceMethod(self, @selector(layoutSubviews));
        Method method2 = class_getInstanceMethod(self, @selector(xn_layoutSubviews));
        method_exchangeImplementations(method1, method2);
        
        method1 = class_getInstanceMethod(self, @selector(setEditing:animated:));
        method2 = class_getInstanceMethod(self, @selector(xn_setEditing:animated:));
        method_exchangeImplementations(method1, method2);
    });
}

- (void)xn_layoutSubviews {
    [self xn_layoutSubviews];
    
    if (self.badgeString) {
        self.badgeView.hidden = self.isEditing;
        
        self.badgeView.text = self.badgeString;
        if (self.badgeFont) {
            self.badgeView.font = self.badgeFont;
        }
        if (self.badgeCornerRadius) {
            self.badgeView.cornerRadius = self.badgeCornerRadius;
        }
        if (self.badgeColor) {
            self.badgeView.badgeColor = self.badgeColor;
        }
        if (self.badgeTextColor) {
            self.badgeView.textColor = self.badgeTextColor;
        }
        
        CGFloat badgeLeftOffset = 10;
        CGFloat badgeRightOffset = (self.accessoryType == UITableViewCellAccessoryNone ? 12 : 0);
        CGSize textSize = [self.badgeString sizeWithAttributes:@{NSFontAttributeName : self.badgeFont}];
        
        //use round() to avoid a irregular shape
        CGFloat realWidth = textSize.width + badgeHorizPadding;
        CGFloat realHeight = textSize.height + badgeVertPadding / textSize.height;
        if (self.forceBadgeCircular) {
            CGFloat sideLength = MAX(realWidth, realHeight);
            self.badgeView.frame = CGRectMake(round(self.contentView.frame.size.width - sideLength - badgeRightOffset),
                                              round((self.contentView.frame.size.height - sideLength) / 2),
                                              round(sideLength),
                                              round(sideLength));
        } else {
            self.badgeView.frame = CGRectMake(round(self.contentView.frame.size.width - realWidth - badgeRightOffset),
                                              round((self.contentView.frame.size.height - realHeight) / 2),
                                              round(realWidth),
                                              round(realHeight));
        }
        
        for (UILabel *label in self.resizeLabels) {
            if (CGRectGetMaxX(label.frame) >= CGRectGetMinX(self.badgeView.frame)) {
                CGFloat textLabelWidth = CGRectGetMinX(self.badgeView.frame) - CGRectGetMinX(label.frame) - badgeLeftOffset;
                label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, textLabelWidth, label.frame.size.height);
            }
        }
    } else {
        self.badgeView.hidden = YES;
    }
}

- (void)xn_setEditing:(BOOL)editing animated:(BOOL)animated {
    [self xn_setEditing:editing animated:animated];
    
    self.badgeView.hidden = editing;
}

#pragma mark - Getters
- (XNBadgeView *)badgeView {
    XNBadgeView *badge = objc_getAssociatedObject(self, _cmd);
    if (!badge) {
        badge = [[XNBadgeView alloc] init];
        [self.contentView addSubview:badge];
        
        objc_setAssociatedObject(self, _cmd, badge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return badge;
}

- (NSMutableArray *)resizeLabels {
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [NSMutableArray array];
        if (self.textLabel) {
            [array addObject:self.textLabel];
        }
        if (self.detailTextLabel) {
            [array addObject:self.detailTextLabel];
        }
        objc_setAssociatedObject(self, _cmd, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (NSString *)badgeString {
    if (objc_getAssociatedObject(self, _cmd)) {
        return objc_getAssociatedObject(self, _cmd);
    } else {
        return self.badgeView.text;
    }
}

- (UIFont *)badgeFont {
    if (objc_getAssociatedObject(self, _cmd)) {
        return objc_getAssociatedObject(self, _cmd);
    } else {
        return self.badgeView.font;
    }
}

- (UIColor *)badgeColor {
    if (objc_getAssociatedObject(self, _cmd)) {
        return objc_getAssociatedObject(self, _cmd);
    } else {
        return self.badgeView.badgeColor;
    }
}

- (UIColor *)badgeTextColor {
    if (objc_getAssociatedObject(self, _cmd)) {
        return objc_getAssociatedObject(self, _cmd);
    } else {
        return self.badgeView.textColor;
    }
}

- (NSNumber *)badgeCornerRadius {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)forceBadgeCircular {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - Setters
- (void)setBadgeString:(NSString *)badgeString {
    objc_setAssociatedObject(self, @selector(badgeString), badgeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    self.badgeView.text = badgeString;
    [self setNeedsLayout];
}

- (void)setBadgeFont:(UIFont *)badgeFont {
    objc_setAssociatedObject(self, @selector(badgeFont), badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.badgeView.font = badgeFont;
    [self setNeedsLayout];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    objc_setAssociatedObject(self, @selector(badgeColor), badgeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.badgeView.badgeColor = badgeColor;
    [self setNeedsLayout];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    objc_setAssociatedObject(self, @selector(badgeTextColor), badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.badgeView.textColor = badgeTextColor;
    [self setNeedsLayout];
}

- (void)setBadgeCornerRadius:(NSNumber *)badgeCornerRadius {
    objc_setAssociatedObject(self, @selector(badgeCornerRadius), badgeCornerRadius, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.badgeView.cornerRadius = badgeCornerRadius;
    [self setNeedsLayout];
}

- (void)setForceBadgeCircular:(BOOL)forceBadgeCircular {
    objc_setAssociatedObject(self, @selector(forceBadgeCircular), @(forceBadgeCircular), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.badgeView.forceCircular = forceBadgeCircular;
    [self setNeedsLayout];
}

@end
