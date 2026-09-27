-- Smartboard OPS Management database backup
-- Generated at 2026-09-26T14:56:13.479Z
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `additional_software_catalog`;
CREATE TABLE `additional_software_catalog` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_add_sw` (`name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `assembled_units`;
CREATE TABLE `assembled_units` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int unsigned NOT NULL,
  `ops_inventory_id` int unsigned NOT NULL,
  `wifi_card_inventory_id` int unsigned DEFAULT NULL,
  `technician_id` int unsigned NOT NULL,
  `notes` text,
  `status` enum('assembly_in_progress','assembled','ready_for_delivery','delivered','in_repair','returned','retired') NOT NULL DEFAULT 'assembly_in_progress',
  `assembly_started_at` datetime DEFAULT NULL,
  `assembly_completed_at` datetime DEFAULT NULL,
  `ready_for_delivery_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_assembled_ops` (`ops_inventory_id`),
  KEY `fk_asm_job` (`job_id`),
  KEY `fk_asm_wifi` (`wifi_card_inventory_id`),
  KEY `fk_asm_technician` (`technician_id`),
  KEY `idx_assembled_status` (`status`),
  KEY `idx_assembled_dates` (`assembly_completed_at`,`delivered_at`),
  CONSTRAINT `fk_asm_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`),
  CONSTRAINT `fk_asm_ops` FOREIGN KEY (`ops_inventory_id`) REFERENCES `inventory_ops` (`id`),
  CONSTRAINT `fk_asm_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_asm_wifi` FOREIGN KEY (`wifi_card_inventory_id`) REFERENCES `inventory_network_cards` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `assembled_units` (`id`, `job_id`, `ops_inventory_id`, `wifi_card_inventory_id`, `technician_id`, `notes`, `status`, `assembly_started_at`, `assembly_completed_at`, `ready_for_delivery_at`, `delivered_at`, `created_at`, `updated_at`) VALUES (1, 2, 5, NULL, 1, NULL, 'assembly_in_progress', '2026-09-21 06:47:03.000', NULL, NULL, NULL, '2026-09-21 06:47:03.000', '2026-09-21 06:47:03.000');

DROP TABLE IF EXISTS `assembly_additional_software`;
CREATE TABLE `assembly_additional_software` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assembled_unit_id` int unsigned NOT NULL,
  `software_id` int unsigned NOT NULL,
  `installed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_asm_add_sw` (`assembled_unit_id`,`software_id`),
  KEY `fk_asm_add_sw_software` (`software_id`),
  CONSTRAINT `fk_asm_add_sw_software` FOREIGN KEY (`software_id`) REFERENCES `additional_software_catalog` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asm_add_sw_unit` FOREIGN KEY (`assembled_unit_id`) REFERENCES `assembled_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `assembly_main_software`;
CREATE TABLE `assembly_main_software` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assembled_unit_id` int unsigned NOT NULL,
  `software_catalog_id` int unsigned NOT NULL,
  `software_key_id` int unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `unassigned_at` datetime DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_asm_main_sw_active` (`assembled_unit_id`,`software_catalog_id`,`is_active`),
  KEY `fk_asm_main_sw_catalog` (`software_catalog_id`),
  KEY `fk_asm_main_sw_key` (`software_key_id`),
  KEY `idx_assembly_main_sw_unit` (`assembled_unit_id`,`is_active`),
  CONSTRAINT `fk_asm_main_sw_catalog` FOREIGN KEY (`software_catalog_id`) REFERENCES `main_software_catalog` (`id`),
  CONSTRAINT `fk_asm_main_sw_key` FOREIGN KEY (`software_key_id`) REFERENCES `main_software_keys` (`id`),
  CONSTRAINT `fk_asm_main_sw_unit` FOREIGN KEY (`assembled_unit_id`) REFERENCES `assembled_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `assembly_rams`;
