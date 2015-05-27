//
//  AKForecastSalesViewController.m
//  XinLaDaoBookSystemCode
//
//  Created by chensen on 14/12/5.
//  Copyright (c) 2014年 凯_SKK. All rights reserved.
//

#import "AKForecastSalesViewController.h"
#import "AKForecastsalesCell.h"
#import "BSDataProvider.h"
#import "AKMySegmentAndView.h"
#import "CVLocalizationSetting.h"

@interface AKForecastSalesViewController ()

@end

@implementation AKForecastSalesViewController
{
    NSArray *_dataArray;
    UITableView *table;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *titleImageView=[[UIImageView alloc]init];
    titleImageView.frame=CGRectMake(0,0,768,44);
    [titleImageView setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"title.png"]];
    titleImageView.userInteractionEnabled=YES;
    [self.view addSubview:titleImageView];
    NSMutableArray *array=[[[BSDataProvider alloc] init] getClassById];
    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"GRP",@"全部",@"DES", nil];
    [array insertObject:dict atIndex:0];
    int i=0;
    for (NSDictionary *dict in array) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor=[UIColor lightGrayColor];
        [button setTitle:[dict objectForKey:@"DES"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(10+100*(i%7),60+60*(i/7), 90, 50);
        button.tag=[[dict objectForKey:@"GRP"] intValue];
    
        [self.view addSubview:button];
        i++;
    }
    [self btnClick:nil];
    table=[[UITableView alloc] initWithFrame:CGRectMake(0, 120+[array count]/7*60, 768, 1024-[array count]/7*60-220) style:UITableViewStylePlain];
    table.delegate=self;
    table.dataSource=self;
    [self.view addSubview:table];
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 50)];
    view.backgroundColor=[UIColor redColor];
    NSArray *ary=[[NSArray alloc] initWithObjects:@"菜品编码",@"菜品名称",@"实际销量",@"预估销量",@"比率", nil];
    for (int j=0; j<5; j++) {
        UILabel *lb=[[UILabel alloc]init];
        lb.frame=CGRectMake(10+(768-20)/5*j, 0, (768-20)/5, 50);
        lb.text=[ary objectAtIndex:j];
        lb.textColor=[UIColor whiteColor];
        [view addSubview:lb];
        if (j>1) {
            lb.textAlignment=UITextAlignmentRight;
        }
    }
    
    table.tableHeaderView=view;
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(360, 1024-70, 140, 50);
    UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10,20, 130, 30)];
    if ([[[NSUserDefaults standardUserDefaults]
          stringForKey:@"language"] isEqualToString:@"en"])
        lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:14];
    else
        lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    lb.text=@"返回";
    lb.backgroundColor=[UIColor clearColor];
    lb.textColor=[UIColor whiteColor];
    [btn addSubview:lb];
    [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_normal_button.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_highlight_button.png"] forState:UIControlStateHighlighted];
    //        [btn setBackgroundImage:[UIImage imageNamed:@"TableButtonRed"] forState:UIControlStateNormal];
    //        [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
    btn.tintColor=[UIColor whiteColor];
    btn.tag=i+1;
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"cell";
    AKForecastsalesCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell=[[AKForecastsalesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setData:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)btnClick:(UIButton *)btn
{
    NSMutableArray *array;
    if (btn) {
        array=[NSMutableArray arrayWithArray:[[[BSDataProvider alloc] init] productEstimate:[NSString stringWithFormat:@"%d",btn.tag]]];
    }else
    {
        array=[NSMutableArray arrayWithArray:[[[BSDataProvider alloc] init] productEstimate:@"0"]];
    }
        if ([[array objectAtIndex:0] isEqualToString:@"0"]) {
            [array removeObject:[array objectAtIndex:0]];
            NSArray *ary=[NSArray arrayWithArray:array];
            NSMutableArray *data=[[NSMutableArray alloc] init];
            for (NSString *str in ary) {
                NSArray *dataAry=[str componentsSeparatedByString:@";"];
                NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[dataAry objectAtIndex:0],@"code",[dataAry objectAtIndex:1],@"DES",[dataAry objectAtIndex:2],@"actual",[dataAry objectAtIndex:3],@"estimate",[dataAry objectAtIndex:4],@"ratio", nil];
                [data addObject:dict];
            }
            _dataArray =data;
        }else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[array objectAtIndex:1] message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    
    [table reloadData];
}


@end
