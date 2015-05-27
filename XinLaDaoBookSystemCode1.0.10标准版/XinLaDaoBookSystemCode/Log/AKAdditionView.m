//
//  AKAdditionView.m
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14-8-29.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import "AKAdditionView.h"
#import "BSDataProvider.h"
#import "AKComboButton.h"


@implementation AKAdditionView
{
    NSMutableArray         *_dataArray;
    UIScrollView    *_scrollView;
    NSArray         *_info;
    NSMutableArray  *_classArray;
    NSMutableArray  *_buttonArray;
    NSMutableArray  *_selectArray;
    UISearchBar     *_barAddition;
    NSMutableArray  *aryCustomAdditions;
    int _total;
    
}
@synthesize delegate=_delegate;
/**
 *
 *
 */
- (id)initWithFrame:(CGRect)frame withSelectAddtions:(NSArray *)array
{
    self =[super initWithFrame:frame];
    if (self) {
        [self setTitle:@"附加项"];
        // Initialization code
        BSDataProvider *bs=[[BSDataProvider alloc] init];
        _classArray=[NSMutableArray array];
        _selectArray=[NSMutableArray array];
        _buttonArray=[NSMutableArray array];
        _dataArray=[NSMutableArray arrayWithArray:[bs getAdditionsAndClass]];
        [_selectArray addObjectsFromArray:array];
        UIScrollView *scroll=[[UIScrollView alloc] initWithFrame:CGRectMake(12, 50,frame.size.width, 50)];
        [scroll setContentSize:CGSizeMake(80*[_dataArray count], 50)];
        int i=0;
        [self addSubview:scroll];
        _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(10, 100,frame.size.width, frame.size.height-200)];
        [self addSubview:_scrollView];
        aryCustomAdditions=[NSMutableArray array];
        for (NSDictionary *dict in _selectArray) {
            if (![dict objectForKey:@"FCODE"]) {
                [aryCustomAdditions addObject:dict];
            }
        }
        NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:@"自定义",@"name",aryCustomAdditions,@"addition", nil];
        [_dataArray addObject:dict];
        for (id arry in _dataArray) {
            //            if ([arry count]>0) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(120*i+10, 7,120, 40);
            if (arry==[_dataArray lastObject])
                [button setTitle:[arry objectForKey:@"name"] forState:UIControlStateNormal];
            else
                [button setTitle:[[arry objectAtIndex:0] objectForKey:@"name"] forState:UIControlStateNormal];
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            i==0?[button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"blackButton.png"] forState:UIControlStateNormal]:[button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"whiteButton.png"] forState:UIControlStateNormal];
            button.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
            [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
            button.tag=i;
            [scroll addSubview:button];
            if (i==0) {
                [self selectButton:button];
            }
            [_classArray addObject:button];
            i++;
            //            }
        }
        NSArray *array=[[NSArray alloc] initWithObjects:@"确认",@"删除",@"取消", nil];
        i=0;
        for (NSString *str in array) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:str forState:UIControlStateNormal];
            button.frame=CGRectMake(200+75*i, frame.size.height-75, 70, 40);
            [button setBackgroundImage:[UIImage imageNamed:@"AlertViewButton.png"] forState:UIControlStateNormal];
            //            button.backgroundColor=[UIColor blueColor];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag=i;
            [self addSubview:button];
            i++;
        }
    }
    return self;
}

/**
 *  类别按钮事件
 *
 *  @param btn 类别的按钮
 */
