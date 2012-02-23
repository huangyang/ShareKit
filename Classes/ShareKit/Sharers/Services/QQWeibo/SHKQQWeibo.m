//  Created by «FULLUSERNAME» on «DATE».


/*

 For a step by step guide to creating your service class, start at the top and move down through the comments.
 
*/

#import "SHKQQWeibo.h"
#import "SHKQQWeiboForm.h"
#import "SBJSON.h"

@implementation SHKQQWeibo 

#pragma mark -
#pragma mark Configuration : Service Defination

// Enter the name of the service
+ (NSString *)sharerTitle
{
	return @"腾讯微薄";
}


// What types of content can the action handle?

// If the action can handle URLs, uncomment this section

+ (BOOL)canShareURL
{
	return YES;
}


// If the action can handle images, uncomment this section

+ (BOOL)canShareImage
{
	return YES;
}


// If the action can handle text, uncomment this section

+ (BOOL)canShareText
{
	return YES;
}


// If the action can handle files, uncomment this section

+ (BOOL)canShareFile
{
	return YES;
}



// Does the service require a login?  If for some reason it does NOT, uncomment this section:
/*
+ (BOOL)requiresAuthentication
{
	return NO;
}
*/ 


#pragma mark -
#pragma mark Configuration : Dynamic Enable

// Subclass if you need to dynamically enable/disable the service.  (For example if it only works with specific hardware)
+ (BOOL)canShare
{
	return YES;
}



#pragma mark -
#pragma mark Authentication

// These defines should be renamed (to match your service name).
// They will eventually be moved to SHKConfig so the user can modify them.

- (id)init
{
	if (self = [super init])
	{		
		self.consumerKey = SHKQQWeiboConsumerKey;		
		self.secretKey = SHKQQWeiboSecretKey;
 		self.authorizeCallbackURL = [NSURL URLWithString:SHKQQWeiboCallbackUrl];
		
		
		// -- //
		
		
		// Edit these to provide the correct urls for each oauth step
//        self.requestURL = [NSURL URLWithString:@"http://api.t.sina.com.cn/oauth/request_token"];
	    self.requestURL = [NSURL URLWithString:@"https://open.t.qq.com/cgi-bin/request_token"];
	    self.authorizeURL = [NSURL URLWithString:@"https://open.t.qq.com/cgi-bin/authorize"];
	    self.accessURL = [NSURL URLWithString:@"https://open.t.qq.com/cgi-bin/access_token"];
		
		// Allows you to set a default signature type, uncomment only one
		self.signatureProvider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
		//self.signatureProvider = [[[OAPlaintextSignatureProvider alloc] init] autorelease];
	}	
	return self;
}

// If you need to add additional headers or parameters to the request_token request, uncomment this section:

- (void)tokenRequestModifyRequest:(OAMutableURLRequest *)oRequest
{
	// Here is an example that adds the user's callback to the request headers
	[oRequest setOAuthParameterName:@"oauth_callback" withValue:authorizeCallbackURL.absoluteString];
}


// If you need to add additional headers or parameters to the access_token request, uncomment this section:

- (void)tokenAccessModifyRequest:(OAMutableURLRequest *)oRequest
{
	// Here is an example that adds the oauth_verifier value received from the authorize call.
	// authorizeResponseQueryVars is a dictionary that contains the variables sent to the callback url
//	[oRequest setOAuthParameterName:@"oauth_verifier" withValue:[authorizeResponseQueryVars objectForKey:@"oauth_verifier"]];
    
    if (pendingAction == SHKPendingRefreshToken)
    {
        if (accessToken.sessionHandle != nil)
            [oRequest setOAuthParameterName:@"oauth_session_handle" withValue:accessToken.sessionHandle];	
    }
    
    else {
        NSLog(@"oauth_verifier: %@", [authorizeResponseQueryVars objectForKey:@"oauth_token"]);
        [oRequest setOAuthParameterName:@"oauth_verifier" withValue:[authorizeResponseQueryVars objectForKey:@"v"]];
    }
}



#pragma mark -
#pragma mark Share Form

// If your action has options or additional information it needs to get from the user,
// use this to create the form that is presented to user upon sharing.

