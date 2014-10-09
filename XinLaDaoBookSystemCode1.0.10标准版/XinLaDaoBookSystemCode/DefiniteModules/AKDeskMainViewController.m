//
//  AKDeskMainViewController.m
//  BookSystem
//
//  Created by chensen on 13-11-7.
//
//
#import "AKsNetAccessClass.h"
#import "AKDeskMainViewController.h"
#import "AKFilePath.h"
#import "AKOrderRepastViewController.h"
#import "Singleton.h"
#import "BSDataProvider.h"
#import "BSQueryViewController.h"
#import "AKURLString.h"
#import "AKsVipViewController.h"
#import "AKSelectCheck.h"
#import "AKsCanDanListClass.h"
#import "AKOrderLeft.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "BSAllCheakRight.h"
#import "SVProgressHUD.h"
#import "PaymentSelect.h"
#import "AKsNewVipViewController.h"
#import "AKMySegmentAndView.h"
#import "CVLocalizationSetting.h"

//#import "CVLocalizationSetting.h"
@interface AKDeskMainViewController ()

@end

@implementation AKDeskMainViewController
{
    UIControl *control;
    UISegmentedControl *segment;
    AKsWaitSeat             *_waitView;
    AKsWaitSeatOpenTable    *_waitOpenView;
    NSMutableArray          *_dataArray;
    NSMutableArray          *_youmianShowArray;
    AKschangeTableView      *_akschangeTable;
    
    AKsYudianShow           *_yuDianView;
    NSString                *_oldTableNum;
    NSString                *_newTableNum;
    AKsRemoveYudingView     *_removeYudianView;
    NSMutableDictionary     *_tabledict;
    AKsOpenSucceed          *_openSucceed;
    UIPanGestureRecognizer  *_pan;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Singleton sharedSingleton].CheckNum=@"";
    [Singleton sharedSingleton].man=@"";
    [Singleton sharedSingleton].woman=@"";
    [Singleton sharedSingleton].SELEVIP=NO;
    [Singleton sharedSingleton].isYudian=NO;
    self.navigationController.navigationBarHidden = YES;
    
    //    [self getTableList:_tabledict];
    bs_dispatch_sync_on_main_thread(^{
        /**
         *  刷新台位
         */
        [self updataTable];
    });
    
    
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    netAccess.zhangdanId=NULL;
    netAccess.PeopleManNum=NULL;
    netAccess.PeopleWomanNum=NULL;
    netAccess.phoneNum=NULL;
    netAccess.SettlemenVip=NO;
    netAccess.showVipMessageDict=nil;
    netAccess.yingfuMoney=NULL;
    netAccess.isVipShow=NO;
    
    
    
    
    //    if(netAccess.isVipShow)
    //    {
    [self dismissViews];
    if(_waitOpenView && _waitOpenView.superview)
    {
        [_waitOpenView removeFromSuperview];
        _waitOpenView=nil;
    }
    if (_waitView &&_waitView.superview)
    {
        [_waitView removeFromSuperview];
        _waitView = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    /**
     *  获取区域
     */
    NSArray *array=[dp getArea];
    NSMutableArray *array1=[[NSMutableArray alloc] init];
    //查询状态
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Area"]]) {
        for (NSDictionary *dict in array) {
            NSString *str=[dict objectForKey:@"TBLNAME"];
            [array1 addObject:str];
        }
        deskClassArray = [[NSMutableArray alloc]initWithArray:array1];
    }else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Floor"]]){
        deskClassArray = [[NSMutableArray alloc]initWithArray:[dp getFloor]];
    }else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Status"]]){
        deskClassArray = [[NSMutableArray alloc]initWithArray:[dp getStatus]];
    }
    [deskClassArray insertObject:[[CVLocalizationSetting sharedInstance] localizedString:@"All"] atIndex:0];
    DESArray = [[NSMutableArray alloc]init];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Status"]]) {
        [DESArray setArray:deskClassArray];
    }else{
        for (NSString *str in deskClassArray) {
            [DESArray addObject:str];
        }
    }
    
    _tabledict=[NSMutableDictionary dictionary];
    if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    segment = [[UISegmentedControl alloc] initWithItems:DESArray];
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,  [UIFont fontWithName:@"ArialRoundedMTBold"size:20],UITextAttributeFont ,[UIColor whiteColor],UITextAttributeTextShadowColor ,nil];
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    segment.frame = CGRectMake(0, 0, 768, 40);
    
    [segment setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"title.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [segment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    segment.selectedSegmentIndex = 0;
    scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(25, 100, 718, 850)];
    [self.view addSubview:scvTables];
    CVLocalizationSetting *cvlocal=[CVLocalizationSetting sharedInstance];
    NSArray *array2=[[NSArray alloc] initWithObjects:[cvlocal localizedString:@"Logout"],[cvlocal localizedString:@"Wait"],[cvlocal localizedString:@"Combine Table"],[cvlocal localizedString:@"Change Table"],[cvlocal localizedString:@"Select Order"],[cvlocal localizedString:@"Updata"], nil];
    for (int i=0; i<[array2 count]; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake((768-20)/[array2 count]*i, 1024-70, 140, 50);
        UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10,20, 130, 30)];
        lb.text=[array2 objectAtIndex:i];
        if ([[[NSUserDefaults standardUserDefaults]
              stringForKey:@"language"] isEqualToString:@"en"])
            lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:14];
        else
            lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        lb.backgroundColor=[UIColor clearColor];
        lb.textColor=[UIColor whiteColor];
        [btn addSubview:lb];
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_normal_button.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_highlight_button.png"] forState:UIControlStateHighlighted];
        //        [btn setBackgroundImage:[UIImage imageNamed:@"TableButtonRed"] forState:UIControlStateNormal];
        //        [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        btn.tintColor=[UIColor whiteColor];
        btn.tag=i+1;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    [self searchBarInit];
    _pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tuodongView:)];
    _pan.delaysTouchesBegan=YES;
    
}

