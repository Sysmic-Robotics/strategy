# Plan de Desarrollo STP - Sysmic SSL

## Objetivo
Desarrollar un sistema completo de skills, tactics y plays que permita a Sysmic competir autónomamente en un partido de RoboCup SSL.

---

## 🔧 Día 1 – Desarrollo de Skills Nuevas

### Skills ya funcionales
- move_to ✅
- aim ✅
- capture_ball ✅
- kick_to_point ✅
- intercept ✅
- pass_receiver ✅
- mark ✅

### Skills nuevas a implementar
| Skill                | Descripción                                               | Prioridad |
|----------------------|-----------------------------------------------------------|-----------|
| dribble_to_point     | Conduce la pelota hacia un punto manteniendo el control   | Alta      |
| clear_ball           | Patea lejos si el robot está bajo presión                 | Media     |
| face_ball_while_move | Se mueve manteniéndose orientado hacia la pelota         | Baja      |

---

## 🧠 Día 2 – Desarrollo de Tactics

### Tactics a construir
| Tactic         | Skills utilizadas                                | Descripción                                         |
|----------------|--------------------------------------------------|-----------------------------------------------------|
| defender       | mark, move_to, face_ball_while_move              | Cubre el arco y bloquea tiros rivales               |
| attacker       | capture_ball, aim, kick_to_point                 | Captura y patea al arco                             |
| receiver       | pass_receiver, capture_ball                      | Recibe pases y mantiene posesión                    |
| interceptor    | intercept, aim                                   | Corta trayectorias de pase                          |
| goalkeeper     | move_to, aim, clear_ball                         | Defiende el arco y despeja                          |
| support        | dribble_to_point, capture_ball                   | Se ofrece como opción de pase o apoya la jugada     |

---

## 🎮 Día 3 – Desarrollo de Plays

### Plays a implementar
| Play            | Roles incluidos                                   | Activación                  |
|------------------|--------------------------------------------------|-----------------------------|
| play_attack      | 1 attacker, 1 receiver, 1 support, 3 defenders    | Si se tiene la pelota       |
| play_defend      | 1 goalie, 2 defenders, 1 interceptor, 2 support   | Si el rival tiene la pelota |

---

## 🧠 Día 4 – Coordinación y Lógica de Juego

- Implementación de `play_selector.lua`
- Sistema de detección de posesión (`we_have_ball()`)
- Transición entre plays
- Testeo funcional básico con grSim

---

## 🧪 Día 5 – Pruebas, ajustes y mejora de comportamiento

- Simulación de partidos reales
- Afinación de movimientos y tiempos
- Corrección de errores

---

## 🎯 Día 6 – Evaluación

- Competencia interna o externa con otro equipo
- Evaluación de rendimiento y mejora continua
