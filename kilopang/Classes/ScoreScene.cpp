//
//  ScoreScene.cpp
//  kilopang
//
//  Created by Junxing Yang on 4/19/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#include "ScoreScene.h"
#include <string>
#include <vector>
#include <sstream>

using namespace	std;
using namespace cocos2d;

CCScene* ScoreScene::scene(int score)
{
	CCScene* scene = CCScene::create();
	
	ScoreScene* scores = ScoreScene::create();
	
	scores->initWithScore(score);
	
	scene->addChild(scores);
	
	return scene;
}

bool ScoreScene::initWithScore(int score)
{
	if (!CCLayer::init()) {
		return false;
	}
	vector<int> scores(NUM_SCORES);
	int place = -1;

	readScores(scores);
	if (score != -1) {
		CCLabelTTF* label = CCLabelTTF::create(CCString::createWithFormat("%d",score)->getCString(), "Arial", 20);
		label->setPosition(ccp(150,150));
		this->addChild(label);
		if (score >= scores[NUM_SCORES-1])
			place = updateScores(score, scores);
	}
	
	CCLabelTTF* labels[NUM_SCORES];
	stringstream ss;
	for (int i = 0; i < NUM_SCORES; i++) {
		if (scores[i] >= 0) {
			ss << scores[i];
			labels[i] = CCLabelTTF::create(ss.str().c_str(), "Arial", 30);
			labels[i]->setPosition(ccp(150, (NUM_SCORES-i)*50+150));
			this->addChild(labels[i]);
			ss.str("");
		}
	}
	
	CCMenuItemImage* new_item = CCMenuItemImage::create("Icon-Small.png", "Icon-Small.png", this, menu_selector(ScoreScene::menuCallBack));
	new_item->setPosition(ccp(100,100));
	new_item->setTag(0);
	CCMenuItemImage* shop_item = CCMenuItemImage::create("Icon.png", "Icon.png", this, menu_selector(ScoreScene::menuCallBack));
	shop_item->setPosition(ccp(50,50));
	shop_item->setTag(1);
	CCMenuItemImage* home_item = CCMenuItemImage::create("CloseNormal.png", "CloseSelected.png", this, menu_selector(ScoreScene::menuCallBack));
	home_item->setPosition(ccp(200,50));
	home_item->setTag(2);
	
	CCMenu* menu = CCMenu::create(new_item,shop_item,home_item,NULL);
	menu->setPosition(ccp(0,0));
	this->addChild(menu,1);
	
	writeScores(scores);
	return true;
}

void ScoreScene::readScores(vector<int> &scores)
{
	CCUserDefault* data = CCUserDefault::sharedUserDefault();
	string str = PREFIX;
	bool firstTime = true;
	for (int i = 0; i < NUM_SCORES; i++) {
		scores[i] = data->getIntegerForKey((str+(char)(((int)'0')+i)).c_str(),-1);
		if (scores[i] != -1)
			firstTime = false;
	}
	string oldKey = data->getStringForKey("key", "");
	if (!oldKey.empty()||(oldKey.empty()&&!firstTime)) {
		checkKey(oldKey, scores);
	}
}

void ScoreScene::checkKey(const string &oldKey, vector<int> &scores)
{
	unsigned long hashValue = hash(scoresToKey(scores));
	stringstream ss;
	ss << hashValue;
	if(ss.str().compare(oldKey)!=0)
	{
		for (int i = 0; i < NUM_SCORES; i++) {
			scores[i] = -1;
		}
	}
}

const char* ScoreScene::scoresToKey(const vector<int> &scores)
{
	stringstream ss;
	string key;
	for (int i = 0; i < NUM_SCORES; i++) {
		ss << scores[i];
		key += ss.str()+',';
		ss.str("");
	}
	return key.c_str();
}

unsigned long ScoreScene::hash(const char* str)
{
	int i,l;
	unsigned long ret=0;
	unsigned short *s;
	
	
	if (str == NULL) return(0);
	l=(strlen(str)+1)/2;
	s=(unsigned short *)str;
	for (i=0; i<l;i++)
		ret^=(s[i]<<(i&0x0f));
	return(ret);
}

int ScoreScene::updateScores(int score, vector<int> &scores)
{
	int i = NUM_SCORES-1;
	for (; i > 0 && score >= scores[i-1]; i--) {
			scores[i] = scores[i-1];
	}
	scores[i] = score;
	if (i == 0) {
		//new Highest score
	}
	return i;
}

void ScoreScene::writeScores(const vector<int> &scores)
{
	CCUserDefault* data = CCUserDefault::sharedUserDefault();
	string str = PREFIX;
	for (int i = 0; i < NUM_SCORES; i++) {
		data->setIntegerForKey((str+(char)(((int)'0')+i)).c_str(),scores[i]);
	}
	unsigned long hashValue = hash(scoresToKey(scores));
	stringstream ss;
	ss << hashValue;
	data->setStringForKey("key", ss.str());
	data->flush();
}

void ScoreScene::menuCallBack(CCObject* pSender)
{
	CCScene* next;
	CCMenuItemImage* item = (CCMenuItemImage*) pSender;
	switch (item->getTag()) {
		case 0:
			next = GameScene::scene();
			CCDirector::sharedDirector()->replaceScene(next);
			break;
		case 1:
			break;
		case 2:
			next = HomeScene::scene();
			CCDirector::sharedDirector()->replaceScene(next);
			break;
		default:
			break;
	}
}