CREATE TABLE `assembly_rams` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assembled_unit_id` int unsigned NOT NULL,
  `ram_inventory_id` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_asm_ram` (`assembled_unit_id`,`ram_inventory_id`),
  KEY `fk_asm_ram_inv` (`ram_inventory_id`),
  CONSTRAINT `fk_asm_ram_inv` FOREIGN KEY (`ram_inventory_id`) REFERENCES `inventory_rams` (`id`),
  CONSTRAINT `fk_asm_ram_unit` FOREIGN KEY (`assembled_unit_id`) REFERENCES `assembled_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `assembly_rams` (`id`, `assembled_unit_id`, `ram_inventory_id`, `created_at`, `updated_at`) VALUES (1, 1, 47, '2026-09-21 06:47:15.000', '2026-09-21 06:47:15.000');

DROP TABLE IF EXISTS `assembly_storage`;
CREATE TABLE `assembly_storage` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `assembled_unit_id` int unsigned NOT NULL,
  `storage_inventory_id` int unsigned NOT NULL,
  `role` enum('primary','secondary','tertiary','additional') NOT NULL DEFAULT 'additional',
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_asm_storage` (`assembled_unit_id`,`storage_inventory_id`),
  KEY `fk_asm_storage_inv` (`storage_inventory_id`),
  CONSTRAINT `fk_asm_storage_inv` FOREIGN KEY (`storage_inventory_id`) REFERENCES `inventory_storage` (`id`),
  CONSTRAINT `fk_asm_storage_unit` FOREIGN KEY (`assembled_unit_id`) REFERENCES `assembled_units` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int unsigned DEFAULT NULL,
  `details` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_audit_user` (`user_id`),
  KEY `idx_audit_created_at` (`created_at`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=642 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (1, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-05 21:59:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (2, 1, 'client.created', 'client', 6, '{\"name\":\"Sabaragamuwa University of Sri Lanka\",\"district_id\":24}', '103.21.166.69', '2026-09-05 22:08:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (3, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-05 22:09:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (4, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-05 22:55:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (5, 1, 'auth.logout', 'user', 1, NULL, '103.21.166.69', '2026-09-06 00:38:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (6, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 00:55:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (7, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 00:55:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (8, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 00:56:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (9, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 00:58:24.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (10, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:09:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (11, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:09:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (12, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:09:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (13, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:11:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (14, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:11:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (15, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:12:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (16, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:16:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (17, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:23:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (18, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:24:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (19, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:24:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (20, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:25:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (21, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:25:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (22, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:28:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (23, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:29:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (24, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:36:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (25, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:36:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (26, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:37:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (27, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:37:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (28, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:37:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (29, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:38:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (30, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:38:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (31, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:38:28.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (32, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:40:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (33, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:41:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (34, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:44:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (35, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:44:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (36, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:45:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (37, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:50:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (38, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:50:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (39, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:51:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (40, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:51:14.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (41, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:51:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (42, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:55:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (43, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:56:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (44, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 01:56:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (45, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:00:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (46, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:01:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (47, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:07:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (48, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:10:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (49, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:10:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (50, 1, 'user.created', 'user', 2, '{\"username\":\"manager\",\"role\":\"manager\"}', '103.21.166.69', '2026-09-06 02:11:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (51, 2, 'auth.login', 'user', 2, '{\"username\":\"manager\",\"role\":\"manager\"}', '103.21.166.69', '2026-09-06 02:11:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (52, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:11:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (53, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:12:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (54, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:15:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (55, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '103.21.166.69', '2026-09-06 02:23:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (56, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '43.205.110.89', '2026-09-06 02:24:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (57, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '43.205.110.89', '2026-09-06 02:24:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (58, 1, 'auth.login', 'user', 1, '{\"username\":\"admin\",\"role\":\"admin\"}', '43.205.110.89', '2026-09-06 02:26:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (59, 1, 'auth.logout', 'user', 1, NULL, '13.234.38.78', '2026-09-06 02:32:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (60, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.234.38.78', '2026-09-06 02:33:14.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (61, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:33:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (62, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 02:33:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (63, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 02:33:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (64, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:33:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (65, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 02:33:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (66, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:34:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (67, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:34:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (68, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 02:34:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (69, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 02:34:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (70, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '43.205.110.89', '2026-09-06 02:34:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (71, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.201.65.24', '2026-09-06 02:36:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (72, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 02:36:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (73, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (74, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (75, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 02:36:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (76, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (77, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (78, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (79, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (80, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (81, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 02:36:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (82, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 02:36:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (83, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 02:36:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (84, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 02:37:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (85, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-06 08:54:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (86, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.250.114.58', '2026-09-06 08:57:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (87, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:57:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (88, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:57:28.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (89, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 08:57:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (90, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:57:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (91, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 08:57:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (92, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 08:58:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (93, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:58:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (94, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 08:58:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (95, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:58:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (96, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:58:45.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (97, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 08:58:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (98, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 08:59:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (99, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 08:59:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (100, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 08:59:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (101, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 08:59:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (102, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 08:59:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (103, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:00:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (104, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:00:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (105, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:00:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (106, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:00:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (107, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:00:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (108, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:00:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (109, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:00:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (110, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:01:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (111, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:01:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (112, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:01:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (113, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:01:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (114, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:01:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (115, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:01:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (116, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:02:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (117, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:02:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (118, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:02:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (119, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:02:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (120, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:02:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (121, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:02:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (122, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:03:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (123, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:03:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (124, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:04:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (125, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:04:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (126, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:04:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (127, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:04:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (128, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:04:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (129, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:05:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (130, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:05:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (131, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:05:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (132, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:05:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (133, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:05:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (134, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:06:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (135, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:06:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (136, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:06:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (137, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:06:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (138, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:06:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (139, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:07:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (140, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:08:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (141, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.114.58', '2026-09-06 09:09:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (142, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:10:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (143, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:11:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (144, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-06 09:12:54.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (145, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-06 09:13:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (146, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '43.205.110.89', '2026-09-06 10:09:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (147, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-06 10:09:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (148, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.201.65.24', '2026-09-06 10:10:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (149, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 10:10:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (150, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.110.89', '2026-09-06 10:10:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (151, 3, 'auth.logout', 'user', 3, NULL, '13.201.65.24', '2026-09-06 10:10:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (152, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.234.38.78', '2026-09-06 10:10:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (153, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-06 14:40:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (154, 1, 'user.created', 'user', 4, '{\"username\":\"Madawa\",\"role\":\"manager\"}', '47.128.155.34', '2026-09-06 14:41:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (155, 1, 'user.deleted', 'user', 4, NULL, '47.128.155.34', '2026-09-06 14:42:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (156, 1, 'user.created', 'user', 5, '{\"username\":\"Madhawa\",\"role\":\"manager\"}', '13.250.15.232', '2026-09-06 14:43:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (157, 5, 'auth.login', 'user', 5, '{\"username\":\"Madhawa\",\"role\":\"manager\"}', '13.250.15.232', '2026-09-06 14:44:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (158, 5, 'auth.login', 'user', 5, '{\"username\":\"Madhawa\",\"role\":\"manager\"}', '47.128.155.34', '2026-09-06 14:44:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (159, 5, 'auth.login', 'user', 5, '{\"username\":\"Madhawa\",\"role\":\"manager\"}', '47.128.155.34', '2026-09-06 14:46:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (160, 5, 'auth.login', 'user', 5, '{\"username\":\"Madhawa\",\"role\":\"manager\"}', '13.250.15.232', '2026-09-06 14:46:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (161, 5, 'auth.logout', 'user', 5, NULL, '13.250.114.58', '2026-09-06 14:47:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (162, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-06 14:47:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (163, 1, 'catalog.created', 'smartboard-models', 1, NULL, '13.250.15.232', '2026-09-06 14:48:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (164, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-06 15:30:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (165, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-06 15:31:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (166, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.201.65.24', '2026-09-06 16:41:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (167, 1, 'catalog.deleted', 'smartboard-models', 1, NULL, '13.234.38.78', '2026-09-06 16:44:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (168, 1, 'catalog.created', 'smartboard-models', 2, NULL, '13.201.65.24', '2026-09-06 16:45:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (169, 1, 'catalog.created', 'smartboard-models', 3, NULL, '13.234.38.78', '2026-09-06 16:45:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (170, 1, 'catalog.created', 'smartboard-models', 4, NULL, '13.234.38.78', '2026-09-06 16:46:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (171, 1, 'catalog.created', 'smartboard-models', 5, NULL, '13.234.38.78', '2026-09-06 16:47:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (172, 1, 'catalog.created', 'smartboard-models', 7, NULL, '13.234.38.78', '2026-09-06 16:47:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (173, 1, 'catalog.created', 'smartboard-models', 8, NULL, '13.201.65.24', '2026-09-06 16:48:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (174, 1, 'catalog.created', 'smartboard-models', 9, NULL, '13.234.38.78', '2026-09-06 16:48:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (175, 1, 'catalog.created', 'smartboard-models', 10, NULL, '43.205.110.89', '2026-09-06 16:48:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (176, 1, 'catalog.created', 'smartboard-models', 11, NULL, '13.234.38.78', '2026-09-06 16:49:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (177, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.234.38.78', '2026-09-07 16:52:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (178, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '3.110.160.47', '2026-09-10 10:27:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (179, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '43.205.111.96', '2026-09-12 08:42:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (180, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-12 20:21:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (181, 1, 'auth.logout', 'user', 1, NULL, '47.128.228.103', '2026-09-12 20:21:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (182, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.250.15.232', '2026-09-12 20:21:14.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (183, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-12 20:21:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (184, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-12 20:21:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (185, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.228.103', '2026-09-12 20:21:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (186, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-12 20:21:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (187, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-12 20:21:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (188, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-12 20:21:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (189, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.228.103', '2026-09-12 20:21:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (190, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-12 20:21:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (191, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-12 20:22:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (192, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.228.103', '2026-09-12 20:22:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (193, 3, 'auth.logout', 'user', 3, NULL, '13.250.15.232', '2026-09-12 20:22:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (194, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-12 20:22:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (195, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.128.155.34', '2026-09-12 20:23:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (196, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-13 16:38:28.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (197, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-13 17:24:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (198, 1, 'auth.logout', 'user', 1, NULL, '47.128.155.34', '2026-09-13 17:33:24.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (199, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-13 17:41:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (200, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '13.250.15.232', '2026-09-13 17:42:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (201, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '47.128.155.34', '2026-09-13 17:46:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (202, 1, 'auth.logout', 'user', 1, NULL, '13.250.15.232', '2026-09-13 18:14:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (203, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.15.232', '2026-09-13 18:14:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (204, 1, 'catalog.created', 'ops-models', 1, NULL, '13.250.15.232', '2026-09-13 18:21:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (205, 1, 'catalog.created', 'ops-models', 2, NULL, '13.250.15.232', '2026-09-13 18:21:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (206, 1, 'catalog.created', 'ops-models', 3, NULL, '47.128.155.34', '2026-09-13 18:21:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (207, 1, 'auth.logout', 'user', 1, NULL, '47.128.155.34', '2026-09-13 18:28:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (208, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.250.15.232', '2026-09-13 18:28:59.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (209, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:29:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (210, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:29:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (211, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:29:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (212, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:29:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (213, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:29:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (214, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:29:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (215, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:29:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (216, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:30:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (217, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:30:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (218, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:30:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (219, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:30:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (220, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:30:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (221, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:30:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (222, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:31:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (223, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:32:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (224, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:33:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (225, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '47.128.155.34', '2026-09-13 18:34:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (226, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:35:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (227, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:36:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (228, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:37:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (229, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:38:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (230, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:39:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (231, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:40:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (232, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:41:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (233, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.250.15.232', '2026-09-13 18:42:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (234, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '54.255.154.110', '2026-09-13 18:43:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (235, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:44:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (236, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:46:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (237, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:46:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (238, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:47:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (239, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:47:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (240, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:47:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (241, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:47:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (242, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:47:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (243, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:47:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (244, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:48:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (245, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:48:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (246, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:48:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (247, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:48:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (248, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:48:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (249, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:48:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (250, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:49:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (251, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:49:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (252, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:49:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (253, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:49:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (254, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:49:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (255, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:49:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (256, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:50:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (257, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:50:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (258, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:50:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (259, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:50:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (260, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:50:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (261, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:50:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (262, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:51:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (263, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:51:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (264, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:51:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (265, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:51:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (266, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:51:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (267, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:51:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (268, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:52:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (269, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:52:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (270, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:52:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (271, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:52:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (272, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:53:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (273, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:54:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (274, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:55:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (275, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:56:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (276, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:57:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (277, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:58:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (278, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:58:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (279, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:58:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (280, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 18:58:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (281, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:58:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (282, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:58:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (283, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:59:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (284, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:59:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (285, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:59:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (286, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 18:59:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (287, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:59:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (288, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 18:59:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (289, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:00:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (290, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:00:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (291, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:01:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (292, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:02:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (293, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:03:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (294, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:04:45.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (295, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:04:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (296, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:04:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (297, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:05:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (298, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:05:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (299, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:05:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (300, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:05:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (301, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:05:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (302, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:05:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (303, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:06:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (304, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:06:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (305, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:06:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (306, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:06:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (307, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:06:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (308, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:06:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (309, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:07:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (310, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:08:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (311, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:09:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (312, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:09:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (313, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:09:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (314, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:09:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (315, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:09:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (316, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:09:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (317, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:09:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (318, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:10:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (319, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:10:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (320, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:10:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (321, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:10:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (322, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:10:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (323, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:10:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (324, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:11:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (325, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:11:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (326, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:11:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (327, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:11:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (328, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:11:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (329, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:12:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (330, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:13:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (331, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:14:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (332, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:15:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (333, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:16:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (334, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:17:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (335, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:18:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (336, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:19:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (337, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:20:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (338, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:21:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (339, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:22:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (340, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:23:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (341, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:23:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (342, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:23:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (343, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:24:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (344, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:24:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (345, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:24:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (346, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:24:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (347, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:24:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (348, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:24:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (349, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:25:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (350, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:25:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (351, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:25:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (352, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:25:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (353, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:25:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (354, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:25:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (355, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:26:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (356, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:26:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (357, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:26:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (358, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '13.234.38.78', '2026-09-13 19:26:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (359, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:26:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (360, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:26:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (361, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:27:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (362, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '52.66.196.186', '2026-09-13 19:27:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (363, 3, 'audit.viewed', 'audit_log', NULL, '{\"page\":1}', '43.205.111.96', '2026-09-13 19:27:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (364, 3, 'auth.logout', 'user', 3, NULL, '13.234.38.78', '2026-09-13 19:27:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (365, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '43.205.111.96', '2026-09-13 19:27:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (366, 1, 'auth.logout', 'user', 1, NULL, '13.234.38.78', '2026-09-13 19:32:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (367, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '52.66.196.186', '2026-09-13 19:32:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (368, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.128.155.34', '2026-09-13 19:52:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (369, 1, 'auth.logout', 'user', 1, NULL, '54.255.154.110', '2026-09-13 19:52:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (370, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.250.15.232', '2026-09-13 19:53:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (371, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '43.205.111.96', '2026-09-13 19:54:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (372, 3, 'auth.logout', 'user', 3, NULL, '13.250.15.232', '2026-09-13 19:56:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (373, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.128.155.34', '2026-09-13 19:57:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (374, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '47.128.155.34', '2026-09-13 20:01:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (375, 1, 'auth.logout', 'user', 1, NULL, '43.205.111.96', '2026-09-13 20:01:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (376, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '52.66.196.186', '2026-09-13 20:01:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (377, 3, 'auth.logout', 'user', 3, NULL, '52.66.196.186', '2026-09-13 20:03:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (378, 1, 'client.created', 'client', 7, '{\"name\":\"University of Jayawardhanapura\",\"district_id\":1}', '54.255.154.110', '2026-09-13 20:10:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (379, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '52.66.196.186', '2026-09-13 20:34:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (380, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.234.38.78', '2026-09-13 20:38:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (381, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.234.38.78', '2026-09-13 23:36:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (382, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.128.155.34', '2026-09-14 03:40:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (383, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '52.66.196.186', '2026-09-14 03:41:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (384, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.234.38.78', '2026-09-14 05:52:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (385, 1, 'catalog.created', 'storage-specs', 1, NULL, '52.66.196.186', '2026-09-14 05:53:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (386, 1, 'catalog.created', 'ram-specs', 1, NULL, '13.234.38.78', '2026-09-14 05:53:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (387, 1, 'inventory.batch_added', 'inventory_storage', NULL, '{\"batch_id\":1,\"inserted\":14,\"rejected\":0}', '52.66.196.186', '2026-09-14 06:09:26.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (388, 1, 'inventory.status_updated', 'inventory_storage', 14, '{\"status\":\"reserved\"}', '13.234.38.78', '2026-09-14 06:36:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (389, 1, 'inventory.status_updated', 'inventory_storage', 14, '{\"status\":\"in_stock\"}', '13.234.38.78', '2026-09-14 06:36:45.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (390, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '35.154.128.139', '2026-09-14 08:15:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (391, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"8SSSS0L25188X3RC11C2DSV\",\"spec_id\":\"1\",\"batch_id\":2}', '43.205.111.96', '2026-09-14 08:37:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (392, 1, 'inventory.item_deleted', 'inventory_storage', 15, NULL, '13.234.38.78', '2026-09-14 08:37:48.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (393, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"8SSSS0L25188X3RC11C2DSV\",\"spec_id\":\"1\",\"batch_id\":3}', '35.154.128.139', '2026-09-14 08:38:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (394, 1, 'inventory.item_deleted', 'inventory_storage', 16, NULL, '43.205.111.96', '2026-09-14 08:39:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (395, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"002538AB01E21BBA\",\"spec_id\":\"1\",\"batch_id\":4}', '35.154.128.139', '2026-09-14 08:39:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (396, 1, 'inventory.item_deleted', 'inventory_storage', 17, NULL, '13.234.38.78', '2026-09-14 08:40:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (397, 1, 'borrowings.lent', 'technician_borrowings', 1, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4UMNX0NB04296\"}', '13.234.38.78', '2026-09-14 08:41:45.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (398, 1, 'borrowings.returned', 'technician_borrowings', 1, NULL, '35.154.128.139', '2026-09-14 08:41:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (399, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '43.205.111.96', '2026-09-14 10:15:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (400, 1, 'client.created', 'client', 8, '{\"name\":\"ASTP TEC PVT LTD\",\"district_id\":10}', '43.205.111.96', '2026-09-14 10:16:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (401, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '35.154.128.139', '2026-09-14 10:30:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (402, 1, 'catalog.created', 'ops-models', 4, NULL, '13.234.38.78', '2026-09-14 10:31:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (403, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-15 04:09:59.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (404, 1, 'catalog.created', 'software_main', 1, NULL, '47.128.155.34', '2026-09-15 04:12:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (405, 1, 'catalog.updated', 'software_main', 1, NULL, '13.250.15.232', '2026-09-15 04:13:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (406, 1, 'catalog.updated', 'software_main', 1, NULL, '13.250.114.58', '2026-09-15 04:14:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (407, 1, 'catalog.created', 'software_main', 2, NULL, '47.128.155.34', '2026-09-15 04:15:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (408, 1, 'job.created', 'job', 1, '{\"job_number\":\"JOB-2026-0001\",\"job_type\":\"both\",\"client_id\":8}', '13.250.15.232', '2026-09-15 04:16:46.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (409, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '15.206.94.206', '2026-09-16 14:02:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (410, 1, 'catalog.updated', 'ram-specs', 1, NULL, '15.206.94.206', '2026-09-16 14:08:18.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (411, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":6,\"inserted\":1,\"rejected\":2}', '13.201.65.24', '2026-09-16 14:14:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (412, 1, 'inventory.item_deleted', 'inventory_ram', 1, NULL, '15.206.94.206', '2026-09-16 14:14:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (413, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":7,\"inserted\":3,\"rejected\":0}', '65.1.65.231', '2026-09-16 14:17:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (414, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":8,\"inserted\":23,\"rejected\":2}', '15.206.94.206', '2026-09-16 14:42:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (415, 1, 'user.created', 'user', 6, '{\"username\":\"Jithma\",\"role\":\"technician\"}', '15.206.94.206', '2026-09-16 14:45:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (416, 1, 'catalog.created', 'storage-specs', 2, NULL, '13.201.65.24', '2026-09-16 14:58:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (417, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"UHANC011KD4MOM\",\"spec_id\":\"2\",\"batch_id\":9}', '65.1.65.231', '2026-09-16 14:59:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (418, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"173107801787\",\"spec_id\":\"2\",\"batch_id\":10}', '15.206.94.206', '2026-09-16 15:00:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (419, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '65.1.65.231', '2026-09-16 15:02:06.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (420, 1, 'borrowings.lent', 'technician_borrowings', 11, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC47101\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (421, 1, 'borrowings.lent', 'technician_borrowings', 4, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270084\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (422, 1, 'borrowings.lent', 'technician_borrowings', 3, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"HMA351S6AFR8N-VK-03\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (423, 1, 'borrowings.lent', 'technician_borrowings', 5, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270039\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (424, 1, 'borrowings.lent', 'technician_borrowings', 2, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"HMA351S6AFR8N-VK-01\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (425, 1, 'borrowings.lent', 'technician_borrowings', 6, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270070\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (426, 1, 'borrowings.lent', 'technician_borrowings', 7, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA33914\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (427, 1, 'borrowings.lent', 'technician_borrowings', 9, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"173107801787\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (428, 1, 'borrowings.lent', 'technician_borrowings', 8, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC46931\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (429, 1, 'borrowings.lent', 'technician_borrowings', 10, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"UHANC011KD4MOM\"}', '15.206.94.206', '2026-09-16 15:03:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (430, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-16 18:38:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (431, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '13.250.114.58', '2026-09-16 19:00:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (432, 1, 'catalog.deleted', 'ops-models', 1, NULL, '47.129.230.55', '2026-09-16 19:00:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (433, 1, 'catalog.deleted', 'ops-models', 2, NULL, '13.250.114.58', '2026-09-16 19:00:28.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (434, 1, 'catalog.deleted', 'ops-models', 3, NULL, '13.250.114.58', '2026-09-16 19:00:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (435, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '13.250.114.58', '2026-09-16 19:02:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (436, 1, 'catalog.updated', 'software_main', 2, NULL, '47.129.230.55', '2026-09-16 19:03:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (437, 1, 'catalog.updated', 'software_main', 2, NULL, '13.250.114.58', '2026-09-16 19:03:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (438, 1, 'auth.logout', 'user', 1, NULL, '13.250.114.58', '2026-09-16 19:04:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (439, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.129.230.55', '2026-09-16 19:04:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (440, 1, 'catalog.created', 'ops-models', 5, NULL, '52.221.215.192', '2026-09-16 19:04:54.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (441, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2553LK1334UA0168\",\"spec_id\":\"5\",\"batch_id\":11}', '13.250.114.58', '2026-09-16 19:07:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (442, 1, 'borrowings.lent', 'technician_borrowings', 14, '{\"technician_id\":\"1\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270043\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (443, 1, 'borrowings.lent', 'technician_borrowings', 17, '{\"technician_id\":\"1\",\"component_type\":\"storage\",\"serial_number\":\"S4YANF0R415725\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (444, 1, 'borrowings.lent', 'technician_borrowings', 15, '{\"technician_id\":\"1\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB19993\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (445, 1, 'borrowings.lent', 'technician_borrowings', 12, '{\"technician_id\":\"1\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270150\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (446, 1, 'borrowings.lent', 'technician_borrowings', 18, '{\"technician_id\":\"1\",\"component_type\":\"ops\",\"serial_number\":\"2553LK1334UA0168\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (447, 1, 'borrowings.lent', 'technician_borrowings', 13, '{\"technician_id\":\"1\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270098\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (448, 1, 'borrowings.lent', 'technician_borrowings', 16, '{\"technician_id\":\"1\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N901720\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (449, 1, 'borrowings.lent', 'technician_borrowings', 19, '{\"technician_id\":\"1\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270060\"}', '52.221.215.192', '2026-09-16 19:24:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (450, 1, 'borrowings.lent', 'technician_borrowings', 20, '{\"technician_id\":\"1\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N903111\"}', '52.221.215.192', '2026-09-16 19:24:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (451, 1, 'auth.logout', 'user', 1, NULL, '13.250.114.58', '2026-09-16 19:28:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (452, 6, 'auth.login', 'user', 6, '{\"username\":\"Jithma\",\"role\":\"technician\"}', '52.221.215.192', '2026-09-16 19:29:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (453, 6, 'auth.logout', 'user', 6, NULL, '47.129.230.55', '2026-09-16 19:29:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (454, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.129.230.55', '2026-09-16 19:29:24.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (455, 1, 'auth.logout', 'user', 1, NULL, '52.221.215.192', '2026-09-16 19:30:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (456, 3, 'auth.login', 'user', 3, '{\"username\":\"auditor\",\"role\":\"auditor\"}', '13.250.114.58', '2026-09-16 19:30:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (457, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '52.221.215.192', '2026-09-16 19:32:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (458, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '47.129.230.55', '2026-09-16 19:34:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (459, 1, 'catalog.created', 'ops-models', 6, NULL, '52.221.215.192', '2026-09-16 19:35:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (460, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2547LK13450HX0083\",\"spec_id\":\"4\",\"batch_id\":13}', '13.250.114.58', '2026-09-16 19:35:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (461, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2547LK13450HX0082\",\"spec_id\":\"4\",\"batch_id\":14}', '13.250.114.58', '2026-09-16 19:36:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (462, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2549LK14450HX0001\",\"spec_id\":\"6\",\"batch_id\":15}', '52.221.215.192', '2026-09-16 19:36:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (463, 1, 'inventory.item_added', 'inventory_ram', NULL, '{\"serial_number\":\"HMA82GS6AFR8N-VK-04\",\"spec_id\":\"1\",\"batch_id\":16}', '47.129.230.55', '2026-09-16 19:38:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (464, 1, 'inventory.batch_added', 'inventory_storage', NULL, '{\"batch_id\":17,\"inserted\":3,\"rejected\":0}', '47.129.230.55', '2026-09-16 19:40:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (465, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":18,\"inserted\":2,\"rejected\":0}', '52.221.215.192', '2026-09-16 19:41:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (466, 1, 'borrowings.lent', 'technician_borrowings', 24, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"HMA82GS6AFR8N-VK-04\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (467, 1, 'borrowings.lent', 'technician_borrowings', 22, '{\"technician_id\":\"6\",\"component_type\":\"ops\",\"serial_number\":\"2547LK13450HX0083\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (468, 1, 'borrowings.lent', 'technician_borrowings', 23, '{\"technician_id\":\"6\",\"component_type\":\"ops\",\"serial_number\":\"2547LK13450HX0082\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (469, 1, 'borrowings.lent', 'technician_borrowings', 21, '{\"technician_id\":\"6\",\"component_type\":\"ops\",\"serial_number\":\"2549LK14450HX0001\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (470, 1, 'borrowings.lent', 'technician_borrowings', 25, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601804\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (471, 1, 'borrowings.lent', 'technician_borrowings', 29, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA12814\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (472, 1, 'borrowings.lent', 'technician_borrowings', 26, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601745\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (473, 1, 'borrowings.lent', 'technician_borrowings', 27, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC48716\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (474, 1, 'borrowings.lent', 'technician_borrowings', 28, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S6VZNJ0R901231\"}', '52.221.215.192', '2026-09-16 19:43:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (475, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '52.221.215.192', '2026-09-17 12:09:13.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (476, 1, 'borrowings.consumed', 'technician_borrowings', 14, NULL, '13.250.114.58', '2026-09-17 12:10:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (477, 1, 'borrowings.consumed', 'technician_borrowings', 16, NULL, '13.250.114.58', '2026-09-17 12:11:47.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (478, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.201.65.24', '2026-09-18 04:11:24.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (479, 1, 'borrowings.returned', 'technician_borrowings', 17, NULL, '13.201.65.24', '2026-09-18 04:13:59.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (480, 1, 'borrowings.returned', 'technician_borrowings', 13, NULL, '3.111.171.68', '2026-09-18 04:14:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (481, 1, 'borrowings.returned', 'technician_borrowings', 12, NULL, '65.0.93.222', '2026-09-18 04:14:58.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (482, 1, 'borrowings.returned', 'technician_borrowings', 15, NULL, '65.0.93.222', '2026-09-18 04:16:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (483, 1, 'borrowings.lent', 'technician_borrowings', 39, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270061\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (484, 1, 'borrowings.lent', 'technician_borrowings', 33, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N916240\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (485, 1, 'borrowings.lent', 'technician_borrowings', 31, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4YANF0R415725\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (486, 1, 'borrowings.lent', 'technician_borrowings', 32, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0T110126\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (487, 1, 'borrowings.lent', 'technician_borrowings', 30, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB19993\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (488, 1, 'borrowings.lent', 'technician_borrowings', 34, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA28630\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (489, 1, 'borrowings.lent', 'technician_borrowings', 40, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270088\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (490, 1, 'borrowings.lent', 'technician_borrowings', 41, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270013\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (491, 1, 'borrowings.lent', 'technician_borrowings', 35, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA37526\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (492, 1, 'borrowings.lent', 'technician_borrowings', 37, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270150\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (493, 1, 'borrowings.lent', 'technician_borrowings', 38, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270056\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (494, 1, 'borrowings.lent', 'technician_borrowings', 36, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270098\"}', '65.0.93.222', '2026-09-18 04:26:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (495, 1, 'borrowings.returned', 'technician_borrowings', 19, NULL, '65.0.93.222', '2026-09-18 04:28:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (496, 1, 'borrowings.returned', 'technician_borrowings', 20, NULL, '65.0.93.222', '2026-09-18 04:29:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (497, 1, 'borrowings.returned', 'technician_borrowings', 18, NULL, '3.111.171.68', '2026-09-18 04:29:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (498, 1, 'borrowings.lent', 'technician_borrowings', 43, '{\"technician_id\":\"5\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N903111\"}', '65.0.93.222', '2026-09-18 04:30:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (499, 1, 'borrowings.lent', 'technician_borrowings', 42, '{\"technician_id\":\"5\",\"component_type\":\"ops\",\"serial_number\":\"2553LK1334UA0168\"}', '65.0.93.222', '2026-09-18 04:30:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (500, 1, 'borrowings.lent', 'technician_borrowings', 44, '{\"technician_id\":\"5\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270060\"}', '65.0.93.222', '2026-09-18 04:30:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (501, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '65.0.93.222', '2026-09-18 14:14:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (502, 1, 'borrowings.returned', 'technician_borrowings', 36, NULL, '13.201.65.24', '2026-09-18 14:16:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (503, 1, 'borrowings.returned', 'technician_borrowings', 40, NULL, '13.201.65.24', '2026-09-18 14:19:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (504, 1, 'borrowings.returned', 'technician_borrowings', 34, NULL, '3.111.171.68', '2026-09-18 14:24:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (505, 1, 'borrowings.returned', 'technician_borrowings', 30, NULL, '65.0.93.222', '2026-09-18 14:24:35.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (506, 1, 'borrowings.returned', 'technician_borrowings', 32, NULL, '3.111.171.68', '2026-09-18 14:24:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (507, 1, 'borrowings.returned', 'technician_borrowings', 35, NULL, '65.0.93.222', '2026-09-18 14:25:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (508, 1, 'borrowings.returned', 'technician_borrowings', 33, NULL, '3.111.171.68', '2026-09-18 14:26:34.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (509, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-20 05:09:16.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (510, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-20 06:53:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (511, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.19.61', '2026-09-20 12:16:14.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (512, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.201.65.24', '2026-09-21 03:27:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (513, 1, 'user.created', 'user', 7, '{\"username\":\"Rukshan\",\"role\":\"technician\"}', '13.232.121.221', '2026-09-21 03:29:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (514, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":19,\"inserted\":9,\"rejected\":0}', '13.232.121.221', '2026-09-21 03:32:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (515, 1, 'borrowings.lent', 'technician_borrowings', 54, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270090\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (516, 1, 'borrowings.lent', 'technician_borrowings', 45, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270088\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (517, 1, 'borrowings.lent', 'technician_borrowings', 46, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270017\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (518, 1, 'borrowings.lent', 'technician_borrowings', 47, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270077\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (519, 1, 'borrowings.lent', 'technician_borrowings', 48, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270210\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (520, 1, 'borrowings.lent', 'technician_borrowings', 49, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270147\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (521, 1, 'borrowings.lent', 'technician_borrowings', 55, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA28630\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (522, 1, 'borrowings.lent', 'technician_borrowings', 56, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB19993\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (523, 1, 'borrowings.lent', 'technician_borrowings', 57, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0T110126\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (524, 1, 'borrowings.lent', 'technician_borrowings', 59, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N916240\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (525, 1, 'borrowings.lent', 'technician_borrowings', 58, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA37526\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (526, 1, 'borrowings.lent', 'technician_borrowings', 60, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YFNE0M941487\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (527, 1, 'borrowings.lent', 'technician_borrowings', 61, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB21440\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (528, 1, 'borrowings.lent', 'technician_borrowings', 62, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4UMNX0NB04296\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (529, 1, 'borrowings.lent', 'technician_borrowings', 50, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601531\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (530, 1, 'borrowings.lent', 'technician_borrowings', 52, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270075\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (531, 1, 'borrowings.lent', 'technician_borrowings', 53, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270014\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (532, 1, 'borrowings.lent', 'technician_borrowings', 51, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270098\"}', '13.232.121.221', '2026-09-21 03:39:55.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (533, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.201.65.24', '2026-09-21 05:11:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (534, 1, 'borrowings.returned', 'technician_borrowings', 11, NULL, '43.205.228.198', '2026-09-21 05:12:09.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (535, 1, 'borrowings.returned', 'technician_borrowings', 10, NULL, '43.205.228.198', '2026-09-21 05:12:22.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (536, 1, 'borrowings.returned', 'technician_borrowings', 8, NULL, '13.232.121.221', '2026-09-21 05:12:30.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (537, 1, 'borrowings.returned', 'technician_borrowings', 7, NULL, '13.201.65.24', '2026-09-21 05:12:41.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (538, 1, 'borrowings.returned', 'technician_borrowings', 9, NULL, '43.205.228.198', '2026-09-21 05:12:54.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (539, 1, 'borrowings.returned', 'technician_borrowings', 6, NULL, '43.205.228.198', '2026-09-21 05:13:24.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (540, 1, 'borrowings.returned', 'technician_borrowings', 3, NULL, '13.232.121.221', '2026-09-21 05:13:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (541, 1, 'borrowings.consumed', 'technician_borrowings', 2, NULL, '13.201.65.24', '2026-09-21 05:13:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (542, 1, 'borrowings.returned', 'technician_borrowings', 4, NULL, '43.205.228.198', '2026-09-21 05:13:57.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (543, 1, 'borrowings.returned', 'technician_borrowings', 5, NULL, '13.201.65.24', '2026-09-21 05:14:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (544, 1, 'borrowings.lent', 'technician_borrowings', 66, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"HMA351S6AFR8N-VK-03\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (545, 1, 'borrowings.lent', 'technician_borrowings', 68, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA33914\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (546, 1, 'borrowings.lent', 'technician_borrowings', 63, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270084\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (547, 1, 'borrowings.lent', 'technician_borrowings', 64, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270039\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (548, 1, 'borrowings.lent', 'technician_borrowings', 67, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC46931\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (549, 1, 'borrowings.lent', 'technician_borrowings', 69, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"UHANC011KD4MOM\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (550, 1, 'borrowings.lent', 'technician_borrowings', 65, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270070\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (551, 1, 'borrowings.lent', 'technician_borrowings', 70, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"173107801787\"}', '13.232.121.221', '2026-09-21 05:18:51.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (552, 1, 'inventory.item_added', 'inventory_ram', NULL, '{\"serial_number\":\"LSK202601270081\",\"spec_id\":\"1\",\"batch_id\":20}', '43.205.228.198', '2026-09-21 05:49:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (553, 1, 'client.created', 'client', 9, '{\"name\":\"University of Peradeniya\",\"district_id\":4}', '13.201.65.24', '2026-09-21 05:51:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (554, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.201.65.24', '2026-09-21 06:37:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (555, 1, 'catalog.ops_specs_updated', 'ops_cpu_specs', NULL, NULL, '43.205.228.198', '2026-09-21 06:38:45.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (556, 1, 'catalog.created', 'ops-models', 8, NULL, '43.205.228.198', '2026-09-21 06:39:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (557, 1, 'catalog.created', 'ram-specs', 4, NULL, '13.201.65.24', '2026-09-21 06:39:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (558, 1, 'inventory.batch_added', 'inventory_ram', NULL, '{\"batch_id\":21,\"inserted\":2,\"rejected\":0}', '43.205.228.198', '2026-09-21 06:40:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (559, 1, 'catalog.created', 'storage-specs', 3, NULL, '13.201.65.24', '2026-09-21 06:44:01.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (560, 1, 'catalog.created', 'storage-specs', 4, NULL, '13.201.65.24', '2026-09-21 06:44:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (561, 1, 'job.created', 'job', 2, '{\"job_number\":\"JOB-2026-0002\",\"job_type\":\"ops\",\"client_id\":9}', '13.201.65.24', '2026-09-21 06:45:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (562, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2550LK13420HA00037\",\"spec_id\":\"8\",\"batch_id\":22}', '13.201.65.24', '2026-09-21 06:46:50.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (563, 1, 'assembly.started', 'assembled_unit', 1, '{\"job_id\":2,\"ops_inventory_id\":5}', '13.201.65.24', '2026-09-21 06:47:03.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (564, 1, 'assembly.ram_added', 'assembled_unit', 1, '{\"ram_inventory_id\":47}', '13.201.65.24', '2026-09-21 06:47:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (565, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"00521\",\"spec_id\":\"4\",\"batch_id\":23}', '43.205.228.198', '2026-09-21 06:51:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (566, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '54.254.195.91', '2026-09-22 04:04:25.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (567, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-22 11:29:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (568, 1, 'borrowings.returned', 'technician_borrowings', 54, NULL, '47.129.223.0', '2026-09-22 11:38:11.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (569, 1, 'borrowings.returned', 'technician_borrowings', 49, NULL, '13.250.114.58', '2026-09-22 11:38:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (570, 1, 'borrowings.returned', 'technician_borrowings', 45, NULL, '47.129.223.0', '2026-09-22 11:38:38.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (571, 1, 'borrowings.returned', 'technician_borrowings', 52, NULL, '13.250.114.58', '2026-09-22 11:38:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (572, 1, 'borrowings.returned', 'technician_borrowings', 51, NULL, '13.250.114.58', '2026-09-22 11:39:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (573, 1, 'borrowings.returned', 'technician_borrowings', 41, NULL, '13.250.114.58', '2026-09-22 11:39:14.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (574, 1, 'borrowings.returned', 'technician_borrowings', 46, NULL, '47.129.201.108', '2026-09-22 11:39:36.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (575, 1, 'borrowings.returned', 'technician_borrowings', 48, NULL, '13.250.114.58', '2026-09-22 11:39:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (576, 1, 'borrowings.returned', 'technician_borrowings', 53, NULL, '47.129.201.108', '2026-09-22 11:40:02.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (577, 1, 'borrowings.returned', 'technician_borrowings', 55, NULL, '47.129.201.108', '2026-09-22 11:43:29.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (578, 1, 'borrowings.returned', 'technician_borrowings', 56, NULL, '47.129.201.108', '2026-09-22 11:43:43.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (579, 1, 'borrowings.returned', 'technician_borrowings', 59, NULL, '47.129.223.0', '2026-09-22 11:43:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (580, 1, 'borrowings.returned', 'technician_borrowings', 58, NULL, '47.129.223.0', '2026-09-22 11:44:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (581, 1, 'borrowings.returned', 'technician_borrowings', 60, NULL, '47.129.201.108', '2026-09-22 11:44:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (582, 1, 'borrowings.returned', 'technician_borrowings', 62, NULL, '13.250.114.58', '2026-09-22 11:44:52.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (583, 1, 'borrowings.returned', 'technician_borrowings', 61, NULL, '13.250.114.58', '2026-09-22 11:45:04.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (584, 1, 'borrowings.lent', 'technician_borrowings', 80, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270075\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (585, 1, 'borrowings.lent', 'technician_borrowings', 71, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB21440\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (586, 1, 'borrowings.lent', 'technician_borrowings', 75, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4UMNX0NB04296\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (587, 1, 'borrowings.lent', 'technician_borrowings', 72, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YFNE0M941487\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (588, 1, 'borrowings.lent', 'technician_borrowings', 74, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA37526\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (589, 1, 'borrowings.lent', 'technician_borrowings', 73, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA28630\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (590, 1, 'borrowings.lent', 'technician_borrowings', 81, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270014\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (591, 1, 'borrowings.lent', 'technician_borrowings', 82, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270081\"}', '13.250.114.58', '2026-09-22 11:53:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (592, 1, 'borrowings.lent', 'technician_borrowings', 77, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270090\"}', '13.250.114.58', '2026-09-22 11:53:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (593, 1, 'borrowings.lent', 'technician_borrowings', 79, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270098\"}', '13.250.114.58', '2026-09-22 11:53:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (594, 1, 'borrowings.lent', 'technician_borrowings', 76, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0N916240\"}', '13.250.114.58', '2026-09-22 11:53:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (595, 1, 'borrowings.lent', 'technician_borrowings', 78, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270017\"}', '13.250.114.58', '2026-09-22 11:53:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (596, 1, 'borrowings.returned', 'technician_borrowings', 70, NULL, '47.129.201.108', '2026-09-22 11:54:28.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (597, 1, 'borrowings.returned', 'technician_borrowings', 69, NULL, '47.129.223.0', '2026-09-22 11:54:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (598, 1, 'borrowings.returned', 'technician_borrowings', 67, NULL, '13.250.114.58', '2026-09-22 11:55:05.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (599, 1, 'borrowings.returned', 'technician_borrowings', 68, NULL, '47.129.223.0', '2026-09-22 11:55:20.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (600, 1, 'borrowings.lent', 'technician_borrowings', 83, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"173107801787\"}', '47.129.201.108', '2026-09-22 12:06:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (601, 1, 'borrowings.lent', 'technician_borrowings', 86, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YBNX0NA33914\"}', '47.129.201.108', '2026-09-22 12:06:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (602, 1, 'borrowings.lent', 'technician_borrowings', 85, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0RB19993\"}', '47.129.201.108', '2026-09-22 12:06:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (603, 1, 'borrowings.lent', 'technician_borrowings', 84, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"UHANC011KD4MOM\"}', '47.129.201.108', '2026-09-22 12:06:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (604, 1, 'borrowings.lent', 'technician_borrowings', 87, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC46931\"}', '47.129.201.108', '2026-09-22 12:06:19.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (605, 1, 'borrowings.returned', 'technician_borrowings', 66, NULL, '47.129.223.0', '2026-09-22 12:06:42.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (606, 1, 'borrowings.returned', 'technician_borrowings', 65, NULL, '13.250.114.58', '2026-09-22 12:06:53.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (607, 1, 'borrowings.returned', 'technician_borrowings', 63, NULL, '13.250.114.58', '2026-09-22 12:07:00.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (608, 1, 'borrowings.returned', 'technician_borrowings', 64, NULL, '47.129.201.108', '2026-09-22 12:07:07.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (609, 1, 'catalog.created', 'storage-specs', 5, NULL, '13.250.114.58', '2026-09-22 12:07:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (610, 1, 'catalog.created', 'storage-specs', 6, NULL, '47.129.223.0', '2026-09-22 12:07:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (611, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"256\",\"spec_id\":\"5\",\"batch_id\":24}', '47.129.201.108', '2026-09-22 12:08:31.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (612, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"256429548211\",\"spec_id\":\"6\",\"batch_id\":25}', '13.250.114.58', '2026-09-22 12:10:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (613, 1, 'borrowings.lent', 'technician_borrowings', 89, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270084\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (614, 1, 'borrowings.lent', 'technician_borrowings', 90, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270039\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (615, 1, 'borrowings.lent', 'technician_borrowings', 93, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"256\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (616, 1, 'borrowings.lent', 'technician_borrowings', 91, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"HMA351S6AFR8N-VK-03\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (617, 1, 'borrowings.lent', 'technician_borrowings', 92, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"256429548211\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (618, 1, 'borrowings.lent', 'technician_borrowings', 88, '{\"technician_id\":\"6\",\"component_type\":\"ram\",\"serial_number\":\"LSK202601270070\"}', '47.129.223.0', '2026-09-22 12:12:10.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (619, 1, 'catalog.created', 'storage-specs', 7, NULL, '13.250.114.58', '2026-09-22 12:16:15.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (620, 1, 'inventory.item_added', 'inventory_storage', NULL, '{\"serial_number\":\"CP133BY5602767\",\"spec_id\":\"7\",\"batch_id\":26}', '47.129.223.0', '2026-09-22 12:17:12.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (621, 1, 'borrowings.lent', 'technician_borrowings', 94, '{\"technician_id\":\"6\",\"component_type\":\"storage\",\"serial_number\":\"CP133BY5602767\"}', '47.129.223.0', '2026-09-22 12:17:40.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (622, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.129.152.12', '2026-09-23 03:51:39.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (623, 1, 'borrowings.lent', 'technician_borrowings', 95, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601571\"}', '47.129.201.108', '2026-09-23 03:53:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (624, 1, 'borrowings.lent', 'technician_borrowings', 96, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601424\"}', '47.129.201.108', '2026-09-23 03:53:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (625, 1, 'borrowings.lent', 'technician_borrowings', 98, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S4YANX0NC47101\"}', '47.129.201.108', '2026-09-23 03:53:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (626, 1, 'borrowings.lent', 'technician_borrowings', 97, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"S/N:21C0160601500\"}', '47.129.201.108', '2026-09-23 03:53:08.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (627, 1, 'inventory.item_added', 'inventory_ops', NULL, '{\"serial_number\":\"2550LK13420HA00198\",\"spec_id\":\"8\",\"batch_id\":27}', '47.129.152.12', '2026-09-23 03:56:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (628, 1, 'inventory.item_added', 'inventory_ram', NULL, '{\"serial_number\":\"21C0160601540\",\"spec_id\":\"1\",\"batch_id\":28}', '47.129.201.108', '2026-09-23 03:59:49.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (629, 1, 'borrowings.returned', 'technician_borrowings', 57, NULL, '13.250.114.58', '2026-09-23 04:01:17.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (630, 1, 'borrowings.lent', 'technician_borrowings', 101, '{\"technician_id\":\"7\",\"component_type\":\"ram\",\"serial_number\":\"21C0160601540\"}', '13.250.114.58', '2026-09-23 04:03:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (631, 1, 'borrowings.lent', 'technician_borrowings', 100, '{\"technician_id\":\"7\",\"component_type\":\"ops\",\"serial_number\":\"2550LK13420HA00198\"}', '13.250.114.58', '2026-09-23 04:03:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (632, 1, 'borrowings.lent', 'technician_borrowings', 99, '{\"technician_id\":\"7\",\"component_type\":\"storage\",\"serial_number\":\"S670NJ0T110126\"}', '13.250.114.58', '2026-09-23 04:03:23.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (633, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.129.201.108', '2026-09-25 09:20:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (634, 1, 'borrowings.returned', 'technician_borrowings', 21, NULL, '13.250.114.58', '2026-09-25 09:21:21.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (635, 1, 'borrowings.returned', 'technician_borrowings', 22, NULL, '13.250.114.58', '2026-09-25 09:21:27.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (636, 1, 'borrowings.returned', 'technician_borrowings', 23, NULL, '47.129.201.108', '2026-09-25 09:21:33.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (637, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.235.132.178', '2026-09-25 09:22:56.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (638, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.235.132.178', '2026-09-26 10:16:44.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (639, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.250.114.58', '2026-09-26 11:40:37.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (640, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '13.235.132.178', '2026-09-26 14:42:32.000');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `entity_type`, `entity_id`, `details`, `ip_address`, `created_at`) VALUES (641, 1, 'auth.login', 'user', 1, '{\"username\":\"Admin\",\"role\":\"admin\"}', '47.129.201.108', '2026-09-26 14:52:59.000');

DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `address` text,
  `district_id` tinyint unsigned NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_clients_district` (`district_id`),
  CONSTRAINT `fk_clients_district` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `clients` (`id`, `name`, `address`, `district_id`, `contact_person`, `phone`, `email`, `created_at`, `updated_at`) VALUES (6, 'Sabaragamuwa University of Sri Lanka', 'Belihuloya', 24, NULL, NULL, NULL, '2026-09-05 22:08:38.000', '2026-09-05 22:08:38.000');
