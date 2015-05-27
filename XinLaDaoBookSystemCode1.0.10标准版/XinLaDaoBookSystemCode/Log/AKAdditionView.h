//
//  AKAdditionView.h
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14-8-29.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol AKAdditionViewDelegate

- (void)additionSelected:(NSArray *)ary;

@end

@interface AKAdditionView : BSRotateView<UISearchBarDelegate>
{
    __weak id<AKAdditionViewDelegate>_delegate;
}
@property(nonatomic,weak)__weak id<AKAdditionViewDelegate>delegate;
- (id)initWithFrame:(CGRect)frame withSelectAddtions:(NSArray *)array;
@end
