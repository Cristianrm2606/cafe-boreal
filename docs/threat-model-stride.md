# Threat Model (STRIDE) - Café Boreal S.R.L.

## Fecha: 2025-08-20
## Metodología: STRIDE (Microsoft)

### COMPONENTES DEL SISTEMA
1. **Frontend Web** (futuro)
2. **Nginx Reverse Proxy** (HTTPS)
3. **APIs Microservicios** (Kubernetes)
4. **Módulo Legado** (Apache + PHP)
5. **Base de Datos PostgreSQL**
6. **Kubernetes Cluster**

---

### AMENAZAS IDENTIFICADAS (STRIDE)

#### 1. SPOOFING (Suplantación de Identidad)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| APIs | Suplantación de servicio | Media | Alto | Certificados TLS, autenticación mutua |
| BD | Conexión no autorizada | Media | Crítico | Credenciales seguras, VPN interna |
| Legacy | Acceso no autorizado | Alta | Medio | Autenticación básica, firewall |

#### 2. TAMPERING (Manipulación de Datos)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| BD | Modificación no autorizada | Baja | Crítico | Permisos restrictivos, auditoría |
| APIs | Inyección SQL/NoSQL | Media | Alto | Queries parametrizadas, validación |
| Secrets | Modificación de claves | Baja | Crítico | RBAC K8s, rotación de claves |

#### 3. REPUDIATION (Repudio)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| APIs | Negación de transacciones | Media | Medio | Logs detallados, timestamps |
| BD | Negación de cambios | Baja | Alto | Auditoría de BD, logs inmutables |
| Sistema | Acciones no trazables | Alta | Medio | Centralización de logs (Loki) |

#### 4. INFORMATION DISCLOSURE (Divulgación de Información)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| BD | **Exposición de identidades** | Alta | **CRÍTICO** | **Cifrado AES-256** ✅ |
| APIs | Datos sensibles en logs | Media | Alto | Sanitización de logs |
| Red | Interceptación tráfico | Media | Alto | HTTPS obligatorio ✅ |
| Backups | Acceso no autorizado | Baja | Crítico | Cifrado de backups |

#### 5. DENIAL OF SERVICE (Denegación de Servicio)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| APIs | Sobrecarga de requests | Alta | Medio | Rate limiting, auto-scaling |
| BD | Agotamiento conexiones | Media | Alto | Connection pooling, limits |
| K8s | Agotamiento recursos | Media | Alto | Resource limits ✅ |

#### 6. ELEVATION OF PRIVILEGE (Escalación de Privilegios)

| Componente | Amenaza | Probabilidad | Impacto | Mitigación |
|------------|---------|--------------|---------|------------|
| Containers | Escape de contenedor | Baja | Crítico | Non-root users ✅, seccomp |
| K8s | Acceso no autorizado | Media | Crítico | RBAC, service accounts |
| BD | Privilegios excesivos | Media | Alto | Principio menor privilegio |

---

### MATRIZ DE RIESGO

| Amenaza | Probabilidad | Impacto | Riesgo | Estado |
|---------|--------------|---------|--------|--------|
| Exposición identidades | Alta | Crítico | **ALTO** | ✅ **MITIGADO** |
| Escape contenedor | Baja | Crítico | Medio | ✅ **MITIGADO** |
| Inyección SQL | Media | Alto | Medio | ✅ **MITIGADO** |
| DoS APIs | Alta | Medio | Medio | ⚠️ **PENDIENTE** |
| Interceptación red | Media | Alto | Medio | ✅ **MITIGADO** |

---

### CONTROLES IMPLEMENTADOS ✅

1. **Cifrado de identidades**: AES-256 con clave de 256 bits
2. **Contenedores no-root**: Usuarios dedicados por servicio
3. **HTTPS obligatorio**: Certificados TLS autofirmados
4. **Queries parametrizadas**: PDO en PHP, ORM en APIs
5. **Resource limits**: CPU/Memory en Kubernetes
6. **Secrets management**: Kubernetes secrets
7. **Firewall**: UFW configurado con puertos mínimos

### CONTROLES PENDIENTES ⚠️

1. **Rate limiting** en APIs
2. **Auditoría centralizada** (implementar en Sección 5)
3. **Rotación automática** de claves
4. **IDS/IPS** básico
5. **Backup cifrado** automático

### REVISIÓN

Este threat model será actualizado con cada cambio arquitectónico significativo.
