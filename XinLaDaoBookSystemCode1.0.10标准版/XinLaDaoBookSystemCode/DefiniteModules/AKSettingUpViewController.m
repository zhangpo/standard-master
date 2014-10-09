//
//  AKSettingUpViewController.m
//  BookSystem
//
//  Created by chensen on 13-11-7.
//
//

#import "AKSettingUpViewController.h"
#import "BSSettingViewController.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"
#import "PaymentSelect.h"
#import "OpenUDID.h"
#import "AKFastLabel.h"

@interface AKSettingUpViewController ()

@end

@implementation AKSettingUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = [[CVLocalizationSetting sharedInstance] localizedString:@"The software Settings"];
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        deskArray = [[NSArray alloc]initWithObjects:[langSetting localizedString:@"Area"],[langSetting localizedString:@"Floor"],[langSetting localizedString:@"Status"], nil];
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Finish"] style:UIBarButtonItemStyleBordered target:self action:@selector(clickLeftBtn)];
    UITableView *deskTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)];
    deskTable.delegate = self;
    deskTable.dataSource = self;
    deskTable.tag = 502;
    UIViewController *vc = [[UIViewController alloc]init];
    [vc.view addSubview:deskTable];
    deskPop = [[UIPopoverController alloc] initWithContentViewController:vc];
    [deskPop setPopoverContentSize:deskTable.frame.size];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)clickLeftBtn
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)choiceDesk:(id)sender
{
    [deskPop presentPopoverFromRect:CGRectMake(self.deskLabel.frame.origin.x, self.deskLabel.frame.origin.y+95.f, self.deskLabel.frame.size.width, self.deskLabel.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 501) {
        static NSString *identifier = @"ConfigruationCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        int section = indexPath.section;
        int row = indexPath.row;
        switch (section) {
            case 0:{
                switch (row) {
                    case 0:{
                        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
                        
                        NSString *deskStr = [langSetting localizedString:@"Area"];
                        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"desk"]) {
                            deskStr =[[NSUserDefaults standardUserDefaults] objectForKey:@"desk"];
                        }else{
                            [[NSUserDefaults standardUserDefaults] setObject:deskStr forKey:@"desk"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        UILabel *deskLabel = [AKFastLabel labelWithFrame:CGRectMake(0, 0, 60, 30) andText:deskStr andtextAlignment:UITextAlignmentRight andFont:14.f andTextColor:[UIColor darkGrayColor] andBackgroundColor:[UIColor clearColor]];
                        self.deskLabel = deskLabel;
                        deskLabel.userInteractionEnabled = YES;
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choiceDesk:)];
                        [deskLabel addGestureRecognizer:tap];
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Table division"];
                        cell.accessoryView = deskLabel;
                        //                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                    case 1:{
                        
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Both male and female"];
                        UISwitch *swShowButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
                        swShowButton.on = NO;
                        swShowButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowButton_image"];
                        swShowButton.tag = 300;
                        [swShowButton addTarget:self action:@selector(swChanged:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = swShowButton;
                    }
                        break;
                    case 2:{
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Equipment serial number"];
                        cell.accessoryView = nil;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                    case 3:{
                        cell.textLabel.text=[[CVLocalizationSetting sharedInstance] localizedString:@"The physical number"];
                        cell.accessoryView = nil;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        BSDataProvider *dp=[[BSDataProvider alloc] init];
                        NSString *deviceID=[dp UUIDString];
                        //                    NSString *deviceID = @"9999999999888888888877777777776666666666";
                        UILabel *lbdevice=[[UILabel alloc] initWithFrame:CGRectMake(0,0,380, 30)];
                        lbdevice.backgroundColor=[UIColor clearColor];
                        lbdevice.textColor=[UIColor lightGrayColor];
                        lbdevice.text=deviceID;
                        cell.accessoryView=lbdevice;
                    }
                        break;
                    case 4:
                    {
                        cell.textLabel.text=[[CVLocalizationSetting sharedInstance] localizedString:@"Equipment registration"];
                        
                    }
                        break;
//                    case 5:
//                    {
//                        cell.textLabel.text=@"店铺编号";
//                        cell.accessoryView = nil;
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                        
//                    }
//                        break;
                    case 5:
                    {
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Whether to use the local library query all list"];
                        UISwitch *swShowButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
                        swShowButton.on = NO;
                        swShowButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"userSql"];
                        swShowButton.tag = 100;
                        [swShowButton addTarget:self action:@selector(swChanged:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = swShowButton;
                    }
                        break;
                        case 6:
                    {
                        NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
                        NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
                        NSString*text =[NSString stringWithFormat:[[CVLocalizationSetting sharedInstance] localizedString:@"The version number"],versionNum];
                        cell.textLabel.text=text;
                        
                    }
                        break;
//                    case 8:
//                    {
//                        cell.textLabel.text=@"设置赠送授权金额";
//                        cell.accessoryView = nil;
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                    }
//                        break;
                    default:
                        break;
                }
            }
                break;
            case 1:{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.accessoryView = nil;
                switch (row) {
                    case 0:
                        cell.textLabel.text =[[CVLocalizationSetting sharedInstance] localizedString:@"Set up the FTP address"];
                        break;
                    case 1:
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Set up the IP address"];
                        break;
                    case 2:
                        cell.textLabel.text = [[CVLocalizationSetting sharedInstance] localizedString:@"Update the data"];
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
        
        return cell;
    }
    else{
        NSString *identifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.text = [deskArray objectAtIndex:indexPath.row];
        return cell;
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag==501) {
        return 0==section?7:3;
    }
    return deskArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView.tag==501) {
        return 2;
    }
    return 1;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 501) {
        int section = indexPath.section;
        int row = indexPath.row;
        if (0==section){
            if (0==row){
                
            }else if (1==row){
                
            }else if (2==row){
                //设备编号
                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypePDAID];
                [self.navigationController pushViewController:vcSetting animated:YES];
            }
            else if(3==row){
            }
            else if(4==row)
            {
                
                BSDataProvider *dp=[[BSDataProvider alloc] init];
                NSString *deviceID=[dp UUIDString];
                NSString *str=[dp registerDeviceId:deviceID];
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:str message:nil delegate:self cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] otherButtonTitles: nil];
                [alert show];
            }
//            else if(5==row)
//            {
//                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeDianPuId];
//                [self.navigationController pushViewController:vcSetting animated:YES];
//                
//            }
//            else if(8==row)
//            {
//                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeZeng];
//                [self.navigationController pushViewController:vcSetting animated:YES];
//            }
        }else if (1==section){
            if (0==row){
                //设置FTP地址
                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeFtp];
                [self.navigationController pushViewController:vcSetting animated:YES];
            }else if (1==row){
                //设置IP地址
                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeSocket];
                [self.navigationController pushViewController:vcSetting animated:YES];
            }else if (2==row){
                //更新资料
                BSSettingViewController *vcSetting = [[BSSettingViewController alloc] initWithType:BSSettingTypeUpdate];
                [self.navigationController pushViewController:vcSetting animated:YES];
            }
            
        }}else{
            [[NSUserDefaults standardUserDefaults]setObject:[deskArray objectAtIndex:indexPath.row] forKey:@"desk"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [deskPop dismissPopoverAnimated:NO];
            [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 501) {
        switch (section) {
            case 0:
                return [[CVLocalizationSetting sharedInstance] localizedString:@"The machine configuration"];
                break;
            case 1:
                return [[CVLocalizationSetting sharedInstance] localizedString:@"The server configuration"];
            default:
                return nil;
                break;
        }
    }
    return nil;
}
- (void)swChanged:(UISwitch *)sw{
    
    if (300==sw.tag){
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:@"ShowButton_image"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [aTableView reloadData];
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"设置成功，重新启动程序生效" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//        [alertView release];
    }else if (100==sw.tag){
        [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:@"userSql"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