- (NSArray *)shareFormFieldsForType:(SHKShareType)type
{
    NSLog(@"In shareFormFieldsForType");
	// See http://getsharekit.com/docs/#forms for documentation on creating forms
	
	if (type == SHKShareTypeURL)
	{
		// An example form that has a single text field to let the user edit the share item's title
		return [NSArray arrayWithObjects:
				[SHKFormFieldSettings label:@"Title" key:@"title" type:SHKFormFieldTypeText start:item.title],
				nil];
	}
	
	else if (type == SHKShareTypeImage)
	{
		// return a form if required when sharing an image
		return nil;		
	}
	
	else if (type == SHKShareTypeText)
	{
		// return a form if required when sharing text
		return nil;		
	}
	
	else if (type == SHKShareTypeFile)
	{
		// return a form if required when sharing a file
		return nil;		
	}
	
	return nil;
}


// If you have a share form the user will have the option to skip it in the future.
// If your form has required information and should never be skipped, uncomment this section.

+ (BOOL)canAutoShare
{
	return NO;
}


// Validate the user input on the share form
- (void)shareFormValidate:(SHKCustomFormController *)form
{	
	/*
	 
	 Services should subclass this if they need to validate any data before sending.
	 You can get a dictionary of the field values from [form formValues]
	 
	 --
	 
	 You should perform one of the following actions:
	 
	 1.	Save the form - If everything is correct call [form saveForm]
	 
	 2.	Display an error - If the user input was incorrect, display an error to the user and tell them what to do to fix it
	 
	 
	 */	
	
	// default does no checking and proceeds to share
	[form saveForm];
}



#pragma mark -
#pragma mark Implementation

// When an attempt is made to share the item, verify that it has everything it needs, otherwise display the share form

- (BOOL)validateItem
{ 
	// The super class will verify that:
	// -if sharing a url	: item.url != nil
	// -if sharing an image : item.image != nil
	// -if sharing text		: item.text != nil
	// -if sharing a file	: item.data != nil
 
	return [super validateItem];
}


- (void)showSinaWeiboForm
{
	SHKQQWeiboForm *rootView = [[SHKQQWeiboForm alloc] initWithNibName:nil bundle:nil];	
	rootView.delegate = self;
	
	// force view to load so we can set textView text
	[rootView view];
	
	rootView.textView.text = [item customValueForKey:@"status"];
	rootView.hasAttachment = item.image != nil;
	
	[self pushViewController:rootView animated:NO];
	
	[[SHK currentHelper] showViewController:self];	
}

- (void) show {
    [item setCustomValue:item.text forKey:@"status"];
    [self showSinaWeiboForm];
}

- (OAMutableURLRequest *)txRequestWithURL:(NSString *)_url dic:(NSDictionary *)_dic method:(NSString *)_method
{
	OAHMAC_SHA1SignatureProvider *hmacSha1Provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:SHKQQWeiboConsumerKey secret:SHKQQWeiboSecretKey];
	
	OAToken *token = nil;
	
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
//    NSString *strAccess = [info valueForKey:@"WBShareKit_txToken"];
    
    NSString *strAccess = accessToken.key;
    
    NSLog(@"AccessToken: %@", accessToken.key);
    
	if (nil != strAccess) {
		token = [[[OAToken alloc] initWithHTTPResponseBody:strAccess] autorelease];
		//NSLog(@"%@,%@",token.secret,token.key);
        
	}
	
	OAMutableURLRequest *hmacSha1Request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]
																			consumer:consumer
																			   token:accessToken
																			   realm:nil
																   signatureProvider:hmacSha1Provider];
        
                                            
	//	OARequestParameter *pa1 = [[OARequestParameter alloc] initWithName:@"x_auth_username" value:strUserName];
	//	OARequestParameter *pa2 = [[OARequestParameter alloc] initWithName:@"x_auth_password" value:strUserPwd];
	//	OARequestParameter *pa3 = [[OARequestParameter alloc] initWithName:@"x_auth_mode" value:@"client_auth"];
	if (nil != _dic) {
		for (NSString *key in [_dic allKeys]) {
			[hmacSha1Request setOAuthParameterName:key withValue:[_dic valueForKey:key]];
		}
	}
	
    //    [hmacSha1Request setOAuthParameterName:@"oauth_verifier" withValue:[info valueForKey:@"WBShareKit_ver"]];
	
	//[hmacSha1Request1 setParameters:[NSArray arrayWithObjects:pa1,pa2,pa3,nil]];
	if (nil != _method) {
		[hmacSha1Request setHTTPMethod:_method];
	}
	
	[hmacSha1Provider release];
	[consumer release];
	//[hmacSha1Request1 release];
	return hmacSha1Request;
}


- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
	// TODO better error handling here
    
	if (ticket.didSucceed) 
		[self sendDidFinish];
	
	else
	{		
		if (SHKDebugShowLogs)
        {
            SHKLog(@"Sina Weibo Send Status Error: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
		
		// CREDIT: Oliver Drobnik
		
		NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];		
		
		// in case our makeshift parsing does not yield an error message
		NSString *errorMessage = @"Unknown Error";		
		
		NSScanner *scanner = [NSScanner scannerWithString:string];
		
		// skip until error message
		[scanner scanUpToString:@"\"error\":\"" intoString:nil];
		
		
		if ([scanner scanString:@"\"error\":\"" intoString:nil])
		{
			// get the message until the closing double quotes
			[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&errorMessage];
		}
		
		
		// this is the error message for revoked access
		if ([errorMessage isEqualToString:@"Invalid / used nonce"])
		{
			[self sendDidFailShouldRelogin];
		}
		else 
		{
			NSError *error = [NSError errorWithDomain:@"Sina Weibo" code:2 userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
			[self sendDidFailWithError:error];
		}
	}
}

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	[self sendDidFailWithError:error];
}

/*
- (void)sendRecordTicket:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",string);
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"发送微博成功" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [al show];
    [al release];
    
}

- (void)sendRecordTicket:(OAServiceTicket *)ticket failedWithError:(NSError *)error
{
    NSLog(@"In sendRecordTicket error");
    
}*/

- (void)sendTxRecordWithStatus:(NSString *)_status lat:(double)_lat lng:(double)_lng format:(NSString *)_format delegate:(id)_delegate successSelector:(SEL)_sSel failSelector:(SEL)_eSel
{
//    _successSEL = _sSel;
//    _failSEL = _eSel;
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"http://open.t.qq.com/api/t/add"];
    NSMutableString *body = [NSMutableString stringWithString:@""];
    
	OAMutableURLRequest *request = [self txRequestWithURL:url dic:nil method:@"POST"];
    
    
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:0];
    if (nil != _status) {
        [parameters addObject:[OARequestParameter requestParameterWithName:@"content" value:_status]];
    }
    if (0 != _lng || 0 != _lat) {
        [parameters addObject:[OARequestParameter requestParameterWithName:@"Wei" value:[NSString stringWithFormat:@"%f",_lat]]];
        [parameters addObject:[OARequestParameter requestParameterWithName:@"Jing" value:[NSString stringWithFormat:@"%f",_lng]]];
    }
    if (nil != _format) {
        [parameters addObject:[OARequestParameter requestParameterWithName:@"format" value:_format]];
    }
    else
    {
        [parameters addObject:[OARequestParameter requestParameterWithName:@"format" value:@"json"]];
    }
    
    [parameters addObject:[OARequestParameter requestParameterWithName:@"clientip" value:@"127.0.0.1"]];
    
    [request setParameters:parameters];
    
    [body appendFormat:@"%@",[request txBaseString]];
    
    NSLog(@"body: %@",body);
    NSLog(@"Url: %@", request.URL.description);
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
	
	OAAsynchronousDataFetcher *addRecordFetcher = [[[OAAsynchronousDataFetcher alloc] init] autorelease];
	[addRecordFetcher initWithRequest:request 
                             delegate:_delegate
                    didFinishSelector:_sSel
                      didFailSelector:_eSel];
	[addRecordFetcher start];
    //    [addRecordFetcher release];
    
    [parameters release];
}



NSString *WBShareKit_BOUNDARY = @"WBShareKit_Oauth_Kit";


- (NSString*) nameValString: (NSDictionary*) dict {
	NSArray* keys = [dict allKeys];
	NSString* result = [NSString string];
	int i;
	for (i = 0; i < [keys count]; i++) {
        result = [result stringByAppendingString:
                  [@"--" stringByAppendingString:
                   [WBShareKit_BOUNDARY stringByAppendingString:
                    [@"\r\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\r\n\r\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\r\n"]]]]]]];
	}
	
	return result;
}


