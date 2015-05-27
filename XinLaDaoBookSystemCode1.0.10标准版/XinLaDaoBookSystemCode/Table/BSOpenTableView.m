//
//  BSOpenTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSOpenTableView.h"
#import "CVLocalizationSetting.h"
#import "Singleton.h"
#import "AKsNetAccessClass.h"

@implementation BSOpenTableView
{
    NSString *openTag;
}
@synthesize delegate=_delegate,btn=_btn,tableDic=_tableDic;

- (id)initWithFrame:(CGRect)frame withtag:(NSString *)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        openTag=tag;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton_image"]) {//判断设置里的版本
            [self viewLoad1];
            
        }else{
            [self viewLoad2];
        }
        
    }
    return self;
}
-(void)viewLoad1
{
    self.transform = CGAffineTransformIdentity;
    CVLocalizationSetting *localization=[CVLocalizationSetting sharedInstance];
    if ([openTag intValue]==1) {
        [self setTitle:[localization localizedString:@"Open Table"]];
    }else
    {
        [self setTitle:@"搭台"];
    }
    
    lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 80, 30)];
    lblPeople.font=[UIFont italicSystemFontOfSize:20];
    lblPeople.textAlignment = UITextAlignmentRight;
    lblPeople.backgroundColor = [UIColor clearColor];
    lblPeople.text = [localization localizedString:@"People:"];
    [self addSubview:lblPeople];
    tfPeople = [[UITextField alloc] initWithFrame:CGRectMake(100, 130, 350, 30)];
    tfPeople.borderStyle = UITextBorderStyleRoundedRect;
    tfPeople.clearButtonMode=UITextFieldViewModeAlways;
    tfPeople.delegate=self;
    [self addSubview:tfPeople];