/**
 *  按钮事件
 *
 *  @param btn
 */


-(void)btnClick:(UIButton *)btn
{
    /**
     *  注销
     */
    if (btn.tag==1) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Logout?"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"], nil];
        alert.tag=2;
        [alert show];
    }
    else if (btn.tag==2){
        /**
         *  等位预定
         */
        [self dismissViews];
        if (!_waitView){
            _waitView=[[AKsWaitSeat alloc]initWithFrame:CGRectMake(768-350, 50, 350, 870)];
            _waitView.delegate=self;
            [self.view addSubview:_waitView];
            [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        }
        else
        {
            [_waitView removeFromSuperview];
            _waitView = nil;
        }
        
        if (_waitOpenView)
        {
            [_waitOpenView removeFromSuperview];
            _waitOpenView=nil;
            
        }
    }else if(btn.tag==3)
    {
        /**
         *  并台
         */
        [[NSUserDefaults standardUserDefaults] setObject:@"multiple" forKey:@"DeskMainButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        scvTables.userInteractionEnabled=NO;
        if (!vSwitch){
            [self dismissViews];
            vSwitch = [[BSSwitchTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vSwitch.delegate = self;
            [vSwitch addGestureRecognizer:_pan];
            //        vSwitch.center = btnSwitch.center;
            vSwitch.center = CGPointMake(384, 1004-27);
            [self.view addSubview:vSwitch];
            [vSwitch firstAnimation];
        }
        else{
            [vSwitch removeFromSuperview];
            vSwitch = nil;
        }
    }else if (btn.tag==4)
    {
        /**
         *  换台
         */
        scvTables.userInteractionEnabled=NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"switchTable" forKey:@"DeskMainButton"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (!vSwitch){
            [self dismissViews];
            vSwitch = [[BSSwitchTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
            vSwitch.delegate = self;
            [vSwitch addGestureRecognizer:_pan];
            //        vSwitch.center = btnSwitch.center;
            vSwitch.center = CGPointMake(384, 1004-27);
            [self.view addSubview:vSwitch];
            [vSwitch firstAnimation];
        }
        else{
            [vSwitch removeFromSuperview];
            vSwitch = nil;
        }
    }else if (btn.tag==5){
        /**
         *  查询台位信息
         */
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Please enter the Table"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"],nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = 4;
        [alertView show];
    }else
    {
        /**
         *  刷新
         */
        if (_waitView)
            [_waitView addshowTableView];
        else
            [self updataTable];
    }
}

//界面可拖动
-(void)tuodongView:(UIPanGestureRecognizer *)pan
{
    
    UIView *piece = [pan view];
    NSLog(@"%@",piece);
    if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [pan translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+ translation.y)];
        
        [pan setTranslation:CGPointZero inView:self.view];
    }
    
}

-(void)viewClick
{
    [self dismissViews];
}
/**
 *  台位搜索框
 */
- (void)searchBarInit {
    UISearchBar *searchBar= [[UISearchBar alloc] initWithFrame:CGRectMake(0, 45, 768, 50)];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeDefault;
	searchBar.backgroundColor=[UIColor clearColor];
	searchBar.translucent=YES;
	searchBar.placeholder=@"搜索";
	searchBar.delegate = self;
	searchBar.barStyle=UIBarStyleDefault;
    [self.view addSubview:searchBar];
}
/**
 *  搜索框事件
 *
 */
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    NSDictionary *info=[[NSDictionary alloc]initWithObjectsAndKeys:@"",@"area",@"",@"floor",@"",@"state",_searchBar.text,@"tableNum", nil];
    _tabledict=info;
    [self getTableList:_tabledict];
    
    //    area=%@&floor=%@&state=
}
#pragma mark  AKsWaitSeatDelegate
/**
 *  删除预定界面
 */
-(void)clickMissButton
{
    [self dismissViews];
    if (!_removeYudianView)
    {
        if(_removeYudianView && _removeYudianView.superview)
        {
            [_removeYudianView removeFromSuperview];
            _removeYudianView=nil;
        }
        _removeYudianView=[[AKsRemoveYudingView alloc]initWithFrame:CGRectMake(0, 0, 492, 354)];
        _removeYudianView.delegate=self;
        [_removeYudianView addGestureRecognizer:_pan];
        [self.view addSubview:_removeYudianView];
    }
    else
    {
        [_removeYudianView removeFromSuperview];
        _removeYudianView = nil;
    }
    
}
/**
 *  添加等位信息
 */
-(void)clickAddButton
{
    [self dismissViews];
    /**
     *  等位开台
     */
    if (!_waitOpenView)
    {
        if(_waitOpenView && _waitOpenView.superview)
        {
            [_waitOpenView removeFromSuperview];
            _waitOpenView=nil;
        }
        _waitOpenView=[[AKsWaitSeatOpenTable alloc]initWithFrame:CGRectMake(0, 0, 492, 354)];
        _waitOpenView.delegate=self;
        [_waitOpenView addGestureRecognizer:_pan];
        [self.view addSubview:_waitOpenView];
    }
    else
    {
        [_waitOpenView removeFromSuperview];
        _waitOpenView = nil;
    }
}
-(void)removeHudOnMainThread
{
    [SVProgressHUD dismiss];
}

-(void)clickTableViewIndexRow:(AKsWaitSeatClass *)waitSeatPeople
{
    [self dismissViews];
    [Singleton sharedSingleton].man=waitSeatPeople.manNum;
    [Singleton sharedSingleton].woman=waitSeatPeople.womanNum;
    [Singleton sharedSingleton].Seat=waitSeatPeople.phoneNum;
    [Singleton sharedSingleton].CheckNum=waitSeatPeople.zhangdan;
    [Singleton sharedSingleton].WaitNum=waitSeatPeople.waitNum;
    [AKsNetAccessClass sharedNetAccess].PeopleManNum=waitSeatPeople.manNum;
    [AKsNetAccessClass sharedNetAccess].PeopleWomanNum=waitSeatPeople.womanNum;
    [AKsNetAccessClass sharedNetAccess].TableNum=waitSeatPeople.waitNum;
    [AKsNetAccessClass sharedNetAccess].zhangdanId=waitSeatPeople.zhangdan;
    [AKsNetAccessClass sharedNetAccess].phoneNum=waitSeatPeople.phoneNum;
    
    
    //    判断数据库是否有以手机号未台位的账单
    /*
     如果有
     ：直接从数据库里面读出改账单的点菜详情并列出详情
     如果没有
     ：保存当前的单例数据，跳入到点餐页面
     */
    
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"queryWholeProducts"]] andPost:dict andTag:queryWholeProducts];
    
}

