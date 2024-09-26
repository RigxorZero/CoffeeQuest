# Coffee Quest

Un nuevo proyecto de Flutter para explorar y compartir recetas de café.

## Tabla de Contenidos

1. [Descripción del Proyecto](#descripción-del-proyecto)
2. [Instalación](#instalación)
3. [Uso](#uso)
4. [Requerimientos](#requerimientos)
   - [Requerimientos Funcionales](#requerimientos-funcionales)
   - [Requerimientos No Funcionales](#requerimientos-no-funcionales)
5. [Recursos Adicionales](#recursos-adicionales)
6. [Documentación](#documentación)

---

## Descripción del Proyecto

**Coffee Quest** es una aplicación móvil desarrollada en Flutter que permite a los usuarios descubrir, crear y compartir recetas de café. La aplicación está diseñada para aficionados y baristas que buscan ampliar sus conocimientos sobre técnicas de preparación y experimentar con nuevos sabores.

---

## Instalación

Para instalar y ejecutar este proyecto localmente:

1. Clona el repositorio:
   ```bash
   git clone https://github.com/usuario/coffee_quest.git
2. Navega al directorio del proyecto.
    ```bash
    cd coffe_quest
3. Instala las dependencias:
    ```bash
    flutter pub get
4. Ejecuta la aplicación:
    ```bash
    flutter run

---

## Uso

1. Al abrir la aplicación, encontrarás una lista de recetas de café disponibles.
2. Navega por las distintas recetas, personalízalas según tus preferencias y guarda tus favoritas.
3. Comparte tus creaciones con otros usuarios y califica las recetas que pruebes.

---

## Requerimientos

### Requerimientos Funcionales

1. **Gestión de Recetas de Café:**
   - RF1.1: El usuario debe poder ver una lista de recetas de café disponibles en la aplicación.
   - RF1.2: El usuario debe poder filtrar recetas por técnica de preparación (espresso, pour-over, cold brew, etc.).
   - RF1.3: El usuario debe poder personalizar las recetas, ajustando parámetros como el tipo de grano, tiempo de extracción y cantidad de agua.
   - RF1.4: El usuario debe poder guardar recetas personalizadas en una lista de favoritas.
   - RF1.5: El usuario debe poder compartir sus recetas a través de la aplicación con otros usuarios. (Sin desarrollar)

2. **Guías de Preparación:**
   - RF2.1: La aplicación debe ofrecer guías paso a paso para diferentes tipos de café.
   - RF2.2: Cada guía debe poder ser personalizada según las preferencias del usuario (ej. tiempo de preparación, cantidad de café, tipo de grano).
   - RF2.3: Debe incluirse una sección de sugerencias y mejores prácticas al preparar café según el método seleccionado.

3. **Personalización del Usuario:**
   - RF3.1: El usuario debe poder crear un perfil donde especifique sus preferencias personales (técnica de extracción favorita, nivel de molienda, tipo de grano preferido).
   - RF3.2: Las preferencias del usuario deben influir en las recetas y guías sugeridas dentro de la aplicación.
   - RF3.3: El usuario debe poder actualizar su perfil en cualquier momento.

4. **Comunidad:**
   - RF4.1: Los usuarios deben poder dejar reseñas y calificaciones para cada receta de café.
   - RF4.2: Los usuarios deben poder comentar y discutir sobre recetas en una sección de foro o chat.
   - RF4.3: La aplicación debe tener una funcionalidad de votación donde las recetas mejor calificadas aparezcan en una sección destacada.
  
5. Exploración de Nuevas Recetas:

   - RF6.1: El usuario debe poder buscar recetas nuevas según sus intereses, como ingredientes exóticos o técnicas innovadoras.
   - RF6.2: Debe existir una opción de "receta del día" que muestre preparaciones destacadas o nuevas cada vez que el usuario accede a la aplicación.
   - RF6.3: El usuario debe poder explorar recetas que utilizan equipos específicos (ej. Aeropress, Chemex, etc.).
  
6. Gestión de Productos Relacionados:

   - RF7.1: La aplicación debe mostrar productos relacionados con la preparación del café (ej. molinos, prensas, etc.).
   - RF7.2: Los productos deben estar vinculados a las recetas, facilitando la compra de equipo necesario directamente desde la aplicación.
   - RF7.3: El usuario debe poder recibir sugerencias de productos basados en sus preferencias personales y recetas favoritas.

### Requerimientos No Funcionales

1. **Compatibilidad Multiplataforma:**
   - RNF1.1: La aplicación debe estar disponible para dispositivos móviles, tabletas y computadoras de escritorio.
   - RNF1.2: La interfaz debe adaptarse automáticamente al tamaño de la pantalla del dispositivo.

2. **Rendimiento:**
   - RNF2.1: La aplicación debe cargarse en menos de 3 segundos al iniciar.
   - RNF2.2: Las transiciones entre pantallas y la navegación deben ser fluidas y sin interrupciones.

3. **Seguridad:**
   - RNF3.1: La aplicación debe garantizar la privacidad de los datos del usuario, almacenando sus preferencias y recetas de manera segura.
   - RNF3.2: Los usuarios deben poder eliminar su cuenta y todos los datos relacionados en cualquier momento.

4. **Escalabilidad:**
   - RNF4.1: La aplicación debe poder gestionar grandes cantidades de usuarios y recetas sin afectar el rendimiento.

---

## Recursos Adicionales

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

---

## Documentación

Para obtener más información sobre Flutter, visita la [documentación en línea](https://docs.flutter.dev/), donde encontrarás tutoriales, ejemplos y referencias de API.
