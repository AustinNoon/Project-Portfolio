#pragma once

class Player
{
private:
	//Private Vars
	sf::Sprite sprite;
	sf::Texture texture;
	float movementSpeed;
	float attackCD;
	float attackCDMax;
	int hp;
	int hpMax;

	//Private Functions
	void initVariables();
	void initTexture();
	void initSprite();

public:
	//Constructor & Destructor
	Player();
	virtual ~Player();

	//Accessor
	const sf::Vector2f& getPos() const;
	const sf::FloatRect getBounds() const;
	const int& getHp() const;
	const int& getHpMax() const;

	//Modifiers
	void setPosition(sf::Vector2f pos);
	void setPosition(const float x, const float y);
	void setHp(const int hp);
	void loseHp(const int value);

	//Public Functions
	void move(const float dirX, const float dirY);
	const bool canATK();
	void updateATKCD();
	void update();
	void render(sf::RenderTarget& target);

};


