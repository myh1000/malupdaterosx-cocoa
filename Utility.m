//
//  Utility.m
//  MAL Updater OS X
//
//  Created by Tail Red on 1/31/15.
//
//

#import "Utility.h"
#import <EasyNSURLConnection/EasyNSURLConnectionClass.h>

@implementation Utility
+(bool)checkMatch:(NSString *)title
         alttitle:(NSString *)atitle
            regex:(OGRegularExpression *)regex
           option:(int)i{
    //Checks for matches
    if ([regex matchInString:title] != nil || ([regex matchInString:atitle] != nil && [atitle length] >0 && i==0)) {
        return true;
    }
    return false;
}
+(NSString *)desensitizeSeason:(NSString *)title {
    // Get rid of season references
    OGRegularExpression * regex = [OGRegularExpression regularExpressionWithString: @"(s)\\d" options:OgreIgnoreCaseOption];
    title = [regex replaceAllMatchesInString:title withString:@""];
    // Remove any Whitespace
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return title;
}
+(NSString *)seasonInWords:(int)season{
    // Translate integer season to word (use for Regex)
    switch (season) {
        case 1:
            return @"first";
        case 2:
            return @"second";
        case 3:
            return @"third";
        case 4:
            return @"fourth";
        case 5:
            return @"fifth";
        case 6:
            return @"sixth";
        case 7:
            return @"seventh";
        case 8:
            return @"eighth";
        case 9:
            return @"ninth";
        default:
            return @"";
}
}
+(BOOL)checkoldAPI{
    if ([[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"MALAPIURL"]] isEqualToString:@"https://malapi.shioridiary.me"]||[[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"MALAPIURL"]] isEqualToString:@"http://mal-api.com"]) {
        return true;
    }
    return false;
}
+(void)showsheetmessage:(NSString *)message
            explaination:(NSString *)explaination
                 window:(NSWindow *)w {
    // Set Up Prompt Message Window
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setInformativeText:explaination];
    // Set Message type to Warning
    [alert setAlertStyle:NSInformationalAlertStyle];
    // Show as Sheet on Preference Window
    [alert beginSheetModalForWindow:w
                      modalDelegate:self
                     didEndSelector:nil
                        contextInfo:NULL];
}
+(NSString *)urlEncodeString:(NSString *)string{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (CFStringRef)string,
                                                                                                  NULL,
                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                  kCFStringEncodingUTF8 ));
}
+(void)donateCheck:(MAL_Updater_OS_XAppDelegate*)delegate{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"donatereminderdate"] == nil){
        [Utility setReminderDate];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"donatereminderdate"] timeIntervalSinceNow] < 0 && ![[NSUserDefaults standardUserDefaults] boolForKey: @"donateremindersuppress"]) {
        NSAlert * alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:@"Donate"];
        [alert addButtonWithTitle:@"Remind Me Later"];
        [alert setMessageText:@"Please Support MAL Updater OS X"];
        [alert setInformativeText:@"We noticed that you have been using MAL Updater OS X for a while. Although MAL Updater OS X is free, it cost us money and time to develop this program as I don't have as much free time to work on it. \r\rIf you find this program helpful, please consider making a donation. Funding will help future development and keep the program functional. Note that donating is completely optional."];
        [alert setShowsSuppressionButton:YES];
        // Set Message type to Warning
        [alert setAlertStyle:NSInformationalAlertStyle];
        if ([alert runModal]== NSAlertFirstButtonReturn) {
            // Open Donation Page
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://malupdaterosx.ateliershiori.moe/donate/"]];
            [Utility setReminderDate];
        }
        else{
            [Utility showDonateReminder:delegate];
        }
    }
}
+(void)showDonateReminder:(MAL_Updater_OS_XAppDelegate*)delegate{
    // Shows Donation Reminder
    NSAlert * alert = [[NSAlert alloc] init] ;
    [alert addButtonWithTitle:@"Donate"];
    [alert addButtonWithTitle:@"Enter Key"];
    [alert addButtonWithTitle:@"Remind Me Later"];
    [alert setMessageText:@"Please Support MAL Updater OS X"];
    [alert setInformativeText:@"We noticed that you have been using MAL Updater OS X for a while. Although MAL Updater OS X is free and open source software, it cost us money and time to develop this program. \r\rIf you find this program helpful, please consider making a donation. You will recieve a key to remove this message and enable weekly builds update channel."];
    [alert setShowsSuppressionButton:NO];
    // Set Message type to Warning
    [alert setAlertStyle:NSInformationalAlertStyle];
    long choice = [alert runModal];
    if (choice == NSAlertFirstButtonReturn) {
        // Open Donation Page
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://malupdaterosx.ateliershiori.moe/donate/"]];
        [Utility setReminderDate];
    }
    else if (choice == NSAlertSecondButtonReturn) {
        // Show Add Donation Key dialog.
        [delegate enterDonationKey:nil];
        [Utility setReminderDate];
    }
    else{
        // Surpress message for 2 weeks.
        [Utility setReminderDate];
    }
}

+(void)setReminderDate{
    //Sets Reminder Date
    NSDate *now = [NSDate date];
    NSDate * reminderdate = [now dateByAddingTimeInterval:60*60*24*14];
    [[NSUserDefaults standardUserDefaults] setObject:reminderdate forKey:@"donatereminderdate"];
}
+(int)checkDonationKey:(NSString *)key name:(NSString *)name{
        //Set Search API
        NSURL *url = [NSURL URLWithString:@"https://updates.ateliershiori.moe/keycheck/check.php"];
        EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
        [request addFormData:name forKey:@"name"];
        [request addFormData:key forKey:@"key"];
        //Ignore Cookies
        [request setUseCookies:NO];
        //Perform Search
        [request startJSONFormRequest];
        // Get Status Code
        long statusCode = [request getStatusCode];
    if (statusCode == 200){
        NSError* jerror;
        NSDictionary * d = [NSJSONSerialization JSONObjectWithData:[request getResponseData] options:nil error:&jerror];
        int valid = [(NSNumber *)d[@"valid"] intValue];
        if (valid == 1) {
            // Valid Key
            return 1;
        }
        else{
            // Invalid Key
            return 0;
        }
    }
    else{
        // No Internet
        return 2;
    }


}

@end