#pragma mark  --AKschangeTableViewDelegate

-(void)AkschangtableSure:(NSString *)phoneNum and:(NSString *)tableNum
{
    _newTableNum=tableNum;
    _oldTableNum=phoneNum;
    
    [self dismissViews];
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",phoneNum,@"tablenumSource",tableNum,@"tablenumDest",netAccess.zhangdanId,@"orderId", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"changeTableNum"]] andPost:dict andTag:changeTableNum];
    
}

-(void)Akschangtablecancle
{
    [_akschangeTable removeFromSuperview];
    _akschangeTable=nil;
}

//预定台位转换
-(void)HHTchangeTableNumSuccessFormWebService:(NSDictionary *)dict
{
    [SVProgressHUD dismiss];
    NSArray *array= [self getArrayWithDict:dict andFunction:changeTableNumName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        if(_waitView)
        {
            [_waitView removeFromSuperview];
            _waitView=nil;
        }
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Turntable success"]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"],nil];
            alert.tag=1003;
            [alert show];
            
        });
        
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"],nil];
            [alert show];
            
        });
        
    }
}
//查询账单
-(void)HHTqueryWholeProductsFormWebService:(NSDictionary *)dict
{
    [SVProgressHUD dismiss];
    
    _dataArray=[[NSMutableArray alloc]init];
    _youmianShowArray=[[NSMutableArray alloc]init];
    NSString *Content=[[[dict objectForKey:@"ns:queryWholeProductsResponse"]objectForKey:@"ns:return" ]objectForKey:@"text"];
    
    NSArray *array=[Content componentsSeparatedByString:@"#"];
    NSMutableArray  *caivalueArray=[[NSMutableArray alloc]init];
    NSMutableArray  *payValueArray=[[NSMutableArray alloc]init];
    
    if([array count]==1)
    {
        NSArray *result=[Content componentsSeparatedByString:@"@"];
        if([[result firstObject]isEqualToString:@"-1"])   //NULL服务器返回，如果相等则没有菜品
        {
            if([[result lastObject]isEqualToString:@"NULL"])
            {
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"This bill does not order"]
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"]
                                                          otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"The official position"],[[CVLocalizationSetting sharedInstance] localizedString:@"CancelWait"],[[CVLocalizationSetting sharedInstance] localizedString:@"Order"],nil];
                    alert.tag=1002;
                    [alert show];
                    
                });
                
            }
            else
            {
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[result lastObject]
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                });
                
            }
            
        }
        else
        {
            NSArray *caivalues=[[array firstObject]componentsSeparatedByString:@";"];
            for (int i=0; i<[caivalues count]; i++)
            {
                //    菜品key
                NSArray *caiarrykey=[[NSArray alloc]initWithObjects:Sisok,Sorderid,Spkid,Spcode,Spcname,Stpcode,Stpname,Stpnum,Spcount,Spromonum,Sfujiacode,Sfujianame,Sprice,Sfujiaprice,Sweight,Sweightflag,Sunit,Sistc,SrushCount,SpullCount,SIsQuit,SQuitCause,SrushOrCall,SeachPrice ,nil];
                
                if(![[caivalues objectAtIndex:i]isEqualToString:@""])
                {
                    
                    NSArray *result=[[caivalues objectAtIndex:i] componentsSeparatedByString:@"@"];
                    NSDictionary *dictData=[[NSDictionary alloc]initWithObjects:result forKeys:caiarrykey];
                    [caivalueArray addObject:dictData];
                }
                else
                {
                    break;
                }
            }
        }
    }
    else
    {
        //         菜品列表
        NSArray *caivalues=[[array firstObject]componentsSeparatedByString:@";"];
        for (int i=0; i<[caivalues count]; i++)
        {
            //    菜品key
            NSArray *caiarrykey=[[NSArray alloc]initWithObjects:Sisok,Sorderid,Spkid,Spcode,Spcname,Stpcode,Stpname,Stpnum,Spcount,Spromonum,Sfujiacode,Sfujianame,Sprice,Sfujiaprice,Sweight,Sweightflag,Sunit,Sistc,SrushCount,SpullCount,SIsQuit,SQuitCause,SrushOrCall,SeachPrice ,nil];
            
            if(![[caivalues objectAtIndex:i]isEqualToString:@""])
            {
                NSArray *result=[[caivalues objectAtIndex:i] componentsSeparatedByString:@"@"];
                NSDictionary *dictData=[[NSDictionary alloc]initWithObjects:result forKeys:caiarrykey];
                [caivalueArray addObject:dictData];
            }
            else
            {
                break;
            }
        }
        
        NSArray *payvalues=[[array objectAtIndex:1]componentsSeparatedByString:@";"];
        for (int i=0; i<[payvalues count]; i++)
        {
            //    支付key
            NSArray *payArraykey=[[NSArray alloc]initWithObjects:@"chenggong",@"zhangdan",@"Payname",@"Payprice", nil];
            //            支付方式列表
            if(![[payvalues objectAtIndex:i]isEqualToString:@""])
            {
                
                NSArray *result=[[payvalues objectAtIndex:i] componentsSeparatedByString:@"@"];
                NSDictionary *dictData=[[NSDictionary alloc]initWithObjects:result forKeys:payArraykey];
                [payValueArray addObject:dictData];
            }
            else
            {
                break;
            }
        }
        [AKsNetAccessClass sharedNetAccess].quandanbeizhu=[NSString stringWithFormat:@"%@",[array lastObject]];
    }
    if([caivalueArray count])
    {
        for (int i=0;i<[caivalueArray count] ; i++)
        {
            AKsCanDanListClass *caiList=[[AKsCanDanListClass alloc]init];
            
            caiList.isok=[[caivalueArray objectAtIndex:i]objectForKey:@"isok"];
            caiList.istc=[[caivalueArray objectAtIndex:i]objectForKey:@"istc"];
            caiList.fujiacode=[[caivalueArray objectAtIndex:i]objectForKey:@"fujiacode"];
            caiList.fujianame=[[caivalueArray objectAtIndex:i]objectForKey:@"fujianame"];
            caiList.fujiaprice=[[caivalueArray objectAtIndex:i]objectForKey:@"fujiaprice"];
            caiList.orderid=[[caivalueArray objectAtIndex:i]objectForKey:@"orderid"];
            caiList.pcname=[[caivalueArray objectAtIndex:i]objectForKey:@"pcname"];
            caiList.pcode=[[caivalueArray objectAtIndex:i]objectForKey:@"pcode"];
            caiList.pcount=[[caivalueArray objectAtIndex:i]objectForKey:@"pcount"];
            caiList.pkid=[[caivalueArray objectAtIndex:i]objectForKey:@"pkid"];
            caiList.price=[[caivalueArray objectAtIndex:i]objectForKey:@"price"];
            caiList.promonum=[[caivalueArray objectAtIndex:i]objectForKey:@"promonum"];
            caiList.tpcode=[[caivalueArray objectAtIndex:i]objectForKey:@"tpcode"];
            caiList.tpname=[[caivalueArray objectAtIndex:i]objectForKey:@"tpname"];
            caiList.tpnum=[[caivalueArray objectAtIndex:i]objectForKey:@"tpnum"];
            caiList.unit=[[caivalueArray objectAtIndex:i]objectForKey:@"unit"];
            caiList.weight=[[caivalueArray objectAtIndex:i]objectForKey:@"weight"];
            caiList.weightflag=[[caivalueArray objectAtIndex:i]objectForKey:@"weightflag"];
            caiList.pullCount=[[caivalueArray objectAtIndex:i]objectForKey:SpullCount];
            caiList.rushCount=[[caivalueArray objectAtIndex:i]objectForKey:SrushCount];
            caiList.rushOrCall=[[caivalueArray objectAtIndex:i]objectForKey:SrushOrCall];
            caiList.IsQuit=[[caivalueArray objectAtIndex:i]objectForKey:SIsQuit];
            caiList.QuitCause=[[caivalueArray objectAtIndex:i]objectForKey:SQuitCause];
            caiList.eachPrice=[[caivalueArray objectAtIndex:i]objectForKey:SeachPrice];
            
            [_dataArray addObject:caiList];
        }
        if([payValueArray count])
        {
            for (int i=0;i<[payValueArray count] ; i++)
            {
                AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
                youhui.youMoney=[[payValueArray objectAtIndex:i]objectForKey:@"Payprice"];
                youhui.youName=[[payValueArray objectAtIndex:i]objectForKey:@"Payname"];
                
                [_youmianShowArray addObject:youhui];
            }
        }
        
        if (!_yuDianView)
        {
            if(_yuDianView && _yuDianView.superview)
            {
                [_yuDianView removeFromSuperview];
                _yuDianView=nil;
            }
            _yuDianView=[[AKsYudianShow alloc]initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width-350, 902)  andArray:_dataArray andPayArray:_youmianShowArray];
            _yuDianView.delegate=self;
            [self.view addSubview:_yuDianView];
        }
        
        
    }
    
    //+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++
}

