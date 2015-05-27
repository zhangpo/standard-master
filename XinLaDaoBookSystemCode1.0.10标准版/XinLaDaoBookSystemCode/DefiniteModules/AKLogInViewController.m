//
//  AKLogInViewController.m
//  BookSystem
//
//  Created by chensen on 13-11-6.
//
//

#import "AKLogInViewController.h"
#import "AKDeskMainViewController.h"
#import "AKSettingUpViewController.h"
#import "AKOrderRepastViewController.h"
#import "BSDataProvider.h"
#import "Singleton.h"
#import "AKForecastSalesViewController.h"
#import "BSSettingViewController.h"
#import "AKsCanDanListClass.h"
#import "PaymentSelect.h"
#import "SVProgressHUD.h"
#import "UIKitUtil.h"
#import "CVLocalizationSetting.h"


#define HHTserviceMin @"7.3.53"     //hhtservice最小支持版本号
#define HHTserviceMax @"7.0.30"     //hhtservice最大支持版本号

@interface AKLogInViewController ()
{
    UILabel         *lb;            //显示当前登录的员工号
    UITextField     *_textField1;   //账号
    UITextField     *_textField2;   //密码
}
@end

@implementation AKLogInViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    if ([[Singleton sharedSingleton].userInfo objectForKey:@"user"]==nil) {
        lb.text=@"";
    }
    else
    {
        lb.text=[NSString stringWithFormat:@"用户名:%@",[[Singleton sharedSingleton].userInfo objectForKey:@"user"]];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.textField2.secureTextEntry = YES;
    UIImageView *BG=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    [BG setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"logo.png"]];
    [self.view addSubview:BG];
    UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(135, 247, 490, 550)];
    [image setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"KeyboardBackground.png"]];
    [BG addSubview:image];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    NSArray *array=[[NSArray alloc]initWithObjects:[langSetting localizedString:@"User:"],[langSetting localizedString:@"Password:"],nil];
    for (int i=0; i<2; i++) {
        UILabel *lblUser=[[UILabel alloc] initWithFrame:CGRectMake(192, 258+65*i, 119, 52)];
        lblUser.text=[array objectAtIndex:i];
        lblUser.backgroundColor=[UIColor clearColor];
        lblUser.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [BG addSubview:lblUser];
    }
    _textField1=[[UITextField alloc] initWithFrame:CGRectMake(300, 270, 250, 40)];
    _textField1.borderStyle=UITextBorderStyleRoundedRect;
    _textField1.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:_textField1];
    _textField2=[[UITextField alloc] initWithFrame:CGRectMake(300, 325, 250, 40)];
    _textField2.borderStyle=UITextBorderStyleRoundedRect;
    _textField2.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    _textField2.secureTextEntry = YES;
    [self.view addSubview:_textField2];
    lb=[[UILabel alloc] initWithFrame:CGRectMake(0, 10, 700, 30)];
    lb.textAlignment=NSTextAlignmentRight;
    [self.view addSubview:lb];
    lb.backgroundColor=[UIColor clearColor];
    
    _keyboardView = [[ZenKeyboardView alloc] initWithFrame:CGRectMake(135, 1024-650, 490, 400)];
    _keyboardView.delegate = self;
    _textField1.delegate=self;
    _textField2.delegate=self;
//    self.textField1.frame=CGRectMake(300, 270, 250, 40);
//    self.textField1.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
//    self.textField2.frame=CGRectMake(300, 325, 250, 40);
    [_textField1 becomeFirstResponder];
    [self.view addSubview:_keyboardView];
    /**
     *  是否需要注册
     *
     *  @param activated] 注册
     *
     *  @return
     */
//    if ([[[BSDataProvider alloc] init] activated]) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"setting.png"] forState:UIControlStateNormal];
        btn.frame=CGRectMake(708,944, 50, 50);
        [btn addTarget:self action:@selector(settingUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
//    }
    UILabel *lbl =[[UILabel alloc] initWithFrame:CGRectMake(0, 1004-20, 768, 20)];
    lbl.font=[UIFont systemFontOfSize:14];
    lbl.textColor=[UIColor whiteColor];
    lbl.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    lbl.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lbl];
    lbl.text = [NSString UUIDString];
}
/**
 *  键盘的按钮事件
 *
 *  @param button
 */
- (void)didNumericKeyPressed:(UIButton *)button
{
    CVLocalizationSetting *cvlocal=[CVLocalizationSetting sharedInstance];
    if([button.titleLabel.text isEqualToString:[cvlocal localizedString:@"Finish"]])
    {
        if ([self.textField1 isFirstResponder])
        {
            [self.textField2 becomeFirstResponder];
        }
        else
        {
            [self.textField1 becomeFirstResponder];
        }
    }
    else if ([button.titleLabel.text isEqualToString:[cvlocal localizedString:@"Delect"]])
    {
        [self didBackspaceKeyPressed];
    }
    else
    {
        if ([self.textField1 isFirstResponder])
        {
            self.textField1.text = [NSString stringWithFormat:@"%@%@", self.textField1.text, button.titleLabel.text];
        }else
        {
            self.textField2.text = [NSString stringWithFormat:@"%@%@", self.textField2.text, button.titleLabel.text];
        }
    }
    
}

