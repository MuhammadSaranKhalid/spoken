# Voice Chat App - Blueprint

## Overview

This document outlines the plan and implementation of a voice-based social media application. The app provides anonymous one-on-one voice conversations with a focus on privacy and simplicity. Key features include secure email-based authentication, a modern user interface, and real-time voice chat powered by Agora.

---

## Completed: UI & Authentication

*   **Authentication:**
    *   Implemented a secure sign-up/login flow using Supabase for email authentication and OTP verification.
    *   Created `auth_screen.dart`, `otp_screen.dart`, and a `splash_screen.dart` to handle the user session.
*   **Theming & Assets:**
    *   Established a full theming system in `theme.dart` with support for light and dark modes, custom fonts (`Plus Jakarta Sans`), and a modern color scheme.
    *   Organized all assets and icons.
*   **Navigation:**
    *   Set up a declarative routing system using `go_router`.
*   **UI Flow:**
    *   **Home Screen (`home_screen.dart`):** A polished landing screen where users can initiate a call.
    *   **Ringing Screen (`ringing_screen.dart`):** A visually engaging animated screen that appears while the app is searching for a connection.
    *   **In-Call Screen (`in_call_screen.dart`):** A complete in-call UI with a live timer, controls for mute/speaker, and an end-call button. The screen simulates a connection by automatically transitioning from the ringing screen.

---

## Current Task: Implement Real-Time Voice Chat

### Plan

1.  **Add Dependencies:**
    *   Integrate the `agora_uikit` package to provide the core voice call functionality and UI.
    *   Resolve any dependency conflicts using `dependency_overrides` in `pubspec.yaml`.

2.  **Create Matchmaking Service (`lib/matchmaking_service.dart`):**
    *   Develop a `MatchmakingService` class to handle the logic for connecting users.
    *   Use Supabase Realtime to listen for and create "waiting rooms" or channels.
    *   **Logic:**
        *   When a user presses "Connect," the service will query a `waiting_pool` table in Supabase.
        *   If another user is already waiting, the service will pair them by creating a unique Agora channel name and returning it to both users.
        *   If no one is waiting, the service will add the current user to the `waiting_pool` and listen for a match.

3.  **Integrate Agora into the In-Call Screen (`lib/in_call_screen.dart`):**
    *   Refactor the existing `in_call_screen.dart`.
    *   Replace the placeholder animations with the `AgoraVideoViewer` and `AgoraVideoButtons` widgets from the `agora_uikit` package.
    *   Configure the Agora client with the provided App ID (`314633f82cfd4e85bfbc2b62f0d5a80b`) and the channel name received from the matchmaking service.

4.  **Connect the Full Flow:**
    *   Modify the `home_screen.dart` to call the `MatchmakingService` when the "Connect" button is pressed.
    *   Update the `ringing_screen.dart` to display while the matchmaking is in progress.
    *   On a successful match, navigate to the `in_call_screen.dart`, passing the unique channel name and Agora token.
    *   Ensure the "End Call" button correctly disconnects from the Agora session and returns the user to the home screen.

5.  **Permissions:**
    *   Ensure that the necessary microphone permissions are requested on both Android and iOS.