//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++
#pragma mark AKsRemoveYudingViewDelegate

-(void)sureAKsRemoveYudingView:(NSString *)phoneNum andMisNum:(NSString *)MisNum
{
    [self dismissViews];
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",phoneNum,@"tableNum",MisNum,@"misOrderId", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancelReserveTableNum"]] andPost:dict andTag:cancelReserveTableNum];
}

-(void)HHTcancelReserveTableNumSuccessFormWebService:(NSDictionary *)dict
{
    [SVProgressHUD dismiss];
    NSLog(@"%@",dict);
    NSArray *array=[self getArrayWithDict:dict andFunction:cancelReserveTableNumName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                  otherButtonTitles:nil];
            alert.tag=1004;
            [alert show];
            
        });
        
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
    }
    
}

-(void)cancleAKsRemoveYudingView
{
    if(_removeYudianView && _removeYudianView.superview)
    {
        [_removeYudianView removeFromSuperview];
        _removeYudianView=nil;
    }
}

//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++//+++++++++++++


#pragma mark AKsYudianShowDelegate
-(void)AKsYudianShowCancle
{
    if(_yuDianView && _yuDianView.superview)
    {
        [_yuDianView removeFromSuperview];
        _yuDianView=nil;
    }
}

-(void)AKsYudianShowSure
{
    [self dismissViews];
    _akschangeTable=[[AKschangeTableView alloc]initWithFrame:CGRectMake(0, 0, 492, 354) andPhoneNum:[AKsNetAccessClass sharedNetAccess].phoneNum];
    _akschangeTable.delegate=self;
    [_akschangeTable addGestureRecognizer:_pan];
    [self.view addSubview:_akschangeTable];
}
-(void)AKsYudianShowAddDish
{
    [Singleton sharedSingleton].isYudian=YES;
    [self AKOrder];
}
-(void)AKsYudianDismiss
{
    [self dismissViews];
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",[AKsNetAccessClass sharedNetAccess].phoneNum,@"tableNum",[Singleton sharedSingleton].WaitNum,@"misOrderId", nil];
    
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancelReserveTableNum"]] andPost:dict andTag:cancelReserveTableNum];
}

