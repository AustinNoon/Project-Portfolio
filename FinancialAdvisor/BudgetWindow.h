#pragma once
#include "pch.h"

enum class FocusedInputBox {
    None,
    Budget,
    Spent
};

class BudgetWindow
{
private:
    sf::RenderWindow window;
    sf::Font font;
    sf::Text titleText;
    sf::Text budgetText;
    sf::Text spentText;
    sf::Text remainingText;
    sf::Text inputText;
    sf::Text spentInputText;
    sf::Text setButtonText;
    sf::Text spendButtonText;
    sf::Text clearButtonText;
    sf::RectangleShape inputBox;
    sf::RectangleShape spentInputBox;
    sf::RectangleShape setButton;
    sf::RectangleShape spendButton;
    sf::RectangleShape clearButton;
    sf::RectangleShape cursor;
    double budget;
    double spent;
    std::string inputString;
    std::string spentInputString;
    FocusedInputBox focusedInputBox;
    sf::Clock blinkClock;

public:
    BudgetWindow(double initialBudget, double initialSpent);
    void run();
    void draw();
    void handleTextInput(sf::Event& event);
    void handleSpentInput(sf::Event& event);
    bool isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition);
    void saveBudget(const std::string& filename);
    void loadBudget(const std::string& filename);
    void updateTexts();
    void updateCursor();
    void clearBudget();
    double getBudget() const;
    double getSpent() const;
};

