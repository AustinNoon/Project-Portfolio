#pragma once
#include "pch.h"
#include "TransactionWindow.h"

class TransactionWindowHistory
{
private:
	sf::RenderWindow window;
	sf::Font font;
	sf::Text titleText;
	std::vector<Transaction> transactions;
	std::vector<sf::Text> transactionTexts;

public:
	TransactionWindowHistory(const std::vector<Transaction>& transactions);
	void run();
	void draw();
};

