#pragma once

#include <iostream>
#include <SFML/Graphics.hpp>

class Enemy
{
private:
	//Private Vars
	unsigned pointCount;
	sf::Sprite enemySprite;
	sf::Texture enemyTexture;
	int type;
	float speed;
	int hp;
	int hpMax;
	int damage;
	int points;

	//Private Functions
	void initVariables();
	void initTexture();
	void initEnemySprite();

public:
	//Constructor && Destructors
	Enemy();
	Enemy(float pos_x, float pos_y);
	virtual ~Enemy();

	//Accessors
	const sf::FloatRect getBounds() const;
	const int& getPoints() const;
	const int& getDamage() const;

	//Public Functions
	void update();
	void render(sf::RenderTarget* target);

};

