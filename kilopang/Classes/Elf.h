//
//  Elf.h
//  kilopang
//
//  Created by Junxing Yang on 4/15/13.
//  Copyright (c) 2013 Stony Brook University. All rights reserved.
//

#ifndef kilopang_Elf_h
#define kilopang_Elf_h
#include "cocos2d.h"
#include "GameScene.h"

#define ELF_TYPES 6
#define ELF_SIZE 45
using namespace cocos2d;
class GameScene;

typedef enum {
	Normal,
	Bigbang,
	Clock,
	Double
}elfAttr;

class Elf : public cocos2d::CCNode
{
public:
	bool initInGame(GameScene* game,int i,int j);
	void initElfSprite(int i,int j,int elfType,elfAttr attr, bool fromTop);
	void setElfPos(const CCPoint& pos);
	const CCPoint& getElfPos()const;
	void elfAction(CCAction* );
	void select();
	void unselect();
	bool isSelected()const;
	int getType()const;
	elfAttr getAttr()const;
	void setAttr(elfAttr attribute);
	int getCol()const;
	
private:
	
	bool selected;
	int elfType;
	elfAttr attr;
	bool removed;
	CCSprite* elfSprite;
	GameScene* game;
	int col;
};

#endif