#pragma mark AKsWaitSeatOpenTableDelegate

-(void)openWaitTableWithOptions:(NSDictionary *)info
{
    if (info){
        if(_waitOpenView)
        {
            [_waitOpenView removeFromSuperview];
            _waitOpenView=nil;
        }
        
        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        
        netAccess.delegate=self;
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",[Singleton sharedSingleton].Seat,@"tableNum",[info objectForKey:@"man"],@"manCounts",[info objectForKey:@"woman"],@"womanCounts", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"reserveTableNum"]] andPost:dict andTag:reserveTableNum];
    }
    
}

-(void)cancleAKsWaitSeat
{
    if(_waitOpenView && _waitOpenView.superview)
    {
        [_waitOpenView removeFromSuperview];
        _waitOpenView=nil;
    }
}

-(void)VipClickWait
{
    //    AKsNewVipViewController *newVip=[[AKsNewVipViewController alloc]init];
    //    [self.navigationController pushViewController:newVip animated:YES];
    [AKsNetAccessClass sharedNetAccess].showVipMessageDict=nil;
    AKsVipViewController *vip=[[AKsVipViewController alloc] init];
    [self.navigationController pushViewController:vip animated:YES];
}

#pragma mark AksNetAccessDelegate

-(void)failedFromWebServie
{
    [SVProgressHUD dismiss];
    bs_dispatch_sync_on_main_thread(^{
        
        
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                      message:@"网络连接失败，请检查网络！"
                                                     delegate:nil
                                            cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                            otherButtonTitles:nil];
        [alert show];
    });
}


-(void)HHTreserveTableNumSuccessFormWebService:(NSDictionary *)dict
{
    [SVProgressHUD dismiss];
    NSArray *array= [self getArrayWithDict:dict andFunction:reserveTableNumName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        //        [self showAlter:[NSString stringWithFormat:@"预定成功\n 等位序号：%@号\n是否预点餐",[array objectAtIndex:2]]];
        [self dismissViews];
        [Singleton sharedSingleton].CheckNum=[array objectAtIndex:1];
        [Singleton sharedSingleton].WaitNum=[array objectAtIndex:2];
        [AKsNetAccessClass sharedNetAccess].zhangdanId=[array objectAtIndex:1];
        if (!_openSucceed){
            _openSucceed=[[AKsOpenSucceed alloc]initWithFrame:CGRectMake(0, 0, 492, 354)];
            _openSucceed.delegate=self;
            [self.view addSubview:_openSucceed];
            //            [self.view addSubview:HUD];
        }
        else
        {
            [_openSucceed removeFromSuperview];
            _openSucceed = nil;
        }
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
    }
    
}
-(void)OpenSucceed:(int)tag
{
    if (tag==101) {
        [Singleton sharedSingleton].isYudian=YES;
        if([AKsNetAccessClass sharedNetAccess].isVipShow)
        {
            [self VipClickWait];
        }
        else
        {
            
            [self AKOrder];
        }
    }
    else if(tag==102)
    {
        [_waitView reloadDataWaitTableView];
    }
    [_openSucceed removeFromSuperview];
    _openSucceed=nil;
}
-(void)showAlter:(NSString *)string
{
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"NO"]
                                              otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"YES"],nil];
        alert.tag=1001;
        [alert show];
        
    });
}



-(NSArray *)getArrayWithDict:(NSDictionary *)dict andFunction:(NSString *)functionName
{
    NSString *str=[[[dict objectForKey:[NSString stringWithFormat:@"ns:%@Response",functionName]]objectForKey:@"ns:return"]objectForKey:@"text"];
    NSArray *array=[str componentsSeparatedByString:@"@"];
    return array;
}



//    ==========================================================================================


