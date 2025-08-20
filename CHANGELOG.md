# Changelog

## [v1-Infraestructura] - 2025-08-19

### Added
- Configuración inicial de VM Ubuntu Server 22.04
- Instalación de Docker y Minikube
- Configuración básica de kubectl
- Estructura base de directorios
- Configuración UFW (firewall)
- Repositorio Git inicializado

### Responsables
- Estudiante 1: [Nombre]
- Estudiante 2: [Nombre]

### Alcance
- Infraestructura base lista para despliegue de servicios

## [v2-Datos] - 2025-08-19

### Added
- Esquema de base de datos PostgreSQL con 4 tablas principales
- 20 productos de café con información completa
- 10 clientes con identidades cifradas usando AES-256
- 5 pedidos de ejemplo con items relacionados
- Funciones de cifrado/descifrado para identidades de clientes
- Secret de Kubernetes con clave de cifrado de 256 bits
- Scripts de backup y restore reproducibles
- Política de rotación de claves documentada

### Security
- Implementación de cifrado AES para números de identidad
- Almacenamiento seguro de claves en Kubernetes Secrets
- Funciones SQL para cifrado/descifrado transparente

### Responsables
- Estudiante 1: [Nombre]
- Estudiante 2: [Nombre]

### Alcance
- Base de datos lista con datos cifrados para APIs
- Sistema de backup/restore operativo
