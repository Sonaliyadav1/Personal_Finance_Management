-- Create database
CREATE DATABASE IF NOT EXISTS pfmsdemo;
USE pfmsdemo;
-- User table
CREATE TABLE user (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    username VARCHAR(50) UNIQUE,
    password VARCHAR(100)
);

-- Account table
CREATE TABLE account (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(10, 2),
    liabilities DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Income source table
CREATE TABLE income_source (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    source_name VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Income table
CREATE TABLE income (
    income_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_id INT,
    income_date DATE,
    income_source VARCHAR(100),
    amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Expense category table
CREATE TABLE expense_category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    category_name VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Expense table
CREATE TABLE expense (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    account_id INT,
    expense_date DATE,
    expense_category VARCHAR(100),
    remark VARCHAR(100),
    amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Transaction table
CREATE TABLE transaction (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    type VARCHAR(10),
    amount DECIMAL(10,2),
    statement VARCHAR(255),
    time TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES account(account_id)
);

-- Budget table
CREATE TABLE budget (
    budget_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    expense_category VARCHAR(100),
    amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Target table
CREATE TABLE target_amount (
    target_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- Trigger: before account delete
DELIMITER //
CREATE TRIGGER beforeAccountdelete
BEFORE DELETE ON account
FOR EACH ROW
BEGIN
    IF OLD.account_id IS NOT NULL THEN
        DELETE FROM expense WHERE account_id = OLD.account_id;
        DELETE FROM income WHERE account_id = OLD.account_id;
        DELETE FROM transaction WHERE account_id = OLD.account_id;
    END IF;
END;
//
DELIMITER ;

-- Trigger: after income insert
DELIMITER //
CREATE TRIGGER afterIncomeInsert
AFTER INSERT ON income
FOR EACH ROW
BEGIN
    INSERT INTO transaction(account_id, type, amount, statement, time) 
    VALUES (NEW.account_id, 'Income', NEW.amount, 
            CONCAT('Income recorded: ', NEW.income_source, ' - Amount: ', NEW.amount), 
            CURRENT_TIMESTAMP);
END;
//
DELIMITER ;

-- Trigger: after expense insert
DELIMITER //
CREATE TRIGGER afterExpenseInsert
AFTER INSERT ON expense
FOR EACH ROW
BEGIN
    INSERT INTO transaction(account_id, type, amount, statement, time) 
    VALUES (NEW.account_id, 'Expense', NEW.amount, 
            CONCAT('Expense recorded: ', NEW.expense_category, ' - Amount: ', NEW.amount), 
            CURRENT_TIMESTAMP);
END;
//
DELIMITER ;

-- Categories table
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  UNIQUE KEY uq_cat (user_id, name),
  FOREIGN KEY (user_id) REFERENCES user(user_id)
);

-- ✅ Sample Data
INSERT INTO user(name, username, password) 
VALUES ('Anant', 'Anant', 'anant@234');

INSERT INTO categories(user_id, name) 
VALUES (1,'Food'), (1,'Rent'), (1,'Shopping');

-- Insert sample transactions
INSERT INTO transaction(account_id, type, amount, statement, time) VALUES
(1, 'Expense', 500.00, 'Lunch', CURRENT_TIMESTAMP),
(1, 'Expense', 10000.00, 'Monthly rent', CURRENT_TIMESTAMP),
(1, 'Expense', 2500.00, 'Clothes', CURRENT_TIMESTAMP),
(1, 'Expense', 700.00, 'Dinner', CURRENT_TIMESTAMP);

