//
//  MyAnimeList+Update.m
//  MAL Updater OS X
//
//  Created by 高町なのは on 2015/02/11.
//  Copyright 2009-2015 Atelier Shiori. All rights reserved. Code licensed under New BSD License
//

#import "MyAnimeList+Update.h"
#import <EasyNSURLConnection/EasyNSURLConnectionClass.h>
#import "MyAnimeList+Keychain.h"

@implementation MyAnimeList (Update)
-(BOOL)checkstatus:(NSString *)titleid {
    NSLog(@"Checking Status");
    //Set Search API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/2.1/%@/%@?mine=1",MALApiUrl, (DetectedTitleisManga ? @"manga" : @"anime"), titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
    [request addHeader:[NSString stringWithFormat:@"Basic %@",[self getBase64]]  forKey:@"Authorization"];
    //Perform Search
    [request startRequest];
    // Get Status Code
    int statusCode = [request getStatusCode];
    NSError * error = [request getError]; // Error Detection
    NSLog(@"%@", [request getResponseDataString]);
    if (statusCode == 200 ) {
        online = true;
        if (DetectedEpisode.length == 0) { // Check if there is a DetectedEpisode (needed for checking
            // Set detected episode to 1
            DetectedEpisode = @"1";
        }
        NSError* jerror;
        NSDictionary *animeinfo = [NSJSONSerialization JSONObjectWithData:[request getResponseData] options:nil error:&jerror];
        if (animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters" : @"episodes")]] == [NSNull null]) { // To prevent the scrobbler from failing because there is no episode total.
            TotalEpisodes = 0; // No Episode Total, Set to 0.
        }
        else { // Episode Total Exists
            TotalEpisodes = [(NSNumber *)animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters" : @"episodes")]] intValue];
        }
        // Watch Status
        NSLog(@"%@",animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"read_status" : @"watched_status")]]);
        if (animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"read_status" : @"watched_status")]] == [NSNull null] || animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"read_status" : @"watched_status")]] == nil) {
            NSLog(@"Not on List");
            LastScrobbledTitleNew = true;
            DetectedCurrentEpisode = 0;
            TitleScore = 0;
        }
        else {
            NSLog(@"Title on List");
            LastScrobbledTitleNew = false;
            WatchStatus = animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"read_status" : @"watched_status")]];
            DetectedCurrentEpisode = [(NSNumber *)animeinfo[[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters_read" : @"watched_episodes")]] intValue];
            if (animeinfo[@"score"] == [NSNull null]){
                // Score is null, set to 0
                TitleScore = 0;
            }
            else {
                TitleScore = [(NSNumber *)animeinfo[@"score"] intValue];
            }
        }
        // New Update Confirmation
        if (([[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmNewTitle"] && LastScrobbledTitleNew && !correcting)|| ([[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmUpdates"] && !LastScrobbledTitleNew && !correcting)) {
            // Manually confirm updates
            confirmed = false;
        }
        else{
            // Automatically confirm updates
            confirmed = true;
        }
        LastScrobbledInfo = animeinfo;
        // Makes sure the values don't get released
        return YES;
    }
    else if (error !=nil){
        if (error.code == NSURLErrorNotConnectedToInternet) {
            online = false;
            return NO;
        }
        else {
            online = true;
            return NO;
        }
    }
    else {
        online = true;
        // Some Error. Abort
        return NO;
    }
    //Should never happen, but...
    return NO;
}

-(int)updatetitle:(NSString *)titleid confirming:(bool)confirming{
    NSLog(@"Updating Title");
    
    if ([DetectedEpisode intValue] <= DetectedCurrentEpisode ) {
        // Already Watched, no need to scrobble
        // Store Scrobbled Title and Episode
        confirmed = true;
        [self storeLastScrobbled];
        return 2;
    }
    else if (!LastScrobbledTitleNew && [[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmUpdates"] && !confirmed && !correcting && !confirming) {
        // Confirm before updating title
        [self storeLastScrobbled];
        return 3;
    }
    else {
        // Update the title
        //Set library/scrobble API
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/2.1/%@/%@", MALApiUrl, (DetectedTitleisManga ? @"mangalist/manga" : @"animelist/anime"), titleid]];
        EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
        //Ignore Cookies
        [request setUseCookies:NO];
        //Set Token
                [request addHeader:[NSString stringWithFormat:@"Basic %@",[self getBase64]]  forKey:@"Authorization"];
        [request setPostMethod:@"PUT"];
        [request addFormData:DetectedEpisode forKey:[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters" : @"episodes")]];
        //Set Status
        if([DetectedEpisode intValue] == TotalEpisodes) {
            //Set Title State for Title (use for Twitter feature)
            WatchStatus = @"completed";
            // Since Detected Episode = Total Episode, set the status as "Complete"
            [request addFormData:WatchStatus forKey:@"status"];
        }
        else {
            //Set Title State for Title (use for Twitter feature)
            WatchStatus = [NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"reading" : @"watching")];
            // Still Watching
            [request addFormData:WatchStatus forKey:@"status"];
        }
        // Set existing score to prevent the score from being erased.
        [request addFormData:[[NSNumber numberWithInt:TitleScore] stringValue] forKey:@"score"];
        // Do Update
        [request startFormRequest];
        
        switch ([request getStatusCode]) {
            case 200:
                // Store Last Scrobbled Title
                LastScrobbledTitle = DetectedTitle;
                LastScrobbledEpisode = DetectedEpisode;
                DetectedCurrentEpisode = [DetectedEpisode intValue];
                LastScrobbledSource = DetectedSource;
                if (confirmed) {
                    LastScrobbledActualTitle = (NSString *)LastScrobbledInfo[@"title"];
                }
                confirmed = true;
                // Update Successful
                return 22;
            default:
                // Update Unsuccessful
                return 53;
        }
        
    }
}
-(int)addtitle:(NSString *)titleid confirming:(bool)confirming{
    NSLog(@"Adding Title");
    //Check Confirm
    if (LastScrobbledTitleNew && [[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmNewTitle"] && !confirmed && !correcting && !confirming) {
        // Confirm before updating title
        [self storeLastScrobbled];
        return 3;
    }
    // Add the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/2.1/%@", MALApiUrl, (DetectedTitleisManga ? @"mangalist/manga" : @"animelist/anime")]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
    [request addHeader:[NSString stringWithFormat:@"Basic %@",[self getBase64]]  forKey:@"Authorization"];
    [request addFormData:titleid forKey:[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"manga_id" : @"anime_id")]];

    [request addFormData:DetectedEpisode forKey:[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters" : @"episodes")]];
    // Check if the detected episode is equal to total episodes. If so, set it as complete (mostly for specials and movies)
    if([DetectedEpisode intValue] == TotalEpisodes) {
        //Set Title State for Title (use for Twitter feature)
        WatchStatus = @"completed";
        // Since Detected Episode = Total Episode, set the status as "Complete"
        [request addFormData:WatchStatus forKey:@"status"];
    }
    else {
        //Set Title State for Title (use for Twitter feature)
        WatchStatus = [NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"reading" : @"watching")];
        // Still Watching
        [request addFormData:WatchStatus forKey:@"status"];
    }
    // Do Update
    [request startFormRequest];
    
    
    //Set Title State for Title
    WatchStatus = [NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"reading" : @"watching")];
    switch ([request getStatusCode]) {
        case 200:
        case 201:
            // Update Successful
            
            //Store last scrobbled information
            LastScrobbledTitle = DetectedTitle;
            LastScrobbledEpisode = DetectedEpisode;
            DetectedCurrentEpisode = [DetectedEpisode intValue];
            LastScrobbledSource = DetectedSource;
            if (confirmed) {
                LastScrobbledActualTitle = (NSString *)LastScrobbledInfo[@"title"];
            }
            confirmed = true;
            return 21;
        default:
            // Update Unsuccessful
            return 52;
    }
}
-(bool)removetitle:(NSString *)titleid{
    NSLog(@"Removing %@", titleid);
    //Set up Delegate
    
    // Update the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/2.1/%@/%@", MALApiUrl, (DetectedTitleisManga ? @"mangalist/manga" : @"animelist/anime"), titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
            [request addHeader:[NSString stringWithFormat:@"Basic %@",[self getBase64]]  forKey:@"Authorization"];
    //Set method to Delete
    [request setPostMethod:@"DELETE"];
    // Do Update
    [request startFormRequest];
    switch ([request getStatusCode]) {
        case 200:
        case 201:
            return true;
        default:
            // Update Unsuccessful
            return false;
    }
    return false;
}
-(BOOL)updatestatus:(NSString *)titleid
              score:(int)showscore
        watchstatus:(NSString*)showwatchstatus
            episode:(NSString*)episode
{
    NSLog(@"Updating Status for %@", titleid);
    // Update the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/2.1/%@/%@", MALApiUrl, (DetectedTitleisManga ? @"mangalist/manga" : @"animelist/anime"), titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
            [request addHeader:[NSString stringWithFormat:@"Basic %@",[self getBase64]]  forKey:@"Authorization"];
    [request setPostMethod:@"PUT"];
    //Set current episode
    [request addFormData:episode forKey:[NSString stringWithFormat:@"%@", (DetectedTitleisManga ? @"chapters" : @"episodes")]];
    //Set new watch status
    [request addFormData:showwatchstatus forKey:@"status"];
    //Set new score.
    [request addFormData:[NSString stringWithFormat:@"%i", showscore] forKey:@"score"];
    // Do Update
    [request startFormRequest];
    switch ([request getStatusCode]) {
        case 200:
            // Update Successful
            //Set New Values
            TitleScore = showscore;
            WatchStatus = showwatchstatus;
            LastScrobbledEpisode = episode;
            DetectedCurrentEpisode = [episode intValue];
            confirmed = true;
            return true;
        default:
            // Update Unsuccessful
            return false;
    }
}
-(void)storeLastScrobbled{
    LastScrobbledTitle = DetectedTitle;
    LastScrobbledEpisode = DetectedEpisode;
    LastScrobbledActualTitle = (NSString *)LastScrobbledInfo[@"title"];
    LastScrobbledSource = DetectedSource;
}
@end
