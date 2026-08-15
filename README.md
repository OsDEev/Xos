# 🖥️ Xos Operating System

> A modular, lightweight, and user-friendly Graphical Operating System for **ComputerCraft: Tweaked** (Minecraft).

Xos provides an intuitive tabbed GUI, a built-in application ecosystem, network file-sharing utilities, dynamic auto-updating via GitHub API, and full support for both standard Desktop Computers and Pocket Computers.

---

## ✨ Features

* **📱 Multi-Edition Support:**
  * **Xos Standard Edition (`os.lua`)**: Optimized for standard display monitors (51x19).
  * **Xos Mini Edition (`os_mini.lua`)**: Tailored specifically for Pocket Computers (26x20) with compact UI elements.
* **📂 Tabbed & Categorized Desktop:**
  * Organized navigation across **`SYSTEM`**, **`FILES`**, **`PACKAGES`**, and **`ALL APPS`** categories.
  * Smooth mouse-wheel scrolling support (`mouse_scroll`).
* **📦 Pakkugaru Package Manager (`pakkugaru.lua`)**:
  * Easily install external programs directly from GitHub repositories or Pastebin codes via an interactive REPL interface.
* **📁 Built-in App Suite:**
  * **Explorer (`explorer.lua`)**: Navigational file manager to browse, create, edit, and delete files.
  * **Terminal (`terminal.lua`)**: Custom shell with CraftOS command execution.
  * **Settings (`settings.lua`)**: Control desktop color themes, monitor storage, and set your computer label.
  * **Networking (`network.lua`, `localfile.lua`, `download.lua`)**: Host and download files across Rednet wireless networks.
* **🔄 Dynamic Auto-Updater (`update.lua`)**:
  * Automatically fetches the latest repository manifest directly using GitHub API—no hardcoded file lists needed!

---

## 🛠️ Installation Guide

Follow these steps to install Xos on any ComputerCraft terminal or Pocket Computer in Minecraft.

### Option 1: Fast One-Line Installer (Recommended)

Run the automated installer directly from Pastebin:

```bash
pastebin run 8xyB9Ysr
