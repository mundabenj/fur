-- phpMyAdmin SQL Dump
-- version 6.0.0-dev
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 18, 2025 at 10:59 AM
-- Server version: 12.0.2-MariaDB
-- PHP Version: 8.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fur`
--
DROP DATABASE IF EXISTS `fur`;
CREATE DATABASE IF NOT EXISTS `fur` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `fur`;

-- --------------------------------------------------------

--
-- Table structure for table `gender`
--

DROP TABLE IF EXISTS `gender`;
CREATE TABLE IF NOT EXISTS `gender` (
  `genderId` tinyint(1) NOT NULL AUTO_INCREMENT,
  `gender` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`genderId`),
  UNIQUE KEY `gender` (`gender`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `roleId` tinyint(1) NOT NULL AUTO_INCREMENT,
  `role` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`roleId`),
  UNIQUE KEY `role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
CREATE TABLE IF NOT EXISTS `skills` (
  `skillId` bigint(11) NOT NULL AUTO_INCREMENT,
  `skill` varchar(200) DEFAULT NULL,
  `points` double(8,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`skillId`),
  UNIQUE KEY `skill` (`skill`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `userId` bigint(11) NOT NULL AUTO_INCREMENT,
  `fullname` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `genderId` tinyint(1) NOT NULL,
  `roleId` tinyint(1) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`userId`),
  UNIQUE KEY `email` (`email`),
  KEY `users_ibfk_1` (`genderId`),
  KEY `users_ibfk_2` (`roleId`)
) ENGINE=InnoDB AUTO_INCREMENT=193425 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `users`
--
DROP TRIGGER IF EXISTS `trg_after_user_insert`;
DELIMITER $$
CREATE TRIGGER `trg_after_user_insert` AFTER INSERT ON `users` FOR EACH ROW BEGIN
INSERT INTO user_points (userId, points) VALUES (NEW.userId, 0.00);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_points`
--

DROP TABLE IF EXISTS `user_points`;
CREATE TABLE IF NOT EXISTS `user_points` (
  `userId` bigint(11) NOT NULL,
  `points` double(8,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`userId`,`points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_skills`
--

DROP TABLE IF EXISTS `user_skills`;
CREATE TABLE IF NOT EXISTS `user_skills` (
  `userId` bigint(11) NOT NULL,
  `skillId` bigint(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`userId`,`skillId`),
  KEY `user_skills_ibfk_2` (`skillId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `user_skills`
--
DROP TRIGGER IF EXISTS `trg_after_user_skill_delete`;
DELIMITER $$
CREATE TRIGGER `trg_after_user_skill_delete` AFTER DELETE ON `user_skills` FOR EACH ROW BEGIN
    DECLARE total_points DOUBLE;
    SELECT SUM(s.points) INTO total_points
    FROM user_skills us
    LEFT JOIN skills s USING (skillId)
    WHERE us.userId = OLD.userId;
    UPDATE user_points SET points = total_points WHERE userId = OLD.userId;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `trg_after_user_skill_insert`;
DELIMITER $$
CREATE TRIGGER `trg_after_user_skill_insert` AFTER INSERT ON `user_skills` FOR EACH ROW BEGIN
    DECLARE total_points DOUBLE;
    SELECT SUM(s.points) INTO total_points
    FROM user_skills us
    LEFT JOIN skills s USING (skillId)
    WHERE us.userId = NEW.userId;
    UPDATE user_points SET points = total_points WHERE userId = NEW.userId;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `user_skill_summary`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `user_skill_summary`;
CREATE TABLE IF NOT EXISTS `user_skill_summary` (
`userId` bigint(11)
,`fullname` varchar(50)
,`ROLE` varchar(50)
,`gender` varchar(50)
,`user_skill` mediumtext
,`total_points` double(19,2)
);

-- --------------------------------------------------------

--
-- Structure for view `user_skill_summary`
--
DROP TABLE IF EXISTS `user_skill_summary`;

DROP VIEW IF EXISTS `user_skill_summary`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user_skill_summary`  AS SELECT `users`.`userId` AS `userId`, `users`.`fullname` AS `fullname`, `roles`.`role` AS `ROLE`, `gender`.`gender` AS `gender`, group_concat(`skills`.`skill` separator ', ') AS `user_skill`, sum(`skills`.`points`) AS `total_points` FROM ((((`users` left join `roles` on(`users`.`roleId` = `roles`.`roleId`)) left join `gender` on(`users`.`genderId` = `gender`.`genderId`)) left join `user_skills` on(`users`.`userId` = `user_skills`.`userId`)) left join `skills` on(`user_skills`.`skillId` = `skills`.`skillId`)) GROUP BY `users`.`userId` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`genderId`) REFERENCES `gender` (`genderId`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`roleId`) REFERENCES `roles` (`roleId`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_points`
--
ALTER TABLE `user_points`
  ADD CONSTRAINT `user_points_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE NO ACTION;

--
-- Constraints for table `user_skills`
--
ALTER TABLE `user_skills`
  ADD CONSTRAINT `user_skills_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE NO ACTION,
  ADD CONSTRAINT `user_skills_ibfk_2` FOREIGN KEY (`skillId`) REFERENCES `skills` (`skillId`) ON DELETE NO ACTION;

DELIMITER $$
--
-- Events
--
DROP EVENT IF EXISTS `evt_cleanup_unsused_skills`$$
CREATE DEFINER=`root`@`localhost` EVENT `evt_cleanup_unsused_skills` ON SCHEDULE EVERY 1 MONTH STARTS '2025-12-18 13:58:22' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM skills
WHERE skillId NOT IN (SELECT DISTINCT skillId FROM user_skills)
 AND created_at < (NOW() - INTERVAL 1 MONTH);
 END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