- (void)sendTxRecordWithStatus:(NSString *)_status lat:(double)_lat lng:(double)_lng format:(NSString *)_format path:(NSString *)_path delegate:(id)_delegate successSelector:(SEL)_sSel failSelector:(SEL)_eSel
{
//    _successSEL = _sSel;
//    _failSEL = _eSel;
    
//    _successSEL = _sSel;
//    _failSEL = _eSel;
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"http://open.t.qq.com/api/t/add_pic"];
    NSMutableString *body = [NSMutableString stringWithString:@""];
    
	OAMutableURLRequest *request = [self txRequestWithURL:url dic:nil method:@"POST"];
    
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (nil != _status) {
        //        [parameters addObject:[OARequestParameter requestParameterWithName:@"content" value:_status]];
        [dic setValue:_status forKey:@"content"];
    }
    if (0 != _lng || 0 != _lat) {
        //        [parameters addObject:[OARequestParameter requestParameterWithName:@"Wei" value:[NSString stringWithFormat:@"%f",_lat]]];
        //        [parameters addObject:[OARequestParameter requestParameterWithName:@"Jing" value:[NSString stringWithFormat:@"%f",_lng]]];
        [dic setValue:[NSString stringWithFormat:@"%f",_lat] forKey:@"Wei"];
        [dic setValue:[NSString stringWithFormat:@"%f",_lng] forKey:@"Jing"];
    }
    if (nil != _format) {
        //        [parameters addObject:[OARequestParameter requestParameterWithName:@"format" value:_format]];
        [dic setValue:_format forKey:@"format"];
    }
    else
    {
        //        [parameters addObject:[OARequestParameter requestParameterWithName:@"format" value:@"json"]];
        [dic setValue:@"json" forKey:@"format"];
    }
    
    //    [parameters addObject:[OARequestParameter requestParameterWithName:@"clientip" value:@"127.0.0.1"]];
    [dic setValue:@"127.0.0.1" forKey:@"clientip"];
    
    for (NSString *key in [dic allKeys]) {
        [parameters addObject:[OARequestParameter requestParameterWithName:key value:[dic valueForKey:key]]];
    }
    
    [request setParameters:parameters];
    
    [body appendFormat:@"%@",[request txBaseString]];
    
    //    NSString *url = [NSString stringWithFormat:@"%@?oauth_callback=%@&%@",TXRequestURL,[CallBackURL URLEncodedString],[hmacSha1Request txBaseString]];
    NSString *_url = [NSString stringWithFormat:@"%@?%@",url,body];
    [request setURL:[NSURL URLWithString:_url]];
    //    NSLog(@"%@",_url);
    
    
    NSMutableData *postbody = [[NSMutableData alloc] init];
    
    NSString *param = [self nameValString:dic];
    NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", WBShareKit_BOUNDARY];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\r\n", WBShareKit_BOUNDARY]];
    param = [param stringByAppendingString:@"Content-Disposition: form-data; name=\"pic\";filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"];
//    NSData *jpeg = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:_path], 0.55);
    
    NSData *jpeg = UIImageJPEGRepresentation([item image], 0.55);
    
    [postbody appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:jpeg];
    [postbody appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
    
    //    NSString *headerTemplate = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: \"image/jpeg\"\r\n\r\n";
    //	NSData *boundaryBytes = [[NSString stringWithFormat:@"\r\n--%@--\r\n", WBShareKit_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding];
    //    NSString *filePath = _path;
    //    NSData *fileData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:filePath], 0.01);
    //    NSString *header = [NSString stringWithFormat:headerTemplate,WBShareKit_BOUNDARY, @"Pic", [[filePath componentsSeparatedByString:@"/"] lastObject]];
    //    [postbody appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
    //    [postbody appendData:fileData];
    //    [postbody appendData:boundaryBytes];
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", WBShareKit_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [postbody length]] forHTTPHeaderField:@"Content-Length"];
    
    //    NSLog(@"%@",body);
    [request setHTTPBody:postbody];
    
	
	OAAsynchronousDataFetcher *addRecordFetcher = [[[OAAsynchronousDataFetcher alloc] init] autorelease];
	[addRecordFetcher initWithRequest:request 
                             delegate:_delegate
                    didFinishSelector:_sSel
                      didFailSelector:_eSel];
	[addRecordFetcher start];
    //    [addRecordFetcher release];
    [parameters release];
    [postbody release];
}



