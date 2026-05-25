# Análisis de Seguridad — Self-Hosted Runners

## 1. Riesgos de runners persistentes

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| **Ejecución continua** | El runner está siempre escuchando, exponiendo un vector de ataque permanente | Usar runners efímeros (ephemeral) cuando sea posible |
| **Token de registro** | El token de registro permite asociar un runner al repo; si se expone, un atacante podría registrar runners maliciosos | Rotar tokens periódicamente, no hardcodearlos |
| **Acceso a secretos** | El runner tiene acceso a todos los secretos del repositorio | Usar `secrets` solo en jobs que realmente lo requieran |
| **Persistencia de datos** | El runner acumula datos de builds previos, exponiendo información sensible | Limpiar el workspace después de cada job (`ACTIONS_RUNNER_FORCE_CLEANUP`) |

## 2. Riesgos de acceso a red

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| **Sin restricción de red** | El runner puede alcanzar cualquier recurso interno de la organización | Usar grupos de runners con NSG / firewalls |
| **Exfiltración de datos** | Jobs maliciosos pueden enviar datos fuera de la red corporativa | Implementar proxy de salida con lista blanca de dominios |
| **Acceso a servicios internos** | El runner podría atacar servicios internos (SSRF, pivoting) | Aislar el runner en una VLAN dedicada |
| **IP pública** | Si el runner tiene IP pública, es accesible desde Internet | No exponer el runner directamente; usar NAT saliente |

## 3. Riesgos de aislamiento insuficiente

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| **Contaminación entre jobs** | Jobs de distintos workflows comparten el mismo runner y sistema de archivos | Usar runners efímeros (por job) o contenedores Docker |
| **Escalada de privilegios** | Un job con permisos puede modificar el runner o instalar software malicioso | Ejecutar el runner con el mínimo privilegio necesario |
| **Falta de contenedorización** | Sin contenedores, los jobs tienen acceso completo al host | Usar `runs-on: [self-hosted, linux]` con ejecución en contenedores Docker |
| **Mezcla de entornos** | Desarrollos y producciones compiten por el mismo runner | Usar runners dedicados por entorno (dev / staging / prod) |

## 4. Recomendaciones generales

1. **Ephemeral runners:** Configurar runners como efímeros (`--ephemeral`) para que se destruyan tras cada job
2. **Grupos de runners:** Usar grupos para aislar entornos (desarrollo, staging, producción)
3. **Actualizaciones:** Mantener el sistema operativo y el software del runner actualizados
4. **Monitoreo:** Auditar regularmente los runners registrados y sus actividades
5. **Mínimo privilegio:** El usuario del runner debe tener solo los permisos necesarios
6. **Red aislada:** El runner debe estar en una subred con acceso controlado

```bash
# Ejemplo: registro con configuración segura
./config.sh \
  --url https://github.com/kfabriciocastilloleo-arch/lab5 \
  --token <token> \
  --ephemeral \
  --labels linux,lab5-runner \
  --work _work \
  --disableupdate
```
