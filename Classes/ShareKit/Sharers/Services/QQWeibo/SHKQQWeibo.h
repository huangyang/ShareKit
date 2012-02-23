//
//  «FILENAME»
//  «PROJECTNAME»
//
//  Created by «FULLUSERNAME» on «DATE».
//  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHK.h"
#import "SHKOAuthSharer.h"
#import "SHKQQWeiboForm.h"

@interface SHKQQWeibo : SHKOAuthSharer {

}

- (void)sendForm:(SHKQQWeiboForm*)form;

- (void)sendTxRecordWithStatus:(NSString *)_status lat:(double)_lat lng:(double)_lng format:(NSString *)_format delegate:(id)_delegate successSelector:(SEL)_sSel failSelector:(SEL)_eSel;

- (void)sendStatusTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)sendStatusTicket:(OAServiceTicket *)ticket didFailWithError:(NSError*)error;

@end
