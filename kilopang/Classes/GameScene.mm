//
//  GameScene.cpp
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#include "GameScene.h"
#include "GCHelper.h"

using namespace cocos2d;
using namespace std;

CCScene* GameScene::scene()
{
	CCScene *scene = CCScene::create();
	
	GameScene *game = GameScene::create();
	
	scene->addChild(game,0,213);
	
	return scene;
}

bool GameScene::init()
{
	if(!CCLayer::init())
		return false;
	CCSize size = CCDirector::sharedDirector()->getWinSize();
	
	CCMenuItemImage* menu_item = CCMenuItemImage::create("Icon-Small.png", "Icon-Small.png", this, menu_selector(GameScene::menuCallBack));
	CCMenu* menu = CCMenu::createWithItem(menu_item);
	menu->setPosition(ccp(300,size.height-30));
	this->addChild(menu);
	
	bonusAttr = 1;
	bonusElf = CCSprite::create("bonus.png");
	bonusElf->setTextureRect(CCRectMake((bonusAttr-1)*30, 0, 30, 30));
	bonusElf->setAnchorPoint(ccp(0,0));
	bonusElf->setPosition(ccp(260,size.height-30));
	this->addChild(bonusElf);
	
	remainingTime = MAX_TIME;
	timeBar = CCSprite::create("bar.png");
	this->addChild(timeBar);
	timeBar->setAnchorPoint(ccp(0,0.5));
	timeBar->setPosition(ccp(10, 20));
	
	timeLabel = CCLabelBMFont::create(CCString::createWithFormat("%d",MAX_TIME)->getCString(), "feedbackFont.fnt");
	timeLabel->setAnchorPoint(ccp(0.5,0));
	timeLabel->setPosition(ccp(size.width/2,20));
	this->addChild(timeLabel);
	
	score = 0;
	goal[0] = 0;
	goal[1] = 10;
	scoreBar = CCSprite::create("scorebar.png");
	this->addChild(scoreBar);
	scoreBar->setAnchorPoint(ccp(0,0.5));
	scoreBar->setPosition(ccp(10,size.height-30));
	scoreBar->setScaleX(0);
	
	scoreLabel = CCLabelBMFont::create("0", "feedbackFont.fnt");
	scoreLabel->setAnchorPoint(ccp(0.5,0));
	scoreLabel->setPosition(ccp(size.width/2,420));
	this->addChild(scoreLabel);
	
	CCSpriteBatchNode* elfSheet = CCSpriteBatchNode::create("elf.png",GRID_ROW*GRID_COLUMN);
	this->addChild(elfSheet, 1, ELFSHEET);
	
	for (int i = 0; i < GRID_ROW; i++) {
		for (int j = 0; j < GRID_COLUMN; j++) {
			Elf* elf = new Elf();
			elf->initInGame(this,i,j);
			grid[i][j] = elf;
			elf->autorelease();
		}
	}
	gridRect = CCRectMake(GRID_OFFSET.x, GRID_OFFSET.y, 
						  ELF_SIZE*GRID_ROW, ELF_SIZE*GRID_COLUMN);
	
	schedule(schedule_selector(GameScene::timeRunning), 1.0f);
	running = true;
	hurry = false;
	allowTouch = true;
	return true;
}


void GameScene::onEnter()
{
    CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, 0, false);  
    CCLayer::onEnter(); 
}

void GameScene::onExit()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
	CCLayer::onExit();
}

bool GameScene::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
	if(allowTouch)
		return true;
	else 
		return false;
}

void GameScene::ccTouchEnded(CCTouch* touch, CCEvent* event)
{
	int i,j;
    CCPoint touchLoc = this->convertToNodeSpace(touch->getLocation());
	if (gridRect.containsPoint(touchLoc)) {
		i = GRID_ROW-(touchLoc.y-GRID_OFFSET.y)/ELF_SIZE;
		j = (touchLoc.x-GRID_OFFSET.x)/ELF_SIZE;
		//printf("touch %d %d\n",i,j);
		updateElves(i, j);
	}
}

void GameScene::updateElves(int row, int col)
{
	allowTouch = false;
	int total = 0, numDouble = 0, numClock = 0;
	int beginI = 0, beginJ = 0, endI = 0, endJ = 0;
	bool bonus = false;
	bool rewarded = false;
	if (grid[row][col]->getAttr()!=Bigbang)
	{
		beginI = row-1>0?row-1:0;
		beginJ = col-1>0?col-1:0;
		endI = row+1>GRID_ROW-1?GRID_ROW-1:row+1;
		endJ = col+1>GRID_COLUMN-1?GRID_COLUMN-1:col+1;
	}
	else
	{
		rewarded = true;
		endI = GRID_ROW - 1;
		endJ = GRID_COLUMN -1;
	}
find:
	for (int i = beginI; i <= endI; i++) {
		for (int j = beginJ; j <= endJ; j++) {
			Elf* e = grid[i][j];
			if (e->getType()==grid[row][col]->getType()) {
				e->select();
				total++;
				if (e->getAttr() == Double)
					numDouble++;
				if (e->getAttr() == Clock)
					numClock++;
				if (e->getAttr() == Bigbang && (i!=row || j!=col)) {
					e->setAttr(Normal);
					beginI = beginJ = 0;
					endI = GRID_ROW - 1;
					endJ = GRID_COLUMN -1;
					total = numDouble = numClock = 0;
					rewarded = true;
					goto find;
				}
			}
		}
	}
	bonus = updateScore(total, numDouble);
	moveElves(total, row, col, bonus, rewarded);
	if (numClock > 0)
		timeAdd(numClock*2+1);
}

