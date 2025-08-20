const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3003;

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

// Clave de cifrado desde variable de entorno
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'CafeBoreal2025SecretKey123456789012';

// Health check
app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', service: 'customers-api', timestamp: new Date().toISOString() });
});

// Listar todos los clientes (con identidad descifrada)
app.get('/customers', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, email, 
             decrypt_identity(encrypted_identity, $1) as identity,
             created_at
      FROM customers 
      ORDER BY name
    `, [ENCRYPTION_KEY]);
    
    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error al obtener clientes:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Obtener cliente por ID (con identidad descifrada)
app.get('/customers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT id, name, email, 
             decrypt_identity(encrypted_identity, $1) as identity,
             created_at
      FROM customers 
      WHERE id = $2
    `, [ENCRYPTION_KEY, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Cliente no encontrado'
      });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error al obtener cliente:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Crear nuevo cliente (con identidad cifrada)
app.post('/customers', async (req, res) => {
  try {
    const { name, email, identity } = req.body;
    
    if (!name || !email || !identity) {
      return res.status(400).json({
        success: false,
        error: 'Nombre, email e identidad son obligatorios'
      });
    }
    
    // Validar formato de email básico
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        error: 'Formato de email inválido'
      });
    }
    
    // Cifrar la identidad antes de guardarla
    const result = await pool.query(`
      INSERT INTO customers (name, email, encrypted_identity) 
      VALUES ($1, $2, encrypt_identity($3, $4)) 
      RETURNING id, name, email, created_at
    `, [name, email, identity, ENCRYPTION_KEY]);
    
    // Devolver el cliente con identidad descifrada para mostrar
    const newCustomer = result.rows[0];
    newCustomer.identity = identity; // Mostrar la identidad original
    
    res.status(201).json({
      success: true,
      data: newCustomer
    });
  } catch (error) {
    if (error.code === '23505') { // Error de email duplicado
      res.status(409).json({
        success: false,
        error: 'Email ya está registrado'
      });
    } else {
      console.error('Error al crear cliente:', error);
      res.status(500).json({
        success: false,
        error: 'Error interno del servidor'
      });
    }
  }
});

// Actualizar cliente
app.put('/customers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, identity } = req.body;
    
    // Construir query dinámicamente
    let updateFields = [];
    let values = [];
    let paramCount = 1;
    
    if (name) {
      updateFields.push(`name = $${paramCount}`);
      values.push(name);
      paramCount++;
    }
    
    if (email) {
      updateFields.push(`email = $${paramCount}`);
      values.push(email);
      paramCount++;
    }
    
    if (identity) {
      updateFields.push(`encrypted_identity = encrypt_identity($${paramCount}, $${paramCount + 1})`);
      values.push(identity, ENCRYPTION_KEY);
      paramCount += 2;
    }
    
    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No hay campos para actualizar'
      });
    }
    
    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);
    
    const query = `
      UPDATE customers 
      SET ${updateFields.join(', ')} 
      WHERE id = $${paramCount} 
      RETURNING id, name, email, created_at, updated_at
    `;
    
    const result = await pool.query(query, values);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Cliente no encontrado'
      });
    }
    
    // Obtener la identidad descifrada para la respuesta
    const customerWithIdentity = await pool.query(`
      SELECT id, name, email, 
             decrypt_identity(encrypted_identity, $1) as identity,
             created_at, updated_at
      FROM customers 
      WHERE id = $2
    `, [ENCRYPTION_KEY, id]);
    
    res.json({
      success: true,
      data: customerWithIdentity.rows[0]
    });
  } catch (error) {
    if (error.code === '23505') {
      res.status(409).json({
        success: false,
        error: 'Email ya está registrado'
      });
    } else {
      console.error('Error al actualizar cliente:', error);
      res.status(500).json({
        success: false,
        error: 'Error interno del servidor'
      });
    }
  }
});

// Eliminar cliente
app.delete('/customers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar si el cliente tiene pedidos
    const ordersCheck = await pool.query(
      'SELECT COUNT(*) as order_count FROM orders WHERE customer_id = $1',
      [id]
    );
    
    if (parseInt(ordersCheck.rows[0].order_count) > 0) {
      return res.status(409).json({
        success: false,
        error: 'No se puede eliminar cliente con pedidos existentes'
      });
    }
    
    const result = await pool.query('DELETE FROM customers WHERE id = $1 RETURNING id', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Cliente no encontrado'
      });
    }
    
    res.json({
      success: true,
      message: 'Cliente eliminado correctamente'
    });
  } catch (error) {
    console.error('Error al eliminar cliente:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Obtener pedidos de un cliente
app.get('/customers/:id/orders', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(`
      SELECT o.id, o.total, o.status, o.created_at,
             COUNT(oi.id) as items_count
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.customer_id = $1
      GROUP BY o.id, o.total, o.status, o.created_at
      ORDER BY o.created_at DESC
    `, [id]);
    
    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error al obtener pedidos del cliente:', error);
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
  console.log(`🚀 Customers API ejecutándose en puerto ${PORT}`);
  console.log(`📊 Health check disponible en http://localhost:${PORT}/healthz`);
});

// Manejo de cierre graceful
process.on('SIGTERM', () => {
  console.log('🔄 Cerrando Customers API...');
  pool.end();
  process.exit(0);
});
