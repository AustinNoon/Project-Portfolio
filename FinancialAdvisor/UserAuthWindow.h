#pragma once
#include "pch.h"
#include "UserAuth.h"

class UserAuthWindow
{
private:
    sf::RenderWindow window;
    sf::Font font;
    sf::Text usernameText;
    sf::Text passwordText;
    sf::Text loginButtonText;
    sf::Text signUpButtonText;
    sf::Text promptText;
    sf::RectangleShape usernameBox;
    sf::RectangleShape passwordBox;
    sf::RectangleShape loginButton;
    sf::RectangleShape signUpButton;
    sf::RectangleShape cursor;
    std::string usernameInputString;
    std::string passwordInputString;
    bool usernameFocused;
    bool passwordFocused;
    sf::Clock blinkClock;
    UserAuth& userAuth;
    bool isAuthenticated;

    void handleTextInput(sf::Event& event);
    bool isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition);
    void updateCursor();

public:
    UserAuthWindow(UserAuth& auth);
    bool run();
    void draw();
    void signUp();
};

