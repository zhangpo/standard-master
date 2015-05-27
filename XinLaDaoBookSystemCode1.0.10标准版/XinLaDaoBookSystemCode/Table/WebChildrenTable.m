//
//  WebChildrenTable.m
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14-8-27.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import "WebChildrenTable.h"
#import "BSTableButton.h"
#import "Singleton.h"

@implementation WebChildrenTable
@synthesize delegete=_delegete;

- (id)initWithFrame:(CGRect)frame withArray:(NSArray *)aryInfo
{
    self = [super initWithFrame:frame];
    if (self) {
        self.transform = CGAffineTransformIdentity;
        CVLocalizationSetting *localization=[CVLocalizationSetting sharedInstance];
        [self setTitle:[localization localizedString:@"搭台"]];
        int i=0;
        /**
         *  生成子台位按钮
         */
        for (NSDictionary *dict in aryInfo) {
//            (0, 0, 492, 354)
            BSTableButton *button=[BSTableButton buttonWithType:UIButtonTypeCustom];
            button.tableDic=dict;
            button.manTitle.text=[dict objectForKey:@"people"];
            button.frame=CGRectMake(30+145*(i%3),60+85*(i/3),135, 75);
            NSString *strImage;
            if ([[dict objectForKey:@"state"] intValue]==0) {
                strImage=@"TableButtonEmpty.png";
            }else
            {
                strImage=@"TableButtonOrdered.png";
            }
            UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:strImage ofType:nil]];
        
            [button setTitle:[NSString stringWithFormat:@"%@(%@)",[Singleton sharedSingleton].tableName,[dict objectForKey:@"tableName"]] forState:UIControlStateNormal];
            [button setBackgroundImage:img forState:UIControlStateNormal];
            
            button.tableType=[[dict objectForKey:@"state"] intValue];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag=i;
            [self addSubview:button];
            i++;
        }
        /**
         *  取消按钮
         */
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(380, 280, 70, 40);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor redColor]];
        [self addSubview:btn];
        

    }
    return self;
}
#pragma mark - 自台位按钮事件
-(void)buttonClick:(BSTableButton *)btn
{
    [_delegete ChiledrenTableButton:btn.tableDic];
}
#pragma mark - 取消按钮事件
-(void)btnClick
{
    [_delegete ChiledrenTableButton:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
