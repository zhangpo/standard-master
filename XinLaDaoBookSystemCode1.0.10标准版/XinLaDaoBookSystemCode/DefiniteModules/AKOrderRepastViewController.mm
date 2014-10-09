//
//  AKOrderRepastViewController.m
//  BookSystem
//
//  Created by chensen on 13-11-13.
//
//
#import "AKOrederClassButton.h"
#import "AKOrderRepastViewController.h"
#import "Singleton.h"
#import "SearchCoreManager.h"
#import "SearchBage.h"
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "BSLogViewController.h"
#import "AKsIsVipShowView.h"
#import "AKComboButton.h"
#import "SVProgressHUD.h"
#import "CVLocalizationSetting.h"


@interface AKOrderRepastViewController ()

@end

@implementation AKOrderRepastViewController
{
    NSArray                     *_array;                        //选择当前类别的菜品按钮
    NSMutableArray              *_buttonArray;                  //所有的菜品按钮
    NSMutableDictionary         *_dict;                         //菜品搜索使用
    NSMutableArray              *_searchByName;                 //菜品名称
    NSMutableArray              *_searchByPhone;                //菜品编码
    UISearchBar                 *_searchBar;                    //搜索框
    UIScrollView                *_scroll;
    NSMutableArray              *_ComButton;                    //套餐菜品按钮
    NSMutableArray              *_selectArray;                  //选择的菜品
    UIImageView                 *_view;                         //套餐背景图片
    UIScrollView                *scrollview;                    //菜品显示的
    AKComboButton               *_button;                       //菜品的按钮
    NSMutableArray              *_allComboArray;                //全部明细
    UIButton                    *_recommendButton;              //套餐推荐
    NSMutableArray              *comboFinish;                   //可构成套餐
    NSMutableArray              *onlyOne;                       //推荐套餐
    NSMutableArray              *_selectCombo;                  //选择的套餐
    AKMySegmentAndView          *akmsav;                        //标题
    NSMutableArray              *classButton;                   //类别按钮
    BSAddtionView               *vAddition;                     //附加项
    NSMutableDictionary         *_dataDic;                      //当前选中的菜品
    UIPanGestureRecognizer      *_pan;                          //拖动
    int                         _total;                         //选择的份数
    int                         _z;                             //TPNUM
    int                         cishu;                          //上面数量的点击次数
    int                         _y;                             //第二单位的份数
    AKsIsVipShowView            *showVip;                       //会员信息
    BSDataProvider              *_dp;
    UIScrollView                *_RecommendView;
    NSArray                     *_soldOut;
    
}

/**
 *      界面初始化
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        BSDataProvider *dp=[[BSDataProvider alloc] init];
        /**
         *  查询菜品类别
         */
        classArray =[dp getClassById];
    }
    return self;
}

