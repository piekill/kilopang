//
//  GameScene.h
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#ifndef kilopang_GameScene_h
#define kilopang_GameScene_h

#include "cocos2d.h"
#include "Elf.h"
#include "PauseLayer.h"
#include "ScoreScene.h"
#include <map>

#define GRID_ROW 7
#define GRID_COLUMN 7
#define MAX_TIME 30

#define GRID_OFFSET ccp(5,100)
#define ELFSHEET 1
#define BONUS_TYPES 3

using namespace cocos2d;
using namespace std;
class Elf;
class PauseLayer;
class ScoreScene;

class GameScene : public cocos2d::CCLayer
{
public:
	
	bool init();
	
	static cocos2d::CCScene* scene();
	
	CREATE_FUNC(GameScene);
	
	void onEnter();  
	void onExit();  
	bool ccTouchBegan(CCTouch* , CCEvent* );  
	void ccTouchEnded(CCTouch* , CCEvent* );
	void menuCallBack(CCObject* );

private:
		
	bool allowTouch;
	
	Elf* grid[GRID_ROW][GRID_COLUMN];
	CCRect gridRect;
	int bonusAttr;
	
	CCSprite* timeBar;
	int remainingTime;
	bool hurry;
	bool running;
	
	CCSprite* scoreBar;
	int score;
	int goal[2];
	
	CCSprite* bonusElf;
	CCLabelBMFont* scoreLabel;
	CCLabelBMFont* timeLabel;
	
	void updateElves(int row,int col);
	void moveElves(int total, int row, int col, bool bonus);
	void goTop(const map<int,int> &indices, CCArray* goingTop, bool bonus);
	
	void timeRunning();
	void timeAdd(int t);
	bool updateScore(int total, int numDouble);
	void updateBonus();
	
	void touchable();
	void barReset();
};

#endif