INSERT INTO `clients` (`id`, `name`, `address`, `district_id`, `contact_person`, `phone`, `email`, `created_at`, `updated_at`) VALUES (7, 'University of Jayawardhanapura', NULL, 1, NULL, NULL, NULL, '2026-09-13 20:10:55.000', '2026-09-13 20:10:55.000');
INSERT INTO `clients` (`id`, `name`, `address`, `district_id`, `contact_person`, `phone`, `email`, `created_at`, `updated_at`) VALUES (8, 'ASTP TEC PVT LTD', '49, 1st Cross Street, Jaffna', 10, NULL, NULL, NULL, '2026-09-14 10:16:47.000', '2026-09-14 10:16:47.000');
INSERT INTO `clients` (`id`, `name`, `address`, `district_id`, `contact_person`, `phone`, `email`, `created_at`, `updated_at`) VALUES (9, 'University of Peradeniya', NULL, 4, NULL, NULL, NULL, '2026-09-21 05:51:39.000', '2026-09-21 05:51:39.000');

DROP TABLE IF EXISTS `districts`;
CREATE TABLE `districts` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `province_id` tinyint unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_district_name_province` (`name`,`province_id`),
  KEY `fk_districts_province` (`province_id`),
  CONSTRAINT `fk_districts_province` FOREIGN KEY (`province_id`) REFERENCES `provinces` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (1, 'Colombo', 1, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (2, 'Gampaha', 1, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (3, 'Kalutara', 1, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (4, 'Kandy', 2, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (5, 'Matale', 2, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (6, 'Nuwara Eliya', 2, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (7, 'Galle', 3, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (8, 'Matara', 3, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (9, 'Hambantota', 3, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (10, 'Jaffna', 4, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (11, 'Kilinochchi', 4, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (12, 'Mannar', 4, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (13, 'Mullaitivu', 4, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (14, 'Vavuniya', 4, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (15, 'Batticaloa', 5, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (16, 'Ampara', 5, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (17, 'Trincomalee', 5, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (18, 'Kurunegala', 6, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (19, 'Puttalam', 6, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (20, 'Anuradhapura', 7, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (21, 'Polonnaruwa', 7, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (22, 'Badulla', 8, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (23, 'Monaragala', 8, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (24, 'Ratnapura', 9, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');
INSERT INTO `districts` (`id`, `name`, `province_id`, `created_at`, `updated_at`) VALUES (25, 'Kegalle', 9, '2026-09-13 18:43:57.000', '2026-09-13 18:43:57.000');

DROP TABLE IF EXISTS `flat_panel_models`;
CREATE TABLE `flat_panel_models` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `model_name` varchar(100) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `model_name` (`model_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `inventory_batches`;
CREATE TABLE `inventory_batches` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `batch_type` enum('ops','ram','storage','network_card','flat_panel') NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_by` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_batches_user` (`created_by`),
  CONSTRAINT `fk_batches_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (1, 'storage', NULL, 1, '2026-09-14 06:09:26.000', '2026-09-14 06:09:26.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (2, 'storage', NULL, 1, '2026-09-14 08:37:18.000', '2026-09-14 08:37:18.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (3, 'storage', NULL, 1, '2026-09-14 08:38:11.000', '2026-09-14 08:38:11.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (4, 'storage', NULL, 1, '2026-09-14 08:39:37.000', '2026-09-14 08:39:37.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (6, 'ram', NULL, 1, '2026-09-16 14:14:20.000', '2026-09-16 14:14:20.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (7, 'ram', NULL, 1, '2026-09-16 14:17:05.000', '2026-09-16 14:17:05.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (8, 'ram', NULL, 1, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (9, 'storage', NULL, 1, '2026-09-16 14:59:37.000', '2026-09-16 14:59:37.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (10, 'storage', NULL, 1, '2026-09-16 15:00:07.000', '2026-09-16 15:00:07.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (11, 'ops', NULL, 1, '2026-09-16 19:07:30.000', '2026-09-16 19:07:30.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (13, 'ops', NULL, 1, '2026-09-16 19:35:49.000', '2026-09-16 19:35:49.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (14, 'ops', NULL, 1, '2026-09-16 19:36:22.000', '2026-09-16 19:36:22.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (15, 'ops', NULL, 1, '2026-09-16 19:36:44.000', '2026-09-16 19:36:44.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (16, 'ram', NULL, 1, '2026-09-16 19:38:13.000', '2026-09-16 19:38:13.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (17, 'storage', NULL, 1, '2026-09-16 19:40:12.000', '2026-09-16 19:40:12.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (18, 'ram', NULL, 1, '2026-09-16 19:41:41.000', '2026-09-16 19:41:41.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (19, 'ram', NULL, 1, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (20, 'ram', NULL, 1, '2026-09-21 05:49:12.000', '2026-09-21 05:49:12.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (21, 'ram', NULL, 1, '2026-09-21 06:40:44.000', '2026-09-21 06:40:44.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (22, 'ops', NULL, 1, '2026-09-21 06:46:50.000', '2026-09-21 06:46:50.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (23, 'storage', NULL, 1, '2026-09-21 06:51:44.000', '2026-09-21 06:51:44.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (24, 'storage', NULL, 1, '2026-09-22 12:08:31.000', '2026-09-22 12:08:31.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (25, 'storage', NULL, 1, '2026-09-22 12:10:23.000', '2026-09-22 12:10:23.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (26, 'storage', '425/208', 1, '2026-09-22 12:17:12.000', '2026-09-22 12:17:12.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (27, 'ops', NULL, 1, '2026-09-23 03:56:32.000', '2026-09-23 03:56:32.000');
INSERT INTO `inventory_batches` (`id`, `batch_type`, `description`, `created_by`, `created_at`, `updated_at`) VALUES (28, 'ram', NULL, 1, '2026-09-23 03:59:49.000', '2026-09-23 03:59:49.000');

DROP TABLE IF EXISTS `inventory_flat_panels`;
CREATE TABLE `inventory_flat_panels` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `model_id` int unsigned NOT NULL,
  `status` enum('in_stock','assigned','faulty','retired','reserved','borrowed') NOT NULL DEFAULT 'in_stock',
  `batch_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `fk_flat_panel_batch` (`batch_id`),
  KEY `fk_flat_panel_model` (`model_id`),
  CONSTRAINT `fk_flat_panel_batch` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_flat_panel_model` FOREIGN KEY (`model_id`) REFERENCES `flat_panel_models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `inventory_network_cards`;
