/**
* 
* @name:       supplements-maroc
* @version:    1.0.0
* @author:     EOussama
* @license     GPL-3.0
* @source:     https://github.com/EOussama/supplements-maroc
* 
* Online store for selling workout-related protein products.
* 
*/

/**
	Setting up the database
*/

-- Creating the database.
CREATE DATABASE IF NOT EXISTS `db_supp_maroc` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Using the database.
USE `db_supp_maroc`;


/**
	Creating the tables.
*/

-- Config.
CREATE TABLE IF NOT EXISTS `Config` (
	`Password`          VARCHAR(100) NOT NULL,
	`PrimaryNumber`     VARCHAR(20) NOT NULL,
	`SecondaryNumber`   VARCHAR(20) NOT NULL,
	`FixedNumber`       VARCHAR(20) NOT NULL,
	`Email`             VARCHAR(50) NOT NULL,
	`Facebook`          NVARCHAR(100),
	`Instagram`         NVARCHAR(100),
	`Youtube`           NVARCHAR(100)
);

-- Mail.
CREATE TABLE IF NOT EXISTS `Mail` (
	`MailID`            INT NOT NULL AUTO_INCREMENT,
	`SenderEmail`       VARCHAR(80) NOT NULL,
	`SenderName`        VARCHAR(300) NOT NULL,
	`Message`           TEXT NOT NULL,
	`IssueDate`         DATETIME NOT NULL DEFAULT NOW(),
	`Read`              BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_mail_id PRIMARY KEY (`MailID`)
);

-- Brands.
CREATE TABLE IF NOT EXISTS `Brands` (
	`BrandID`           SMALLINT NOT NULL AUTO_INCREMENT,
	`BrandName`         VARCHAR(50) NOT NULL,
	`Logo`              VARCHAR(300) NOT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_brands_id PRIMARY KEY (`BrandID`)
);

-- Flavors.
CREATE TABLE IF NOT EXISTS `Flavors` (
	`FlavorID`          SMALLINT NOT NULL AUTO_INCREMENT,
	`FlavorName`        VARCHAR(30) NOT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_flavor_id PRIMARY KEY (`FlavorID`)
);

-- Categories.
CREATE TABLE IF NOT EXISTS `Categories` (
	`CategoryID`        SMALLINT NOT NULL AUTO_INCREMENT,
	`CategoryName`      VARCHAR(50) NOT NULL,
	`CategoryParent`    SMALLINT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_categories_id PRIMARY KEY (`CategoryID`),
	CONSTRAINT fk_categories_id FOREIGN KEY (`CategoryParent`) REFERENCES `Categories` (`CategoryID`)
);

-- Coupons.
CREATE TABLE IF NOT EXISTS `Coupons` (
	`CouponID`          SMALLINT NOT NULL AUTO_INCREMENT,
	`CouponCode`        VARCHAR(50) NOT NULL,
	`Times`							SMALLINT NOT NULL,
	`Activated`         BIT NOT NULL DEFAULT 1,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_coupons_id PRIMARY KEY(`CouponID`)
);

-- CouponsHistory.
CREATE TABLE IF NOT EXISTS `CouponsHistory` (
	`CouponID`          SMALLINT NOT NULL,
	`CreatedDate`       DATETIME NOT NULL DEFAULT NOW(),
	`Discount`          TINYINT NOT NULL,

	CONSTRAINT pk_coupons_history_id PRIMARY KEY (`CouponID`, `CreatedDate`),
	CONSTRAINT fk_coupons_history_id FOREIGN KEY (`CouponID`) REFERENCES `Coupons` (`CouponID`),
	CONSTRAINT ck_coupons_history_dc CHECK (`Discount` BETWEEN 0 AND 100)
);

-- ShippingBumpHistory.
CREATE TABLE IF NOT EXISTS `ShippingBumpHistory` (
	`ShippingBump`      DECIMAL(12, 2) NOT NULL,
	`StartingDate`      DATETIME NOT NULL DEFAULT NOW(),

	CONSTRAINT pk_shipping_bump_history_id PRIMARY KEY (`ShippingBump`, `StartingDate`)
);

-- ShippingPriceHistory.
CREATE TABLE IF NOT EXISTS `ShippingPriceHistory` (
	`ShippingPrice`     DECIMAL(12, 2) NOT NULL,
	`StartingDate`      DATETIME NOT NULL DEFAULT NOW(),

	CONSTRAINT pk_shipping_price_history_id PRIMARY KEY (`ShippingPrice`, `StartingDate`)
);

-- Products.
CREATE TABLE IF NOT EXISTS `Products` (
	`ProductID`         INT NOT NULL AUTO_INCREMENT,
	`ProductName`       VARCHAR(80) NOT NULL,
	`NutritionInfo`     TEXT NULL, 
	`Description`       TEXT NOT NULL,
	`Usage`             TEXT NOT NULL,
	`Warning`           TEXT NOT NULL,
	`AddedDate`         DATETIME NOT NULL DEFAULT NOW(),
	`CategoryID`        SMALLINT NOT NULL,
	`BrandID`           SMALLINT NOT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_products_id PRIMARY KEY (`ProductID`),
	CONSTRAINT fk_products_cat FOREIGN KEY (`CategoryID`) REFERENCES `Categories` (`CategoryID`),
	CONSTRAINT fk_products_brd FOREIGN KEY (`BrandID`) REFERENCES `Brands` (`BrandID`)
);

-- ProductsVariants.
CREATE TABLE IF NOT EXISTS `ProductsVariants` (
	`VariantID`         INT NOT NULL AUTO_INCREMENT,
	`ProductID`         INT NOT NULL,
	`VariantValue`			FLOAT NOT NULL,
	`VariantType`				TINYINT NOT NULL DEFAULT 1,
	`Tags`							TEXT NULL,
	`FeaturedVariant`   BIT NOT NULL DEFAULT 0,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_products_variants_id PRIMARY KEY (`VariantID`),
	CONSTRAINT fk_products_variants_id FOREIGN KEY (`ProductID`) REFERENCES `Products` (`ProductID`)
);