//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updataTable
{
    [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
    [NSThread detachNewThreadSelector:@selector(getTableList:) toTarget:self withObject:_tabledict];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==2) {
        if (buttonIndex==1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 耗时的操作
                BSDataProvider *dp=[[BSDataProvider alloc] init];
                NSArray *array=[dp logout];
                [Singleton sharedSingleton].userInfo=nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[array objectAtIndex:0] intValue]==0) {
                        [Singleton sharedSingleton].userInfo=nil;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        UIAlertView *alwet=[[UIAlertView alloc] initWithTitle:@"提示" message:[array objectAtIndex:1] delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
                        [alwet show];
                    }
                    
                    //                    [alwet show];
                    
                });
            });
        }
    }else if (alertView.tag==4) {
        if (buttonIndex==1) {
            UITextField *tf1 = [alertView textFieldAtIndex:0];
            [Singleton sharedSingleton].Seat=tf1.text;
            AKSelectCheck *select=[[AKSelectCheck alloc] init];
            [self.navigationController pushViewController:select animated:YES];
        }
    }
    else if(alertView.tag==3){
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag==1001)
    {
        if(buttonIndex==0)
        {
            [_waitView reloadDataWaitTableView];
        }
        else
        {
            if(_waitView)
            {
                [_waitView removeFromSuperview];
                _waitView=nil;
            }
            [self AKOrder];
            [Singleton sharedSingleton].isYudian=YES;
        }
    }
    else if (alertView.tag==1002)
    {
        if(buttonIndex==1)
        {
            [self dismissViews];
            _akschangeTable=[[AKschangeTableView alloc]initWithFrame:CGRectMake(0, 0, 492, 354) andPhoneNum:[AKsNetAccessClass sharedNetAccess].phoneNum];
            _akschangeTable.delegate=self;
            [_akschangeTable addGestureRecognizer:_pan];
            [self.view addSubview:_akschangeTable];
        }else if(buttonIndex==2)
        {
            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
            netAccess.delegate=self;
            [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",[AKsNetAccessClass sharedNetAccess].phoneNum,@"tableNum",[Singleton sharedSingleton].WaitNum,@"misOrderId", nil];
            
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancelReserveTableNum"]] andPost:dict andTag:cancelReserveTableNum];
        }else if(buttonIndex==3)
        {
            [Singleton sharedSingleton].isYudian=YES;
            [self AKOrder];
        }
    }
    else if (alertView.tag==1003)
    {
        [self getTableList:_tabledict];
    }
    else if(alertView.tag==1004)
    {
        [_waitView reloadDataWaitTableView];
    }
    else if(alertView.tag==1005)
    {
        [Singleton sharedSingleton].isYudian=YES;
        [self AKOrder];
    }
    
}
//换台代理事件
- (void)switchTableWithOptions:(NSDictionary *)info{
    scvTables.userInteractionEnabled=YES;
    
    if (info){
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        //        [SVProgressHUD showProgress:-1 status:@"换台中..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 耗时的操作
            CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
            BSDataProvider *dp = [[BSDataProvider alloc] init];
            NSArray *dic=[[dp getOrdersBytabNum1:[info objectForKey:@"oldtable"]] objectForKey:@"message"];
            NSDictionary *dict= [dp pChangeTable:info];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                NSString *msg,*title;
                if (dict) {
                    NSString *result = [[[dict objectForKey:@"ns:changeTableResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
                    NSArray *ary=[result componentsSeparatedByString:@"@"];
                    
                    if ([[ary objectAtIndex:0] intValue]==0) {
                        [dp updateChangTable:info :[dic objectAtIndex:0]];
                    }
                    title=[ary objectAtIndex:1];
                }
                [self getTableList:_tabledict];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            });
        });
    }
    
    [self dismissViews];
}
//并台代理事件
-(void)multipleTableWithOptions:(NSDictionary *)info{
    scvTables.userInteractionEnabled=YES;
    if (info){
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        //        [SVProgressHUD showProgress:-1 status:@"并台中..."];
        [NSThread detachNewThreadSelector:@selector(multiple:) toTarget:self withObject:info];
    }
    [self dismissViews];
}
//换台请求
- (void)switchTable:(NSDictionary *)info{
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    
    NSArray *dic=[[dp getOrdersBytabNum1:[info objectForKey:@"oldtable"]]objectForKey:@"message"];
    NSDictionary *dict= [dp pChangeTable:info];
    NSString *msg,*title;
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:changeTableResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary=[result componentsSeparatedByString:@"@"];
        
        if ([[ary objectAtIndex:0] intValue]==0) {
            [dp updateChangTable:info :[dic objectAtIndex:0]];
        }
        title=[ary objectAtIndex:1];
    }
    [self getTableList:_tabledict];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
    [alert show];
}
/**
 *  并台请求
 *
 *  @param info 并台信息
 */
-(void)multiple:(NSDictionary *)info
{
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    NSDictionary *dict = [dp combineTable:info];
    [SVProgressHUD dismiss];
    NSString *msg
    ;
    if (dict) {
        NSString *result = [[[dict objectForKey:@"ns:combineTableResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary=[result componentsSeparatedByString:@"@"];
        if ([[ary objectAtIndex:0] intValue]==0) {
            [dp updatecombineTable:info :[ary objectAtIndex:1]];
            segment.selectedSegmentIndex=[Singleton sharedSingleton].segment;
            [self segmentClick:segment];
            msg=[ary objectAtIndex:1];
        }
        else
        {
            msg=[ary objectAtIndex:1];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
    [alert show];
    
}
#pragma mark View's Delegate
- (void)checkTableWithOptions:(NSDictionary *)info{
    scvTables.userInteractionEnabled=YES;
    self.checkTableInfo = info;
    
    //    [SVProgressHUD showProgress:-1 status:@"查询台位中..."];
    if (self.checkTableInfo){
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        [NSThread detachNewThreadSelector:@selector(getTableList:) toTarget:self withObject:info];
        //        self.dicListTable = info;
    }
    [self dismissViews];
}
/**
 *  查询台位请求
 *
 *  @param info
 */
- (void)getTableList:(NSDictionary *)info{
    _tabledict=[[NSMutableDictionary alloc] initWithDictionary:info];
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    NSDictionary *dict = [dp pListTable:info];
    //    [SVProgressHUD dismiss];
    
    NSMutableArray *mutTables = [NSMutableArray array];
    if (dict){
        NSString *result = [[[dict objectForKey:@"ns:listTablesResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        
        NSArray *ary = [result componentsSeparatedByString:@";"];
        
        for (NSString *str in ary) {
            NSArray *aryTableInfo = [str componentsSeparatedByString:@"@"];
            NSMutableDictionary *mutTable = [NSMutableDictionary dictionary];
            if ([aryTableInfo count]>=4){
                [mutTable setObject:[aryTableInfo objectAtIndex:1] forKey:@"code"];
                [mutTable setObject:[aryTableInfo objectAtIndex:2] forKey:@"short"];
                [mutTable setObject:[aryTableInfo objectAtIndex:3] forKey:@"name"];
                [mutTable setObject:[aryTableInfo objectAtIndex:4] forKey:@"status"];
                [mutTable setObject:[aryTableInfo objectAtIndex:5] forKey:@"num"];
                [mutTable setObject:[aryTableInfo objectAtIndex:6] forKey:@"man"];
                [mutTables addObject:mutTable];
            } else{
                [SVProgressHUD dismiss];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[aryTableInfo objectAtIndex:1] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
                [alert show];
                return;
            }
            
        }
    }
    else{
        [SVProgressHUD dismiss];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Query failed"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
        return;
    }
    self.aryTables = mutTables;
    /**
     *  显示台位
     */
    [self showTables:self.aryTables];
}
- (void)segmentClick:(UISegmentedControl*)sender
{
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[BSTableButton class]])
            [v removeFromSuperview];
    }
    
    NSString *DESStr = [DESArray objectAtIndex:segment.selectedSegmentIndex];
    CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
    if (segment.selectedSegmentIndex==0) {
        [_tabledict removeAllObjects];
    }else
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Area"]]) {
            BSDataProvider *dp=[[BSDataProvider alloc] init];
            NSArray *array=[dp getArea];
            [_tabledict setValue:[[array objectAtIndex:segment.selectedSegmentIndex-1] objectForKey:@"AREARID"] forKey:@"area"];
        }else
            if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Floor"]]){
                [_tabledict setObject:DESStr forKey:@"Floor"];
            }else if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]isEqualToString:[langSetting localizedString:@"Status"]]){
                //NSArray *array=[[NSArray alloc] initWithObjects:@"空闲",@"开台",@"点菜",@"结账",@"封台",@"换台",@"子台位",@"挂单",@"菜齐", nil];
                for(int i=0;i<9;i++)
                {
                    if (i<5) {
                        if (i==segment.selectedSegmentIndex) {
                            [_tabledict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"state"];
                        }
                    }
                    else
                    {
                        if (i==segment.selectedSegmentIndex) {
                            [_tabledict setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"state"];
                        }
                    }
                    
                }
            }
    }
    [Singleton sharedSingleton].segment=segment.selectedSegmentIndex;
    [self getTableList:_tabledict];
}
/**
 *  显示台位
 *
 *  @param ary 所有台位信息
 */
