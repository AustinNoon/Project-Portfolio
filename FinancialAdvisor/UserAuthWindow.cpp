#include "pch.h"
#include "UserAuthWindow.h"

UserAuthWindow::UserAuthWindow(UserAuth& auth) : userAuth(auth), isAuthenticated(false), usernameFocused(false), passwordFocused(false) {
    window.create(sf::VideoMode(600, 400), "User Authentication");

    if (!font.loadFromFile("Fonts/MagnisaSans-Regular.ttf")) {
        std::cerr << "Error loading font" << std::endl;
        exit(-1);
    }
    
    promptText.setFont(font);
    promptText.setString("Please Login or Sign Up");
    promptText.setCharacterSize(32);
    promptText.setFillColor(sf::Color::Black);
    promptText.setPosition(24, 15);

    usernameBox.setSize(sf::Vector2f(300, 40));
    usernameBox.setFillColor(sf::Color::White);
    usernameBox.setOutlineColor(sf::Color::Black);
    usernameBox.setOutlineThickness(1);
    usernameBox.setPosition(150, 100);

    usernameText.setFont(font);
    usernameText.setCharacterSize(20);
    usernameText.setFillColor(sf::Color::Black);
    usernameText.setPosition(160, 110);
    usernameText.setString("Username:");

    passwordBox.setSize(sf::Vector2f(300, 40));
    passwordBox.setFillColor(sf::Color::White);
    passwordBox.setOutlineColor(sf::Color::Black);
    passwordBox.setOutlineThickness(1);
    passwordBox.setPosition(150, 200);

    passwordText.setFont(font);
    passwordText.setCharacterSize(20);
    passwordText.setFillColor(sf::Color::Black);
    passwordText.setPosition(160, 210);
    passwordText.setString("Password:");

    loginButton.setSize(sf::Vector2f(150, 50));
    loginButton.setFillColor(sf::Color::White);
    loginButton.setOutlineColor(sf::Color::Black);
    loginButton.setOutlineThickness(1);
    loginButton.setPosition(100, 300);

    loginButtonText.setFont(font);
    loginButtonText.setString("Log In");
    loginButtonText.setCharacterSize(20);
    loginButtonText.setFillColor(sf::Color::Black);
    loginButtonText.setPosition(150, 310);

    signUpButton.setSize(sf::Vector2f(150, 50));
    signUpButton.setFillColor(sf::Color::White);
    signUpButton.setOutlineColor(sf::Color::Black);
    signUpButton.setOutlineThickness(1);
    signUpButton.setPosition(350, 300);

    signUpButtonText.setFont(font);
    signUpButtonText.setString("Sign Up");
    signUpButtonText.setCharacterSize(20);
    signUpButtonText.setFillColor(sf::Color::Black);
    signUpButtonText.setPosition(390, 310);

    cursor.setSize(sf::Vector2f(1, 25));
    cursor.setFillColor(sf::Color::Black);
}

void UserAuthWindow::handleTextInput(sf::Event& event) {
    if (usernameFocused) {
        if (event.text.unicode == '\b') {
            if (!usernameInputString.empty()) {
                usernameInputString.pop_back();
            }
        }
        else if (event.text.unicode < 128 && event.text.unicode != 13) {
            usernameInputString += static_cast<char>(event.text.unicode);
        }
        usernameText.setString("Username: " + usernameInputString);
    }
    else if (passwordFocused) {
        if (event.text.unicode == '\b') {
            if (!passwordInputString.empty()) {
                passwordInputString.pop_back();
            }
        }
        else if (event.text.unicode < 128 && event.text.unicode != 13) {
            passwordInputString += static_cast<char>(event.text.unicode);
        }
        passwordText.setString("Password: " + std::string(passwordInputString.size(), '*'));
    }
}

bool UserAuthWindow::isMouseOverButton(const sf::RectangleShape& button, const sf::Vector2i& mousePosition) {
    return button.getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePosition));
}

void UserAuthWindow::updateCursor() {
    if (usernameFocused) {
        cursor.setPosition(usernameText.getGlobalBounds().left + usernameText.getGlobalBounds().width + 5, usernameText.getPosition().y);
    }
    else if (passwordFocused) {
        cursor.setPosition(passwordText.getGlobalBounds().left + passwordText.getGlobalBounds().width + 5, passwordText.getPosition().y);
    }
}

void UserAuthWindow::draw() {
    window.draw(promptText);
    window.draw(usernameBox);
    window.draw(usernameText);
    window.draw(passwordBox);
    window.draw(passwordText);
    window.draw(loginButton);
    window.draw(loginButtonText);
    window.draw(signUpButton);
    window.draw(signUpButtonText);

    if ((usernameFocused || passwordFocused) && blinkClock.getElapsedTime().asSeconds() < 0.5f) {
        window.draw(cursor);
    }

    if (blinkClock.getElapsedTime().asSeconds() >= 1.0f) {
        blinkClock.restart();
    }
}

bool UserAuthWindow::run() {
    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                window.close();

            if (event.type == sf::Event::MouseButtonPressed) {
                if (event.mouseButton.button == sf::Mouse::Left) {
                    sf::Vector2i mousePosition = sf::Mouse::getPosition(window);

                    if (isMouseOverButton(usernameBox, mousePosition)) {
                        usernameFocused = true;
                        passwordFocused = false;
                        blinkClock.restart();
                        updateCursor();
                    }
                    else if (isMouseOverButton(passwordBox, mousePosition)) {
                        usernameFocused = false;
                        passwordFocused = true;
                        blinkClock.restart();
                        updateCursor();
                    }
                    else if (isMouseOverButton(loginButton, mousePosition)) {
                        if (userAuth.authenticate(usernameInputString, passwordInputString)) {
                            isAuthenticated = true;
                            window.close();
                        }
                        else {
                            std::cerr << "Invalid username or password." << std::endl;
                        }
                    }
                    else if (isMouseOverButton(signUpButton, mousePosition)) {
                        signUp();
                    }
                }
            }

            if (event.type == sf::Event::TextEntered) {
                handleTextInput(event);
                updateCursor();
            }
        }

        window.clear(sf::Color(211, 211, 211));
        draw();
        window.display();
    }

    return isAuthenticated;
}

void UserAuthWindow::signUp() {
    if (!usernameInputString.empty() && !passwordInputString.empty()) {
        userAuth.saveUser(usernameInputString, passwordInputString);
        std::cout << "User signed up successfully." << std::endl;
    }
    else {
        std::cerr << "Username and password cannot be empty." << std::endl;
    }
}
