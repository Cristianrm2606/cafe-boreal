-- Limpiar datos existentes
TRUNCATE TABLE order_items, orders, customers, products RESTART IDENTITY CASCADE;

-- Insertar 20 productos de café
INSERT INTO products (name, price, stock, description, image) VALUES
('Café Boreal Clásico', 15.50, 100, 'Mezcla tradicional de granos arábica de las montañas de Costa Rica', 'cafe-clasico.jpg'),
('Espresso Intenso', 18.75, 85, 'Blend robusto perfecto para espresso con notas de chocolate', 'espresso-intenso.jpg'),
('Café Orgánico Premium', 22.00, 60, 'Granos orgánicos certificados de fincas sostenibles', 'organico-premium.jpg'),
('Descafeinado Suave', 16.25, 75, 'Proceso de descafeinado natural manteniendo el sabor original', 'descafeinado-suave.jpg'),
('Tueste Francés', 19.50, 90, 'Tueste oscuro con sabor ahumado y cuerpo completo', 'tueste-frances.jpg'),
('Café de Origen Tarrazú', 25.00, 45, 'Granos exclusivos de la región de Tarrazú, notas frutales', 'tarrazu-origen.jpg'),
('Mezcla de la Casa', 17.75, 120, 'Blend especial de la cafetería con equilibrio perfecto', 'mezcla-casa.jpg'),
('Café Frío Cold Brew', 14.00, 80, 'Concentrado para preparar café frío, suave y refrescante', 'cold-brew.jpg'),
('Granos Enteros Artesanal', 21.50, 55, 'Granos enteros tostados artesanalmente en lotes pequeños', 'artesanal-granos.jpg'),
('Café Molido Tradicional', 13.25, 110, 'Molido medio ideal para cafetera de filtro', 'molido-tradicional.jpg'),
('Espresso Crema', 20.00, 70, 'Blend especial que produce crema dorada perfecta', 'espresso-crema.jpg'),
('Café de Altura', 23.75, 40, 'Granos cultivados a más de 1500 metros de altitud', 'cafe-altura.jpg'),
('Tueste Medio Americano', 16.50, 95, 'Tueste medio balanceado, ideal para el paladar americano', 'tueste-americano.jpg'),
('Café Gourmet Especial', 28.00, 30, 'Edición limitada de granos seleccionados manualmente', 'gourmet-especial.jpg'),
('Café Instantáneo Premium', 12.75, 150, 'Café soluble de alta calidad para preparación rápida', 'instantaneo-premium.jpg'),
('Café con Vainilla', 18.25, 65, 'Mezcla aromatizada naturalmente con esencia de vainilla', 'cafe-vainilla.jpg'),
('Café Tostado Oscuro', 19.75, 85, 'Tueste oscuro con sabor intenso y bajo en acidez', 'tostado-oscuro.jpg'),
('Café Ecológico Fair Trade', 24.50, 50, 'Comercio justo certificado, apoyando a productores locales', 'ecologico-fairtrade.jpg'),
('Café de Exportación', 26.75, 35, 'Calidad de exportación disponible en mercado local', 'cafe-exportacion.jpg'),
('Café Cappuccino Mix', 15.75, 90, 'Mezcla especial para preparar cappuccino perfecto', 'cappuccino-mix.jpg');

-- Insertar 10 clientes con identidades cifradas
-- Usando la clave: 'CafeBoreal2025SecretKey123456789012'
INSERT INTO customers (name, email, encrypted_identity) VALUES
('María González Rodríguez', 'maria.gonzalez@email.com', 
 encrypt_identity('1-0234-0567', 'CafeBoreal2025SecretKey123456789012')),
('Carlos Jiménez Morales', 'carlos.jimenez@email.com', 
 encrypt_identity('2-0345-0678', 'CafeBoreal2025SecretKey123456789012')),
('Ana Sofía Vargas López', 'ana.vargas@email.com', 
 encrypt_identity('1-0456-0789', 'CafeBoreal2025SecretKey123456789012')),
('Roberto Alvarado Castro', 'roberto.alvarado@email.com', 
 encrypt_identity('2-0567-0890', 'CafeBoreal2025SecretKey123456789012')),
('Carmen Elizondo Fernández', 'carmen.elizondo@email.com', 
 encrypt_identity('1-0678-0901', 'CafeBoreal2025SecretKey123456789012')),
('Luis Fernando Quirós Salas', 'luis.quiros@email.com', 
 encrypt_identity('2-0789-0012', 'CafeBoreal2025SecretKey123456789012')),
('Patricia Rojas Herrera', 'patricia.rojas@email.com', 
 encrypt_identity('1-0890-0123', 'CafeBoreal2025SecretKey123456789012')),
('José Manuel Cordero Vega', 'jose.cordero@email.com', 
 encrypt_identity('2-0901-0234', 'CafeBoreal2025SecretKey123456789012')),
('Silvia Marín Chavarría', 'silvia.marin@email.com', 
 encrypt_identity('1-0012-0345', 'CafeBoreal2025SecretKey123456789012')),
('Fernando Castillo Ramírez', 'fernando.castillo@email.com', 
 encrypt_identity('2-0123-0456', 'CafeBoreal2025SecretKey123456789012'));

-- Insertar algunos pedidos de ejemplo
INSERT INTO orders (customer_id, total, status) VALUES
(1, 47.25, 'completed'),
(2, 33.50, 'pending'),
(3, 71.00, 'completed'),
(4, 28.75, 'processing'),
(5, 56.25, 'completed');

-- Insertar items de pedidos
INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES
-- Pedido 1
(1, 1, 2, 15.50, 31.00),
(1, 3, 1, 22.00, 22.00),
-- Pedido 2  
(2, 5, 1, 19.50, 19.50),
(2, 10, 1, 13.25, 13.25),
-- Pedido 3
(3, 14, 2, 28.00, 56.00),
(3, 8, 1, 14.00, 14.00),
-- Pedido 4
(4, 15, 2, 12.75, 25.50),
-- Pedido 5
(5, 12, 1, 23.75, 23.75),
(5, 20, 2, 15.75, 31.50);
