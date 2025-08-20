const express = require('express');
const path = require('path');
const app = express();
const PORT = 3000;

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'cafe-boreal-frontend' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🌐 Frontend Café Boreal corriendo en puerto ${PORT}`);
});