//    _btn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _btn.frame=CGRectMake(50, 180, 30, 30);
//    _btn.selected=NO;
//    [_btn setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"select_no.png"] forState:UIControlStateNormal];
//    [_btn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_btn];
//    UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(100, 180, 300, 40)];
//    lb.text=@"是否会员?";
//    lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:25];
//    lb.backgroundColor=[UIColor clearColor];
//    lb.textColor=[UIColor redColor];
//    [self addSubview:lb];
    btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnConfirm.frame = CGRectMake(240, 265, 90, 40);
    [btnConfirm setTitle:[localization localizedString:@"OK"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.font=[UIFont italicSystemFontOfSize:20];
//    [btnConfirm setImage:[UIImage imageNamed:@"AlertViewButton.png"] forState:UIControlStateNormal];
    [self addSubview:btnConfirm];
    btnConfirm.tag = 700;
    [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [btnConfirm setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
    btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnCancel.frame = CGRectMake(345, 265, 90, 40);
    btnCancel.titleLabel.font=[UIFont italicSystemFontOfSize:20];
    [btnCancel setTitle:[localization localizedString:@"Cancel"] forState:UIControlStateNormal];
    [btnCancel setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
//    [btnCancel setImage:[UIImage imageNamed:@"AlertViewButton.png"] forState:UIControlStateNormal];

    [self addSubview:btnCancel];
    btnCancel.tag = 701;
    [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
}
-(void)viewLoad2
{
    self.transform = CGAffineTransformIdentity;
    CVLocalizationSetting *localization=[CVLocalizationSetting sharedInstance];
    if ([openTag intValue]==1) {
        [self setTitle:[localization localizedString:@"Open Table"]];
    }else
    {
        [self setTitle:@"搭台"];
    }
    lblUser = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 90, 40)];
    lblUser.textAlignment = UITextAlignmentRight;
    lblUser.backgroundColor = [UIColor clearColor];
    lblUser.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    lblUser.text = [localization localizedString:@"Mister"];
    [self addSubview:lblUser];
    
    lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 90, 40)];
    lblPeople.textAlignment = UITextAlignmentRight;
    lblPeople.backgroundColor = [UIColor clearColor];
    lblPeople.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    lblPeople.text = [localization localizedString:@"Mistress"];
    [self addSubview:lblPeople];
    tfUser = [[UITextField alloc] initWithFrame:CGRectMake(110, 80, 320, 40)];
    tfPeople = [[UITextField alloc] initWithFrame:CGRectMake(110, 130, 320, 40)];
    tfUser.clearButtonMode=UITextFieldViewModeAlways;
    tfPeople.clearButtonMode=UITextFieldViewModeAlways;
    tfUser.keyboardType=UIKeyboardTypeNumberPad;
    tfUser.borderStyle = UITextBorderStyleRoundedRect;
    tfPeople.borderStyle = UITextBorderStyleRoundedRect;
    tfPeople.keyboardType=UIKeyboardTypeNumberPad;
    tfPeople.delegate=self;
    tfUser.delegate=self;
    tfWaiter.delegate=self;
    
    [self addSubview:tfUser];
    [self addSubview:tfPeople];
//    _btn=[UIButton buttonWithType:UIButtonTypeCustom];
//    _btn.frame=CGRectMake(50, 180, 30, 30);
//    _btn.selected=NO;
//    [_btn setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"select_no.png"] forState:UIControlStateNormal];
//    [_btn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_btn];
//    UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(100, 180, 300, 40)];
//    lb.text=@"是否会员?";
//    lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:25];
//    lb.backgroundColor=[UIColor clearColor];
//    lb.textColor=[UIColor redColor];
//    [self addSubview:lb];
    btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    btnConfirm.frame = CGRectMake(240, 265, 90, 40);
    
    [btnConfirm setTitle:[localization localizedString:@"OK"] forState:UIControlStateNormal];
    btnConfirm.titleLabel.textColor=[UIColor whiteColor];
    btnConfirm.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [btnConfirm setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
    [self addSubview:btnConfirm];
    btnConfirm.tag = 700;
    [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    
    btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(345, 265, 90, 40);
    btnCancel.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [btnCancel setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
    [btnCancel setTitle:[localization localizedString:@"Cancel"] forState:UIControlStateNormal];
    btnCancel.titleLabel.textColor=[UIColor whiteColor];
    [self addSubview:btnCancel];
    btnCancel.tag = 701;
    [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    //    tfUser.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
}


-(void)selectBtnClick:(UIButton *)btn
{
    if (btn.selected) {
        //[fmdb executeUpdate:@"updata "]
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"select_no.png"] forState:UIControlStateNormal];
          [AKsNetAccessClass sharedNetAccess].isVipShow=NO;
        btn.selected=NO;
    }
    else
    {
        if ([tfPeople.text length]>0||[tfUser.text length]>0) {
            [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"select_yes.png"] forState:UIControlStateNormal];
            [AKsNetAccessClass sharedNetAccess].isVipShow=YES;
            [AKsNetAccessClass sharedNetAccess].PeopleManNum=tfUser.text;
            [AKsNetAccessClass sharedNetAccess].PeopleWomanNum=tfPeople.text;
            [Singleton sharedSingleton].man=tfUser.text;
            [Singleton sharedSingleton].woman=tfPeople.text;
            [Singleton sharedSingleton].Seat=[AKsNetAccessClass sharedNetAccess].TableNum;
            btn.selected=YES;
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请录入人数" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alert show];
        }
    }
    
}
- (void)confirm{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton_image"]) {//判断设置里的版本
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"name"] forKey:@"user"];
//        [dic setObject:@"0" forKey:@"waiter"];
        
        if ([tfPeople.text length]>0)
        {
            [_tableDic setValue:tfPeople.text forKeyPath:@"man"];
            [Singleton sharedSingleton].man=tfPeople.text;
        }
        [_tableDic setValue:@"0" forKeyPath:@"tag"];
        [_tableDic setValue:openTag forKeyPath:@"openTag"];
        [_delegate openTableWithOptions:_tableDic];
        
    }else{
        if ([tfPeople.text intValue]>0||[tfUser.text intValue]>0) {
            NSMutableDictionary *dict=[NSMutableDictionary dictionary];
            [Singleton sharedSingleton].man=tfUser.text;
            [Singleton sharedSingleton].woman=tfPeople.text;
            if ([tfUser.text length]==0) {
                tfUser.text=0;
            }
            if ([tfPeople.text length]==0)
            {
                tfPeople.text=0;
            }
            [_tableDic setValue:tfPeople.text forKey:@"woman"];
            [_tableDic setValue:tfUser.text forKey:@"man"];
            [_tableDic setValue:@"1" forKey:@"tag"];
            [_tableDic setValue:openTag forKey:@"openTag"];
            [_delegate openTableWithOptions:_tableDic];
        }
        else
        {
            UIAlertView *al=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请录入人数" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [al show];
        }
        
    }
}

- (void)cancel{
    [_delegate openTableWithOptions:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    
    if([string isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        if ([textField.text length]>=2) {
            return NO;
        }
//        ^\d{m,n}$
        
        NSString *validRegEx =@"^[0-9]$";
        
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
        
        if (myStringMatchesRegEx)
            
            return YES;
        
        else
            
            return NO;
    }
    
}

@end
