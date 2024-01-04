#pragma once

#include "Player.h"
#include "Bullet.h"
#include "Enemy.h"


class Game
{
private:
	//Private Vars
	sf::RenderWindow* window;

	//Resources
	std::map<std::string, sf::Texture*> textures;
	std::vector<Bullet*> bullets;

	//GUI
	sf::Font font;
	sf::Text pointText;
	sf::Text gameOverText;

	//World
	sf::Texture worldBackgroundTex;
	sf::Sprite worldBackground;

	//Systems
	unsigned points;

	//Player
	Player* player;

	//Player GUI
	sf::RectangleShape playerHpBar;
	sf::RectangleShape playerHpBarBack;

	//Enemies
	float spawnTimer;
	float spawnTimerMax;
	std::vector<Enemy*> enemies;

	//Private Functions
	void initWindow();
	void initTextures();
	void initGUI();
	void initWorld();
	void initSystems();
	void initPlayer();
	void initEnemies();

public:
	//Constructors & Destructors
	Game();
	virtual ~Game();


	//Public Functions
	void run();
	void updatePollEvents();
	void updateInput();
	void updateGUI();
	void updateWorld();
	void updateCollision();
	void updateBullets();
	void updateEnemies();
	void updateCombat();
	void update();
	void renderGUI();
	void renderWorld();
	void render();
};



