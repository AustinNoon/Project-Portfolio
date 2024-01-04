#pragma once

class Bullet
{
private:
	//Private Vars
	sf::Sprite shape;
	sf::Vector2f direction;
	float movementSpeed;

	//Private Functions

public:
	//Constructors && Destructors 
	Bullet();
	Bullet(sf::Texture* texture, float pos_X, float pos_Y, float dir_X, float dir_Y, float movement_speed);
	virtual ~Bullet();

	//Accessor
	const sf::FloatRect getBounds() const;

	//Public Functions
	void update();
	void render(sf::RenderTarget* target);

};

