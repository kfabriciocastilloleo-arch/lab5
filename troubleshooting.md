# Documento de Troubleshooting — Laboratorio 5

## Resumen

Se identificaron y resolvieron los siguientes problemas provocados en el pipeline híbrido con self-hosted runners.

---

## 1. Label incorrecto

**Problema:**
El job especificaba `runs-on: [self-hosted, wrong-label]` y el runner estaba etiquetado como `lab5-runner`, no como `wrong-label`.

**Síntoma:**
```
No runner matching the specified labels was found:
    self-hosted, wrong-label
```

**Solución:**
Corregir el label en el workflow para que coincida con los labels del runner registrado.

```yaml
# ❌ Incorrecto
runs-on: [self-hosted, wrong-label]

# ✅ Correcto
runs-on: [self-hosted, linux, lab5-runner]
```

**Evidencia:**
- Captura del error "No runner matching the specified labels"
- Captura del label correcto en la configuración del runner

---

## 2. Runner offline

**Problema:**
El runner self-hosted no estaba ejecutándose (servicio detenido o no iniciado).

**Síntoma:**
```
Can't find any runner for job. The job is waiting for a runner to come online.
```

**Solución:**
1. Verificar estado del servicio:
   ```bash
   cd /home/fabri/actions-runner
   ./svc.sh status
   ```
2. Iniciar el runner:
   ```bash
   ./run.sh   # modo interactivo
   # o
   ./svc.sh start   # modo servicio
   ```
3. Verificar conectividad con GitHub:
   ```bash
   ./config.sh --check
   ```

**Evidencia:**
- Captura del job en espera "waiting for a runner"
- Captura del runner online en Settings → Actions → Runners

---

## 3. Dependencia inexistente

**Problema:**
El workflow ejecutaba un comando o script que requería una herramienta no instalada en el runner self-hosted.

**Síntoma:**
```
command not found: some-unknown-command
```

**Solución:**
Instalar la dependencia faltante en el runner o usar una herramienta alternativa:

```bash
# Instalar dependencia
sudo apt-get update && sudo apt-get install -y <paquete>
```

**Evidencia:**
- Captura del error "command not found"
- Captura del paso corregido ejecutándose exitosamente

---

## 4. Path inválido

**Problema:**
El workflow intentaba acceder a un archivo o directorio que no existía en el runner.

**Síntoma:**
```
cat: /ruta/inexistente/archivo.txt: No such file or directory
```

**Solución:**
Verificar que el archivo exista antes de acceder:

```yaml
- name: Verificar path antes de acceder
  run: |
    if [ -f "archivo.txt" ]; then
      cat archivo.txt
    else
      echo "⚠️ Archivo no encontrado, creándolo..."
      echo "contenido" > archivo.txt
    fi
```

**Evidencia:**
- Captura del error de path
- Captura del fix aplicado

---

## 5. Error de permisos

**Problema:**
El runner no tenía permisos suficientes para ejecutar ciertos comandos o acceder a recursos.

**Síntoma:**
```
Permission denied
```

**Solución:**
- Ejecutar el runner con un usuario con permisos adecuados
- Agregar el usuario del runner al grupo correspondiente:
  ```bash
  sudo usermod -aG docker,www-data <runner-user>
  ```
- Ajustar permisos de directorios:
  ```bash
  sudo chown -R <runner-user> /ruta/deploy
  ```

**Evidencia:**
- Captura del error "Permission denied"
- Captura del job exitoso tras corregir permisos

---

## Parte 4 — Logging Detallado

### Activación de logs detallados

Para activar logging detallado en los workflows:

1. **Secretos del repositorio:**
   - `ACTIONS_RUNNER_DEBUG: true`
   - `ACTIONS_STEP_DEBUG: true`

2. **O desde la UI:** Re-ejecutar un job con "Enable debug logging"

### Identificación de fallos

Con logs detallados se puede identificar:

- **Línea exacta** donde falla el script
- **Contexto del runner:** sistema operativo, versión, recursos
- **Variables de entorno** disponibles
- **Salida completa de comandos** (stdout y stderr)

### Información que proporciona el runner

- Estado de conectividad con GitHub
- Versión del runner
- Jobs asignados y su estado
- Errores de configuración
- Logs del servicio (`svc.sh`)

```bash
# Ver logs del servicio runner
journalctl -u actions.runner.* -f

# Ver información de diagnóstico
./config.sh --check
```
