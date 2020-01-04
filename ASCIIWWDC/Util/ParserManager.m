//
//  ParserManager.m
//  ASCIIWWDC
//
//  Created by 汪泽伟 on 2018/5/17.
//  Copyright © 2018年 Wang Zewei. All rights reserved.
//

#import "ParserManager.h"

@implementation ParserManager

+ (instancetype) sharedManager {
    static ParserManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ParserManager alloc] init];
    });
    return manager;
}

- (NSArray *)createSessionsArrayFromTrackNode:(HTMLElement *) trackNode {
    NSArray *dtNodes = [trackNode querySelectorAll:@"dt"];
    NSArray *ddNodes = [trackNode querySelectorAll:@"dd"];
    NSAssert(dtNodes.count == ddNodes.count, @"dtNodes.count != ddNodes.count");
    NSMutableArray *sessions = [NSMutableArray array];
    for(int i = 0; i < dtNodes.count; i++) {
        HTMLElement *dtNode = dtNodes[i];
        HTMLElement *ddNode = ddNodes[i];
        Session *thisSession = [[Session alloc] init];
        thisSession.sessionID = dtNode.attributes[@"id"];
        thisSession.title = [ddNode querySelector:@"a"].attributes[@"title"];
        thisSession.urlString = [ddNode querySelector:@"a"].attributes[@"href"];
        [sessions addObject:thisSession];
    }
    return [sessions copy];
}

- (NSArray *)createTracksArrayFromConferenceNode:(HTMLElement *) conferenceNode {
    NSArray * trackNodes = [conferenceNode querySelectorAll:@".track"];
    __block NSMutableArray *tracks = [NSMutableArray array];
    [trackNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HTMLElement *trackNode = (HTMLElement *) obj;
        Track *track = [[Track alloc] init];
        track.trackName = [trackNode querySelector:@"h1"].textContent;
        track.sessions = [self createSessionsArrayFromTrackNode:trackNode];
        [track.sessions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Session *session = (Session *)obj;
            session.trackName = track.trackName;
        }];
        [tracks addObject:track];
    }];
    
    return [tracks copy];
}

- (Conference *)createConferenceFromConferenceNode:(HTMLElement *) conferenceNode {
    __block Conference *conference = [[Conference alloc] init];

    conference.logoUrlString = [conferenceNode querySelector:@"header img"].attributes[@"src"];
    
    conference.name = [conferenceNode querySelector:@"header hgroup h1"].textContent;
    conference.shortDescription = [conferenceNode querySelector:@"header hgroup h2"].textContent;
    conference.time = [conferenceNode querySelector:@"header time"].attributes[@"content"];
    
    __block Location *location = [[Location alloc] init];
    NSArray *locationsNode = [conferenceNode querySelectorAll:@"header address span"];
    
    [locationsNode enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HTMLElement *element = (HTMLElement *)obj;
        NSString *tagValue = element.attributes[@"itemprop"];
        NSString *contentText = element.textContent;
        if ([tagValue isEqualToString:@"name"]) {
            location.name = contentText;
        } else if ([tagValue isEqualToString:@"streetAddress"]) {
            location.streetAddress = contentText;
        } else if ([tagValue isEqualToString:@"addressLocality"]) {
            location.addressLocality = contentText;
        } else if ([tagValue isEqualToString:@"addressRegion"]) {
            location.addressRegion = contentText;
        } else if ([tagValue isEqualToString:@"postalCode"]) {
            location.postalCode = contentText;
        } else if ([tagValue isEqualToString:@"addressCountry"]) {
            location.addressCountry = contentText;
        }
        conference.location = location;
    }];
    
    conference.tracks = [self createTracksArrayFromConferenceNode:conferenceNode];
    [conference.tracks enumerateObjectsUsingBlock:^(Track * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.conferenceName = conference.name;
    }];
    return conference;
}

- (NSArray *)createConferencesArrayFromResponseObject:(id)responseObject {
    
    NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString];
    HTMLDocument *document = [parser parseDocument];
    NSArray * conferencesNodes = [document.body querySelectorAll:@".conference"];
    
    __block NSMutableArray<Conference *> *conferences = [NSMutableArray array];
    [conferencesNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HTMLElement *conferenceNode = (HTMLElement *)obj;
        Conference *conference = [self createConferenceFromConferenceNode:conferenceNode];
        [conferences addObject:conference];
    }];
    
    return [conferences copy];
}

@end
