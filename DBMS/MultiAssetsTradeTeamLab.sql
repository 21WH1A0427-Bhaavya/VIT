CREATE DATABASE MultiAssetsTradesTeamLab;
USE MultiAssetsTradesTeamLab;

CREATE TABLE Users_check (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('trader','admin') NOT NULL
);

CREATE TABLE Assets (
  asset_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_name VARCHAR(100) NOT NULL,
  ticker VARCHAR(20) UNIQUE NOT NULL,
  type ENUM('commodity','currency','forex','stock','crypto') NOT NULL
);

CREATE TABLE Markets (
  market_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT,
  region VARCHAR(50),
  exchange VARCHAR(100),
  FOREIGN KEY (asset_id) REFERENCES Assets(asset_id)
);

CREATE TABLE Prices (
  price_id INT AUTO_INCREMENT PRIMARY KEY,
  asset_id INT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  open DECIMAL(10,2),
  close DECIMAL(10,2),
  high DECIMAL(10,2),
  low DECIMAL(10,2),
  volume DECIMAL(15,2),
  FOREIGN KEY (asset_id) REFERENCES Assets(asset_id)
);

CREATE TABLE Transactions (
  trans_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  asset_id INT,
  buyOrSell ENUM('buy','sell'),
  quantity INT CHECK(quantity>0),
  price DECIMAL(10,2),
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users_check(user_id),
  FOREIGN KEY (asset_id) REFERENCES Assets(asset_id)
);

CREATE TABLE Portfolio (
  port_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  asset_id INT,
  holdings INT DEFAULT 0,
  avg_price DECIMAL(10,2) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES Users_check(user_id),
  FOREIGN KEY (asset_id) REFERENCES Assets(asset_id),
  UNIQUE (user_id, asset_id)
);

CREATE TABLE AuditLog (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(255),
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users_check(user_id)
);

DROP TRIGGER IF EXISTS user_creation;
DELIMITER $$
CREATE TRIGGER user_creation
AFTER INSERT ON Users_check
FOR EACH ROW
BEGIN
  INSERT INTO AuditLog(user_id, action, timestamp)
  VALUES (NEW.user_id, CONCAT('New user created: ',NEW.username,' | Role: ',NEW.role,' @ ',NOW()),NOW());
END$$

DROP TRIGGER IF EXISTS insert_asset;
CREATE TRIGGER insert_asset
AFTER INSERT ON Assets
FOR EACH ROW
BEGIN
  INSERT INTO AuditLog(user_id, action, timestamp)
  VALUES (NULL, CONCAT('Asset added: ',NEW.asset_name,' | Symbol: ',NEW.ticker,' @ ',NOW()),NOW());
END$$

DROP TRIGGER IF EXISTS delete_asset;
CREATE TRIGGER delete_asset
AFTER DELETE ON Assets
FOR EACH ROW
BEGIN
  INSERT INTO AuditLog(user_id, action, timestamp)
  VALUES (NULL, CONCAT('Asset deleted: ',OLD.asset_name,' | Symbol: ',OLD.ticker,' @ ',NOW()),NOW());
END$$

DROP TRIGGER IF EXISTS calc_spread;
CREATE TRIGGER calc_spread
BEFORE INSERT ON Prices
FOR EACH ROW
BEGIN
  SET NEW.volume=NEW.high-NEW.low;
END$$

DROP TRIGGER IF EXISTS stop_loss;
CREATE TRIGGER stop_loss
AFTER INSERT ON Prices
FOR EACH ROW
BEGIN
  IF NEW.close<50 THEN
    INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
    VALUES (1,NEW.asset_id,'sell',10,NEW.close,NOW());
    INSERT INTO AuditLog(user_id, action, timestamp)
    VALUES (1,CONCAT('Stop-loss triggered for Asset ID ',NEW.asset_id,' @ ',NEW.close),NOW());
  END IF;
END$$

DROP TRIGGER IF EXISTS take_profit;
CREATE TRIGGER take_profit
AFTER INSERT ON Prices
FOR EACH ROW
BEGIN
  IF NEW.close>200 THEN
    INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
    VALUES (1,NEW.asset_id,'sell',10,NEW.close,NOW());
    INSERT INTO AuditLog(user_id, action, timestamp)
    VALUES (1,CONCAT('Take-profit triggered for Asset ID ',NEW.asset_id,' @ ',NEW.close),NOW());
  END IF;
END$$