CREATE TABLE `inventory_network_cards` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `model_id` int unsigned NOT NULL,
  `status` enum('in_stock','assigned','faulty','retired','reserved','borrowed') NOT NULL DEFAULT 'in_stock',
  `batch_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `fk_netcard_batch` (`batch_id`),
  KEY `fk_netcard_model` (`model_id`),
  KEY `idx_inventory_net_status` (`status`),
  CONSTRAINT `fk_netcard_batch` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_netcard_model` FOREIGN KEY (`model_id`) REFERENCES `network_card_models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `inventory_ops`;
CREATE TABLE `inventory_ops` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `motherboard_serial` varchar(100) NOT NULL,
  `ops_model_id` int unsigned NOT NULL,
  `status` enum('in_stock','assigned','faulty','retired','reserved','borrowed') NOT NULL DEFAULT 'in_stock',
  `batch_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  UNIQUE KEY `motherboard_serial` (`motherboard_serial`),
  KEY `fk_ops_batch` (`batch_id`),
  KEY `fk_ops_model` (`ops_model_id`),
  KEY `idx_inventory_ops_status` (`status`),
  CONSTRAINT `fk_ops_batch` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ops_model` FOREIGN KEY (`ops_model_id`) REFERENCES `ops_models` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (1, '2553LK1334UA0168', 'AL2512160179', 5, 'borrowed', 11, 'Western ', '2026-09-16 19:07:30.000', '2026-09-18 04:30:49.000');
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (2, '2547LK13450HX0083', 'CXD2511180139', 4, 'in_stock', 13, NULL, '2026-09-16 19:35:49.000', '2026-09-25 09:21:27.000');
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (3, '2547LK13450HX0082', 'CXD2511180112', 4, 'in_stock', 14, NULL, '2026-09-16 19:36:22.000', '2026-09-25 09:21:33.000');
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (4, '2549LK14450HX0001', 'CXD2510250395', 6, 'in_stock', 15, NULL, '2026-09-16 19:36:44.000', '2026-09-25 09:21:21.000');
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (5, '2550LK13420HA00037', 'SLX202504190924', 8, 'assigned', 22, NULL, '2026-09-21 06:46:50.000', '2026-09-21 06:47:03.000');
INSERT INTO `inventory_ops` (`id`, `serial_number`, `motherboard_serial`, `ops_model_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (6, '2550LK13420HA00198', 'SX25040600010307', 8, 'borrowed', 27, NULL, '2026-09-23 03:56:32.000', '2026-09-23 04:03:23.000');

