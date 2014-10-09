//
//  CVWebServiceAgent.m
//  CapitalVueHD
//
//  Created by jishen on 8/23/10.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import "BSWebServiceAgent.h"
#import "BSDataProvider.h"
#import "XMLReader.h"

@interface BSWebServiceAgent()
@property(nonatomic, retain) NSString *m_element;
@property(nonatomic, retain) NSMutableArray *m_array;
@property(nonatomic, retain) NSMutableDictionary *m_rootObject;
@property(nonatomic, retain) NSMutableDictionary *m_object;




- (NSDictionary *)parseXML:(NSString *)serviceUrl;
- (NSString *)serviceUrl:(NSString *)api arg:(NSString *)arg;


@end

@implementation BSWebServiceAgent

@synthesize m_element;
@synthesize m_array;
@synthesize m_rootObject;
@synthesize m_object;
@synthesize strData;

static NSDictionary *DICT_API_InterfazAdd = nil;
static NSString *LOGIN_TOKEN = nil;

-(id)init{
    self = [super init];
    if (self) {
        if (DICT_API_InterfazAdd==nil) {
            NSString *plistPath = plistPath = [@"apiList.plist" documentPath];
            if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
                plistPath = [[NSBundle mainBundle] pathForResource:@"apiList" ofType:@"plist"];
            }
            
            DICT_API_InterfazAdd = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];
        }
        
    }
    return self;
}

- (void) dealloc {
    self.m_element = nil;
    self.m_array = nil;
    self.m_rootObject = nil;
    self.m_object = nil;
    self.strData = nil;
    
	[super dealloc];
}



- (NSString *)serviceUrl:(NSString *)api arg:(NSString *)arg{
    NSString *strAPI = [DICT_API_InterfazAdd objectForKey:api];
    if (!strAPI){
        strAPI = [[NSDictionary dictionaryWithContentsOfFile:[@"apiList.plist" bundlePath]] objectForKey:api];
    }
    
    NSArray *docPaths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docPaths objectAtIndex:0];
    NSString *settingPath = [docPath stringByAppendingPathComponent:@"ip.plist"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:settingPath];
    NSString *str = [dict objectForKey:@"ip"];
    if (!str){
        str = kSocketServer;
        [[NSDictionary dictionaryWithObject:str forKey:@"ip"] writeToFile:settingPath atomically:NO];
    }
    
    str = [NSString stringWithFormat:@"http://%@/ChoiceWebService/services/HHTSocket?",str];
    return [NSString stringWithFormat:@"%@/%@%@",str,strAPI,arg];
}




- (NSDictionary *)GetData:(NSString *)api arg:(NSString *)arg {
	NSString *strUrl;
	
	strUrl = [self serviceUrl:api arg:arg];
    NSLog(@"log = %@",strUrl);
    
	return [self parseXML:strUrl];
}



-(NSDictionary *)parseXML:(NSString *)serviceUrl {
    NSDictionary *dicInfo = nil;
    
    NSURL *url = nil;
    NSMutableURLRequest *request = nil;
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *serviceData = nil;
    
    url = [[NSURL alloc] initWithString:[serviceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    request = [[NSMutableURLRequest alloc] initWithURL:url
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"gzip" forHTTPHeaderField:@"accept-encoding"];
    
    serviceData = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&response
                                                    error:&error];
    // 1001 is the error code for a connection timeout
    if (error && [error code]==-1001 ) {
        NSLog( @"Server timeout!" );
        //        [self showAlert];
    } else if (serviceData) {
        NSError *error = nil;
        self.strData = [NSString stringWithCString:[serviceData bytes] encoding:NSUTF8StringEncoding];
        dicInfo = [XMLReader dictionaryForXMLData:serviceData error:&error];
        NSLog(@"Service Data String:%@",dicInfo);
        if (!dicInfo && strData)
            dicInfo = [NSDictionary dictionaryWithObject:strData forKey:@"error"];
        if (error)
            NSLog(@"Parse XML Error:%@",error);
        
    }
    
    [url release];
    [request release];
    
	
	return dicInfo;
}
- (void)showAlert

{
    
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"网络连接超时请重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [promptAlert show];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:promptAlert
                                    repeats:NO];
    
    
}
- (void)timerFireMethod:(UIAlertView*)theTimer
{
    [theTimer dismissWithClickedButtonIndex:0 animated:NO];
    
    [theTimer release];
    theTimer =NULL;
}

#pragma mark XMLParser delegate

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName
	forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	NSUInteger count;
	NSMutableDictionary *dict;
	NSMutableString *strValue;
	count = [self.m_object count];
	if (0 == count) {
		// an empty object, so create it
		dict = [[NSMutableDictionary alloc] init];
		[dict setObject:string forKey:@"value"];
		self.m_object = dict;
		[dict release];
	} else {
		// it is not empty
		// get the existing value and append string to it
		strValue = [[NSMutableString alloc] init];
		if (nil == [m_object objectForKey:@"value"]) {
			[strValue setString:string];
		} else {
			[strValue setString:[m_object objectForKey:@"value"]];
			[strValue appendString:string];
		}
		[m_object setObject:strValue forKey:@"value"];
		[strValue release];
	}
    
    
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
	
	[m_array addObject:m_object];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
	// take the attributeDict as a pair of key and value of an object
	self.m_object = dict;
	self.m_element = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	NSMutableDictionary *dict;
	
	// get the last object of the array
	dict = [m_array lastObject];
	
	if ([dict objectForKey:elementName] != nil)
	{
		// if there is an object with the same key in the upper level dictionary
		id upperObj = [dict objectForKey:elementName];
		
		if ( [upperObj isKindOfClass:[NSMutableArray class]] )
		{
			// the upper object is an array
			[(NSMutableArray *)upperObj addObject:m_object];
		}
		else
		{
			// the upper object is not an array, but the current object and
			// and uppper object shares the common attribute, so construct an
			// array to hold them.
			NSMutableArray * newArray = [[NSMutableArray alloc] initWithCapacity:2];
			[newArray addObject:upperObj];
			[newArray addObject:m_object];
			
			[dict removeObjectForKey:elementName];
			[dict setObject:newArray forKey:elementName];
			[newArray release];
		}
	}
	else
	{
		[dict setObject:m_object forKey:elementName];
	}
	
	// pop current dictionary
	self.m_object = [m_array lastObject];
	[m_array removeLastObject];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	self.m_object = m_rootObject;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

@end
