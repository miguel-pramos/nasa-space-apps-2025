# Rocket Module Internal Layout Construction

This document outlines the goals for implementing the internal layout construction of each module in the rocket scene.

## Overview

The core idea is to allow players to customize the internal layout of each rocket module. This will be achieved by transitioning the camera from the main rocket view to a dedicated module editing scene. 

## Key Features

### 1. Focused Module Highlight

*   **Goal:** Implement a visual indicator to show which rocket module is currently selected or "focused" on the main rocket scene.
*   **Implementation:** This could be a highlight, an outline, or any other visual cue that clearly distinguishes the selected module from the others.

### 2. Module Editing State and Persistence

*   **Goal:** Create a system to manage the editing state and save the internal layout of each module.
*   **Implementation:**
    *   A variable or a state machine to track which module is currently being edited.
    *   A data structure (e.g., a dictionary or a custom resource) to store the layout information for each module. This data should be saved and loaded with the game state.

### 3. Scene Integration

*   **Goal:** Seamlessly transition between the main rocket scene and the module editing scene.
*   **Implementation:**
    *   When a player chooses to edit a module, the camera will move to a designated area in the main scene.
    *   The specific scene for the selected module will be loaded into this area.
    *   The main UI will be updated to provide the necessary tools for editing the module's internal layout.

### 4. Camera Mechanics

*   **Goal:** Refine the camera movement and rotation mechanics.
*   **Implementation:**
    *   **Rotation:** The current rotation mechanic is not working as expected and needs to be fixed. The camera should have a defined rotation axis, but the user should have the ability to freely rotate and zoom the camera around this axis.
    *   **Positioning:** For the module editing feature, only the camera's position needs to be changed to move to the editing area. The rotation will be controlled by the user.
