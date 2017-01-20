//
//  GameLayer.h
//  Conqure me
//
//  Created by 1 on 1/10/14.
//  Copyright 2014 individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameLayer : CCLayer {
    CCSprite* m_sprRed;
    CCSprite* m_sprBlue;
  
    BOOL    m_isRed;
    BOOL    m_NormalIPhone;
    BOOL    m_Branch;
    
    CGSize  size;
    int     m_touchArray[300];
    int     m_touchCount;
    int     m_checkCount;
    int     m_remainCheckCount;
    int     m_otherConnectPoint;
    int     m_checkPoints[200];
    int     m_remainCheckPoints[100];
    int     resultPoints[60];
    int     remainPoints[60];
    int     firstCount;
    int     nTouchId;
    int     m_CntFirst;
    int     m_ArrayFirst[50];
    int     m_CntSecond;
    int     m_ArraySecond[50];
    
    int     m_arrayBranchFirstPos[10];
    int     m_ArrayUseStack[20];
    
    int     m_scoreBlue;
    int     m_scoreRed;
    int     m_redPolygonCount;
    int     m_bluePolygonCount;
    
    int     m_rPolygonLineCount[50];
    int     m_bPolygonLineCount[50];
    
    int     m_redDrawPoints[50][50];
    int     m_blueDrawPoints[50][50];
    
    BOOL    m_drawRedPolygon[50];
    BOOL    m_drawBluePolygon[50];
    BOOL    m_UseStackFound;
    BOOL    m_SquareFour;
    int     m_branchCount;
    int     m_lastStackSearch;
    int     m_CntStack;
 
    int     m_CntUseStack;
    int     m_arrayCheckStack[20];
    
    CCLabelTTF* lblBlue;
    CCLabelTTF* lblRed;

    CCLabelTTF* lblWhichTeam;
    
    NSMutableArray* m_blueSpriteArray;
    NSMutableArray* m_redSpriteArray;
    NSMutableArray* m_remainArray;
}

+(CCScene*) scene;
- (BOOL) searchPoint:(int) nId;
- (BOOL) checkSprite:(int) sprId;
- (BOOL) checkOldPoint:(int) nTouchNumber;
- (void) searchPath:(int) nId;
@end