-(void)selectButton:(UIButton *)btn
{
    /**
     *  选中的按钮换图片
     */
    for (UIButton *button in _classArray)
    {
        if (button==btn) {
            [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"blackButton.png"]forState:UIControlStateNormal];
        }else
        {
            [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"whiteButton.png"] forState:UIControlStateNormal];
        }
    }
    /**
     *  将原来的按钮移除
     */
    for (UIButton *button in _scrollView.subviews) {
        [button removeFromSuperview];
    }
    /**
     *  判断是否有按钮，如果没有生成按钮
     */
    if ([_buttonArray count]==0) {
        /**
         *  查询没有类的附加项array
         */
        for (id array in _dataArray) {
            NSMutableArray * ary=[NSMutableArray array];
            if (array ==[_dataArray lastObject]) {
                UIView *vAddition = [[UIView alloc] initWithFrame:CGRectMake(15,0, 320, 50)];
                _barAddition = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
                _barAddition.barStyle = UIBarStyleDefault;
                //       barAddition.showsBookmarkButton = YES;
                //       barAddition.tintColor = [UIColor whiteColor];
                _barAddition.delegate = self;
                [vAddition addSubview:_barAddition];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
                //      [btn setTitle:@"+" forState:UIControlStateNormal];
                btn.frame = CGRectMake(270, 0, 50, 50);
                [vAddition addSubview:btn];
                [btn addTarget:self action:@selector(addCustiomAddition) forControlEvents:UIControlEventTouchUpInside];
                [ary addObject:vAddition];
                //                [_buttonArray addObject:ary];
                /**
                 *  查询每一个附加项并生成按钮
                 */
                int i=0;
                //                NSArray *array1=[array objectForKey:@"addition"];
                for (NSDictionary *dict in aryCustomAdditions) {
                    AKComboButton *button=[AKComboButton buttonWithType:UIButtonTypeCustom];
                    button.frame=CGRectMake(i%4*130+5,i/4*90+50,130,80);
                    button.titleLabel1.frame=CGRectMake(85, 55, 25, 25);
                    [button setTitle:[dict objectForKey:@"FNAME"] forState:UIControlStateNormal];
                    //                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
                    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                    button.dataInfo=dict;
                    [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                    button.tag=i;
                    button.selected=NO;
                    button.btnTag=btn.tag;
                    [ary addObject:button];
                    i++;
                }
                [_buttonArray addObject:ary];
                
            }else
            {
                int i=0;
                
                /**
                 *  查询每一个附加项并生成按钮
                 */
                for (NSDictionary *dict in array) {
                    AKComboButton *button=[AKComboButton buttonWithType:UIButtonTypeCustom];
                    button.frame=CGRectMake(i%4*110+5,i/4*90,110,80);
                    button.titleLabel1.frame=CGRectMake(85, 55, 25, 25);
                    [button setTitle:[dict objectForKey:@"FNAME"] forState:UIControlStateNormal];
                    //                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
                    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                    button.dataInfo=dict;
                    [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                    button.tag=i;
                    button.selected=NO;
                    button.btnTag=btn.tag;
                    [ary addObject:button];
                    i++;
                }
                [_buttonArray addObject:ary];
            }
        }
        /**
         *  判断之前是否选了附加项，如果有执行
         */
        for (NSDictionary *dict in _selectArray) {
            /**
             *  遍历按钮的数组
             */
            for (NSArray *array in _buttonArray) {
                /**
                 *  改变选中按钮按钮的图片
                 */
                for (AKComboButton *button in array) {
                    
                    if ([_buttonArray lastObject]==array) {
                        if (![button isEqual:[array objectAtIndex:0]]) {
                            btn.selected=YES;
                            [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
                            button.titleLabel1.text=[dict objectForKey:@"total"];
                        }
                        
                    }else
                    {
                        if ([[button.dataInfo objectForKey:@"pk_redefine"] isEqualToString:[dict objectForKey:@"pk_redefine"]]) {
                            btn.selected=YES;
                            [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
                            button.titleLabel1.text=[dict objectForKey:@"total"];
                        }
                    }
                }
            }
        }
    }
    /**
     *  判断选中的类别，将该类别的按钮放在界面上
     */
    for (UIView *button in [_buttonArray objectAtIndex:btn.tag]) {
        [_scrollView addSubview:button];
        if (button.tag==[_buttonArray count]-1) {
            [_scrollView setContentSize:CGSizeMake(600, [[_buttonArray objectAtIndex:btn.tag] count]/4*90+200)];
        }else
        {
            [_scrollView setContentSize:CGSizeMake(480, [[_buttonArray objectAtIndex:btn.tag] count]/4*90+90)];
        }
        
    }
}
/**
 *  添加附加项
 */
-(void)addCustiomAddition
{
    if ([_barAddition.text length]>0){
        for (NSDictionary *dic in aryCustomAdditions){
            if ([[dic objectForKey:@"FNAME"] isEqualToString:_barAddition.text])
                return;
        }
        NSMutableDictionary *dicToAdd = [NSMutableDictionary dictionaryWithObjectsAndKeys:_barAddition.text,@"FNAME",@"0.0",@"FPRICE",@"1",@"total",_barAddition.text,@"pk_redefine", nil];
        [_selectArray addObject:dicToAdd];
        int i=0;
        i=[_buttonArray count];
        [_buttonArray removeAllObjects];
        _barAddition.text = nil;
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.tag=i-1;
        [aryCustomAdditions addObject:dicToAdd];
        [self selectButton:button];
    }
    
}
/**
 *  附加项按钮事件
 *
 *  @param btn 附加项按钮
 */
-(void)btnClick:(AKComboButton *)btn
{
    /**
     *  判断是否是删除
     */
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
    /**
     *  判断是否为0
     */
    btn.titleLabel1.text=[NSString stringWithFormat:@"%d",[btn.titleLabel1.text intValue]+1];
    if ([btn.titleLabel1.text intValue]==1) {
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:btn.dataInfo];
        [dict setObject:@"1" forKey:@"total"];
        [_selectArray addObject:dict];
    }else
    {
        for (NSMutableDictionary *dict in _selectArray) {
            if ([[dict objectForKey:@"FCODE"] isEqualToString:[btn.dataInfo objectForKey:@"FCODE"]]) {
                [dict setObject:btn.titleLabel1.text forKey:@"total"];
                break;
            }
        }
    }
}
-(void)buttonClick:(UIButton *)btn
{
    if (btn.tag==0) {
        [_delegate additionSelected:_selectArray];
    }else if (btn.tag==1){
        _total=10000;
    }else if (btn.tag==2){
        [_delegate additionSelected:nil];
    }
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    
    if([text isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        //        ^\d{m,n}$
        
        NSString *validRegEx =@"^[a-zA-Z0-9\u4E00-\u9FA5]";
        
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:text];
        
        if (myStringMatchesRegEx)
            
            return YES;
        
        else
            
            return NO;
    }
    
}
//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