/**
 *  当退出界面时调用
 *
 *  @param animated
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_dp)
    {
        _dp=nil;
    }
}
/**
 *  当进入界面时调用
 *
 *  @param animated
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    akmsav= [[AKMySegmentAndView alloc] init];
    akmsav.frame=CGRectMake(0, 0, 768, 114);
    akmsav.delegate=self;
    [self.view addSubview:akmsav];
    if(!_dp)
    {
        _dp=[[BSDataProvider alloc]init];
        _soldOut=[_dp soldOut];
        [self upload];
        
    }else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _y=0;
    _pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tuodongView:)];
    _pan.delaysTouchesBegan=YES;
    _allComboArray=[[[BSDataProvider alloc] init] allCombo];
    _dataDic=[NSMutableDictionary dictionary];
    classButton=[[NSMutableArray alloc] init];
    _selectCombo=[[NSMutableArray alloc] init];
    [self searchBarInit];
    
    int i=[classArray count];
    scrollview=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 170, 100, 1024-190)];
    [scrollview setContentSize:CGSizeMake(100,60*i)];
    [self.view addSubview:scrollview];
    UIImageView *image=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 60*i)];
    [image setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"ClassBG.png"]];
    [scrollview addSubview:image];
    int j=0;
    for (NSDictionary *dict in classArray) {
        AKOrederClassButton *btn=[[AKOrederClassButton alloc] initWithFrame:CGRectMake(0,60*j,90, 59)];
        [btn.button setTitle:[dict objectForKey:@"DES"] forState:UIControlStateNormal];
        btn.button.tag=j;
        [btn.button addTarget:self action:@selector(segmentClick1:) forControlEvents:UIControlEventTouchUpInside];
        [scrollview addSubview:btn];
        [classButton addObject:btn];
        j++;
    }
    _total=1;
    _ComButton=[NSMutableArray array];
    _searchByName=[[NSMutableArray alloc] init];
    _searchByPhone=[[NSMutableArray alloc] init];
    _dict=[[NSMutableDictionary alloc] init];
    _scroll=[[UIScrollView alloc] init];
    _scroll.bounces=NO;
    _view=[[UIImageView alloc] init];
    _view.frame=CGRectMake(90, 350, 678, 580);
    [_view setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"Packagebg.png"]];
    _view.userInteractionEnabled=YES;
    _scroll.frame=CGRectMake(0, 60,678, 500);
    [_view addSubview:_scroll];
    [self.view addSubview:_view];
    [self.view sendSubviewToBack:_view];
    _RecommendView=[[UIScrollView alloc] initWithFrame:CGRectMake(90, 450, 678, 400)];
    _RecommendView.backgroundColor=[UIColor whiteColor];
    
    [self.view addSubview:_RecommendView];
    aScrollView.frame=CGRectMake(80,175, 688, 740);
    aScrollView.backgroundColor=[UIColor whiteColor];
    NSArray *array=[[NSArray alloc] initWithObjects:[[CVLocalizationSetting sharedInstance] localizedString:@"Additions"],[[CVLocalizationSetting sharedInstance] localizedString:@"OrderedFood"],[[CVLocalizationSetting sharedInstance] localizedString:@"Back"], nil];
    for (int i=0; i<3; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(270+125*i, 1024-70, 140, 60);
        UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10,20, 125, 30)];
        lb.text=[array objectAtIndex:i];
        if ([[[NSUserDefaults standardUserDefaults]
              stringForKey:@"language"] isEqualToString:@"en"])
            lb.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:17];
        else
            lb.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:20];
        lb.backgroundColor=[UIColor clearColor];
        lb.textColor=[UIColor whiteColor];
        [btn addSubview:lb];
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_normal_button.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"cv_rotation_highlight_button.png"] forState:UIControlStateHighlighted];
        btn.tintColor=[UIColor whiteColor];
        if (i==0) {
            [btn addTarget:self action:@selector(Beizhu:) forControlEvents:UIControlEventTouchUpInside];
        }else if (i==1)
        {
            [btn addTarget:self action:@selector(alreadyBuyGreens:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(i==2){
            [btn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:btn];
    }
    _recommendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _recommendButton.frame=CGRectMake(60, 800, 60, 60);
    _RecommendView.frame=_recommendButton.frame;
    [_recommendButton addGestureRecognizer:_pan];
    [_recommendButton setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"sweep.png"] forState:UIControlStateNormal];
    _recommendButton.hidden=YES;
    [_recommendButton addTarget:self action:@selector(recommendShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recommendButton];
    _RecommendView.hidden=YES;
    [_RecommendView sendSubviewToBack:_view];
}
-(void)recommendShow
{
    if (_RecommendView.hidden==NO) {
        [UIView animateWithDuration:0.3f animations:^{
            _RecommendView.frame = _recommendButton.frame;
        }completion:^(BOOL finished) {
            _RecommendView.hidden=YES;
        }];
    }else
    {
        _RecommendView.hidden=NO;
        [UIView animateWithDuration:0.3f animations:^{
            _RecommendView.frame = CGRectMake(90, 450, 678, 450);
        }completion:^(BOOL finished) {
            
            [_RecommendView bringSubviewToFront:self.view];
        }];
    }
    
}
//界面可拖动
-(void)tuodongView:(UIPanGestureRecognizer *)pan
{
    UIView *piece = [pan view];
    NSLog(@"%@",piece);
    _RecommendView.frame=_recommendButton.frame;
    if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [pan translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+ translation.y)];
        
        [pan setTranslation:CGPointZero inView:self.view];
    }
    
}

//类别按钮事件
- (void)segmentClick1:(UIButton *)sender
{
    if ([_ComButton count]>0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"你当前的套餐没有选择完毕" delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
        return;
    }
    for (AKOrederClassButton *btn in [aScrollView subviews]) {
        [btn removeFromSuperview];
    }
    //    _count=sender.selectedSegmentIndex;
    [self button:sender.tag];
}
-(void)upload
{
    _selectArray=[NSMutableArray array];
    _buttonArray=[[NSMutableArray alloc] init];
    self.navigationController.navigationBarHidden = YES;
    NSMutableArray *ary =[Singleton sharedSingleton].dishArray;
    
    for (NSMutableDictionary *dict in [NSArray arrayWithArray:ary]) {
        if ([dict objectForKey:@"CNT"]) {
            [ary removeObject:dict];
        }
        
    }
    for (NSMutableDictionary *dict in ary) {
        if ([[dict objectForKey:@"ISTC"] intValue]==1) {
            [dict setObject:@"NO" forKey:@"isShow"];
        }
    }
    for (UIButton *btn in [aScrollView subviews])
    {
        [btn removeFromSuperview];
    }
    [self button:0];
    [_selectArray removeAllObjects];
    [_ComButton removeAllObjects];
    
    NSArray *array=[_dp selectCache];
    
    if (![ary count])
    {
        NSMutableArray *array1=[NSMutableArray array];
        array1=[NSMutableArray arrayWithArray:array];
        [_selectArray addObjectsFromArray:array1];
    }
    [_selectArray addObjectsFromArray:ary];
    [self changeButtonColor];
    [ary removeAllObjects];
    [_RecommendView sendSubviewToBack:self.view];
}
-(void)changeButtonColor
{
    for (int i=0; i<[classArray count]; i++) {
        for (int j=0;j<[[_buttonArray objectAtIndex:i] count];j++) {
            int x=0;
            AKComboButton *btn=[[_buttonArray objectAtIndex:i] objectAtIndex:j];
            for (NSString *str in _soldOut) {
                if ([btn.PCODE isEqualToString:str]) {
                    x++;
                }
            }
            if (x>0) {
                [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"assess.png"] forState:UIControlStateNormal];
            }else
            {
                [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            if (btn.selected==NO) {
                btn.lblCount.text=@"";
                btn.selected=YES;
            }
            for (NSDictionary *dict in _selectArray) {
                int k=0;
                int x=0;
                NSString *str=[dict objectForKey:@"DES"];
                if ([btn.titleLabel.text isEqualToString:str]) {
                    if (btn.selected==NO) {
                                               btn.lblCount.text=@"";
                        btn.selected=YES;
                    }
                    for (NSDictionary *dict1 in _selectArray) {
                        if ([[dict1 objectForKey:@"DES"] isEqualToString:str]) {
                            k=k+[[dict1 objectForKey:@"total"] intValue];
                        }
                    }
                    if ([dict objectForKey:@"Tpcode"]==nil||[[dict objectForKey:@"Tpcode"] isEqualToString:@"(null)"]||[[dict objectForKey:@"Tpcode"] isEqualToString:[dict objectForKey:@"ITCODE"]]||[[dict objectForKey:@"Tpcode"] isEqualToString:@""]) {
                        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
                        NSLog(@"%@",dict);
                        btn.selected=NO;
                        
                        btn.lblCount.text =[NSString stringWithFormat:@"%d",k];
                        //                        j+=[[dict objectForKey:@"total"] intValue];
                    }
                }
                
                x++;
                [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
    [self updataTitle];
}
- (void)searchBarInit {
    _searchBar= [[UISearchBar alloc] initWithFrame:CGRectMake(0, 120, 768, 50)];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_searchBar.keyboardType = UIKeyboardTypeDefault;
	_searchBar.backgroundColor=[UIColor clearColor];
	_searchBar.translucent=YES;
	_searchBar.placeholder=@"搜索";
	_searchBar.delegate = self;
	_searchBar.barStyle=UIBarStyleDefault;
    [self.view addSubview:_searchBar];
}
- (void)additionSelected:(NSArray *)ary{
    if (ary) {
        [_dataDic setValue:ary forKey:@"addition"];
    }
    [vAddition removeFromSuperview];
    vAddition=nil;
}
-(void)updataTitle
{
    for (int i=0; i<[classArray count]; i++) {
        int j=0;
        AKOrederClassButton *button=[classButton objectAtIndex:i];
        for (AKComboButton *btn in [_buttonArray objectAtIndex:i]) {
            if ([btn.lblCount.text intValue]>0) {
                j+=[btn.lblCount.text intValue];
            }
        }
        if (j==0) {
            button.label.text=@"";
            button.frame=CGRectMake(0,60*i,90, 59);
            button.button.frame=CGRectMake(0,0,90,59);
            [button.button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"ClassShort.png"] forState:UIControlStateNormal];
        }
        else
        {
            button.frame=CGRectMake(0,60*i,100, 59);
            button.button.frame=CGRectMake(0,0,100,59);
            [button.button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"ClassLong.png"] forState:UIControlStateNormal];
            button.label.text=[NSString stringWithFormat:@"%d",j];
        }
    }
    
}

-(void)button:(int)tag
{
    if ([_buttonArray count]==0) {
        int k=0;
        for (int j=0; j<[classArray count]; j++) {
            NSArray *array1=[BSDataProvider getFoodList:[NSString stringWithFormat:@"class=%@",[[classArray objectAtIndex:j] objectForKey:@"GRP"]]];
            NSMutableArray *array2=[[NSMutableArray alloc] init];
            for (int i=0; i<[array1 count]; i++)
            {
                AKComboButton *btn=[AKComboButton buttonWithType:UIButtonTypeCustom];
                btn.selected=YES;
                
                if ([[[array1 objectAtIndex:i] objectForKey:@"ISTC"] intValue]==1) {
                    btn.tag=i+10000;
                }
                else
                {
                    btn.tag=i;
                }
                btn.dataInfo=[array1 objectAtIndex:i];
                btn.btnTag=j;
                btn.lblCount.frame=CGRectMake(70, 50, 50, 30);
                btn.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:20];
                btn.tintColor=[UIColor whiteColor];
                btn.titleLabel.numberOfLines=2;
                [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                btn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
                btn.titleLabel.textAlignment=NSTextAlignmentCenter;
                [btn setTitle:[[array1 objectAtIndex:i] objectForKey:@"DES"] forState:UIControlStateNormal];
                btn.PCODE=[[array1 objectAtIndex:i] objectForKey:@"ITCODE"];
                [array2 addObject:btn];
                SearchBage *search=[[SearchBage alloc] init];
                search.localID = [NSNumber numberWithInt:k];
                search.name=[[array1 objectAtIndex:i] objectForKey:@"DES"];
                NSMutableArray *ary=[[NSMutableArray alloc] init];
                [ary addObject:[[array1 objectAtIndex:i] objectForKey:@"ITCODE"]];
                search.phoneArray=ary;
                [_dict setObject:search forKey:search.localID];
                [[SearchCoreManager share] AddContact:search.localID name:search.name phone:search.phoneArray];
                k++;
            }
            [_buttonArray addObject:array2];
            //_buttonArray存的是所有的button
        }
    }
    _array=[_buttonArray objectAtIndex:tag];
    for (int i=0; i<[classArray count]; i++) {
        int k=0;
        for (AKComboButton *btn in [_buttonArray objectAtIndex:i]) {
            btn.frame=CGRectMake(k%5*135+15,k/5*90+15,120,80);
            k++;
        }
    }
    for (AKComboButton *btn in _array) {
        [aScrollView addSubview:btn];
    }
    [aScrollView setContentSize:CGSizeMake(688, [_array count]/5*90+114)];
}
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    for (UIButton *btn in [aScrollView subviews]) {
        [btn removeFromSuperview];
    }
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:_searchByName phoneMatch:_searchByPhone];
    
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for (int i=0; i<[_searchByName count]; i++) {//搜索到的
        localID = [_searchByName objectAtIndex:i];
        //姓名匹配 获取对应匹配的拼音串 及高亮位置
        int k=0;
        for (int i=0; i<[classArray count]; i++) {//每一个类
            for (UIButton *btn in [_buttonArray objectAtIndex:i]) {//
                if (k==[localID intValue]) {
                    [_dict objectForKey:localID];
                    [array addObject:btn];
                    if ([_searchBar.text length]) {
                        [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
                    }
                }
                k++;
            }
        }
    }
    //    NSNumber *localID = nil;
    //    NSMutableString *matchString = [NSMutableString string];
    //    NSMutableArray *matchPos = [NSMutableArray array];
    NSMutableArray *matchPhones = [NSMutableArray array];
    for (int i=0; i<[_searchByPhone count]; i++) {//搜索到的
        localID = [_searchByPhone objectAtIndex:i];
        int k=0;
        for (int i=0; i<[classArray count]; i++) {//每一个类
            for (UIButton *btn in [_buttonArray objectAtIndex:i]) {//
                if (k==[localID intValue]) {
                    [array addObject:btn];
                    //号码匹配 获取对应匹配的号码串 及高亮位置
                    if ([_searchBar.text length]) {
                        [[SearchCoreManager share] GetPhoneNum:localID phone:matchPhones matchPos:matchPos];
                        [matchString appendString:[matchPhones objectAtIndex:0]];
                    }
                }
                k++;
            }
        }
    }
    int a=0;
    _array=array;
    for (AKComboButton *btn in _array) {
        
        btn.frame=CGRectMake(a%5*135+15,a/5*90+15,120,80);
        [aScrollView addSubview:btn];
        a++;
    }
    [aScrollView setContentSize:CGSizeMake(688, [_array count]/5*90+114)];
}
-(void)buttonClick:(AKComboButton *)btn
{

    /**
     *  判断是否是删除
     */
    if(_total==0)
    {
        /**
         *  如果是已经选择的
         */
        if (btn.selected==NO){
            /**
             *  根据主键从选择的菜品里面删除
             */
            for (NSDictionary *dict in _selectArray) {
                if ([[dict objectForKey:@"ITEM"] isEqualToString:[btn.dataInfo objectForKey:@"ITEM"]]) {
                    [_selectArray removeObject:dict];
                    break;
                }
            }
            /**
             *  将套餐数据删除
             */
            [_selectCombo removeAllObjects];
            /**
             *  将套餐按钮删除
             */
            [_ComButton removeAllObjects];
            //            [_Combo removeAllObjects];
            /**
             *  将套餐按钮从界面移除
             */
            for (UIButton *btn in [_scroll subviews]) {
                [btn removeFromSuperview];
            }
            
            aScrollView.frame=CGRectMake(80,175, 688, 740);
            [self.view sendSubviewToBack:_view];
            [self PackageGroup];
            /**
             *  按钮初始化
             */
            [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
            btn.lblCount.text=@"";
            btn.selected=YES;
            /**
             *  刷新类别的数量
             */
            [self updataTitle];
        }
        
        _total=1;
        /**
         *  akmsav初始化
         */
        [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
        [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
        cishu=0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
    }else
    {
        
        if ([_ComButton count]>0) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"你当前的套餐没有选择完毕，请选择完毕或者取消套餐以后再选择" delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            btn.selected=NO;
            [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
            /**
             *  判断套餐或单品
             */
            if (btn.tag>=10000) {
                /**
                 *  当为套餐时
                 */
                aScrollView.frame=CGRectMake(80,175, 688, 360);
                [self.view bringSubviewToFront:_view];
                btn.lblCount.text=[NSString stringWithFormat:@"%d",[btn.lblCount.text intValue]+_total];
                _total=1;
                [self comboClick1:btn];
                _button=btn;
                
            }
            else
            {
                aScrollView.frame=CGRectMake(80,175, 688,740);
                aScrollView.backgroundColor=[UIColor whiteColor];
                btn.lblCount.text=[NSString stringWithFormat:@"%d",[btn.lblCount.text intValue]+_total];
                [self.view sendSubviewToBack:_view];
                /**
                 *  判断是否是第二单位
                 */
                NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:btn.dataInfo];
                _dataDic=dict;
                if ([[dict objectForKey:@"UNITCUR"] intValue]==2) {
                    [self WeightFlg];
                }
                else
                {
                    
                    [_dataDic setValue:@"0" forKey:@"Weight"];
                    [_dataDic setValue:@"1" forKey:@"UNITCUR"];
                    [dict setValue:[NSString stringWithFormat:@"%d",_total] forKey:@"total"];
                    for (NSDictionary *dict1 in _selectArray) {
                        if ([[dict1 objectForKey:@"ISTC"] intValue]==0&&[[dict1 objectForKey:@"ITEM"] isEqualToString:[_dataDic objectForKey:@"ITEM"]]&&[dict1 objectForKey:@"addition"]==nil) {
                            [dict setValue:[NSString stringWithFormat:@"%d",_total+[[dict1 objectForKey:@"total"] intValue]] forKey:@"total"];
                            [_selectArray removeObject:dict1];
                            break;
                        }
                    }
                    [dict setValue:@"0" forKey:@"TPNUM"];
                    [_selectArray addObject:dict];
                    _total=1;
                    [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
                    [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
                    cishu=0;
                    [self updataTitle];
                }
                //            注释该行代码，菜品默认选择segment份数
                [self PackageGroup];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
                
            }
        }
    }
}
-(void)WeightFlg
{
    if (_total>_y) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"重量" message:@"请输入重量" delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:@"确定",nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf1 = [alertView textFieldAtIndex:0];
        tf1.delegate=self;
        alertView.tag=3;
        [alertView show];
    }
    else
    {
        _y=0;
    }
}
//点套餐
-(void)comboClick1:(AKComboButton *)btn
{
    BSDataProvider *dp=[[BSDataProvider alloc] init];
    /**
     *  根据主键查询套餐明细
     */
    NSArray *arry=[dp combo:[btn.dataInfo objectForKey:@"ITCODE"]];
    [_ComButton removeAllObjects];
    /**
     *  获取当前套餐信息
     */
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:btn.dataInfo];
    [dict setValue:@"1" forKey:@"total"];
    [dict setValue:[NSString stringWithFormat:@"%d",_total] forKey:@"count"];
    /**
     *  套餐唯一的表示从0开始
     */
    _z=0;
    for (NSDictionary *dict1 in _selectArray) {
        if ([[dict1 objectForKey:@"ISTC"] intValue]==1&&[[dict1 objectForKey:@"ITCODE"] isEqualToString:[dict objectForKey:@"ITCODE"]]) {
            _z++;
        }
    }
    [dict setValue:[NSString stringWithFormat:@"%d",_z] forKey:@"TPNUM"];
    /**
     *  将套餐放在选择菜品中
     */
    [_selectArray addObject:dict];
    _dataDic=dict;
    /**
     *  更新选择的数量
     */
    [self updataTitle];
    if ([arry count]==0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"此套餐已点完" delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
        aScrollView.frame=CGRectMake(80,175, 688, 740);
        [self.view sendSubviewToBack:_view];
    }
    else
    {
        NSMutableArray *array=[[NSMutableArray alloc] init];
        /**
         *  判断每一层的套餐明细，是否需要选择
         */
        for (NSArray *array1 in arry) {
            /**
             *  当数量为一份的时候默认选择
             */
            if ([[[array1 lastObject] objectForKey:@"pmin"]intValue]==[[[array1 lastObject] objectForKey:@"pmax"] intValue]&&[array1 count]==1) {
                [[array1 lastObject] setValue:@"1" forKey:@"total"];
                [[array1 lastObject] setValue:[NSString stringWithFormat:@"%d",_z] forKey:@"TPNUM"];
                [_selectCombo addObjectsFromArray:array1];
                [[_selectArray lastObject] setObject:_selectCombo forKey:@"combo"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
            }
            else{
                /**
                 *  可换购的套餐
                 */
                [array addObject:array1];
            }
        }
        if ([array count]>0) {
            [self comboShow:array];
        }else
        {
            
            [self comboend];
            aScrollView.frame=CGRectMake(80,175, 688, 740);
            [self.view sendSubviewToBack:_view];
        }
        
    }
    
}
//查询套餐的可换购项，生成按钮
-(void)comboShow:(NSArray *)comboArray{
    /**
     *  判断是否有套餐明细按钮如果每一生成
     */
    if ([_ComButton count]==0) {
        /**
         *  套餐的每一类换购项
         */
        for (int i=0;i<[comboArray count];i++) {
            int k=0;
            NSMutableArray *array=[[NSMutableArray alloc] init];
            /**
             *  套餐的每一个明细的菜品
             */
            for (NSDictionary *dict in [comboArray objectAtIndex:i]) {
                AKComboButton *btn=[AKComboButton buttonWithType:UIButtonTypeCustom];
                [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                btn.frame=CGRectMake(k%5*135+10,k/5*90+50,120,80);
                /**
                 *  套餐层
                 */
                /**
                 *  当前层套餐唯一标示
                 */
                btn.btnTag=i;
                btn.tag=k;
                btn.selected=YES;
                [btn setTitle:[dict objectForKey:@"PNAME"] forState:UIControlStateNormal];
                btn.lblCount.text=[NSString stringWithFormat:@"%@-%@",[dict objectForKey:@"MINCNT"],[dict objectForKey:@"MAXCNT"]];
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                btn.tintColor=[UIColor whiteColor];
                btn.dataInfo=dict;
                if ([[dict objectForKey:@"MINCNT"] intValue]>0) {
                    btn.selected=NO;
                    [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
                    [dict setValue:[NSString stringWithFormat:@"%d",_z] forKey:@"TPNUM"];
                    //                    [dict setValue:@"1" forKey:@"total"];
                    [dict setValue:[dict objectForKey:@"MINCNT"] forKey:@"total"];
                    [_selectCombo addObject:dict];
                    btn.titleLabel1.text=[dict objectForKey:@"total"];
                }else
                {
                    btn.selected=YES;
                    [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
                }
                btn.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:20];
                
                btn.tintColor=[UIColor whiteColor];
                btn.titleLabel.numberOfLines=2;
                btn.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
                btn.titleLabel.textAlignment=NSTextAlignmentCenter;
                [array addObject:btn];
                k++;
            }
            [_ComButton addObject:array];
        }
    }
    /**
     *  将套餐明细的按钮显示在界面上
     */
    int j=0;
    for (int i=0; i<[_ComButton count]; i++) {
        NSArray *array=[_ComButton objectAtIndex:i];
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0,j, 678, ([array count]/5)*90+135)];
        if ([array count] % 5 == 0) {
            view.frame = CGRectMake(0,j, 678, (([array count]/5)-1)*90+135);
        }else{
            view.frame = CGRectMake(0,j, 678, ([array count]/5)*90+135);
        }
        view.backgroundColor=[UIColor colorWithRed:200/255.0 green:239/255.0 blue:249/255.0 alpha:0.5];
        UILabel *label1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,660,40)];
        
        label1.text=[NSString stringWithFormat:@"%@   %@-%@",[[[comboArray objectAtIndex:i] lastObject] objectForKey:@"GROUPTITLE"],[[[comboArray objectAtIndex:i] lastObject] objectForKey:@"TYPMINCNT"],[[[comboArray objectAtIndex:i] lastObject] objectForKey:@"TYPMAXCNT"]];
        label1.backgroundColor=[UIColor clearColor];
        label1.font=[UIFont systemFontOfSize:20];
        [view addSubview:label1];
        //        view.backgroundColor=[UIColor ]
        for (UIButton *btn in array) {
            [view addSubview:btn];
        }
        [_scroll addSubview:view];
        if ([array count]%5==0) {
            j=j+(([array count]/5)-1)*90+140;
        }else
        {
            j=j+([array count]/5)*90+140;
        }
        
    }
    /**
     *  套餐选择界面下面的2个按钮
     */
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(450, j+10,80,40);
    btn.backgroundColor=[UIColor redColor];
    [btn setTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:20];
    [btn addTarget:self action:@selector(comboConfirm:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag=1;
    [_scroll addSubview:btn];
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame=CGRectMake(550, j+10,80,40);
    btn1.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold" size:20];
    btn1.backgroundColor=[UIColor redColor];
    [btn1 setTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(comboConfirm:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag=2;
    [_scroll addSubview:btn1];
    [_scroll setContentSize:CGSizeMake(120*5+30,j+60)];
}

/**
 *  套餐的点击事件
 *
 *  @param btn 套餐明细按钮
 */
-(void)btnClick:(AKComboButton *)btn
{
    
    /**
     *  当_total=0时为删除
     */
    if (_total==0) {
        if (btn.selected==NO) {
            for (NSDictionary *dict in _selectCombo) {
                if ([[dict objectForKey:@"PCODE"] isEqualToString:[btn.dataInfo objectForKey:@"PCODE"]]) {
                    [_selectCombo removeObject:dict];
                }
            }
        }
        btn.titleLabel1.text=@"";
        [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
        _total=1;
        btn.selected=YES;
        [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
        [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
        return;
    }
    /**
     *  i为当前层菜品选择数量
     */
    int i=0;
    /**
     *  遍历当前层
     */
    for (AKComboButton *button in [_ComButton objectAtIndex:btn.btnTag]) {
        i+=[button.titleLabel1.text intValue];
    }
    _total=1;
    [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
    [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
    /**
     *  判断层的最大数量
     */
    
    if (i<[[btn.dataInfo objectForKey:@"TYPMAXCNT"] intValue]) {
        /**
         *  判断该菜品的最大数量
         */
        int j=[btn.titleLabel1.text intValue];
        if (j==[[btn.dataInfo objectForKey:@"TYPMAXCNT"] intValue]) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"已经到达这个菜的限购数量" delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        if (btn.selected==NO) {
            btn.titleLabel1.text=[NSString stringWithFormat:@"%d",[btn.titleLabel1.text intValue]+1];
        }else
        {
            btn.titleLabel1.text=@"1";
            [btn setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"OrderBG.png"] forState:UIControlStateNormal];
            btn.selected=NO;
        }
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:btn.dataInfo];
        _dataDic=dict;
        for (NSDictionary *dict1 in _selectCombo) {
            if ([[dict1 objectForKey:@"TPNUM"] intValue]==_z&&[[dict1 objectForKey:@"PCODE1"] isEqualToString:[_dataDic objectForKey:@"PCODE1"]]&&[dict1 objectForKey:@"addition"]==nil) {
                [dict setValue:[NSString stringWithFormat:@"%d",[btn.titleLabel1.text intValue]] forKey:@"total"];
                [_selectCombo removeObject:dict1];
                break;
            }
        }
        if (![dict objectForKey:@"total"]) {
            [dict setObject:@"1" forKey:@"total"];
        }
        [dict setValue:[NSString stringWithFormat:@"%d",_z] forKey:@"TPNUM"];
        [_selectCombo addObject:dict];
        [[_selectArray lastObject] setObject:_selectCombo forKey:@"combo"];
        if ([[_dataDic objectForKey:@"UNITCNT"] intValue]==2) {
            [_dataDic setValue:@"2" forKey:@"UNITCUR"];
            [self WeightFlg];
        }
        else
        {
            [_dataDic setValue:@"0" forKey:@"Weight"];
            [_dataDic setValue:@"1" forKey:@"UNITCUR"];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"This option can only choose one, please cancel the selected choose again"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
}

//套餐下面按钮的事件
-(void)comboConfirm:(UIButton *)btn
{
    if (btn.tag==1) {
        [self comboend];
    }else
    {
        aScrollView.frame=CGRectMake(80,175, 688, 740);
        _total=1;
        if ([_button.lblCount.text intValue]>1) {
            _button.lblCount.text=[NSString stringWithFormat:@"%d",[_button.lblCount.text intValue]-1];
        }else
        {
            _button.lblCount.text=@"";
            _button.selected=YES;
            [_button
             setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"product.png"] forState:UIControlStateNormal];
        }
        [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
        [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
        [_ComButton removeAllObjects];
        for (UIView *button in [_scroll subviews]) {
            [button removeFromSuperview];
        }
        [_selectArray removeLastObject];
        [self.view sendSubviewToBack:_view];
        aScrollView.frame=CGRectMake(80,175, 688, 740);
        [self updataTitle];
    }
    [_scroll setContentOffset:CGPointMake(0, 0) animated:NO];
    
}
-(void)comboend
{
    
    int x=0;
    int z=1;
    for (NSArray *array in _ComButton) {
        BOOL tag=YES;
        for (AKComboButton *button in array) {
            if (button.selected==NO) {
                x+=[button.titleLabel1.text intValue];
                tag=NO;
            }
        }
        
        if (tag&&[[((AKComboButton *)[array lastObject]).dataInfo objectForKey:@"TYPMINCNT"] intValue]!=0) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:[[CVLocalizationSetting sharedInstance] localizedString:@"Also have no choice"],z] message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            return;
        }
        z++;
    }
    float mrMoney = 0.0;
    float tcMoney=[[[_selectArray lastObject] objectForKey:@"PRICE"] floatValue];
    for (NSDictionary *dict in _selectCombo) {
        if ([[dict objectForKey:@"NADJUSTPRICE"] floatValue]>0) {
            tcMoney+=[[dict objectForKey:@"NADJUSTPRICE"] floatValue]*[[dict objectForKey:@"total"] floatValue];
        }
    }
    [[_selectArray lastObject] setObject:[NSNumber numberWithFloat:tcMoney] forKey:@"PRICE"];
    
    for (int i=0; i<[_selectCombo count]; i++) {
        
        NSDictionary *dict=[_selectCombo objectAtIndex:i];
        if ([[dict objectForKey:@"UNITCUR"] intValue]==2) {
            mrMoney+=[[dict objectForKey:@"UNITCUR"] floatValue]*[[dict objectForKey:@"PRICE1"] floatValue];
        }
        if ([dict objectForKey:@"total"]==nil) {
            [dict setValue:@"1" forKey:@"total"];
        }
        [dict setValue:[NSString stringWithFormat:@"%.2f",[[dict objectForKey:@"PRICE1"] floatValue]*[[dict objectForKey:@"total"] floatValue]] forKey:@"PRICE"];
        mrMoney+=[[dict objectForKey:@"PRICE"] floatValue];
    }
    
    for (int i=0; i<[_selectCombo count]; i++) {
        NSDictionary *dict=[_selectCombo objectAtIndex:i];
        float m_price1=[[dict objectForKey:@"PRICE1"] floatValue];
        int TC_m_State=[[dict objectForKey:@"TCMONEYMODE"] floatValue];
        if(TC_m_State == 1)   //计价方式一
        {
            
            //                float youhuijia =mrMoney-tcMoney;     //优惠的价钱    合计 - 套餐价额
            float tempMoney1=m_price1*tcMoney/mrMoney;
            //                    float tempMoney1=m_price1-(youhuijia*(m_price1/mrMoney));
            [dict setValue:[NSString stringWithFormat:@"%.2f",tempMoney1] forKey:@"PRICE"];
        }
        else if(TC_m_State==2)
        {
            NSDictionary *dict1=[_selectArray lastObject];
            [dict1 setValue:[NSString stringWithFormat:@"%.2f",mrMoney] forKey:@"PRICE"];
        }else if (TC_m_State==3) {
            if (mrMoney<tcMoney) {
                //                    float youhuijia =mrMoney-tcMoney;     //优惠的价钱    合计 - 套餐价额
                float tempMoney1=m_price1*tcMoney/mrMoney;
                //                        float tempMoney1=m_price1-(youhuijia*(m_price1/mrMoney));
                [dict setValue:[NSString stringWithFormat:@"%.2f",tempMoney1] forKey:@"PRICE"];
            }
            else
            {
                NSDictionary *dict1=[_selectArray lastObject];
                [dict1 setValue:[NSString stringWithFormat:@"%.2f",mrMoney] forKey:@"PRICE"];
            }
        }
        if (i==[_selectCombo count]-1) {
            float mrMoney1 = 0.0;
            //                    float tcMoney=[[[_selectArray objectAtIndex:[_selectArray count]-[arry count]+[_Combo count]-x-1] objectForKey:@"PRICE"] floatValue];
            
            for (int i=0; i<[_selectCombo count]; i++) {
                
                NSDictionary *dict=[_selectCombo objectAtIndex:i];
                if ([[dict objectForKey:@"UNITCUR"] intValue]==2) {
                    mrMoney1+=[[dict objectForKey:@"UNITCUR"] floatValue]*[[dict objectForKey:@"PRICE"] floatValue];
                }else{
                    mrMoney1+=[[dict objectForKey:@"PRICE"] floatValue];
                }
            }
            
            if (mrMoney1!=tcMoney) {
                for (int i=0; i<[_selectCombo count]; i++) {
                    NSDictionary *dict=[_selectCombo objectAtIndex:i];
                    
                    if ([[dict objectForKey:@"PRICE"] floatValue]>0) {
                        if ([[dict objectForKey:@"UNITCUR"] intValue]!=2) {
                            float x=[[dict objectForKey:@"PRICE"] floatValue]+tcMoney-mrMoney1;
                            [dict setValue:[NSString stringWithFormat:@"%.2f",x] forKey:@"PRICE"];
                            break;
                        }
                        
                    }
                }
            }
            
        }
        
    }
    [[_selectArray lastObject] setObject:[NSArray arrayWithArray:_selectCombo] forKey:@"combo"];
    [_selectCombo removeAllObjects];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"This package has chosen to complete"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
    [alert show];
    for (UIView *button in [_scroll subviews]) {
        [button removeFromSuperview];
    }
    [_ComButton removeAllObjects];
    aScrollView.frame=CGRectMake(80,175, 688, 740);
    [self.view sendSubviewToBack:_view];
    _total=1;
    [akmsav setsegmentIndex:[NSString stringWithFormat:@"%d",_total-1]];
    [akmsav setTitle:[NSString stringWithFormat:@"%d",_total]];
    cishu=0;
    
}

-(void)selectSegmentIndex:(NSString *)segmentIndex andSegment:(UISegmentedControl *)segment
{
    if(![segmentIndex isEqualToString:@"X"])
    {
        if([[NSString stringWithFormat:@"%d",_total]length]>1)
        {
            _total=1;
            cishu=0;
            [segment setSelectedSegmentIndex:11];
            [segment setTitle:[NSString stringWithFormat:@"%d",_total] forSegmentAtIndex:11];
        }
        else
        {
            int index=[segmentIndex intValue];
            cishu=cishu*10+index;
            _total=cishu;
            NSLog(@"%d",_total);
            [segment setSelectedSegmentIndex:11];
            [segment setTitle:[NSString stringWithFormat:@"%d",_total] forSegmentAtIndex:11];
        }
    }
    else
    {
        _total=1;
        cishu=0;
        [segment setSelectedSegmentIndex:11];
        [segment setTitle:[NSString stringWithFormat:@"%d",_total] forSegmentAtIndex:11];
    }
}



- (IBAction)alreadyBuyGreens:(id)sender//已点菜品
{
    if ([_ComButton count]>0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"你的套餐还没有选择完毕" delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSArray *foods =[[NSArray alloc] initWithArray:_selectArray];
    NSMutableArray *array1=[[NSMutableArray alloc] init];
    for (int i=0; i<[foods count]; i++) {
        //        for (int j=0; j<[[[foods objectAtIndex:i] objectForKey:@"total"] intValue]; j++) {
        NSMutableDictionary *dict1=[[NSMutableDictionary alloc] initWithDictionary:[_selectArray objectAtIndex:i]];
        [dict1 setObject:@"UNIT" forKey:@"unitKey"];
        [array1 addObject:dict1];
    }
    [Singleton sharedSingleton].dishArray=array1;
    BSLogViewController *vbsvc=[[BSLogViewController alloc] init];
    [self.navigationController pushViewController:vbsvc animated:YES];
}
- (IBAction)Beizhu:(UIButton *)sender {
    if ([_dataDic count]>0) {
        if (!vAddition){
            vAddition = [[BSAddtionView alloc] initWithFrame:CGRectMake(0, 0, 492, 354) withPcode:[_dataDic objectForKey:@"ITCODE"]];
            vAddition.delegate = self;
            
            //        vAddition.arySelectedAddtions=;
        }
        if (!vAddition.superview){
            vAddition.center = CGPointMake(self.view.center.x,924+self.view.center.y);
            [vAddition.arySelectedAddtions removeAllObjects];
            vAddition.arySelectedAddtions=[NSMutableArray arrayWithArray:[_dataDic objectForKey:@"addition"]];
            [vAddition.tv reloadData];
            [self.view addSubview:vAddition];
            [vAddition firstAnimation];
        }
        else{
            [vAddition removeFromSuperview];
            vAddition = nil;
        }
        
    }else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"你还没有选择菜" delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)goBack:(id)sender//返回
{
    
    if ([_ComButton count]>0) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"当前套餐没有选择完毕，请将该套餐选择完毕或取消之后再返回" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"], nil];
        [alert show];
        return;
    }
    if ([_selectArray count]>0&&![Singleton sharedSingleton].isYudian) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Save the dishes"] message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] otherButtonTitles:[[CVLocalizationSetting sharedInstance] localizedString:@"YES"],[[CVLocalizationSetting sharedInstance] localizedString:@"NO"], nil];
        alert.tag=1;
        alert.delegate=self;
        [alert show];
    }
    else if (![AKsNetAccessClass sharedNetAccess].isVipShow)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        if (1==buttonIndex){
            NSMutableArray *array=[[NSMutableArray alloc] initWithArray:_selectArray];
            int i=0,j=0;
            for (NSDictionary *dict in _selectArray) {
                if (![dict objectForKey:@"isShow"]&&[[dict objectForKey:@"ISTC"] intValue]==1) {
                    NSRange range = NSMakeRange(i+1+j,[[dict  objectForKey:@"combo"] count]);
                    j=[[dict objectForKey:@"combo"] count];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [array insertObjects:[dict objectForKey:@"combo"] atIndexes:indexSet];
                }
                i++;
            }
            BSDataProvider *dp=[[BSDataProvider alloc] init];
            [dp cache:array];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Save Success"] message:nil delegate:nil cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
            if(![AKsNetAccessClass sharedNetAccess].isVipShow)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
            }
            
        }else if (2==buttonIndex){
            if(![AKsNetAccessClass sharedNetAccess].isVipShow)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1]  animated:YES];
            }
        }
        
    }
    else  if (alertView.tag==10001)
    {
        [akmsav setsegmentIndex:@"11"];
        [akmsav setTitle:@"1"];
        _total=1;
    }
    
    if (alertView.tag==3) {
        UITextField *tf1 = [alertView textFieldAtIndex:0];
        
        if (1==buttonIndex) {
            [_dataDic setValue:@"1" forKey:@"total"];
            [_dataDic setValue:@"2" forKey:@"UNITCUR"];
            [_dataDic setValue:tf1.text forKey:@"Weight"];
            [_selectArray addObject:_dataDic];
            _y++;
            [self WeightFlg];
            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
        }
        else
        {
            _y++;
            [self WeightFlg];
        }
    }
}
-(void)PackageGroup
{
    NSMutableArray *comboArray=[NSMutableArray array];
    for (NSArray *array in _allComboArray) {//取出所有套餐
        for (NSArray *ary in array) {//取出所有组
            [comboArray addObjectsFromArray:ary];//取出所有的菜
        }
    }
//    int x=0;
    /**
     *  遍历所有的明细菜品
     */
    for (NSDictionary *dictAll in comboArray) {
        for (NSDictionary *dictSelect in _selectArray) {
            if ([[dictSelect objectForKey:@"ISTC"] intValue]!=1) {
                if ([[dictSelect objectForKey:@"ITCODE"] isEqualToString:[dictAll objectForKey:@"PCODE1"]]) {
                    [dictAll setValue:@"0" forKey:@"count"];
                    [dictAll setValue:[dictSelect objectForKey:@"total"] forKey:@"count"];
//                    x++;
                }
            }
        }
    }
    comboFinish=[NSMutableArray array];//可选择套餐
    onlyOne=[NSMutableArray array];//推荐套餐
    for (int i=0;i<[_allComboArray count];i++) {//所有的套餐
        NSMutableArray *array=[_allComboArray objectAtIndex:i];//单个套餐
        NSMutableArray *ary2=[NSMutableArray array];
        for (int k=0;k<[array count];k++) {//套餐里的层
            NSMutableArray *ary=[array objectAtIndex:k];
            int j=0;
            
            NSMutableArray *ary1=[NSMutableArray array];
            for (NSDictionary *dict in ary) {//该层里的菜
                NSMutableDictionary *dicFood=[NSMutableDictionary dictionary];
                if ([[dict objectForKey:@"MINCNT"] intValue]<=[[dict objectForKey:@"count"] intValue]&&[[dict objectForKey:@"count"] intValue]!=0&&[[dict objectForKey:@"TYPMAXCNT"] intValue]>=j+1) {//判断数量是不是在该菜的范围
                    if ([[dict objectForKey:@"MINCNT"] intValue]==0) {
                        j+=1;
                    }else
                        j+=[[dict objectForKey:@"MINCNT"] intValue];
                    [ary1 addObject:dict];
                }
                if (dict==[ary lastObject]) {//判断最后一个菜
                    if (j>=[[dict objectForKey:@"TYPMAXCNT"] intValue]&&j!=0) {//判断是否在套餐的范围内
                        [dicFood setObject:ary1 forKey:@"food"];
                        [dicFood setObject:[NSString stringWithFormat:@"%d",k] forKey:@"num"];
                        [ary2 addObject:dicFood];//选择的菜
                    }
                }
            }
            if (k==[array count]-1) {//判断套餐的最后一个菜
                //                for (NSArray *ary in array) {
                //                    if ([[[ary lastObject] objectForKey:@"tpmin"] intValue]!=0) {
                //
                //                    }
                //                }
                if ([ary2 count]==[array count]) {//判断是否符合套餐
                    [comboFinish addObject:ary2];
                }
                if ([ary2 count]==[array count]-1) {//判断是否符合推荐套餐
                    int z=0;
                    BOOL isy=NO;
                    
                    
                    for (int y=0;y<[ary2 count];y++) {
                        if ([[[ary2 objectAtIndex:y] objectForKey:@"num"] intValue]!=y) {
                            z=y;
                            isy=YES;
                            break;
                        }
                    }
                    if (!isy) {
                        z=[ary2 count];
                    }
                    NSMutableDictionary *dict10=[[NSMutableDictionary alloc] init];
                    [dict10 setObject:ary2 forKey:@"food"];
                    [dict10 setObject:[array objectAtIndex:z] forKey:@"combo"];
                    int b=0;
                    for (int a=0; a<[[array objectAtIndex:z] count];a++) {
                        b+=[[[[array objectAtIndex:z] objectAtIndex:a] objectForKey:@"count"] intValue];
                    }
                    if ((b+1==[[[[array objectAtIndex:z] lastObject] objectForKey:@"TYPMINCNT"] intValue]&&[[[[array objectAtIndex:z] lastObject] objectForKey:@"TYPMINCNT"] intValue]!=0)||[[[[array objectAtIndex:z] lastObject] objectForKey:@"TYPMINCNT"] intValue]==0) {
                        [onlyOne addObject:dict10];
                    }
                    if ([[[[array objectAtIndex:z] lastObject] objectForKey:@"TYPMINCNT"] intValue]==0) {
                        [comboFinish addObject:ary2];
                    }
                    
                }
            }
        }
    }
    for(UIView *view in [_RecommendView subviews])
    {
        [view removeFromSuperview];
    }
    if ([comboFinish count]!=0||[onlyOne count]!=0) {
        
        UIImageView *image1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 660, 400)];
        [image1 setImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"recommendBG.png"]];
        [_RecommendView addSubview:image1];
        int h=0;
        if ([comboFinish count]>0) {
            UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10, 20, 660,30)];
            lb.text=@"可组成套餐";
            lb.font=[UIFont fontWithName:@"Noteworthy-Bold" size:25];
            lb.textColor=[UIColor redColor];
            lb.textAlignment=NSTextAlignmentCenter;
            [_RecommendView addSubview:lb];
            int y=0;
            for (NSArray *ary11 in comboFinish) {
                
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                button.frame=CGRectMake(y%5*135,y/5*90+50,120,80);
                [button setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"TableButtonEmpty.png"] forState:UIControlStateNormal];
                [button setTitle:[[[[ary11 lastObject] objectForKey:@"food"] lastObject] objectForKey:@"DES"] forState:UIControlStateNormal];
                //                button.titleLabel.text=[[[[ary11 lastObject] objectForKey:@"food"] lastObject] objectForKey:@"tpname"];
                //                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.tag=y+1;
                button.titleLabel.numberOfLines=0;
                button.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
                [button addTarget:self action:@selector(makePackage:) forControlEvents:UIControlEventTouchUpInside];
                y++;
                [_RecommendView addSubview:button];
                h=button.frame.origin.y+button.frame.size.height;
            }
            _recommendButton.hidden=NO;
        }
        //        _RecommendView.backgroundColor=[UIColor lightGrayColor];
        if ([onlyOne count]>0) {
            UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(30, h+20, 660,30)];
            lb.text=@"推荐套餐";
            lb.textColor=[UIColor redColor];
            lb.font=[UIFont fontWithName:@"Noteworthy-Bold" size:25];
            lb.textAlignment=NSTextAlignmentCenter;
            [_RecommendView addSubview:lb];
            int j=0;
            for (NSDictionary *dict in onlyOne) {
                int i=0;
                NSArray *array=[dict objectForKey:@"combo"];
                UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(30, h+50, 476, 30)];
                lb.text=[NSString stringWithFormat:@"选择可构成%@",[[array lastObject] objectForKey:@"DES"]];
                lb.textColor=[UIColor redColor];
                [_RecommendView addSubview:lb];
                for (NSDictionary *dict in array) {
                    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame=CGRectMake(i%5*135,h+i/5*90+80,120,80);
                    [button setBackgroundImage:[[CVLocalizationSetting sharedInstance]imgWithContentsOfFile:@"TableButtonEmpty.png"] forState:UIControlStateNormal];
                    [button setTitle:[dict objectForKey:@"PNAME"] forState:UIControlStateNormal];
                    button.titleLabel.numberOfLines=0;
                    button.titleLabel.lineBreakMode=NSLineBreakByWordWrapping;
                    button.tag=10000*(j+1)+i;
                    [button addTarget:self action:@selector(makePackage:) forControlEvents:UIControlEventTouchUpInside];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_RecommendView addSubview:button];
                    i++;
                }
                j++;
                h+=120;
                [_RecommendView setContentSize:CGSizeMake(650,h+50)];
                
                
            }
            
            [_RecommendView sendSubviewToBack:self.view];
            _RecommendView.hidden=YES;
            _recommendButton.hidden=NO;
        }
        image1.frame=CGRectMake(0, 0, 660, h+50);
    }else
    {
        _recommendButton.hidden=YES;
    }
}
-(void)makePackage:(UIButton *)btn
{
    /**
     *  array代表已经选择的菜品
     */
    NSMutableArray *array=[NSMutableArray array];
    /**
     *  当tag>=10000时，说明是推荐套餐，反之是组合成的套餐
     */
    if (btn.tag>=10000) {
        /**
         *  获得可注册套餐的菜品
         */
        for (NSDictionary *dict in [[onlyOne objectAtIndex:btn.tag/10000-1] objectForKey:@"food"]) {
            /**
             *  将已经选择的菜品放入数组中
             */
            for (NSDictionary *dict1 in [dict objectForKey:@"food"]) {
                [array addObject:[NSMutableDictionary dictionaryWithDictionary:dict1]];
            }
//            [array addObjectsFromArray:[NSMutableArray arrayWithArray:]];
        }
        /**
         *  获取选择的菜品
         */
        [[[[onlyOne objectAtIndex:btn.tag/10000-1] objectForKey:@"combo"] objectAtIndex:btn.tag%10000] setObject:@"1" forKey:@"total"];
//        [array addObject:[NSMutableDictionary dictionaryWithDictionary:[[[onlyOne objectAtIndex:btn.tag/10000-1] objectForKey:@"combo"] objectAtIndex:btn.tag%10000]]];
        [array addObject:[NSMutableDictionary dictionaryWithDictionary:[[[onlyOne objectAtIndex:btn.tag/10000-1] objectForKey:@"combo"] objectAtIndex:btn.tag%10000]]];
    }else
    {
        /**
         *  组合成套餐的菜品
         */
        for (NSDictionary *fooddic in [comboFinish objectAtIndex:btn.tag-1]) {
            [array addObjectsFromArray:[[NSArray alloc] initWithArray:[fooddic objectForKey:@"food"]]];
        }
    }
    //ary已经点的菜品
    NSMutableArray *ary=[[NSMutableArray alloc] initWithArray:_selectArray];
    int i=0;
    int k=0;
    /**
     *  将组合成套餐的菜品从数组里删除
     */
    for (NSDictionary *dict in array) {
        int j=0;
        for (NSDictionary *food in ary) {
            if ([[dict objectForKey:@"PCODE1"] isEqualToString:[food objectForKey:@"ITCODE"]]) {
                if ([[dict objectForKey:@"count"] intValue]>=[[food objectForKey:@"total"] intValue]) {
                    [_selectArray removeObject:food];
                    [dict setValue:[dict objectForKey:@"count"] forKey:@"total"];
                    
                    //                    j已点菜数组第几个
                    //                    k去掉几个菜
                    //
                    k++;
                }else
                {
                    [[_selectArray objectAtIndex:j-k] setObject:[NSString stringWithFormat:@"%d",[[food objectForKey:@"total"] intValue]-[[dict objectForKey:@"count"] intValue] ] forKey:@"total"];
                    
                }
            }
            j++;
        }
        i++;
    }
    int j=0;
    /**
     *  计算套餐标示TPNUM
     */
    for (NSDictionary *dic in _selectArray) {
        if ([[dic objectForKey:@"ITCODE"]isEqualToString:[[array lastObject] objectForKey:@"ITCODE"]]) {
            j++;
        }
    }
    for (NSDictionary *dict1 in array) {
        [dict1 setValue:[NSString stringWithFormat:@"%d",j] forKey:@"TPNUM"];
    }
    /**
     *  拼接组合成套餐的数据
     */
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%d",j] forKey:@"TPNUM"];
    [dict setObject:[[array lastObject] objectForKey:@"PCODE"] forKey:@"Tpcode"];
    [dict setObject:[[array lastObject] objectForKey:@"DES"] forKey:@"DES"];
    [dict setObject:[[array lastObject] objectForKey:@"PCODE"] forKey:@"ITCODE"];
    [dict setObject:[[array lastObject] objectForKey:@"PRICE"] forKey:@"PRICE"];
    [dict setObject:@"1" forKey:@"total"];
    [dict setObject:@"1" forKey:@"ISTC"];
//    NSArray *ary1=[[NSArray alloc] initWithArray:array];
    [dict setObject:array forKey:@"combo"];
    _selectCombo=array;
    onlyOne=nil;
    comboFinish=nil;
    
    [_selectArray addObject:dict];
    _RecommendView.hidden=YES;
    _recommendButton.hidden=YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postData" object:_selectArray];
    [self comboend];
    [self changeButtonColor];
    
}
#pragma mark  AKMySegmentAndViewDelegate
-(void)showVipMessageView:(NSArray *)array andisShowVipMessage:(BOOL)isShowVipMessage
{
    if(isShowVipMessage)
    {
        [showVip removeFromSuperview];
        showVip=nil;
    }
    else
    {
        showVip=[[AKsIsVipShowView alloc]initWithArray:array];
        [self.view addSubview:showVip];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    
    if([string isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        NSString *validRegEx =@"^[0-9]+(.[0-9]{2})?$";
        
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
        
        if (myStringMatchesRegEx)
            
            return YES;
        
        else
            
            return NO;
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
}
@end
