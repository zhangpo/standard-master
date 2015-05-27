//
//  AKPrivateAdditionView.h
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14-8-29.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import "BSRotateView.h"

@protocol AKPrivateAdditionDelegate <NSObject>

- (void)privateAdditionSelected:(NSArray *)ary;

@end

@interface AKPrivateAdditionView : BSRotateView
{
    __weak id<AKPrivateAdditionDelegate>_delegate;
}
- (id)initWithFrame:(CGRect)frame withPcode:(NSString *)pcode;
@property(nonatomic,weak)__weak id<AKPrivateAdditionDelegate>delegate;
@end