- (void)didBackspaceKeyPressed {
    if ([self.textField1 isFirstResponder]) {
        NSInteger length = self.textField1.text.length;
        if (length == 0) {
            self.textField1.text = @"";
            return;
        }
        NSString *substring = [self.textField1.text substringWithRange:NSMakeRange(0, length - 1)];
        self.textField1.text = substring;
    }else
    {
        NSInteger length = self.textField2.text.length;
        if (length == 0) {
            self.textField2.text = @"";
            return;
        }
        NSString *substring = [self.textField2.text substringWithRange:NSMakeRange(0, length - 1)];
        self.textField2.text = substring;
    }
    
}
-(void)zenKeychongzhiDelegate
{
    self.textField1.text=@"";
    self.textField2.text=@"";
    [self.textField1 becomeFirstResponder];
}
-(void)zenKeydengluDelegate
{
    [self logIn:nil];
}

////md5加密
//- (NSString *)md5HexDigest:(NSString*)password
//{
//    const char *original_str = [password UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(original_str, strlen(original_str), result);
//    NSMutableString *hash = [NSMutableString string];
//    for (int i = 0; i < 16; i++)
//    {
//        [hash appendFormat:@"%02X", result[i]];
//    }
//    NSString *mdfiveString = [hash lowercaseString];
//    NSLog(@"Encryption Result = %@",mdfiveString);
//    return mdfiveString;
//}


//程序升级
//-(void)isupdata
//{
//    NSString *dianPuNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"DianPuId"];
//    //    NSString *banbenNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"versionNum"];
//    //    if(!banbenNum)
//    //    {
//    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
//    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
//    [[NSUserDefaults standardUserDefaults]setObject:versionNum forKey:@"versionNum"];
//    //    }
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设定时间格式,这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"yyyy"];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *yy = [dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setDateFormat:@"MM"];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *MM = [dateFormatter stringFromDate:[NSDate date]];
//    
//    NSString *xmlstr=[NSString stringWithFormat:@"choicesoft%@%@",yy,MM];
//    NSString *md5XmlStr=[self md5HexDigest:xmlstr];
//    
//    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
//    netAccess.delegate=self;
//    
//    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:md5XmlStr,@"xmlStr",dianPuNum,@"scode",versionNum,@"version", nil];
//    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"IsHHTUpgradeWebService"]] andPost:dict andTag:IsHHTUpgradeWebService];
//    
//}

////升级成功反馈信息
//-(void)isupdataFanKui
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设定时间格式,这里可以设置成自己需要的格式
//    [dateFormatter setDateFormat:@"yyyy"];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *yy = [dateFormatter stringFromDate:[NSDate date]];
//    [dateFormatter setDateFormat:@"MM"];
//    //用[NSDate date]可以获取系统当前时间
//    NSString *MM = [dateFormatter stringFromDate:[NSDate date]];
//    
//    NSString *xmlstr=[NSString stringWithFormat:@"choicesoft%@%@",yy,MM];
//    NSString *md5XmlStr=[self md5HexDigest:xmlstr];
//    
//    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
//    netAccess.delegate=self;
//    
//    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:md5XmlStr,@"xmlStr",@"",@"version",@"",@"ip",@"",@"oldVersion", nil];
//    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"HHTUpgradeVersion"]] andPost:dict andTag:HHTUpgradeVersion];
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  登录
 *
 *  @param sender
 */
- (IBAction)logIn:(UIButton *)sender {
//    ZBarReaderViewController *reader = [ZBarReaderViewController new];
//    reader.readerDelegate = self;
//    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
//    
//    ZBarImageScanner *scanner = reader.scanner;
//    
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    [self presentModalViewController:reader animated: YES];
    [SVProgressHUD dismiss];
    if (_textField1.text.length&&_textField2.text.length) {
        NSDictionary *requestDic = [NSDictionary dictionaryWithObjectsAndKeys:self.textField1.text,@"userCode",self.textField2.text,@"usePass", nil];
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        /**
         *  @param loginRequest: 登录信息
         */
        [NSThread detachNewThreadSelector:@selector(loginRequest:) toTarget:self withObject:requestDic];
    }else{
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"User and Password could not be empty"]
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                             otherButtonTitles:nil];
        [alert show];
    }
}
/**
 *  登录相应的事件
 *
 *  @param requestDic
 */