DROP TRIGGER IF EXISTS update_portfolio_after_tx;
CREATE TRIGGER update_portfolio_after_tx
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
  IF NEW.buyOrSell='buy' THEN
    INSERT INTO Portfolio(user_id, asset_id, holdings, avg_price)
    VALUES (NEW.user_id,NEW.asset_id,NEW.quantity,NEW.price)
    ON DUPLICATE KEY UPDATE
      holdings=holdings+NEW.quantity,
      avg_price=((avg_price*(holdings-NEW.quantity))+(NEW.price*NEW.quantity))/NULLIF(holdings,0);
  ELSE
    UPDATE Portfolio
    SET holdings=holdings-NEW.quantity
    WHERE user_id=NEW.user_id AND asset_id=NEW.asset_id;
  END IF;
  INSERT INTO AuditLog(user_id, action, timestamp)
  VALUES (NEW.user_id,CONCAT('Transaction executed: ',NEW.buyOrSell,' ',NEW.quantity,' of Asset ID ',NEW.asset_id,' @ ',NEW.price,' @ ',NOW()),NOW());
END$$
DELIMITER ;
SELECT * FROM Users_check;
INSERT INTO Users_check (username, password, role) VALUES
('deepikap','hash1','trader'),
('bhaavyar','hash2','trader'),
('indirapriya','hash3','trader'),
('priyan','hash4','trader'),
('rameshi','hash5','trader'),
('lakshmis','hash6','trader'),
('vikrams','hash7','trader'),
('anitham','hash8','trader'),
('sundarp','hash9','trader'),
('meenac','hash10','trader'),
('harin','hash11','trader'),
('sangeethar','hash12','trader'),
('gopalv','hash13','trader'),
('rathik','hash14','trader'),
('balajis','hash15','trader');
SELECT * FROM Assets;
INSERT INTO Assets (asset_name, ticker, type) VALUES
('Tesla Inc','TSLA','stock'),
('Apple Inc','AAPL','stock'),
('Bitcoin','BTC','crypto'),
('Ethereum','ETH','crypto'),
('Gold','XAU','commodity'),
('USD/INR','USDINR','forex'),
('Infosys Ltd','INFY','stock'),
('Tata Motors','TTM','stock'),
('Ripple','XRP','crypto'),
('Reliance Industries','RELI','stock'),
('Silver','XAG','commodity'),
('Cardano','ADA','crypto'),
('NASDAQ ETF','QQQ','stock'),
('Sensex ETF','BSEETF','stock'),
('S&P 500 ETF','SPY','stock');
SELECT * FROM Markets;
INSERT INTO Markets (asset_id, region, exchange) VALUES
(1,'US','NASDAQ'),
(2,'US','NASDAQ'),
(3,'Global','CryptoExchange'),
(4,'Global','CryptoExchange'),
(5,'Global','Bullion Market'),
(6,'India','NSE Forex'),
(7,'India','NSE'),
(8,'India','BSE'),
(9,'Global','CryptoExchange'),
(10,'India','NSE'),
(11,'Global','Bullion Market'),
(12,'India','BSE'),
(13,'Global','CryptoExchange'),
(14,'US','NASDAQ'),
(15,'India','NSE');
SELECT * FROM Prices;
INSERT INTO Prices (asset_id, open, close, high, low, volume) VALUES
(1,240,245,250,239,100000),
(2,150,155,160,148,200000),
(3,30000,31000,32000,29500,5000),
(4,2000,2100,2150,1980,8000),
(5,1800,1820,1850,1790,12000),
(6,75,76,77,74,1000000),
(7,1500,1520,1550,1480,50000),
(8,395,405,410,390,60000),
(9,0.9,1.0,1.1,0.85,9000000),
(10,2300,2320,2350,2290,30000),
(11,25,26,27,24,100000),
(12,1.45,1.55,1.60,1.40,10000000),
(13,400,415,420,395,25000),
(14,370,385,390,360,28000),
(15,405,410,415,400,35000);
SELECT * FROM Portfolio;
INSERT INTO Portfolio (user_id, asset_id, holdings, avg_price) VALUES
(1,1,50,240.50),
(2,3,2,30000),
(3,2,10,150.25),
(4,5,100,1800),
(5,4,20,2100),
(6,7,200,1500),
(7,8,150,400),
(8,9,500,0.90),
(9,10,100,2300),
(10,11,500,25), 
(11,12,300,1.50),
(12,13,150,410),
(13,14,100,380),
(14,15,80,385),
(15,6,200,75);

START TRANSACTION;
INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
VALUES(1,1,'buy',10,50.00,NOW());
INSERT INTO Portfolio(user_id, asset_id, holdings, avg_price)
VALUES (1, 1, 10, 50.00)
ON DUPLICATE KEY UPDATE
  holdings = holdings + VALUES(holdings),
  avg_price = (avg_price * holdings + VALUES(avg_price) * VALUES(holdings)) / (holdings + VALUES(holdings));
COMMIT;
SELECT * FROM AuditLog
WHERE log_id = 57;

START TRANSACTION;
INSERT INTO Prices(asset_id, open, close, high, low, volume)
VALUES (1,100,45,105,44,5000);
COMMIT;
SELECT * FROM AuditLog
WHERE log_id IN (58, 59);

