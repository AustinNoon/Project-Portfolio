#pragma once
#include "pch.h"

class UserAuth
{
private:
	std::string username;
	std::string passwordHash;
	std::string hashPassword(const std::string& password);
	void loadUser();

public:
	UserAuth();
	bool authenticate(const std::string& inputUsername, const std::string& inputPassword);
	void saveUser(const std::string& newUsername, const std::string& newPassword);
	bool userExists();
};