- (void)showTables:(NSArray *)ary{
    int count = [ary count];
    
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[BSTableButton class]])
            [v removeFromSuperview];
    }
    
    for (int i=0;i<count;i++){
        int row = i/5;
        int column = i%5;
        NSDictionary *dic = [ary objectAtIndex:i];
        
        BSTableButton *btnTable = [BSTableButton buttonWithType:UIButtonTypeCustom];
        btnTable.delegate = self;
        btnTable.tag = i;
        btnTable.frame = CGRectMake(145*column, 5+85*row, 135, 75);
        [btnTable addTarget:self action:@selector(tableClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnTable.tableTitle =[NSString stringWithFormat:@"%@",[dic objectForKey:@"num"]];
        btnTable.manTitle.text=[dic objectForKey:@"man"];
        btnTable.tableType = [[dic objectForKey:@"status"] intValue];
        
        [scvTables addSubview:btnTable];
        [scvTables setContentSize:CGSizeMake(141*column, 83*row+100)];
    }
    [SVProgressHUD dismiss];
    
}
#pragma mark Handle TableButton Click Event
//台位点击事件
- (void)tableClicked:(BSTableButton *)btn{
    [self dismissViews];
    [AKsNetAccessClass sharedNetAccess].showVipMessageDict=nil;
    [Singleton sharedSingleton].isYudian=NO;
    [Singleton sharedSingleton].Seat=@"";
    [AKsNetAccessClass sharedNetAccess].TableNum=NULL;
    
    dSelectedIndex = btn.tag;
    [Singleton sharedSingleton].dishArray=nil;
    NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];
    BSTableType type = [[info objectForKey:@"status"] intValue];
    UIAlertView *alert;
    segment.selectedSegmentIndex=[Singleton sharedSingleton].segment;
    /**
     *  当为空闲台位
     */
    if (type==BSTableTypeEmpty) {
        [AKsNetAccessClass sharedNetAccess].TableNum=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
        if (vOpen){
            [vOpen removeFromSuperview];
            vOpen = nil;
        }
        vOpen = [[BSOpenTableView alloc] initWithFrame:CGRectMake(0, 0, 492, 354)];
        vOpen.delegate = self;
        vOpen.center = CGPointMake(384, 512);
        vOpen.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        [vOpen addGestureRecognizer:_pan];
        [self.view addSubview:vOpen];
        scvTables.userInteractionEnabled=NO;
        [UIView animateWithDuration:0.5f animations:^(void) {
            vOpen.transform = CGAffineTransformIdentity;
        }];
    }
    /**
     *  开台
     *
     */
    else if (type==BSTableTypeOpen)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Please select operation"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"Order"],[[CVLocalizationSetting sharedInstance] localizedString:@"Clear the table"], nil];
        alert.tag=kdish;
        [alert show];
    }
    /**
     *  结账
     *
     */
    else if (type==BSTableTypeCheck){
        alert = [[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"This table is already the checkout, to clear the table?"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"], nil];
        alert.tag = kCancelTag;
        [alert show];
    }
    /**
     *  封单
     *
     */
    else if (type==BSTableTypeSeal){
        alert = [[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"The table has a account, please go to the cashier's desk"] message:nil
                                          delegate:self cancelButtonTitle:nil otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"], nil];
        [alert show];
    }else
    {
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        [NSThread detachNewThreadSelector:@selector(getOrdersBytale:) toTarget:self withObject:@"2"];
    }
}
/**
 *  根据台位查询账单号
 *
 *  @param tag
 */
-(void)getOrdersBytale:(NSString *)tag
{
    BSDataProvider *dp=[[BSDataProvider alloc] init];
    NSDictionary *dict=[dp getOrdersBytabNum1:[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"]];
    [SVProgressHUD dismiss];
    if ([[dict objectForKey:@"tag"] intValue]==0) {
        NSArray *array=[dict objectForKey:@"message"];
        [AKsNetAccessClass sharedNetAccess].TableNum=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
        [Singleton sharedSingleton].Seat=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
        [Singleton sharedSingleton].CheckNum=[array objectAtIndex:0];
        [Singleton sharedSingleton].man=[array objectAtIndex:1];
        [Singleton sharedSingleton].woman=[[[array objectAtIndex:2]componentsSeparatedByString:@"#"] firstObject];
        if ([tag intValue]==1) {
            [self AKOrder];
        }
        else
        {
            [self quertView];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[dict objectForKey:@"message"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
    }
}
- (void)dismissViews{
    if (vOpen && vOpen.superview){
        [vOpen removeFromSuperview];
        vOpen = nil;
    }
    if (vSwitch && vSwitch.superview){
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
    if(_akschangeTable && _akschangeTable.subviews)
    {
        [_akschangeTable removeFromSuperview];
        _akschangeTable=nil;
    }
    if(_yuDianView && _yuDianView.superview)
    {
        [_yuDianView removeFromSuperview];
        _yuDianView=nil;
    }
    if(_removeYudianView && _removeYudianView.superview)
    {
        [_removeYudianView removeFromSuperview];
        _removeYudianView=nil;
    }
}
/**
 *  开台的代理事件
 *
 *  @param info 开台信息
 */
- (void)openTableWithOptions:(NSDictionary *)info{
    scvTables.userInteractionEnabled=YES;
    if (info){
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"table"];
        [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
        [NSThread detachNewThreadSelector:@selector(openTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}
/**
 *  开台请求
 *
 *  @param info 开台信息
 */
- (void)openTable:(NSDictionary *)info{
    
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    NSDictionary *dict = [dp pStart:info];
    [SVProgressHUD dismiss];
    if (dict) {
        NSString *result = [[dict objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary = [result componentsSeparatedByString:@"@"];
        if ([ary count]<2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:result message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSString *STR=[ary objectAtIndex:1];
            /**
             *  开台成功
             */
            if ([[ary objectAtIndex:0] intValue]==0) {
                [AKsNetAccessClass sharedNetAccess].TableNum=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
                [AKsNetAccessClass sharedNetAccess].PeopleManNum=[info objectForKey:@"man"];
                [AKsNetAccessClass sharedNetAccess].PeopleWomanNum=[info objectForKey:@"woman"];
                [Singleton sharedSingleton].Seat=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
                
                [Singleton sharedSingleton].CheckNum=STR;//账单号
                [AKsNetAccessClass sharedNetAccess].zhangdanId=STR;
                if([AKsNetAccessClass sharedNetAccess].isVipShow)
                {
                    
                    bs_dispatch_sync_on_main_thread(^{
                        AKsVipViewController *vipView=[[AKsVipViewController alloc]init];
                        [self.navigationController pushViewController:vipView animated:YES];
                    });
                    
                }
                else
                {
                    [self AKOrder];
                }
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STR message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            }
        }
        
    }
}

#pragma mark AlertViewDelegate
//对话框代理事件
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(kdish==alertView.tag){
        if (2==buttonIndex) {
            /**
             *  清台
             */
            [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
            NSThread* myThread1 = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(changTableState)
                                                            object:nil];
            [myThread1 start];
        }
        else if (1==buttonIndex){
            /**
             *  查询账单号
             */
            [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
            [NSThread detachNewThreadSelector:@selector(getOrdersBytale:) toTarget:self withObject:@"1"];
            
        }
    }
    else if(alertView.tag==kCancelTag)
    {
        if (1==buttonIndex) {
            /**
             *  清台
             */
            [SVProgressHUD showProgress:-1 status:[[CVLocalizationSetting sharedInstance] localizedString:@"load..."] maskType:SVProgressHUDMaskTypeBlack];
            NSThread* myThread1 = [[NSThread alloc] initWithTarget:self
                                                          selector:@selector(changTableState)
                                                            object:nil];
            [myThread1 start];
        }
    }
}
/**
 *  改变台位状态，清台
 */
-(void)changTableState
{
    [SVProgressHUD dismiss];
    BSDataProvider *dp=[[BSDataProvider alloc] init];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [Singleton sharedSingleton].Seat=[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"];
    [dict setObject:[[_aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"tableNum"];
    [dict setObject:@"6" forKey:@"currentState"];
    [dict setObject:@"1" forKey:@"nextState"];
    /**
     *  调用改变台位状态接口
     */
    NSDictionary *dict1=[dp changTableState:dict];
    if (dict1){
        NSString *result = [[[dict1 objectForKey:@"ns:changTableStateResponse"] objectForKey:@"ns:return"] objectForKey:@"text"];
        NSArray *ary=[result componentsSeparatedByString:@"@"];
        NSLog(@"%@",ary);
        if ([[ary objectAtIndex:0] intValue]==0) {
            /**
             *  刷新台位
             *
             *  @param getTableList: 调用查询台位接口
             *
             *  @return
             */
            NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                         selector:@selector(getTableList:)
                                                           object:_tabledict];
            [myThread start];
            [AKsNetAccessClass sharedNetAccess].VipCardNum=@"";
            
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[ary lastObject] message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
        }
    }
    
}
/**
 *  跳转到点菜界面
 */
-(void)AKOrder
{
    UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
    
    UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
    MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:centerViewController rightDrawerViewController:leftSideDrawerViewController];
    [drawerController setMaximumRightDrawerWidth:280.0];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    [self.navigationController pushViewController:drawerController animated:YES];
    
}
//跳转全单
-(void)quertView
{
    BSQueryViewController *bsq=[[BSQueryViewController alloc] init];
    [self.navigationController pushViewController:bsq animated:YES];
}

@end
