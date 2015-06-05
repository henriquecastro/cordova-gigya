/********* CordovaGigya.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <GigyaSDK/Gigya.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CordovaGigya : CDVPlugin {
// Member variables go here.
}

- (void)initialize:(CDVInvokedUrlCommand*)command;
@end

@implementation CordovaGigya

- (void)pluginInitialize;
{
    NSLog(@"Cordova Gigya Plugin Initialize from my custom fork edited");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedOpenUrl:) name:@"CDVPluginHandleOpenURLNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification object:nil];

    [super pluginInitialize];
}

// selectors
- (void)notifiedOpenUrl:(NSNotification *)notification
{

    NSLog(@"Url handled");
    NSLog(@"notification object: %@", notification.object);

    //NSURL* url = (NSURL*)notification.object;
    NSURL* url = [notification object];

    if ([url isKindOfClass:[NSURL class]]) {
        [Gigya handleOpenURL:url sourceApplication:nil annotation:nil];
    }
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [Gigya handleDidBecomeActive];
}

// CDV Plugin commands
- (void)initialize:(CDVInvokedUrlCommand*)command
{
    NSString* apiKey = [command.arguments objectAtIndex:0];
    [Gigya initWithAPIKey:apiKey];

}

- (void)showLoginUI:(CDVInvokedUrlCommand*)command
{
    NSArray* providers;

    if([command.arguments objectAtIndex:0] != [NSNull null]){
        providers = [command.arguments objectAtIndex:0];
    }
    else {
        providers = @[];
    }

    NSDictionary* loginParams = nil;

    if([command.arguments objectAtIndex:1] != [NSNull null]){
        loginParams = [command.arguments objectAtIndex:1];
    }

    [Gigya showLoginProvidersDialogOver:super.viewController
        providers:providers
        parameters:loginParams
        completionHandler:^(GSUser *user, NSError *error) {
            CDVPluginResult* pluginResult = nil;

            if (!error) {
                NSString* userString = [user JSONString];
                NSData* userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* userDictionary = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDictionary];
            }
            else {
                // Handle error
                NSLog(@"Login error: %@", error);
                NSDictionary* userInfo = [error userInfo];
                NSDictionary* data = nil;

                if(userInfo[@"state"] && userInfo[@"regToken"]) {
                    data = @{
                       @"state": [NSString stringWithString:userInfo[@"state"]],
                       @"regToken": [NSString stringWithString:userInfo[@"regToken"]],
                       @"errorCode": [NSNumber numberWithInteger:error.code],
                       @"errorMessage": [NSString stringWithString:userInfo[@"NSLocalizedDescription"]]
                    };
                } else {
                    data = @{
                       @"errorCode": [NSNumber numberWithInteger:error.code],
                       @"errorMessage": [NSString stringWithString:userInfo[@"NSLocalizedDescription"]]
                    };
                }

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:data];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }];
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    NSString* provider = [command.arguments objectAtIndex:0];

    NSDictionary* loginParams = nil;

    if([command.arguments objectAtIndex:1] != [NSNull null]){
        loginParams = [command.arguments objectAtIndex:1];
    }

    [Gigya loginToProvider:provider
                parameters:loginParams
                      over:super.viewController
         completionHandler:^(GSUser *user, NSError *error) {
            CDVPluginResult* pluginResult = nil;


            if (!error) {
                NSLog(@"Email = %@", user[@"email"]);
                NSString* userString = [user JSONString];
                NSData* userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* userDictionary = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDictionary];
            }
            else {
                // Handle error
                NSLog(@"Login error: %@", error);

                NSDictionary* userInfo = [error userInfo];
                NSDictionary* data = nil;

                if(userInfo[@"state"] && userInfo[@"regToken"]) {
                    data = @{
                       @"state": [NSString stringWithString:userInfo[@"state"]],
                       @"regToken": [NSString stringWithString:userInfo[@"regToken"]],
                       @"errorCode": [NSNumber numberWithInteger:error.code],
                       @"errorMessage": [NSString stringWithString:userInfo[@"NSLocalizedDescription"]]
                    };
                } else {
                    data = @{
                       @"errorCode": [NSNumber numberWithInteger:error.code],
                       @"errorMessage": [NSString stringWithString:userInfo[@"NSLocalizedDescription"]]
                    };
                }

                

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:data];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

         }];
}

- (void)getSession:(CDVInvokedUrlCommand*)command
{

    GSSession* session = [Gigya session];
    CDVPluginResult* pluginResult = nil;

    BOOL isValid = [session isValid];
    if(isValid){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:session.token];
    }
    else{
        NSLog(@"Session error: no valid session");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

- (void)sendRequest:(CDVInvokedUrlCommand*)command
{
    NSString* requestMethod = [command.arguments objectAtIndex:0];

    GSRequest* request;

    if([command.arguments objectAtIndex:1] != [NSNull null]){
        NSDictionary* requestParams = [command.arguments objectAtIndex:1];
        request = [GSRequest requestForMethod:requestMethod parameters:requestParams];
    }
    else{
        request = [GSRequest requestForMethod:requestMethod];
    }

    [request sendWithResponseHandler:^(GSResponse *response, NSError *error) {
        CDVPluginResult* pluginResult = nil;

        NSString* responseString = [response JSONString];
        NSData* responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        if (!error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseDictionary];
        }
        else {
            // Handle error
            NSLog(@"Request error: %@", error);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:responseDictionary];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)addConnectionToProvider:(CDVInvokedUrlCommand*)command
{
    NSLog(@"AddConnectionToProvider ");
    
    NSString* provider = [command.arguments objectAtIndex:0];

    NSDictionary* loginParams = nil;

    if([command.arguments objectAtIndex:1] != [NSNull null]){
        loginParams = [command.arguments objectAtIndex:1];
    }

    [Gigya addConnectionToProvider:provider
                parameters:loginParams
                      over:super.viewController
         completionHandler:^(GSUser *user, NSError *error) {
            
            CDVPluginResult* pluginResult = nil;


            if (!error) {
                NSLog(@"AddConnectionToProvider success");
                NSString* userString = [user JSONString];
                NSData* userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* userDictionary = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDictionary];
            }
            else {
                // Handle error
                NSLog(@"AddConnectionToProvider error: %@", error);

                NSDictionary* userInfo = [error userInfo];

                NSDictionary* data = @{
                   @"state": [NSString stringWithString:userInfo[@"state"]],
                   @"regToken": [NSString stringWithString:userInfo[@"regToken"]],
                   @"errorCode": [NSNumber numberWithInteger:error.code],
                   @"errorMessage": [NSString stringWithString:userInfo[@"NSLocalizedDescription"]]
                };

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:data];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

         }];

}

- (void)loginUserWithPassword:(CDVInvokedUrlCommand*)command
{
    if (![[Gigya session] isValid]) {

        GSRequest* request;

        if([command.arguments objectAtIndex:0] != [NSNull null]){
            NSDictionary* requestParams = [command.arguments objectAtIndex:0];
            request = [GSRequest requestForMethod:@"accounts.login" parameters:requestParams];
        }
        else{
            request = [GSRequest requestForMethod:@"accounts.login"];
        }

        [request sendWithResponseHandler:^(GSResponse *response, NSError *error) {
            CDVPluginResult* pluginResult = nil;
            
            NSString* responseString = [response JSONString];
            NSData* responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

            if (!error) {
                NSString* sessionToken = response[@"sessionInfo"][@"sessionToken"];
                NSString* sessionSecret = response[@"sessionInfo"][@"sessionSecret"];
                GSSession* gigyaSession = [[GSSession alloc] initWithSessionToken:sessionToken secret:sessionSecret];
                [Gigya setSession:gigyaSession];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseDictionary];
            }
            else {
                // Handle error
                NSLog(@"Request error: %@", error);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:responseDictionary];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    else {
        NSLog(@"Already logged in. Logout first.");
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Already logged in. Logout first."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showAddConnectionUI:(CDVInvokedUrlCommand*)command
{
    NSArray* providers;

    if([command.arguments objectAtIndex:0] != [NSNull null]){
        providers = [command.arguments objectAtIndex:0];
    }
    else {
        providers = @[];
    }

    NSDictionary* params = nil;

    if([command.arguments objectAtIndex:1] != [NSNull null]){
        params = [command.arguments objectAtIndex:1];
    }

    [Gigya showAddConnectionProvidersDialogOver:super.viewController
        providers:providers
        parameters:params
        completionHandler:^(GSUser *user, NSError *error) {
            CDVPluginResult* pluginResult = nil;

            NSString* userString = [user JSONString];
            NSData* userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* userDictionary = [NSJSONSerialization JSONObjectWithData:userData options:kNilOptions error:&error];

            if (!error) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDictionary];
            }
            else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userDictionary];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [Gigya logoutWithCompletionHandler:^(GSResponse *response, NSError *error) {
        CDVPluginResult* pluginResult = nil;

        NSString* responseString = [response JSONString];
        NSData* responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

        if (!error) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseDictionary];
        }
        else {
            NSLog(@"Logout error: %@", error);

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:responseDictionary];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
