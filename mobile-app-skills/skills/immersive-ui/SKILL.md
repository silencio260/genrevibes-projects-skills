# Immersive Borderless UI Skill

## Overview
This skill defines the mandatory implementation pattern for achieving premium, edge-to-edge "borderless" user interfaces in Flutter, as required for the Note AI project. It ensures the application background flows into the status and navigation bar areas without intrusive "dead zones".

## Critical Rules

### 1. No Outer SafeArea
- **DO NOT** use `SafeArea` as a top-level wrapper for your `Scaffold` or main `body`. This creates "dark spots" and "dead zones" that break the immersive experience.
- Instead, allow the `Scaffold` background (usually `Colors.white`) to bleed into the system UI areas.

### 2. Manual Padding via MediaQuery
- To protect interactive content (like titles, buttons, or notches) from being obscured, use **manual padding** using `MediaQuery`:
    - **Header Padding**: `padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top)`
    - **Footer Padding**: `padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)`
- This keeps the UI functional while the background remains 100% immersive.

### 3. AnnotatedRegion Control
- Always wrap the top-level screen in an **`AnnotatedRegion<SystemUiOverlayStyle>`**.
- This ensures the status bar and navigation bar are:
    - **Transparent**: `statusBarColor: Colors.transparent`, `systemNavigationBarColor: Colors.transparent`.
    - **Themed correctly**: Use `statusBarIconBrightness: Brightness.dark` for white backgrounds to ensure system icons (Time, Battery) are visible.

### 4. Scaffold Configuration
- Always set **`extendBody: true`** in your `Scaffold`.
- This tells Flutter to allow the body content to flow behind the bottom navigation bar/system gesture area.

### 5. Preference for Dart-Only Fixes
- Prioritize Flutter/Dart solutions (like those above) for UI immersion.
- Avoid modified native Android/Kotlin code unless the Dart-only approach is technically impossible on a specific platform version.

## Design Goal
The goal is a seamless, modern look where the app and the system UI feel like a single unit. Avoid Any alignment or padding that results in black/grey bars around the screen edges.