void GameScene::moveElves(int total, int row, int col, bool bonus, bool rewarded)
{
	CCArray* goingTop = CCArray::create();
	map<int,int> indices;
	elfAttr attr = Normal;
	int count = 0;
	if (total >= 4 && !rewarded) {
		if (total == 4)
			attr = Double;
		else if (total == 5)
			attr = Clock;
		else
			attr = Bigbang;
	}
	for (int j = 0; j < GRID_COLUMN; j++) {
		count = 0;
		for (int i = GRID_ROW-1; i >= 0 ; i--) {
			Elf* e = grid[i][j];
			if (count > 0) {
				grid[i][j] = NULL;
				grid[i+count][j] = e;
			}
			if (e->isSelected()) {
				if (attr != Normal && i==row && j==col && e->getAttr()!=Bigbang) {
					e->initElfSprite(i, j, e->getType(), attr, false);
					e->unselect();
				}
				else{
					count++;
					CCActionInterval * action = CCFadeOut::create(0.5);
					e->elfAction(action);
					goingTop->addObject(e);
				}
			}
			if(count > 0 && !e->isSelected())
			{
				//e->setElfPos(ccp(e->getElfPos().x,e->getElfPos().y-count*ELF_SIZE));
				CCActionInterval * action = CCMoveBy::create(0.2,
														ccp(0,-count*ELF_SIZE));
				e->elfAction(action);
			}
		}
		indices[j] = count;
	}
	goTop(indices, goingTop, bonus);
}

void GameScene::goTop(const map<int,int> &indices, CCArray* goingTop, bool bonus)
{
	int bonusIndex = -1, size = goingTop->count();
	int count, arrayIndex = 0;
	
	if (bonus) {
		bonusIndex = arc4random()%size;
	}
	for (int j = 0; j < GRID_COLUMN; j++) {
		count = indices.find(j)->second;
		if (count > 0) {
			for (int k = 0; k < count; k++, arrayIndex++) {
				Elf* e = (Elf*) goingTop->objectAtIndex(arrayIndex);
				grid[count-k-1][j] = e;
				e->unselect();
				if (arrayIndex != bonusIndex)
					e->initElfSprite(count-k-1, j, -1, Normal, true);
				else
					e->initElfSprite(count-k-1, j, -1, (elfAttr)bonusAttr, true);
				
				CCActionInterval * action = CCMoveTo::create(0.2, ccp(ELF_SIZE*j + GRID_OFFSET.x,ELF_SIZE*(GRID_ROW-count+k)+GRID_OFFSET.y));
				if (arrayIndex!=size-1)
					e->elfAction(action);
				else
					e->elfAction(CCSequence::createWithTwoActions(action, CCCallFunc::create(this, callfunc_selector(GameScene::touchable))));
				CCActionInterval * action1 = CCFadeIn::create(0.5);
				e->elfAction(action1);
				
			}
		}
	}
	goingTop->removeAllObjects();
}
void GameScene::timeRunning()
{
	if (running) {
		if (remainingTime > 0) {
			remainingTime--;
		}
		timeBar->setScaleX((float)remainingTime/MAX_TIME);
		timeLabel->setString(CCString::createWithFormat("%d",remainingTime)
							 ->getCString());
		bool current = hurry;
		if (remainingTime < 10)
			hurry = true;
		else
			hurry = false;
		if (!current && hurry)
			timeBar->runAction(CCTintTo::create(1.0, 255, 0, 0));
		else if(current && !hurry)
			timeBar->runAction(CCTintTo::create(1.0, 255, 255, 255));
		if (remainingTime <= 0) {
			allowTouch = false;
			unschedule(schedule_selector(GameScene::timeRunning));
			[[GCHelper sharedInstance] reportScore: score forCategory:@"TS_LB"];
			CCScene* scores = ScoreScene::scene(score);
			CCDirector::sharedDirector()->replaceScene(scores);
		}
	}
}

void GameScene::timeAdd(int t)
{
	remainingTime += t;
	if (remainingTime > MAX_TIME)
		remainingTime = MAX_TIME;
	timeBar->runAction(CCEaseExponentialIn::create(CCScaleTo::create(0.5f, (float)remainingTime/MAX_TIME, 1.0f)));
}

bool GameScene::updateScore(int total, int numDouble)
{
	bool bonus = false;
	score += total*(1+numDouble);
	if (score >= goal[1])
	{
		bonus = true;
		goal[0] = goal[1];
		goal[1] *= 2;
		updateBonus();
	}
	CCActionInterval* scaleAct = CCScaleTo::create(0.5f, (float)(score-goal[0])/(goal[1]-goal[0]), 1.0f);
	CCActionEase* easeAct = CCEaseExponentialInOut::create(scaleAct);
	if (bonus) {
		scoreBar->runAction(CCSequence::create
						(CCEaseExponentialIn::create(CCScaleTo::create(0.3f, 1.0f)),
				  CCCallFunc::create(this, callfunc_selector(GameScene::barReset)),
						easeAct, NULL));
	}
	else
		scoreBar->runAction(easeAct);
	scoreLabel->setString(CCString::createWithFormat("%d",score)->getCString());
	return bonus;
}

void GameScene::updateBonus()
{
	bonusAttr = ((bonusAttr+1)%BONUS_TYPES+1)%BONUS_TYPES;
	bonusElf->setTextureRect(CCRectMake((bonusAttr-1)*30, 0, 30, 30));
}

void GameScene::menuCallBack(CCObject* pSender)
{
	CCDirector::sharedDirector()->pause();
	PauseLayer* pause = PauseLayer::create();
	this->addChild(pause,10);
}

void GameScene::touchable()
{
	allowTouch = true;
}
void GameScene::barReset()
{
	scoreBar->setScale(0);
}