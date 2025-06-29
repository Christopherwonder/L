# laundr.me

This is the main repository for the **laundr.me** project, a mobile-first peer-to-peer (P2P) financial transfer platform.

## Getting Started

### Prerequisites

-   Docker and Docker Compose
-   A Codespaces environment (or a local setup with the above tools)
-   Node.js and npm/yarn for frontend development
-   An iOS or Android development environment (Xcode/Android Studio)

### Setup

1.  **Configure Environment**: Populate the root `.env` file with your credentials.
    Refer to `CONFIGURATION_VARS.md` for details.

2.  **Build and Run Backend**:
    ```bash
    docker-compose up --build -d
    ```

3.  **Run the Frontend**:
    -   Navigate to the `frontend` directory: `cd frontend`
    -   Install dependencies: `npm install`
    -   Start the Metro bundler: `npm start`
    -   In a new terminal, run on your simulator: `npm run ios` or `npm run android`