START TRANSACTION;
INSERT INTO Prices(asset_id, open, close, high, low, volume)
VALUES (1,190,210,220,185,7000); 
COMMIT;
SELECT * FROM AuditLog
WHERE log_id IN (60, 61);

START TRANSACTION;
INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
VALUES(1,5,'buy',5,1800.00,NOW());
SAVEPOINT after_gold_purchase;
INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
VALUES(1,2,'buy',20,80.00,NOW());
ROLLBACK TO SAVEPOINT after_gold_purchase;
COMMIT;
SELECT * FROM AuditLog
WHERE log_id = 62;

START TRANSACTION;
UPDATE Portfolio
SET holdings=holdings-10
WHERE user_id=1 AND asset_id=1;
SAVEPOINT after_deduction;
INSERT INTO Portfolio (user_id, asset_id, holdings, avg_price)
VALUES (2,1,10,100.00)
ON DUPLICATE KEY UPDATE
  holdings=holdings+VALUES(holdings),
  avg_price=(avg_price*holdings+VALUES(holdings)*VALUES(avg_price))/(holdings+VALUES(holdings));
INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
VALUES (1,1,'sell',5,100.00,NOW());
UPDATE Portfolio
SET holdings=holdings-5
WHERE user_id=1 AND asset_id=1;
INSERT INTO Transactions(user_id, asset_id, buyOrSell, quantity, price, timestamp)
VALUES (2,1,'buy',5,100.00,NOW());
INSERT INTO Portfolio(user_id, asset_id, holdings, avg_price)
VALUES (2,1,5,100.00)
ON DUPLICATE KEY UPDATE
  holdings=holdings+VALUES(holdings),
  avg_price=((avg_price*holdings)+(VALUES(holdings)*VALUES(avg_price)))/(holdings+VALUES(holdings));
INSERT INTO AuditLog(user_id, action, timestamp)
VALUES (1,'User 1 sold 5 units to User 2',NOW()),
       (2,'User 2 bought 5 units from User 1',NOW());
COMMIT;
SELECT * FROM AuditLog
WHERE log_id IN (64,65,66,67);

CREATE USER 'appuser'@'%' IDENTIFIED BY 'apppass';
GRANT ALL PRIVILEGES ON MultiAssetsTradeTeamLab.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

DELIMITER $$
CREATE FUNCTION authenticate_user(p_username VARCHAR(80), p_password VARCHAR(255))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  DECLARE v_role VARCHAR(20);
  SELECT role INTO v_role
  FROM Users_check
  WHERE username=p_username AND password=p_password;
  RETURN v_role;
END$$

CREATE PROCEDURE view_assets(p_username VARCHAR(80), p_password VARCHAR(255))
BEGIN
  DECLARE v_role VARCHAR(20);
  SET v_role=authenticate_user(p_username,p_password);
  IF v_role IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Authentication failed';
  ELSE
    INSERT INTO AuditLog(user_id, action, timestamp)
    SELECT user_id, CONCAT('Viewed assets @ ',NOW()),NOW()
    FROM Users_check WHERE username=p_username;
    SELECT * FROM Assets;
  END IF;
END$$

CREATE PROCEDURE add_asset(p_username VARCHAR(80), p_password VARCHAR(255),
p_asset_name VARCHAR(100), p_ticker VARCHAR(20), p_type VARCHAR(20))
BEGIN
  DECLARE v_role VARCHAR(20);
  DECLARE v_uid INT;
  SET v_role=authenticate_user(p_username,p_password);
  SELECT user_id INTO v_uid FROM Users_check WHERE username=p_username;
  IF v_role IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Authentication failed';
  ELSEIF v_role<>'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unauthorized: Admin only';
  ELSE
    INSERT INTO Assets(asset_name,ticker,type) VALUES(p_asset_name,p_ticker,p_type);
    INSERT INTO AuditLog(user_id, action, timestamp)
    VALUES(v_uid,CONCAT('Added asset: ',p_asset_name,' @ ',NOW()),NOW());
  END IF;
END$$

CREATE PROCEDURE delete_asset(p_username VARCHAR(80), p_password VARCHAR(255), p_asset_id INT)
BEGIN
  DECLARE v_role VARCHAR(20);
  DECLARE v_uid INT;
  SET v_role=authenticate_user(p_username,p_password);
  SELECT user_id INTO v_uid FROM Users_check WHERE username=p_username;
  IF v_role IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Authentication failed';
  ELSEIF v_role<>'admin' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unauthorized: Admin only';
  ELSE
    DELETE FROM Assets WHERE asset_id=p_asset_id;
    INSERT INTO AuditLog(user_id, action, timestamp)
    VALUES(v_uid,CONCAT('Deleted asset ID: ',p_asset_id,' @ ',NOW()),NOW());
  END IF;
END$$
DELIMITER ;