-(void)loginRequest:(NSDictionary *)requestDic
{
   

    BSDataProvider *dp=[[BSDataProvider alloc] init];
    NSDictionary *dict=[dp pLoginUser:requestDic];
    if (dict) {
        [SVProgressHUD dismiss];
        NSString *result = [[dict objectForKey:@"ns:return"] objectForKey:@"text"];
        NSLog(@"%@",result);
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([ary count]==1) {
            /**
             *  未知错误的判断
             */
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ary lastObject]
                                                           message:nil
                                                          delegate:nil
                                                 cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                 otherButtonTitles:nil];
            [alert show];
            
        }
        else
        {
            NSString *content=[ary objectAtIndex:1];
            NSString *str=[ary objectAtIndex:0];
            /**
             *  当为0时为成功
             */
            if ([str isEqualToString:@"0"]) {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
                [dict setObject:self.textField1.text forKey:@"user"];
                [dict setObject:self.textField2.text forKey:@"password"];
                [AKsNetAccessClass sharedNetAccess].UserPass=self.textField1.text;
                [Singleton sharedSingleton].userInfo=dict;
                [AKsNetAccessClass sharedNetAccess].baoliuXiaoshu=[ary objectAtIndex:3];
                [Singleton sharedSingleton].Time=[ary objectAtIndex:1];
                [AKsNetAccessClass sharedNetAccess].dataVersion=[ary objectAtIndex:4];
                [Singleton sharedSingleton].jurisdiction=[ary objectAtIndex:2];
                [Singleton sharedSingleton].userName=[ary objectAtIndex:6];
                NSString *min=HHTserviceMin;
//                NSString *max=HHTserviceMax;
//                if ([ary lastObject]) {
//                    NSArray *array1=[[ary lastObject] componentsSeparatedByString:@"."];
//                    NSArray *array2=[min componentsSeparatedByString:@"."];
//                    //                                NSArray *array3=[max componentsSeparatedByString:@"."];
//                    for (int i=0; i<3; i++) {
//                        if([[array1 objectAtIndex:i] intValue]<[[array2 objectAtIndex:i] intValue])
//                        {
//                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"HHTservice版本号低，请联系网管，及时更新%@以上版本的程序",min] message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//                            [alert show];
//                            alert=nil;
//                            return ;
//                        }
//                        
//                    }
//                    array1=nil;
//                    array2=nil;
//                }

                NSDictionary *BanBen=[[NSDictionary alloc]initWithObjectsAndKeys:[ary objectAtIndex:4],@"POS",[ary objectAtIndex:5],@"HHT", nil];
                [[NSUserDefaults standardUserDefaults]setObject:BanBen forKey:@"BanBen"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                if([ary objectAtIndex:4] && [ary objectAtIndex:5])
                {
                    if([[ary objectAtIndex:4]isEqualToString:[ary objectAtIndex:5]])
                    {
                        bs_dispatch_sync_on_main_thread(^{
                            AKDeskMainViewController *deskMainViewController = [[AKDeskMainViewController alloc]initWithNibName:nil bundle:nil];
                            [self.navigationController pushViewController:deskMainViewController animated:YES];
                        });

                        
                    }
                    else
                    {
                        bs_dispatch_sync_on_main_thread(^{
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Version updated FTP synchronize data"]
                                                                           message:nil
                                                                          delegate:self
                                                                 cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"NO"]
                                                                 otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"YES"],nil];
                            alert.tag=4;
                            [alert show];
                        });
                    }
                }
                
            }
            else
            {
                [SVProgressHUD dismiss];
                if (content==nil) {
                    content=[[CVLocalizationSetting sharedInstance] localizedString:@"network connection timeout"];
                }
                [SVProgressHUD showErrorWithStatus:content];
            }
        }
    }
    else
    {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[[CVLocalizationSetting sharedInstance] localizedString:@"network connection timeout"]];
        
    }
}
/**
 *  设置按钮事件
 *
 *  @param sender
 */
- (IBAction)settingUp:(UIButton *)sender//设置
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:[[CVLocalizationSetting sharedInstance] localizedString:@"Please enter the password"] delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"],nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alertView.tag=3;
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==4)
    {
        if(buttonIndex==1)
        {
            /**
             *  数据同步
             */
            BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeUpdate];
            [self.navigationController pushViewController:vcSetting animated:YES];
        }
    }
    else if (alertView.tag==3) {
        /**
         *  设置密码算法
         */
        if (buttonIndex==1) {
            NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
            NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];               NSInteger interval = [zone secondsFromGMTForDate:datenow]+60*60*24*3;
            NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yy"];
            //用[NSDate date]可以获取系统当前时间
            NSString *yy = [dateFormatter stringFromDate:localeDate];
            [dateFormatter setDateFormat:@"MM"];
            //用[NSDate date]可以获取系统当前时间
            NSString *MM = [dateFormatter stringFromDate:localeDate];
            [dateFormatter setDateFormat:@"dd"];
            //用[NSDate date]可以获取系统当前时间
            NSString *dd = [dateFormatter stringFromDate:localeDate];
            NSString *str=[NSString stringWithFormat:@"%@%@%@",dd,MM,yy];
            UITextField *tf1 = [alertView textFieldAtIndex:0];
            if ([tf1.text isEqualToString:str]) {
                AKSettingUpViewController *settingUpViewController = [[AKSettingUpViewController alloc]initWithNibName:nil bundle:nil];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:settingUpViewController];
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }
            else
                
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[[CVLocalizationSetting sharedInstance] localizedString:@"Wrong password, please enter again"] delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
                [alert show];
            }
            
        }
    }
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.inputView=[[UIView alloc]initWithFrame:CGRectZero];
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)Notification{
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [tempWindow setAlpha:0];
}
@end
