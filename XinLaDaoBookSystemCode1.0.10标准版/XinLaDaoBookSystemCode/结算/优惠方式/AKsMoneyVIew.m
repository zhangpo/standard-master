//
//  AKsMoneyVIew.m
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

#import "AKsMoneyVIew.h"
#import "CVLocalizationSetting.h"

@implementation AKsMoneyVIew
{
    UITextField *_moneyField;
    NSDictionary *_paymentDict;
}

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame withPayment:(NSDictionary *)paymentDic
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _paymentDict=paymentDic;
        if ([[paymentDic objectForKey:@"OPERATEVALUE"] floatValue]>0) {
            [self setTitle:[NSString stringWithFormat:@"%@ %@",[paymentDic objectForKey:@"OPERATENAME"],[paymentDic objectForKey:@"OPERATEVALUE"]]];
        }else
        {
            [self setTitle:[paymentDic objectForKey:@"OPERATENAME"]];
        }
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(240, 265, 90, 40);
        buttonSure.titleLabel.textColor=[UIColor whiteColor];
        buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonSure setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
        [buttonSure setTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"] forState:UIControlStateNormal];
        buttonSure.tag=1;
        [buttonSure addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSure];
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.frame=CGRectMake(345, 265, 90, 40);
        buttonCancle.titleLabel.textColor=[UIColor whiteColor];
        buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonCancle setBackgroundImage:[[CVLocalizationSetting sharedInstance] imgWithContentsOfFile:@"AlertViewButton.png"] forState:UIControlStateNormal];
        [buttonCancle setTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"Cancel"] forState:UIControlStateNormal];
        buttonCancle.tag=2;
        [buttonCancle addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonCancle];
        
        _moneyField=[[UITextField alloc]init];
        _moneyField.delegate=self;
        [_moneyField becomeFirstResponder];
        _moneyField.frame=CGRectMake(100, 90, 300, 40);
        _moneyField.borderStyle=UITextBorderStyleRoundedRect;
        _moneyField.placeholder=@"请输入支付现金数";
        _moneyField.clearButtonMode=UITextFieldViewModeAlways;
        _moneyField.keyboardType=UIKeyboardTypeNumberPad;
        [self addSubview:_moneyField];
        //OPERATEVALUE 汇率
        if ([[paymentDic objectForKey:@"OPERATEVALUE"] floatValue]==0) {
            _moneyField.text=[paymentDic objectForKey:@"PAYABILL"];
        }else
        {
            _moneyField.text=[NSString stringWithFormat:@"%.2f",[[paymentDic objectForKey:@"PAYABILL"] floatValue]/[[paymentDic objectForKey:@"OPERATEVALUE"] floatValue]];
        }
    }
    return self;
}


-(void)sureButtonClick:(UIButton *)btn
{
    if (btn.tag==1) {
        if([_moneyField.text length]<=0)
        {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入钱数不可为空,确定重新输入"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:[[CVLocalizationSetting sharedInstance] localizedString:@"OK"]
                                                      otherButtonTitles:nil];
                [alert show];
                
                
            });
        }
        else
        {
            [_paymentDict setValue:_moneyField.text forKey:@"paymentMoney"];
            [_delegate AKsMoneyVIewClick:_paymentDict];
        }
    }else
    {
        [_delegate AKsMoneyVIewClick:nil];
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    if([string isEqualToString:@""])
    {
        return YES;
    }
    else if([string isEqualToString:@"."])
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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