// Send the share item to the server
- (BOOL)send
{	
    NSLog(@"IN SEND!!!");
    NSLog(@"validateItem: ", [self validateItem]);
    
	if (![self validateItem]) {
        [self show];
        return NO;
    }
        
    if (item.shareType == SHKShareTypeText) {
        [self sendTxRecordWithStatus:[item customValueForKey:@"status"] lat:0 lng:0 format:@"json" delegate:self successSelector:@selector(sendStatusTicket:didFinishWithData:) failSelector:@selector(sendStatusTicket:didFailWithError:)];
    } else if (item.shareType == SHKShareTypeImage) {
        [self sendTxRecordWithStatus:[item customValueForKey:@"status"] lat:0 lng:0 format:@"json" path:[[NSBundle mainBundle] pathForResource:@"sanFn" ofType:@"jpg"] delegate:self successSelector:@selector(sendStatusTicket:didFinishWithData:) failSelector:@selector(sendStatusTicket:didFailWithError:)];
    }
    
    	
	/*
	 Enter the necessary logic to share the item here.
	 
	 The shared item and relevant data is in self.item
	 // See http://getsharekit.com/docs/#sending
	 
	 --
	 
	 A common implementation looks like:
	 	 
	 -  Send a request to the server
	 -  call [self sendDidStart] after you start your action
	 -	after the action completes, fails or is cancelled, call one of these on 'self':
		- (void)sendDidFinish (if successful)
		- (void)sendDidFailShouldRelogin (if failed because the user's current credentials are out of date)
		- (void)sendDidFailWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin
		- (void)sendDidCancel
	 */ 
	
	
	// Here is an example.  
	// This example is for a service that can share a URL
	 
	/* 
	// Determine which type of share to do
	if (item.shareType == SHKShareTypeURL) // sharing a URL
	{
		// For more information on OAMutableURLRequest see http://code.google.com/p/oauthconsumer/wiki/UsingOAuthConsumer
		
		OAMutableURLRequest *oRequest = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.example.com/share"]
																		consumer:consumer // this is a consumer object already made available to us
																		   token:accessToken // this is our accessToken already made available to us
																		   realm:nil
															   signatureProvider:signatureProvider];
		
		// Set the http method (POST or GET)
		[oRequest setHTTPMethod:@"POST"];
		
		
		// Create our parameters
		OARequestParameter *urlParam = [[OARequestParameter alloc] initWithName:@"url"
																		  value:SHKEncodeURL(item.URL)];
		
		OARequestParameter *titleParam = [[OARequestParameter alloc] initWithName:@"title"
																		   value:SHKEncode(item.title)];
		
		// Add the params to the request
		[oRequest setParameters:[NSArray arrayWithObjects:titleParam, urlParam, nil]];
		[urlParam release];
		[titleParam release];
		
		// Start the request
		OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oRequest
																							  delegate:self
																					 didFinishSelector:@selector(sendTicket:didFinishWithData:)
																					   didFailSelector:@selector(sendTicket:didFailWithError:)];	
		
		[fetcher start];
		[oRequest release];
		
		// Notify delegate
		[self sendDidStart];
		
		return YES;
	}
	
	return NO;
	*/
}

// This is a continuation of the example provided in 'send' above.  It handles the OAAsynchronousDataFetcher response
// This is not a required method and is only provided as an example
/*
- (void)sendTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data 
{	
	if (ticket.didSucceed)
	{
		// The send was successful
		[self sendDidFinish];
	}
	
	else 
	{
		// Handle the error
		
		// If the error was the result of the user no longer being authenticated, you can reprompt
		// for the login information with:
		// [self sendDidFailShouldRelogin];
		
		// Otherwise, all other errors should end with:
		[self sendDidFailWithError:[SHK error:@"Why it failed"] shouldRelogin:NO];
	}
}
- (void)sendTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error
{
	[self sendDidFailWithError:error shouldRelogin:NO];
}
*/

- (void)sendForm:(SHKQQWeiboForm*)form {
    [item setCustomValue:form.textView.text forKey:@"status"];
    [self tryToSend];
}

@end
