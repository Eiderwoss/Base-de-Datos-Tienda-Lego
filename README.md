# Base-de-Datos-Tienda-Lego
Proyecto de bases de datos semestre sep/ene 2025-2026

## Integrantes:
- Oscar Manrique
- Rolando Rodrigo
- Javier Delmoral
- César Cova

## Estructura del Repositorio

### Ramas
Trabajaremos con 5 ramas principales:
- **main**: La usaremos solo para guardar lo que tengamos por seguro que funciona, será cómo donde estén las versiones de nuestro proyecto.
- **dev**: La usaremos cada que queramos añadir una nueva funcionalidad al frontend, son cambios experimentales. Hasta no estar seguros de que algo funcione no haremos merge con la rama de front.
- **front**: La usaremos para guardar registro de lo que ya funciona del frontend. Esta rama solo se actualiza cuando algo en dev funcione 100%.
- **back**: La usaremos para ir cargando los cambios en el desarrollo del backend.
- **database**: La usaremos para ir cargando y modificando los scripts sql que cargaremos en nuestra BD.

### Commits
Usaremos ciertos prefijos antes de montar un commit que indicarán el propósito de este nuevo cambio en alguna de las ramas:
- **chore**: Son cambios que solo percibimos nosotros como desarrolladores, mover algún archivo, crear una nueva carpeta, etc.
- **feat**: Cualquier nueva funcionalidad que añadamos al sistema. Incluye nuevos artefactos de código, nuevos archivos de código, etc.
- **fix**: Arreglos de código, especialmente de cosas que no funcionaban antes o cuyo desempeño afectan otros pedazos de código.
- **BREAKING CHANGE**: Uso ocasional, se trata de un cambio que puede perjudicar el rendimiento del sistema, cambiar dependencias, arquitectura, etc.

## Herramientas de Desarrollo

### Front
  Usaremos Javascript, CSS y HTML con poca integración de frameworks o librerías poco convencionales.

### Back 
  Usaremos Javascript junto con NEST JS para la creación de una aplicación del lado del servidor.

### Database
  Usaremos la versión gratuita del manejador de base de datos de ORACLE: Oracle Database 23ai. SQL Developer será nuestra aplicación cliente para la copnexión con nuestra BD. (Importante resaltar que esta BD es de uso local y no pretende ser colocada en producción en servidores).
