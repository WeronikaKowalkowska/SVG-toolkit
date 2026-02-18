# Vector Graphics Suite – Processing Project

## Project Overview

This project was created as part of the **Project Oriented Programming** course assignment.

A graphic design company commissioned the development of a set of applications that enable the creation, editing, and presentation of vector graphics across multiple platforms.

The system consists of three integrated applications:

1.  Desktop Application 
2.  Mobile Application (Android)
3.  Web Application

Each application fulfills a specific role in the vector graphics workflow – from creation and editing to presentation and portfolio display.

---

##  1. Desktop Application

###  Purpose

Provides a graphical user interface for manual vector graphics editing.

### Features

* Drawing vector primitives:

  * Line
  * Rectangle
  * Ellipse
  * Polygon
* Object manipulation:

  * Move
  * Resize
  * Change color
* Object selection
* Editing existing shapes
* Saving and loading projects (SVG format)

###  Technologies

* Processing (Java mode)
* Object-oriented design
* Custom UI components

---

##  2. Mobile Application (Android)

###  Purpose

Enables users to create and edit vector graphics using a touch interface.

### Features

* Drawing primitives using touch gestures
* Editing basic properties:

  * Position
  * Size
  * Color
* Gesture-based interactions
* Exporting and importing graphics (SVG format)

###  Technologies

* Processing for Android / Android SDK
* Touch event handling
* Gesture recognition

---

##  3. Web Application

###  Purpose

Presents the company’s vector graphics portfolio.

### Fatures

* Loading SVG files
* Displaying vector projects
* Interactive project browsing
* Zoom and pan functionality
* Responsive layout

###  Technologies

* HTML
* CSS
* p5.js

---

##  System Architecture

The project follows a modular architecture:

* **Creation Layer** → Desktop & Mobile apps
* **Presentation Layer** → Web app
* **Common Format** → SVG (Scalable Vector Graphics)

All applications support vector-based graphics to ensure:

* Scalability without quality loss
* Cross-platform compatibility
* Easy export and presentation

---

## Project Structure

```
/desktop_app
/mobile_app
/web_app
```

---

##  Project Goals

* Implement vector graphics editing tools
* Apply object-oriented programming principles
* Handle user interaction across different platforms
* Work with SVG format
* Create a consistent multi-platform system

---



