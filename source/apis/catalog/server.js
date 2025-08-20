const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

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
  res.json({ status: 'ok', service: 'catalog-api', timestamp: new Date().toISOString() });
});

// Listar todos los productos
app.get('/products', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, price, stock, description, image, created_at FROM products ORDER BY name'
    );
    res.json({
      success: true,
      data: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error al obtener productos:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Obtener producto por ID
app.get('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT id, name, price, stock, description, image, created_at FROM products WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado'
      });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error al obtener producto:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Crear nuevo producto
app.post('/products', async (req, res) => {
  try {
    const { name, price, stock, description, image } = req.body;
    
    if (!name || !price) {
      return res.status(400).json({
        success: false,
        error: 'Nombre y precio son obligatorios'
      });
    }
    
    const result = await pool.query(
      'INSERT INTO products (name, price, stock, description, image) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, price, stock || 0, description || '', image || '']
    );
    
    res.status(201).json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error al crear producto:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Actualizar producto
app.put('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, stock, description, image } = req.body;
    
    const result = await pool.query(
      'UPDATE products SET name = $1, price = $2, stock = $3, description = $4, image = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 RETURNING *',
      [name, price, stock, description, image, id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado'
      });
    }
    
    res.json({
      success: true,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Error al actualizar producto:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

// Eliminar producto
app.delete('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING id', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Producto no encontrado'
      });
    }
    
    res.json({
      success: true,
      message: 'Producto eliminado correctamente'
    });
  } catch (error) {
    console.error('Error al eliminar producto:', error);
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
  console.log(`🚀 Catalog API ejecutándose en puerto ${PORT}`);
  console.log(`📊 Health check disponible en http://localhost:${PORT}/healthz`);
});

// Manejo de cierre graceful
process.on('SIGTERM', () => {
  console.log('🔄 Cerrando Catalog API...');
  pool.end();
  process.exit(0);
});