DROP TABLE IF EXISTS `inventory_rams`;
CREATE TABLE `inventory_rams` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `ram_spec_id` int unsigned NOT NULL,
  `status` enum('in_stock','assigned','faulty','retired','reserved','borrowed') NOT NULL DEFAULT 'in_stock',
  `batch_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `fk_ram_batch` (`batch_id`),
  KEY `fk_ram_spec` (`ram_spec_id`),
  KEY `idx_inventory_rams_status` (`status`),
  CONSTRAINT `fk_ram_batch` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ram_spec` FOREIGN KEY (`ram_spec_id`) REFERENCES `ram_specs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (4, 'HMA351S6AFR8N-VK-01', 'Hynix', 1, 'assigned', 7, NULL, '2026-09-16 14:17:05.000', '2026-09-21 05:13:50.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (5, 'HMA351S6AFR8N-VK-02', 'Hynix', 1, 'in_stock', 7, NULL, '2026-09-16 14:17:05.000', '2026-09-16 14:17:05.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (6, 'HMA351S6AFR8N-VK-03', 'Hynix', 1, 'borrowed', 7, NULL, '2026-09-16 14:17:05.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (7, 'LSK202601270039', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (8, 'LSK202601270070', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (9, 'LSK202601270084', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (10, 'LSK202601270031', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (11, 'LSK202601270035', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (12, 'LSK202601270060', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-18 04:30:49.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (13, 'LSK202601270210', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:39:49.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (14, 'LSK202601270042', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (15, 'LSK202601270147', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:38:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (16, 'LSK202601270120', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (17, 'LSK202601270146', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-16 14:42:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (18, 'LSK202601270043', 'Unbranded Black -NB', 1, 'assigned', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-17 12:10:03.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (19, 'LSK202601270061', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-18 04:26:11.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (20, 'LSK202601270017', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (21, 'LSK202601270150', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-18 04:26:11.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (22, 'LSK202601270098', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (23, 'LSK202601270013', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:39:14.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (24, 'LSK202601270088', 'Unbranded Black -NB', 1, 'in_stock', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:38:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (25, 'LSK202601270075', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (26, 'LSK202601270090', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (27, 'LSK202601270014', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (28, 'LSK202601270077', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-21 03:39:55.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (29, 'LSK202601270056', 'Unbranded Black -NB', 1, 'borrowed', 8, NULL, '2026-09-16 14:42:20.000', '2026-09-18 04:26:11.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (33, 'HMA82GS6AFR8N-VK-04', 'Hynix', 1, 'borrowed', 16, NULL, '2026-09-16 19:38:13.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (34, 'S/N:21C0160601804', 'Kinsotin', 1, 'borrowed', 18, NULL, '2026-09-16 19:41:41.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (35, 'S/N:21C0160601745', 'Kinsotin', 1, 'borrowed', 18, NULL, '2026-09-16 19:41:41.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (36, 'S/N:21C0160601571', 'Kinsotin', 1, 'borrowed', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-23 03:53:08.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (37, 'S/N:21C0160601518', 'Kinsotin', 1, 'in_stock', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (38, 'S/N:21C0160601531', 'Kinsotin', 1, 'borrowed', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:39:55.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (39, 'S/N:21C0160601500', 'Kinsotin', 1, 'borrowed', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-23 03:53:08.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (40, 'S/N:21C0160601575', 'Kinsotin', 1, 'in_stock', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (41, 'S/N:21C0160601599', 'Kinsotin', 1, 'in_stock', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (42, 'S/N:21C0160601567', 'Kinsotin', 1, 'in_stock', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (43, 'S/N:21C0160601424', 'Kinsotin', 1, 'borrowed', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-23 03:53:08.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (44, 'S/N:21C0160601535', 'Kinsotin', 1, 'in_stock', 19, NULL, '2026-09-21 03:32:38.000', '2026-09-21 03:32:38.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (45, 'LSK202601270081', 'Unbranded Black -NB', 1, 'borrowed', 20, NULL, '2026-09-21 05:49:12.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (46, 'ECN432D2308002740', 'KingBank', 4, 'in_stock', 21, NULL, '2026-09-21 06:40:44.000', '2026-09-21 06:40:44.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (47, 'ECN432D2308002622', 'KingBank', 4, 'assigned', 21, NULL, '2026-09-21 06:40:44.000', '2026-09-21 06:47:15.000');
INSERT INTO `inventory_rams` (`id`, `serial_number`, `brand`, `ram_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (48, '21C0160601540', 'Kinsotin', 1, 'borrowed', 28, NULL, '2026-09-23 03:59:49.000', '2026-09-23 04:03:23.000');

