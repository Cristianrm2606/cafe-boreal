const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Configuración de base de datos
const pool = new Pool({
  host: process.env.DB_HOST || 'postgres-service.cafe-boreal.svc.cluster.local',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'cafeboreal',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres123',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Health check
app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', service: 'orders-api', timestamp: new Date().toISOString() });
});

// Listar todos los pedidos
app.get('/orders', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT o.id, o.total, o.status, o.created_at,
             c.name as customer_name, c.email as customer_email
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      ORDER BY o.created_at DESC
    `);
    
    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error al obtener pedidos:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Obtener pedido por ID con items
app.get('/orders/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Obtener pedido
    const orderResult = await pool.query(`
      SELECT o.id, o.total, o.status, o.created_at,
             c.name as customer_name, c.email as customer_email,
             decrypt_identity(c.encrypted_identity, 'CafeBoreal2025SecretKey123456789012') as customer_identity
      FROM orders o
      JOIN customers c ON o.customer_id = c.id
      WHERE o.id = $1
    `, [id]);
    
    if (orderResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Pedido no encontrado'
      });
    }
    
    // Obtener items del pedido
    const itemsResult = await pool.query(`
      SELECT oi.id, oi.quantity, oi.unit_price, oi.subtotal,
             p.name as product_name, p.description as product_description
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = $1
    `, [id]);
    
    const order = orderResult.rows[0];
    order.items = itemsResult.rows;
    
    res.json({
      success: true,
      data: order
    });
  } catch (error) {
    console.error('Error al obtener pedido:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Crear nuevo pedido
app.post('/orders', async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { customer_id, items } = req.body;
    
    if (!customer_id || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'customer_id e items son obligatorios'
      });
    }
    
    // Verificar que el cliente existe
    const customerCheck = await client.query(
      'SELECT id FROM customers WHERE id = $1',
      [customer_id]
    );
    
    if (customerCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        error: 'Cliente no encontrado'
      });
    }
    
    // Calcular total
    let total = 0;
    const orderItems = [];
    
    for (const item of items) {
      const { product_id, quantity } = item;
      
      // Obtener precio del producto
      const productResult = await client.query(
        'SELECT price, stock FROM products WHERE id = $1',
        [product_id]
      );
      
      if (productResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          error: `Producto ${product_id} no encontrado`
        });
      }
      
      const product = productResult.rows[0];
      
      if (product.stock < quantity) {
        await client.query('ROLLBACK');
        return res.status(400).json({
          success: false,
          error: `Stock insuficiente para producto ${product_id}`
        });
      }
      
      const subtotal = parseFloat(product.price) * quantity;
      total += subtotal;
      
      orderItems.push({
        product_id,
        quantity,
        unit_price: product.price,
        subtotal
      });
    }
    
    // Crear pedido
    const orderResult = await client.query(
      'INSERT INTO orders (customer_id, total, status) VALUES ($1, $2, $3) RETURNING *',
      [customer_id, total.toFixed(2), 'pending']
    );
    
    const order = orderResult.rows[0];
    
    // Crear items del pedido y actualizar stock
    for (const item of orderItems) {
      await client.query(
        'INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES ($1, $2, $3, $4, $5)',
        [order.id, item.product_id, item.quantity, item.unit_price, item.subtotal]
      );
      
      // Actualizar stock
      await client.query(
        'UPDATE products SET stock = stock - $1 WHERE id = $2',
        [item.quantity, item.product_id]
      );
    }
    
    await client.query('COMMIT');
    
    res.status(201).json({
      success: true,
      data: {
        ...order,
        items: orderItems
      }
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al crear pedido:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  } finally {
    client.release();
  }
});

// Actualizar estado del pedido
app.put('/orders/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const validStatuses = ['pending', 'processing', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        error: 'Estado inválido. Use: pending, processing, completed, cancelled'
      });
    }
    
    const result = await pool.query(
      'UPDATE orders SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [status, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Pedido no encontrado'
      });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error al actualizar pedido:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Manejo de errores 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint no encontrado'
  });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Orders API ejecutándose en puerto ${PORT}`);
  console.log(`📊 Health check disponible en http://localhost:${PORT}/healthz`);
});

// Manejo de cierre graceful
process.on('SIGTERM', () => {
  console.log('🔄 Cerrando Orders API...');
  pool.end();
  process.exit(0);
});
