//
//  ScoreScene.h
//  kilopang
//
//  Created by Junxing Yang on 4/19/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#ifndef kilopang_ScoreScene_h
#define kilopang_ScoreScene_h

#include "cocos2d.h"
#include "GameScene.h"
#include <vector>
#include <string>

#define NUM_SCORES 5
#define PREFIX "score"

class ScoreScene : public cocos2d::CCLayer
{
public:
	
	static cocos2d::CCScene* scene(int score);
	
	void menuCallBack(CCObject* );
	
	CREATE_FUNC(ScoreScene);
	
private:
	
	bool initWithScore(int score);
	void readScores(std::vector<int> &scores);
	void writeScores(const std::vector<int> &scores);
	unsigned long hash(const char* str);
	const char* scoresToKey(const std::vector<int> &scores);
	void checkKey(const std::string &oldKey, std::vector<int> &scores);
	int updateScores(int score, std::vector<int> &scores);
};

#endif