DROP TABLE IF EXISTS `inventory_storage`;
CREATE TABLE `inventory_storage` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `storage_spec_id` int unsigned NOT NULL,
  `status` enum('in_stock','assigned','faulty','retired','reserved','borrowed') NOT NULL DEFAULT 'in_stock',
  `batch_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial_number` (`serial_number`),
  KEY `fk_storage_batch` (`batch_id`),
  KEY `fk_storage_spec` (`storage_spec_id`),
  KEY `idx_inventory_storage_status` (`status`),
  CONSTRAINT `fk_storage_batch` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_storage_spec` FOREIGN KEY (`storage_spec_id`) REFERENCES `storage_specs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (1, 'S4UMNX0NB04296', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (2, 'S670NJ0RB21440', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (3, 'S4YFNE0M941487', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (4, 'S4YBNX0NA37526', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (5, 'S4YBNX0NA28630', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (6, 'S4YBNX0N916240', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 11:53:20.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (7, 'S670NJ0T110126', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-23 04:03:23.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (8, 'S4YBNX0N901720', 'Samsung', 1, 'assigned', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-17 12:11:47.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (9, 'S670NJ0RB19993', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 12:06:19.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (10, 'S4YANF0R415725', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-18 04:26:11.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (11, 'S4YANX0NC47101', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-23 03:53:08.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (12, 'S4YANX0NC46931', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 12:06:19.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (13, 'S4YBNX0NA33914', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-22 12:06:19.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (14, 'S4YBNX0N903111', 'Samsung', 1, 'borrowed', 1, NULL, '2026-09-14 06:09:26.000', '2026-09-18 04:30:49.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (19, 'UHANC011KD4MOM', 'LITE-ON', 2, 'borrowed', 9, NULL, '2026-09-16 14:59:37.000', '2026-09-22 12:06:19.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (20, '173107801787', 'SanDisk', 2, 'borrowed', 10, NULL, '2026-09-16 15:00:07.000', '2026-09-22 12:06:19.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (21, 'S4YANX0NC48716', 'Samsung', 1, 'borrowed', 17, NULL, '2026-09-16 19:40:12.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (22, 'S6VZNJ0R901231', 'Samsung', 1, 'borrowed', 17, NULL, '2026-09-16 19:40:12.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (23, 'S4YBNX0NA12814', 'Samsung', 1, 'borrowed', 17, NULL, '2026-09-16 19:40:12.000', '2026-09-16 19:43:51.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (24, '00521', 'Unbranded', 4, 'in_stock', 23, NULL, '2026-09-21 06:51:44.000', '2026-09-21 06:51:44.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (25, '256', 'Unbraded', 5, 'borrowed', 24, NULL, '2026-09-22 12:08:31.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (26, '256429548211', 'Xriss', 6, 'borrowed', 25, NULL, '2026-09-22 12:10:23.000', '2026-09-22 12:12:10.000');
INSERT INTO `inventory_storage` (`id`, `serial_number`, `brand`, `storage_spec_id`, `status`, `batch_id`, `notes`, `created_at`, `updated_at`) VALUES (27, 'CP133BY5602767', 'Unbranded', 7, 'borrowed', 26, '425 softlogic /208 hub', '2026-09-22 12:17:12.000', '2026-09-22 12:17:40.000');

DROP TABLE IF EXISTS `job_additional_software`;
CREATE TABLE `job_additional_software` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int unsigned NOT NULL,
  `software_id` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_job_add_sw` (`job_id`,`software_id`),
  KEY `fk_job_add_sw_software` (`software_id`),
  CONSTRAINT `fk_job_add_sw_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_job_add_sw_software` FOREIGN KEY (`software_id`) REFERENCES `additional_software_catalog` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `job_main_software_requirements`;
CREATE TABLE `job_main_software_requirements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int unsigned NOT NULL,
  `software_catalog_id` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_job_main_sw` (`job_id`,`software_catalog_id`),
  KEY `fk_job_main_sw_software` (`software_catalog_id`),
  CONSTRAINT `fk_job_main_sw_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_job_main_sw_software` FOREIGN KEY (`software_catalog_id`) REFERENCES `main_software_catalog` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `job_main_software_requirements` (`id`, `job_id`, `software_catalog_id`, `created_at`, `updated_at`) VALUES (1, 1, 2, '2026-09-15 04:16:46.000', '2026-09-15 04:16:46.000');
INSERT INTO `job_main_software_requirements` (`id`, `job_id`, `software_catalog_id`, `created_at`, `updated_at`) VALUES (2, 1, 1, '2026-09-15 04:16:46.000', '2026-09-15 04:16:46.000');
INSERT INTO `job_main_software_requirements` (`id`, `job_id`, `software_catalog_id`, `created_at`, `updated_at`) VALUES (3, 2, 1, '2026-09-21 06:45:25.000', '2026-09-21 06:45:25.000');

DROP TABLE IF EXISTS `job_storage_requirements`;
CREATE TABLE `job_storage_requirements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_id` int unsigned NOT NULL,
  `storage_spec_id` int unsigned NOT NULL,
  `role` enum('primary','secondary','tertiary','additional') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_job_storage_role` (`job_id`,`role`),
  KEY `fk_job_storage_spec` (`storage_spec_id`),
  CONSTRAINT `fk_job_storage_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_job_storage_spec` FOREIGN KEY (`storage_spec_id`) REFERENCES `storage_specs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `job_storage_requirements` (`id`, `job_id`, `storage_spec_id`, `role`, `created_at`, `updated_at`) VALUES (1, 1, 1, 'primary', '2026-09-15 04:16:46.000', '2026-09-15 04:16:46.000');
INSERT INTO `job_storage_requirements` (`id`, `job_id`, `storage_spec_id`, `role`, `created_at`, `updated_at`) VALUES (2, 2, 4, 'primary', '2026-09-21 06:45:25.000', '2026-09-21 06:45:25.000');

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `job_number` varchar(50) NOT NULL,
  `job_type` enum('smartboard','ops','both') NOT NULL DEFAULT 'both',
  `client_id` int unsigned NOT NULL,
  `district_id` tinyint unsigned NOT NULL,
  `smartboard_model_id` int unsigned DEFAULT NULL,
  `smartboard_count` int unsigned NOT NULL DEFAULT '1',
  `ops_model_id` int unsigned DEFAULT NULL,
  `ram_ddr_version` varchar(10) DEFAULT NULL,
  `ram_capacity_gb` smallint unsigned DEFAULT NULL,
  `required_date` date DEFAULT NULL,
  `status` enum('created','assembly_in_progress','ready_for_delivery','completed','cancelled') NOT NULL DEFAULT 'created',
  `created_by` int unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_number` (`job_number`),
  KEY `fk_jobs_smartboard` (`smartboard_model_id`),
  KEY `fk_jobs_ops_model` (`ops_model_id`),
  KEY `fk_jobs_created_by` (`created_by`),
  KEY `idx_jobs_client_date` (`client_id`,`created_at`),
  KEY `idx_jobs_district_date` (`district_id`,`created_at`),
  CONSTRAINT `fk_jobs_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `fk_jobs_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_jobs_district` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`),
  CONSTRAINT `fk_jobs_ops_model` FOREIGN KEY (`ops_model_id`) REFERENCES `ops_models` (`id`),
  CONSTRAINT `fk_jobs_smartboard` FOREIGN KEY (`smartboard_model_id`) REFERENCES `smartboard_models` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `jobs` (`id`, `job_number`, `job_type`, `client_id`, `district_id`, `smartboard_model_id`, `smartboard_count`, `ops_model_id`, `ram_ddr_version`, `ram_capacity_gb`, `required_date`, `status`, `created_by`, `created_at`, `updated_at`) VALUES (1, 'JOB-2026-0001', 'both', 8, 10, 9, 2, 4, 'DDR4', 8, '2026-09-16 00:00:00.000', 'created', 1, '2026-09-15 04:16:46.000', '2026-09-15 04:16:46.000');
INSERT INTO `jobs` (`id`, `job_number`, `job_type`, `client_id`, `district_id`, `smartboard_model_id`, `smartboard_count`, `ops_model_id`, `ram_ddr_version`, `ram_capacity_gb`, `required_date`, `status`, `created_by`, `created_at`, `updated_at`) VALUES (2, 'JOB-2026-0002', 'ops', 9, 4, NULL, 0, 8, 'DDR4', 16, '2026-09-22 00:00:00.000', 'assembly_in_progress', 1, '2026-09-21 06:45:25.000', '2026-09-21 06:47:03.000');

DROP TABLE IF EXISTS `main_software_catalog`;
CREATE TABLE `main_software_catalog` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `software_type` enum('windows','office','iq_whiteboard','antivirus') NOT NULL,
  `name` varchar(100) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_main_sw` (`software_type`,`name`,`version`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `main_software_catalog` (`id`, `software_type`, `name`, `version`, `description`, `created_at`, `updated_at`) VALUES (1, 'windows', 'MS Office 2024', '2024', NULL, '2026-09-15 04:12:55.000', '2026-09-15 04:13:09.000');
INSERT INTO `main_software_catalog` (`id`, `software_type`, `name`, `version`, `description`, `created_at`, `updated_at`) VALUES (2, 'windows', 'Kaspersky Standard Protection ', NULL, NULL, '2026-09-15 04:15:11.000', '2026-09-16 19:03:15.000');

DROP TABLE IF EXISTS `main_software_keys`;
CREATE TABLE `main_software_keys` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `software_catalog_id` int unsigned NOT NULL,
  `license_key` varchar(255) NOT NULL,
  `license_type` enum('lifetime','subscription') NOT NULL DEFAULT 'lifetime',
  `subscription_start_date` date DEFAULT NULL,
  `subscription_end_date` date DEFAULT NULL,
  `status` enum('purchased','assigned','revoked','expired') NOT NULL DEFAULT 'purchased',
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `license_key` (`license_key`),
  KEY `fk_msw_key_catalog` (`software_catalog_id`),
  CONSTRAINT `fk_msw_key_catalog` FOREIGN KEY (`software_catalog_id`) REFERENCES `main_software_catalog` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `network_card_models`;
CREATE TABLE `network_card_models` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `model_name` varchar(100) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `model_name` (`model_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `ops_models`;
CREATE TABLE `ops_models` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `model_name` varchar(100) NOT NULL,
  `processor_series` varchar(30) NOT NULL,
  `processor_core` varchar(20) NOT NULL,
  `processor_count` tinyint unsigned DEFAULT NULL,
  `base_speed_ghz` decimal(4,2) DEFAULT NULL,
  `cache_mb` decimal(5,1) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `model_name` (`model_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `ops_models` (`id`, `model_name`, `processor_series`, `processor_core`, `processor_count`, `base_speed_ghz`, `cache_mb`, `description`, `created_at`, `updated_at`) VALUES (4, 'OPS 13450HX', 'i5', 'i5-13450HX', 10, '2.60', '20.0', NULL, '2026-09-14 10:31:00.000', '2026-09-14 10:31:00.000');
INSERT INTO `ops_models` (`id`, `model_name`, `processor_series`, `processor_core`, `processor_count`, `base_speed_ghz`, `cache_mb`, `description`, `created_at`, `updated_at`) VALUES (5, 'OPS 1334U', 'i5', 'i5-1334U', 10, '1.30', '12.0', NULL, '2026-09-16 19:04:54.000', '2026-09-16 19:04:54.000');
INSERT INTO `ops_models` (`id`, `model_name`, `processor_series`, `processor_core`, `processor_count`, `base_speed_ghz`, `cache_mb`, `description`, `created_at`, `updated_at`) VALUES (6, 'OPS 14450HX', 'i5', 'i5-14450HX', 10, '2.40', '20.0', NULL, '2026-09-16 19:35:04.000', '2026-09-16 19:35:04.000');
INSERT INTO `ops_models` (`id`, `model_name`, `processor_series`, `processor_core`, `processor_count`, `base_speed_ghz`, `cache_mb`, `description`, `created_at`, `updated_at`) VALUES (8, 'OPS 13420H', 'i5', 'i5-13420H', 4, '1.20', '12.0', NULL, '2026-09-21 06:39:29.000', '2026-09-21 06:39:29.000');

DROP TABLE IF EXISTS `ops_replacements`;
CREATE TABLE `ops_replacements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `original_assembled_unit_id` int unsigned NOT NULL,
  `replacement_ops_inventory_id` int unsigned NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `assigned_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `returned_at` datetime DEFAULT NULL,
  `status` enum('assigned','returned','permanent') NOT NULL DEFAULT 'assigned',
  `technician_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_ops_repl_unit` (`original_assembled_unit_id`),
  KEY `fk_ops_repl_ops` (`replacement_ops_inventory_id`),
  KEY `fk_ops_repl_tech` (`technician_id`),
  CONSTRAINT `fk_ops_repl_ops` FOREIGN KEY (`replacement_ops_inventory_id`) REFERENCES `inventory_ops` (`id`),
  CONSTRAINT `fk_ops_repl_tech` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ops_repl_unit` FOREIGN KEY (`original_assembled_unit_id`) REFERENCES `assembled_units` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `provinces`;
CREATE TABLE `provinces` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (1, 'Western', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (2, 'Central', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (3, 'Southern', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (4, 'Northern', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (5, 'Eastern', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (6, 'North Western', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (7, 'North Central', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (8, 'Uva', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');
INSERT INTO `provinces` (`id`, `name`, `created_at`, `updated_at`) VALUES (9, 'Sabaragamuwa', '2026-09-13 18:43:56.000', '2026-09-13 18:43:56.000');

DROP TABLE IF EXISTS `ram_specs`;
CREATE TABLE `ram_specs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ddr_version` varchar(10) NOT NULL,
  `capacity_gb` smallint unsigned NOT NULL,
  `bus_speed_mhz` int DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ram_spec` (`ddr_version`,`capacity_gb`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `ram_specs` (`id`, `ddr_version`, `capacity_gb`, `bus_speed_mhz`, `description`, `created_at`, `updated_at`) VALUES (1, 'DDR4', 8, 2666, NULL, '2026-09-14 05:53:47.000', '2026-09-16 14:08:18.000');
INSERT INTO `ram_specs` (`id`, `ddr_version`, `capacity_gb`, `bus_speed_mhz`, `description`, `created_at`, `updated_at`) VALUES (4, 'DDR4', 16, 3200, NULL, '2026-09-21 06:39:52.000', '2026-09-21 06:39:52.000');

DROP TABLE IF EXISTS `repair_component_replacements`;
CREATE TABLE `repair_component_replacements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `repair_job_id` int unsigned NOT NULL,
  `component_type` enum('ops','ram','storage','wifi_card','flat_panel','software_key') NOT NULL,
  `old_inventory_id` int unsigned DEFAULT NULL COMMENT 'ID in corresponding inventory table or software_keys',
  `new_inventory_id` int unsigned DEFAULT NULL,
  `replacement_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `technician_id` int unsigned DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_rep_replace_job` (`repair_job_id`),
  KEY `fk_rep_replace_tech` (`technician_id`),
  KEY `idx_rep_replace_type` (`component_type`),
  KEY `idx_rep_replace_old` (`old_inventory_id`),
  KEY `idx_rep_replace_new` (`new_inventory_id`),
  CONSTRAINT `fk_rep_replace_job` FOREIGN KEY (`repair_job_id`) REFERENCES `repair_jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rep_replace_tech` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `repair_jobs`;
CREATE TABLE `repair_jobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `repair_number` varchar(50) NOT NULL,
  `assembled_unit_id` int unsigned NOT NULL,
  `client_id` int unsigned NOT NULL,
  `reported_issue` text NOT NULL,
  `status` enum('open','in_progress','completed','closed') NOT NULL DEFAULT 'open',
  `technician_id` int unsigned DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `repair_number` (`repair_number`),
  KEY `fk_repair_unit` (`assembled_unit_id`),
  KEY `fk_repair_client` (`client_id`),
  KEY `fk_repair_technician` (`technician_id`),
  KEY `idx_repair_status_date` (`status`,`created_at`),
  CONSTRAINT `fk_repair_client` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `fk_repair_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_repair_unit` FOREIGN KEY (`assembled_unit_id`) REFERENCES `assembled_units` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `smartboard_models`;
CREATE TABLE `smartboard_models` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `model_name` varchar(100) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `model_name` (`model_name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (2, 'IS - 6518', 'INGSCREEN', NULL, '2026-09-06 16:45:01.000', '2026-09-06 16:45:01.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (3, 'IS - 6516', 'INGSCREEN', NULL, '2026-09-06 16:45:58.000', '2026-09-06 16:45:58.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (4, 'IS - 6512', 'INGSCREEN', NULL, '2026-09-06 16:46:20.000', '2026-09-06 16:46:20.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (5, 'IS - 7518', 'INGSCREEN', NULL, '2026-09-06 16:47:01.000', '2026-09-06 16:47:01.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (7, 'IS - 7516', 'INGSCREEN', NULL, '2026-09-06 16:47:51.000', '2026-09-06 16:47:51.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (8, 'IS - 7512', 'INGSCREEN', NULL, '2026-09-06 16:48:15.000', '2026-09-06 16:48:15.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (9, 'IS - 8518', 'INGSCREEN', NULL, '2026-09-06 16:48:32.000', '2026-09-06 16:48:32.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (10, 'IS - 8516', 'INGSCREEN', NULL, '2026-09-06 16:48:48.000', '2026-09-06 16:48:48.000');
INSERT INTO `smartboard_models` (`id`, `model_name`, `brand`, `description`, `created_at`, `updated_at`) VALUES (11, 'IS - 8512', 'INGSCREEN', NULL, '2026-09-06 16:49:03.000', '2026-09-06 16:49:03.000');

DROP TABLE IF EXISTS `storage_specs`;
CREATE TABLE `storage_specs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `form_factor` varchar(50) NOT NULL,
  `interface` varchar(20) NOT NULL,
  `storage_type` enum('SSD','HDD') NOT NULL,
  `capacity_gb` int unsigned NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_storage_spec` (`form_factor`,`interface`,`storage_type`,`capacity_gb`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (1, 'M.2', 'NVMe', 'SSD', 128, 'Windows 11 + Office24 + IQ', '2026-09-14 05:53:05.000', '2026-09-14 05:53:05.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (2, 'M.2', 'SATA', 'SSD', 128, NULL, '2026-09-16 14:58:43.000', '2026-09-16 14:58:43.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (3, 'M.2', 'SATA', 'SSD', 1024, NULL, '2026-09-21 06:44:01.000', '2026-09-21 06:44:01.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (4, 'M.2', 'SATA', 'SSD', 512, NULL, '2026-09-21 06:44:53.000', '2026-09-21 06:44:53.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (5, 'M.2', 'SATA', 'SSD', 256, NULL, '2026-09-22 12:07:33.000', '2026-09-22 12:07:33.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (6, 'M.2', 'NVMe', 'SSD', 256, NULL, '2026-09-22 12:07:49.000', '2026-09-22 12:07:49.000');
INSERT INTO `storage_specs` (`id`, `form_factor`, `interface`, `storage_type`, `capacity_gb`, `description`, `created_at`, `updated_at`) VALUES (7, 'mSATA', 'SATA', 'SSD', 128, NULL, '2026-09-22 12:16:15.000', '2026-09-22 12:16:15.000');

DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2370 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES (1, 'system_name', 'React EduTech', '2026-09-05 23:04:39.000');
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES (2, 'system_logo_url', 'https://static.cdnlogo.com/logos/r/85/react.svg', '2026-09-05 22:10:33.000');
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES (3, 'primary_color', '#0ea5e9', '2026-09-05 21:59:24.000');
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES (130, 'audit_activity_visibility', '1', '2026-09-13 17:33:21.000');
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES (1379, 'ops_cpu_specs', '{\"processors\":[{\"model\":\"OPS i5-1135G7\",\"generation\":\"11th Gen\",\"series\":\"i5\",\"core\":\"i5-1135G7\",\"cores\":4,\"base_speed_ghz\":2.4,\"cache_mb\":8},{\"model\":\"OPS i7-1185G7\",\"generation\":\"11th Gen\",\"series\":\"i7\",\"core\":\"i7-1185G7\",\"cores\":4,\"base_speed_ghz\":3,\"cache_mb\":12},{\"model\":\"OPS 13450HX\",\"generation\":\"13th Gen\",\"series\":\"i5\",\"core\":\"i5-13450HX\",\"cores\":10,\"base_speed_ghz\":2.6,\"cache_mb\":20},{\"model\":\"OPS 14450HX\",\"generation\":\"14th Gen\",\"series\":\"i5\",\"core\":\"i5-14450HX\",\"cores\":10,\"base_speed_ghz\":2.4,\"cache_mb\":20},{\"model\":\"OPS 1334U\",\"generation\":\"13th Gen\",\"series\":\"i5\",\"core\":\"i5-1334U\",\"cores\":10,\"base_speed_ghz\":1.3,\"cache_mb\":12},{\"model\":\"OPS 13420H\",\"generation\":\"13th Gen\",\"series\":\"i5\",\"core\":\"i5-13420H\",\"cores\":4,\"base_speed_ghz\":1.2,\"cache_mb\":12}]}', '2026-09-21 06:38:45.000');

DROP TABLE IF EXISTS `technician_borrowings`;
CREATE TABLE `technician_borrowings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `technician_id` int unsigned NOT NULL,
  `component_type` enum('ops','ram','storage','network_card','flat_panel') NOT NULL,
  `inventory_id` int unsigned NOT NULL,
  `borrowed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `returned_at` datetime DEFAULT NULL,
  `status` enum('borrowed','returned','consumed') NOT NULL DEFAULT 'borrowed',
  `notes` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_borrowings_status` (`status`),
  KEY `idx_borrowings_tech` (`technician_id`),
  KEY `idx_borrowings_comp` (`component_type`,`inventory_id`),
  CONSTRAINT `fk_borrowings_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (1, 5, 'storage', 1, '2026-09-14 08:41:45.000', '2026-09-14 08:41:53.000', 'returned', NULL, '2026-09-14 08:41:45.000', '2026-09-14 08:41:53.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (2, 6, 'ram', 4, '2026-09-16 15:03:42.000', NULL, 'consumed', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:13:50.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (3, 6, 'ram', 6, '2026-09-16 15:03:42.000', '2026-09-21 05:13:36.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:13:36.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (4, 6, 'ram', 9, '2026-09-16 15:03:42.000', '2026-09-21 05:13:57.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:13:57.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (5, 6, 'ram', 7, '2026-09-16 15:03:42.000', '2026-09-21 05:14:04.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:14:04.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (6, 6, 'ram', 8, '2026-09-16 15:03:42.000', '2026-09-21 05:13:24.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:13:24.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (7, 6, 'storage', 13, '2026-09-16 15:03:42.000', '2026-09-21 05:12:41.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:12:41.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (8, 6, 'storage', 12, '2026-09-16 15:03:42.000', '2026-09-21 05:12:30.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:12:30.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (9, 6, 'storage', 20, '2026-09-16 15:03:42.000', '2026-09-21 05:12:54.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:12:54.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (10, 6, 'storage', 19, '2026-09-16 15:03:42.000', '2026-09-21 05:12:22.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:12:22.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (11, 6, 'storage', 11, '2026-09-16 15:03:42.000', '2026-09-21 05:12:09.000', 'returned', NULL, '2026-09-16 15:03:42.000', '2026-09-21 05:12:09.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (12, 1, 'ram', 21, '2026-09-16 19:24:21.000', '2026-09-18 04:14:58.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:14:58.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (13, 1, 'ram', 22, '2026-09-16 19:24:21.000', '2026-09-18 04:14:40.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:14:40.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (14, 1, 'ram', 18, '2026-09-16 19:24:21.000', NULL, 'consumed', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-17 12:10:03.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (15, 1, 'storage', 9, '2026-09-16 19:24:21.000', '2026-09-18 04:16:01.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:16:01.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (16, 1, 'storage', 8, '2026-09-16 19:24:21.000', NULL, 'consumed', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-17 12:11:47.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (17, 1, 'storage', 10, '2026-09-16 19:24:21.000', '2026-09-18 04:13:59.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:13:59.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (18, 1, 'ops', 1, '2026-09-16 19:24:21.000', '2026-09-18 04:29:15.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:29:15.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (19, 1, 'ram', 12, '2026-09-16 19:24:21.000', '2026-09-18 04:28:53.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:21.000', '2026-09-18 04:28:53.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (20, 1, 'storage', 14, '2026-09-16 19:24:47.000', '2026-09-18 04:29:04.000', 'returned', 'Rathnapura After Service Trip (Gavindu, Rukshan)', '2026-09-16 19:24:47.000', '2026-09-18 04:29:04.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (21, 6, 'ops', 4, '2026-09-16 19:43:51.000', '2026-09-25 09:21:21.000', 'returned', NULL, '2026-09-16 19:43:51.000', '2026-09-25 09:21:21.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (22, 6, 'ops', 2, '2026-09-16 19:43:51.000', '2026-09-25 09:21:27.000', 'returned', NULL, '2026-09-16 19:43:51.000', '2026-09-25 09:21:27.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (23, 6, 'ops', 3, '2026-09-16 19:43:51.000', '2026-09-25 09:21:33.000', 'returned', NULL, '2026-09-16 19:43:51.000', '2026-09-25 09:21:33.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (24, 6, 'ram', 33, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (25, 6, 'ram', 34, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (26, 6, 'ram', 35, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (27, 6, 'storage', 21, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (28, 6, 'storage', 22, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (29, 6, 'storage', 23, '2026-09-16 19:43:51.000', NULL, 'borrowed', NULL, '2026-09-16 19:43:51.000', '2026-09-16 19:43:51.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (30, 5, 'storage', 9, '2026-09-18 04:26:11.000', '2026-09-18 14:24:35.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:24:35.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (31, 5, 'storage', 10, '2026-09-18 04:26:11.000', NULL, 'borrowed', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 04:26:11.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (32, 5, 'storage', 7, '2026-09-18 04:26:11.000', '2026-09-18 14:24:55.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:24:55.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (33, 5, 'storage', 6, '2026-09-18 04:26:11.000', '2026-09-18 14:26:34.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:26:34.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (34, 5, 'storage', 5, '2026-09-18 04:26:11.000', '2026-09-18 14:24:09.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:24:09.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (35, 5, 'storage', 4, '2026-09-18 04:26:11.000', '2026-09-18 14:25:22.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:25:22.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (36, 5, 'ram', 22, '2026-09-18 04:26:11.000', '2026-09-18 14:16:30.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:16:30.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (37, 5, 'ram', 21, '2026-09-18 04:26:11.000', NULL, 'borrowed', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 04:26:11.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (38, 5, 'ram', 29, '2026-09-18 04:26:11.000', NULL, 'borrowed', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 04:26:11.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (39, 5, 'ram', 19, '2026-09-18 04:26:11.000', NULL, 'borrowed', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 04:26:11.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (40, 5, 'ram', 24, '2026-09-18 04:26:11.000', '2026-09-18 14:19:02.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-18 14:19:02.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (41, 5, 'ram', 23, '2026-09-18 04:26:11.000', '2026-09-22 11:39:14.000', 'returned', 'Western Schools (piliyndala,jpura) Madawa, Rukshan', '2026-09-18 04:26:11.000', '2026-09-22 11:39:14.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (42, 5, 'ops', 1, '2026-09-18 04:30:49.000', NULL, 'borrowed', 'Western Schools (Piliyandala, Jpura) Madawa, Rukshan', '2026-09-18 04:30:49.000', '2026-09-18 04:30:49.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (43, 5, 'storage', 14, '2026-09-18 04:30:49.000', NULL, 'borrowed', 'Western Schools (Piliyandala, Jpura) Madawa, Rukshan', '2026-09-18 04:30:49.000', '2026-09-18 04:30:49.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (44, 5, 'ram', 12, '2026-09-18 04:30:49.000', NULL, 'borrowed', 'Western Schools (Piliyandala, Jpura) Madawa, Rukshan', '2026-09-18 04:30:49.000', '2026-09-18 04:30:49.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (45, 7, 'ram', 24, '2026-09-21 03:39:55.000', '2026-09-22 11:38:38.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:38:38.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (46, 7, 'ram', 20, '2026-09-21 03:39:55.000', '2026-09-22 11:39:36.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:39:36.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (47, 7, 'ram', 28, '2026-09-21 03:39:55.000', NULL, 'borrowed', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-21 03:39:55.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (48, 7, 'ram', 13, '2026-09-21 03:39:55.000', '2026-09-22 11:39:49.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:39:49.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (49, 7, 'ram', 15, '2026-09-21 03:39:55.000', '2026-09-22 11:38:20.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:38:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (50, 7, 'ram', 38, '2026-09-21 03:39:55.000', NULL, 'borrowed', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-21 03:39:55.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (51, 7, 'ram', 22, '2026-09-21 03:39:55.000', '2026-09-22 11:39:00.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:39:00.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (52, 7, 'ram', 25, '2026-09-21 03:39:55.000', '2026-09-22 11:38:52.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:38:52.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (53, 7, 'ram', 27, '2026-09-21 03:39:55.000', '2026-09-22 11:40:02.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:40:02.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (54, 7, 'ram', 26, '2026-09-21 03:39:55.000', '2026-09-22 11:38:11.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:38:11.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (55, 7, 'storage', 5, '2026-09-21 03:39:55.000', '2026-09-22 11:43:29.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:43:29.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (56, 7, 'storage', 9, '2026-09-21 03:39:55.000', '2026-09-22 11:43:43.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:43:43.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (57, 7, 'storage', 7, '2026-09-21 03:39:55.000', '2026-09-23 04:01:17.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-23 04:01:17.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (58, 7, 'storage', 4, '2026-09-21 03:39:55.000', '2026-09-22 11:44:08.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:44:08.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (59, 7, 'storage', 6, '2026-09-21 03:39:55.000', '2026-09-22 11:43:56.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:43:56.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (60, 7, 'storage', 3, '2026-09-21 03:39:55.000', '2026-09-22 11:44:37.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:44:37.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (61, 7, 'storage', 2, '2026-09-21 03:39:55.000', '2026-09-22 11:45:04.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:45:04.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (62, 7, 'storage', 1, '2026-09-21 03:39:55.000', '2026-09-22 11:44:52.000', 'returned', 'Homagama 6 Schools Madawa, Rukshan', '2026-09-21 03:39:55.000', '2026-09-22 11:44:52.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (63, 6, 'ram', 9, '2026-09-21 05:18:51.000', '2026-09-22 12:07:00.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 12:07:00.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (64, 6, 'ram', 7, '2026-09-21 05:18:51.000', '2026-09-22 12:07:07.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 12:07:07.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (65, 6, 'ram', 8, '2026-09-21 05:18:51.000', '2026-09-22 12:06:53.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 12:06:53.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (66, 6, 'ram', 6, '2026-09-21 05:18:51.000', '2026-09-22 12:06:42.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 12:06:42.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (67, 6, 'storage', 12, '2026-09-21 05:18:51.000', '2026-09-22 11:55:05.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 11:55:05.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (68, 6, 'storage', 13, '2026-09-21 05:18:51.000', '2026-09-22 11:55:20.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 11:55:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (69, 6, 'storage', 19, '2026-09-21 05:18:51.000', '2026-09-22 11:54:39.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 11:54:39.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (70, 6, 'storage', 20, '2026-09-21 05:18:51.000', '2026-09-22 11:54:28.000', 'returned', 'Opex PVT LTD', '2026-09-21 05:18:51.000', '2026-09-22 11:54:28.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (71, 7, 'storage', 2, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (72, 7, 'storage', 3, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (73, 7, 'storage', 5, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (74, 7, 'storage', 4, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (75, 7, 'storage', 1, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (76, 7, 'storage', 6, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (77, 7, 'ram', 26, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (78, 7, 'ram', 20, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (79, 7, 'ram', 22, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (80, 7, 'ram', 25, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (81, 7, 'ram', 27, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (82, 7, 'ram', 45, '2026-09-22 11:53:20.000', NULL, 'borrowed', 'Horana, Kaluthara Schools', '2026-09-22 11:53:20.000', '2026-09-22 11:53:20.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (83, 6, 'storage', 20, '2026-09-22 12:06:19.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:06:19.000', '2026-09-22 12:06:19.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (84, 6, 'storage', 19, '2026-09-22 12:06:19.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:06:19.000', '2026-09-22 12:06:19.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (85, 6, 'storage', 9, '2026-09-22 12:06:19.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:06:19.000', '2026-09-22 12:06:19.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (86, 6, 'storage', 13, '2026-09-22 12:06:19.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:06:19.000', '2026-09-22 12:06:19.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (87, 6, 'storage', 12, '2026-09-22 12:06:19.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:06:19.000', '2026-09-22 12:06:19.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (88, 6, 'ram', 8, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (89, 6, 'ram', 9, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (90, 6, 'ram', 7, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (91, 6, 'ram', 6, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (92, 6, 'storage', 26, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (93, 6, 'storage', 25, '2026-09-22 12:12:10.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:12:10.000', '2026-09-22 12:12:10.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (94, 6, 'storage', 27, '2026-09-22 12:17:40.000', NULL, 'borrowed', 'Kandy, Kurunegala', '2026-09-22 12:17:40.000', '2026-09-22 12:17:40.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (95, 7, 'ram', 36, '2026-09-23 03:53:08.000', NULL, 'borrowed', 'Kelaniya, Jpura', '2026-09-23 03:53:08.000', '2026-09-23 03:53:08.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (96, 7, 'ram', 43, '2026-09-23 03:53:08.000', NULL, 'borrowed', 'Kelaniya, Jpura', '2026-09-23 03:53:08.000', '2026-09-23 03:53:08.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (97, 7, 'ram', 39, '2026-09-23 03:53:08.000', NULL, 'borrowed', 'Kelaniya, Jpura', '2026-09-23 03:53:08.000', '2026-09-23 03:53:08.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (98, 7, 'storage', 11, '2026-09-23 03:53:08.000', NULL, 'borrowed', 'Kelaniya, Jpura', '2026-09-23 03:53:08.000', '2026-09-23 03:53:08.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (99, 7, 'storage', 7, '2026-09-23 04:03:23.000', NULL, 'borrowed', 'Kelaniya, Japura', '2026-09-23 04:03:23.000', '2026-09-23 04:03:23.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (100, 7, 'ops', 6, '2026-09-23 04:03:23.000', NULL, 'borrowed', 'Kelaniya, Japura', '2026-09-23 04:03:23.000', '2026-09-23 04:03:23.000');
INSERT INTO `technician_borrowings` (`id`, `technician_id`, `component_type`, `inventory_id`, `borrowed_at`, `returned_at`, `status`, `notes`, `created_at`, `updated_at`) VALUES (101, 7, 'ram', 48, '2026-09-23 04:03:23.000', NULL, 'borrowed', 'Kelaniya, Japura', '2026-09-23 04:03:23.000', '2026-09-23 04:03:23.000');

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `role` enum('admin','manager','technician','auditor') NOT NULL DEFAULT 'technician',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (1, 'Admin', '$2a$12$ExIg1gR6A2gam08PKTdxVur5WkgT9OyZ92k9n48Fx.6tAB.uCZo8q', 'Gavindu Gayashan', 'gavindukariyawasam@gmail.com', 'admin', 1, '2026-09-05 21:41:23.000', '2026-09-06 02:31:48.000');
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (2, 'Manager', '$2b$10$ItksteB7O.tH5S845F8PCujwTKvu1nwQHRu4nmJuIcvCiUj5uVhge', 'Manager', 'manager@mail.com', 'manager', 1, '2026-09-06 02:11:29.000', '2026-09-06 02:31:59.000');
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (3, 'auditor', '$2a$12$5D5SZBun7bNlE4Umn4UGpuGAwKOPvJbZAzuUo1wt.fc6cs88e3JDm', 'Auditor', 'gavindukariyawasam@gmai.com', 'auditor', 1, '2026-09-06 02:31:31.000', '2026-09-06 02:31:31.000');
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (5, 'Madhawa', '$2b$10$M9bX1.bWNfwsdxwzevkAWuqaEv7ZJzTi7.XwlyydbiUmeYiVlL/ce', 'Ishan RSKM', 'madhawaishan368@gmail.com', 'manager', 1, '2026-09-06 14:43:29.000', '2026-09-06 14:43:29.000');
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (6, 'Jithma', '$2b$10$XhwU6jKg05kgikvSCPOkGeT0xI//bHipGCtD8CemgD3mJOIpambju', 'Jithma Navodya', NULL, 'technician', 1, '2026-09-16 14:45:21.000', '2026-09-16 14:45:21.000');
INSERT INTO `users` (`id`, `username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`, `updated_at`) VALUES (7, 'Rukshan', '$2b$10$WoSKENuam/T/zwSWCNDQkO8DRn7TrNCj115dz8pnuZXHnOY3w4jru', 'Rukshan Sandeep', NULL, 'technician', 1, '2026-09-21 03:29:11.000', '2026-09-21 03:29:11.000');

SET FOREIGN_KEY_CHECKS=1;
