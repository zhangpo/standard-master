//
//  AKPrivateAdditionView.m
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14-8-29.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import "AKPrivateAdditionView.h"
#import "BSDataProvider.h"
#import "AKComboButton.h"


@implementation AKPrivateAdditionView
{
    NSMutableArray *_buttonArray;
    NSMutableArray *_selectArray;
    int            _total;
}
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame withPcode:(NSString *)pcode
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIScrollView *scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(10, 50, frame.size.width, frame.size.height-150)];
//        [scroll setBackgroundColor:[UIColor redColor]];
        [self addSubview:scroll];
        _buttonArray =[NSMutableArray array];
        _selectArray =[NSMutableArray array];
        BSDataProvider *bs=[[BSDataProvider alloc] init];
        /**
         *  查询该菜品的所有的固定附加项
         */
        NSArray *array=[bs webSelectPrivateAddition:pcode];
        int i=0;
        int k=0;
        for (NSArray *ary in array) {
            //显示类别标题
            UILabel *lable=[[UILabel alloc] initWithFrame:CGRectMake(0,i, 300, 30)];
            [scroll addSubview:lable];
            lable.text=[NSString stringWithFormat:@"%@ %@-%@",[[ary lastObject] objectForKey:@"typvname"],[[ary lastObject] objectForKey:@"typmincount"],[[ary lastObject] objectForKey:@"typmaxcount"]];
            i+=30;
            int j=0;
            /**
             *  显示类别下的按钮
             */
            NSMutableArray *btnAry=[NSMutableArray array];
            for (NSDictionary *dict in ary) {
                AKComboButton *button=[AKComboButton buttonWithType:UIButtonTypeCustom];
                [button setTitle:[dict objectForKey:@"FoodFuJia_Des"] forState:UIControlStateNormal];
                button.lblCount.text=[NSString stringWithFormat:@"%@-%@",[dict objectForKey:@"MINCNT"],[dict objectForKey:@"MAXCNT"]];
                button.dataInfo=dict;
                button.btnTag=k;
                [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                button.frame=CGRectMake(j%4*135+10,i+j/4*85,120,80);
                [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [scroll addSubview:button];
                button.tag=j;
                if (dict==[ary lastObject]) {
                    i=i+j/4*85+80;
                }
                [btnAry addObject:button];
                [scroll setContentSize:CGSizeMake(frame.size.width, i)];
                j++;
            }
            /**
             *  将按钮放在数组中，方便判断数量
             */
            [_buttonArray addObject:btnAry];
            k++;
            
        }
        NSArray *ary=[[NSArray alloc] initWithObjects:@"确认",@"删除",@"取消", nil];
        i=0;
        for (NSString *str in ary) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:str forState:UIControlStateNormal];
            button.frame=CGRectMake(200+75*i, frame.size.height-75, 70, 40);
            button.backgroundColor=[UIColor blueColor];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag=i;
            [self addSubview:button];
            i++;
        }
    }
    return self;
}
/**
 *  附加项的点击事件
 *
 *  @param btn 附加项
 */
-(void)btnClick:(AKComboButton *)btn
{
    if (_total==10000) {
        /**
         *  判断删除是是否是选中的附加项
         */
        if ([btn.titleLabel1.text intValue]>0) {
            /**
             *  遍历选中的附加项
             */
            for (NSDictionary *dict in _selectArray) {
                /**
                 *  根据主键删除附加项
                 */
                if ([[dict objectForKey:@"pk_redefine"] isEqualToString:[btn.dataInfo objectForKey:@"pk_redefine"]]) {
                    [_selectArray removeObject:dict];
                    break;
                }
            }
            /**
             *  将按钮初始化
             */
            btn.selected=NO;
            btn.titleLabel1.text=@"";
            [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
        }
        _total=0;
        return;

    }
    int i=0;
    NSMutableDictionary *info=[NSMutableDictionary dictionaryWithDictionary:btn.dataInfo];
    for (AKComboButton *button in [_buttonArray objectAtIndex:btn.btnTag]) {
        i+=[button.titleLabel1.text intValue];
    }
    //判断类最大份数
    if (i==[[info objectForKey:@"typmaxcount"] intValue]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"已经是该层的最大份数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    /**
     *  判断单个附加项的份数
     */
    if ([btn.titleLabel1.text intValue]==[[info objectForKey:@"MAXCNT"] intValue]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"已经是该附加项的最大份数" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([btn.titleLabel1.text intValue]==0) {
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
        [info setObject:@"1" forKey:@"total"];
        [_selectArray addObject:info];
        btn.titleLabel1.text=@"1";
    }else
    {
        btn.titleLabel1.text=[NSString stringWithFormat:@"%d",[btn.titleLabel1.text intValue]+1];
        [info setObject:btn.titleLabel1.text forKey:@"total"];
        for (NSDictionary *dict in _selectArray) {
            if ([[dict objectForKey:@"pk_redefine"] isEqualToString:[info objectForKey:@"pk_redefine"]]) {
                [_selectArray removeObject:dict];
                [_selectArray addObject:info];
                break;
            }
        }
    }
}
-(void)buttonClick:(UIButton *)btn
{
    if (btn.tag==0) {
        [_delegate privateAdditionSelected:_selectArray];
    }else if (btn.tag==1){
        _total=10000;
    }else if (btn.tag==2){
        [_delegate privateAdditionSelected:nil];
    }

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