-- ProductsVariantsFlavors.
CREATE TABLE `ProductsVariantsFlavors` (
	`VariantID`					INT NOT NULL,
	`VariantImage`     	TEXT NULL,
	`Quantity`          SMALLINT NOT NULL DEFAULT 0,
	`FlavorID`					SMALLINT NOT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,
	
	CONSTRAINT pk_products_variants_flavor_id PRIMARY KEY (`VariantID`, `FlavorID`),
	CONSTRAINT fk_products_variants_flavor_id FOREIGN KEY (`VariantID`) REFERENCES `ProductsVariants` (`VariantID`),
	CONSTRAINT fk_products_variants_flavor_flv FOREIGN KEY (`FlavorID`) REFERENCES `Flavors` (`FlavorID`)
);

-- ProductsPriceHistory.
CREATE TABLE IF NOT EXISTS `ProductsPriceHistory` (
	`VariantID`         INT NOT NULL,
	`Price`             DECIMAL(12, 2) NOT NULL DEFAULT 1,
	`ChangedDate`       DATETIME NOT NULL DEFAULT NOW(),

	CONSTRAINT pk_price_history_id PRIMARY KEY (`VariantID`, `ChangedDate`),
	CONSTRAINT fk_price_history_id FOREIGN KEY (`VariantID`) REFERENCES `ProductsVariants` (`VariantID`)
);

-- Packs.
CREATE TABLE IF NOT EXISTS `Packs` (
	`PackID`						INT NOT NULL AUTO_INCREMENT,
	`PackImage`     		TEXT NULL,
	`Discount`					DECIMAL(12, 2) NOT NULL DEFAULT 0,
	`AddedDate`         DATETIME NOT NULL DEFAULT NOW(),
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_packs_id PRIMARY KEY (`PackID`)
);

-- PacksVariants.
CREATE TABLE IF NOT EXISTS `PacksVariants` (
	`PackVariantID`			INT NOT NULL AUTO_INCREMENT,
	`PackID`						INT NOT NULL,
	`VariantID`         INT NOT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_packs_variants_id PRIMARY KEY (`PackVariantID`),
	CONSTRAINT fk_packs_pack_id FOREIGN KEY (`PackID`) REFERENCES `Packs` (`PackID`),
	CONSTRAINT fk_packs_variant_id FOREIGN KEY (`VariantID`) REFERENCES `ProductsVariants` (`VariantID`)
);

-- Orders.
CREATE TABLE IF NOT EXISTS `Orders` (
	`OrderID`           INT NOT NULL AUTO_INCREMENT,
	`OrderReference`    VARCHAR(50) NOT NULL UNIQUE,
	`OrderDate`         DATETIME NOT NULL DEFAULT NOW(),
	`Firstname`         VARCHAR(50) NOT NULL,
	`Lastname`          VARCHAR(50) NOT NULL,
	`PhoneNumber`       VARCHAR(30) NOT NULL,
	`Email`             VARCHAR(50) NOT NULL,
	`City`              VARCHAR(30) NOT NULL,
	`Address`           VARCHAR(100) NOT NULL,
	`StateID`           TINYINT NOT NULL,
	`CouponID`          SMALLINT NULL,
	`Deleted`           BIT NOT NULL DEFAULT 0,

	CONSTRAINT pk_orders_id PRIMARY KEY (`OrderID`),
	CONSTRAINT fk_orders_cp FOREIGN KEY (`CouponID`) REFERENCES `Coupons` (`CouponID`)
);

-- OrdersDetails.
CREATE TABLE IF NOT EXISTS `OrdersDetails` (
	`OrderDetailsID`   	INT NOT NULL AUTO_INCREMENT,
	`OrderId`           INT NOT NULL,
	`ProductID`         INT NOT NULL,
	`Quantity`          SMALLINT NOT NULL DEFAULT 1,
	`FlavorID`          SMALLINT NOT NULL,

	CONSTRAINT pk_orders_details_id PRIMARY KEY (`OrderDetailsID`),
	CONSTRAINT fk_order_details_id FOREIGN KEY (`OrderID`) REFERENCES `Orders` (`OrderID`),
	CONSTRAINT fk_order_details_ts FOREIGN KEY (`FlavorID`) REFERENCES `Flavors` (`FlavorID`)
);

-- Carousel.
CREATE TABLE IF NOT EXISTS `Carousel` (
	`CarouselID` 				INT NOT NULL AUTO_INCREMENT,
	`CarouselURL`				TEXT,
	`Tag`								VARCHAR(100) NOT NULL,
	`Deleted`						BIT NULL DEFAULT 0,

	CONSTRAINT pk_carousel_id PRIMARY KEY (`CarouselID`)
);


/**
	Data insertion.
*/

-- Config insertion.
INSERT INTO `Config` VALUES (
	'w4jkPd5ePA5kBaAA', 
	'0656975326', 
	'0680016480', 
	'0500000000', 
	'supplementsmaroc@gmail.com', 
	'Suppléments Maroc|https://www.facebook.com/supplemaroc/',
	'supplementmaroc|https://www.instagram.com/supplementmaroc/',
	'supmar|https://www.youtube.com/'
);

-- ShippingPriceHistory insertion.
INSERT INTO `ShippingPriceHistory`(`ShippingPrice`) VALUES (49);

-- ShippingBumpHistory insertion.
INSERT INTO `ShippingBumpHistory`(`ShippingBump`) VALUES (999.99);
