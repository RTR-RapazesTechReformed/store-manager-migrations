INSERT INTO collection (id, name, abbreviation, release_date)
VALUES (UUID(), 'Meruru Base Set', 'MBS', '2025-01-01');

-- 2) Inserir a carta no catálogo
INSERT INTO card (id, title, artist_name, season, collection_id, code, rarity)
VALUES (
  UUID(),
  'Flame Dragon',
  'Akira Toru',
  'S1',
  (SELECT id FROM collection WHERE abbreviation = 'MBS'),
  'MBS-001',
  'rare_holo'
);

-- 3) Criar o produto associado à carta
INSERT INTO product (id, name, description, type, card_id, price, product_condition)
VALUES (
  UUID(),
  'Flame Dragon - Rare Holo',
  'Carta colecionável Flame Dragon edição base',
  'CARD',
  (SELECT id FROM card WHERE code = 'MBS-001' AND collection_id = (SELECT id FROM collection WHERE abbreviation = 'MBS')),
  29.90,
  'mint'
);

-- 4) Inserir quantidade em estoque
INSERT INTO inventory (product_id, quantity)
VALUES (
  (SELECT id FROM product WHERE name = 'Flame Dragon - Rare Holo'),
  20
);

-- 5) (Opcional) Registrar movimento de entrada no histórico
INSERT INTO inventory_movement (id, product_id, user_id, quantity, unit_purchase_price, type, description)
VALUES (
  UUID(),
  (SELECT id FROM product WHERE name = 'Flame Dragon - Rare Holo'),
  '00000000-0000-0000-0000-000000000001', -- ajuste: id de um usuário válido
  20,
  10.00,
  'in',
  'Entrada inicial de estoque'
);

select * from product;

desc product