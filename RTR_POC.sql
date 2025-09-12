-- =====================================================
-- BANCO DE DADOS MERURU TCG - POC SIMPLES
-- =====================================================

 drop database RTR;
CREATE DATABASE IF NOT EXISTS RTR CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_unicode_ci';
USE RTR;

-- =====================================================
-- MERURU TCG DATABASE - SIMPLE POC
-- =====================================================

-- -----------------------------------------------------
-- TABLE: permission
-- Defines available actions in the system.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS permission (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255) NOT NULL,
  
  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: user_role (ATUALIZADA para ID de 3 dígitos)
-- -----------------------------------------------------
DROP TABLE IF EXISTS user_role;
CREATE TABLE IF NOT EXISTS user_role (
  id CHAR(3) PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(100) NOT NULL,
  
  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: role_permission
-- N:N relation between user_role and permission
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS role_permission (
  role_id CHAR(3) NOT NULL,
  permission_id CHAR(36) NOT NULL,
  
  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,
  
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES user_role(id),
  FOREIGN KEY (permission_id) REFERENCES permission(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: user
-- System users.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS user (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  email VARCHAR(200) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id CHAR(36) NOT NULL,

  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,
  
  FOREIGN KEY (role_id) REFERENCES user_role(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: collection
-- Card collections/sets.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS collection (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  abbreviation VARCHAR(50),
  release_date DATE,

  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: card
-- Basic card catalog.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS card (
  id CHAR(36) PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  artist_name VARCHAR(200),
  season VARCHAR(10),
  collection_id CHAR(36) NOT NULL,
  code VARCHAR(10) NOT NULL,
  rarity ENUM(
  'common',
  'uncommon',
  'rare',
  'rare_holo',
  'rare_reverse_holo',
  'rare_holo_ex',
  'rare_holo_gx',
  'rare_holo_v',
  'rare_holo_vmax',
  'rare_holo_vstar',
  'rare_prime',
  'rare_legend',
  'rare_break',
  'rare_ultra',
  'rare_secret',
  'rare_promo'
) NOT NULL DEFAULT 'common',


  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,

  FOREIGN KEY (collection_id) REFERENCES collection(id),
  UNIQUE (code, collection_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: product
-- Generic store products (cards, booster boxes, accessories).
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS product (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500), 
  type ENUM('card', 'booster_box', 'accessory') NOT NULL,
  card_id CHAR(36), 
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  product_condition ENUM(
  'mint',
  'lightly_played',
  'moderately_played',
  'heavily_played',
  'damaged',
  'sealed',
  'opened',
  'used'
  ) NOT NULL DEFAULT 'mint',

  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,

  FOREIGN KEY (card_id) REFERENCES card(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: inventory
-- Current inventory snapshot.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory (
  product_id CHAR(36) PRIMARY KEY,
  quantity INT NOT NULL DEFAULT 0,

  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,

  FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: inventory_movement
-- Inventory change history (in/out/adjust).
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS inventory_movement (
  id CHAR(36) PRIMARY KEY,
  product_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  quantity INT NOT NULL, -- positive = in, negative = out
  unit_purchase_price DECIMAL(10,2) NULL, 
  unit_sale_price DECIMAL(10,2) NULL,
  type ENUM('in','out','adjust') NOT NULL,
  description VARCHAR(255),
	
  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,

  FOREIGN KEY (product_id) REFERENCES product(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: user_session
-- User session
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS user_session (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  active BOOLEAN DEFAULT TRUE,

  FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- TABLE: price_history
-- Historical product prices.
-- -----------------------------------------------------
/*
CREATE TABLE IF NOT EXISTS price_history (
  id CHAR(36) PRIMARY KEY,
  product_id CHAR(36) NOT NULL,
  price DECIMAL(10,2) NOT NULL,

  created_by CHAR(36) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_by CHAR(36) NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP NULL,

  FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
*/

-- =====================================================
-- INSERTS INICIAIS
-- =====================================================

-- ROLES
INSERT INTO user_role (id, name, description) VALUES
('001', 'admin', 'Acesso total ao sistema'),
('002', 'manager', 'Gerencia estoque e relatórios'),
('003', 'staff', 'Cadastro de cartas e vendas');

-- PERMISSIONS
INSERT INTO permission (id, name, description) VALUES
(UUID(), 'card.create', 'Cadastrar novas cartas'),
(UUID(), 'card.update', 'Editar cartas existentes'),
(UUID(), 'card.delete', 'Remover cartas'),
(UUID(), 'inventory.view', 'Visualizar estoque'),
(UUID(), 'inventory.update', 'Alterar quantidades do estoque'),
(UUID(), 'pricing.update', 'Atualizar precificação'),
(UUID(), 'report.view', 'Visualizar dashboards e relatórios'),
(UUID(), 'user.manage', 'Gerenciar usuários e cargos'),
(UUID(), 'order.create', 'Realizar compras'),
(UUID(), 'order.view', 'Visualizar histórico de pedidos');

-- ROLE_PERMISSIONS
-- admin: todas
INSERT INTO role_permission (role_id, permission_id)
SELECT '001', id FROM permission;

-- manager: gestão de cartas, estoque, pricing e relatórios
INSERT INTO role_permission (role_id, permission_id)
SELECT '002', id FROM permission WHERE name IN (
  'card.create','card.update','inventory.view','inventory.update',
  'pricing.update','report.view','order.view'
);

-- staff: cadastro de cartas e pedidos
INSERT INTO role_permission (role_id, permission_id)
SELECT '003', id FROM permission WHERE name IN (
  'card.create','card.update','inventory.view','order.create'
);
