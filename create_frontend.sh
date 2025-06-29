#!/bin/bash
# Filename: create_frontend.sh

echo "Creating frontend directory structure..."
mkdir -p frontend/src/api frontend/src/components/core frontend/src/state frontend/src/navigation frontend/src/screens/Auth frontend/src/screens/Home

echo "Generating all frontend files..."

# --- Filename: frontend/package.json ---
cat << 'EOF' > frontend/package.json
{
  "name": "laundrme", "version": "0.0.1", "private": true,
  "scripts": { "android": "react-native run-android", "ios": "react-native run-ios", "start": "react-native start" },
  "dependencies": {
    "@react-navigation/bottom-tabs": "^6.5.20", "@react-navigation/native": "^6.1.17", "@react-navigation/stack": "^6.3.29",
    "axios": "^1.6.8", "react": "18.2.0", "react-native": "0.74.1", "react-native-dotenv": "^3.4.11",
    "react-native-gesture-handler": "^2.16.2", "react-native-safe-area-context": "^4.10.1", "react-native-screens": "^3.31.1",
    "zustand": "^4.5.2"
  },
  "devDependencies": { "@babel/core": "^7.20.0", "@babel/preset-env": "^7.20.0", "@babel/runtime": "^7.20.0", "@react-native/babel-preset": "0.74.83", "@react-native/eslint-config": "0.74.83", "@react-native/metro-config": "0.74.83", "@react-native/typescript-config": "0.74.83", "@types/react": "^18.2.6", "@types/react-test-renderer": "^18.0.0", "babel-jest": "^29.6.3", "eslint": "^8.19.0", "jest": "^29.6.3", "prettier": "2.8.8", "react-test-renderer": "18.2.0", "typescript": "5.0.4" }
}
EOF

# --- Filename: frontend/babel.config.js ---
cat << 'EOF' > frontend/babel.config.js
module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ["module:react-native-dotenv", { "moduleName": "@env", "path": ".env", "safe": true, "allowUndefined": false }],
    ['module-resolver', { 'root': ['./src'], 'alias': { '@': './src' } }]
  ],
};
EOF

# --- Filename: frontend/tsconfig.json ---
cat << 'EOF' > frontend/tsconfig.json
{ "extends": "@react-native/typescript-config/tsconfig.json" }
EOF

# --- Filename: frontend/index.js ---
cat << 'EOF' > frontend/index.js
import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';
AppRegistry.registerComponent(appName, () => App);
EOF

# --- Filename: frontend/app.json ---
cat << 'EOF' > frontend/app.json
{ "name": "laundrme", "displayName": "laundr.me" }
EOF

# --- Filename: frontend/App.tsx ---
cat << 'EOF' > frontend/App.tsx
import React from 'react';
import { StatusBar } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import AppNavigator from '@/navigation/AppNavigator';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

const App = () => (
  <GestureHandlerRootView style={{ flex: 1 }}>
    <NavigationContainer>
      <StatusBar barStyle="light-content" />
      <AppNavigator />
    </NavigationContainer>
  </GestureHandlerRootView>
);
export default App;
EOF

# --- Filename: frontend/src/api/apiClient.ts ---
cat << 'EOF' > frontend/src/api/apiClient.ts
import axios from 'axios';
import { API_BASE_URL } from '@env';
import { useAuthStore } from '@/state/authStore';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = useAuthStore.getState().token;
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default apiClient;
EOF

# --- Filename: frontend/src/state/authStore.ts ---
cat << 'EOF' > frontend/src/state/authStore.ts
import { create } from 'zustand';

type User = { id: number; username: string; email: string; };
interface AuthState {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;
  setAuth: (token: string, user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  user: null,
  isAuthenticated: false,
  setAuth: (token, user) => set({ token, user, isAuthenticated: true }),
  logout: () => set({ token: null, user: null, isAuthenticated: false }),
}));
EOF

# --- Filename: frontend/src/navigation/AppNavigator.tsx ---
cat << 'EOF' > frontend/src/navigation/AppNavigator.tsx
import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { useAuthStore } from '@/state/authStore';
import MainTabNavigator from './MainTabNavigator';
import AuthNavigator from './AuthNavigator';

const RootStack = createStackNavigator();

const AppNavigator = () => {
  const isAuthenticated = useAuthStore(state => state.isAuthenticated);
  return (
    <RootStack.Navigator screenOptions={{ headerShown: false }}>
      {isAuthenticated ? (
        <RootStack.Screen name="MainApp" component={MainTabNavigator} />
      ) : (
        <RootStack.Screen name="Auth" component={AuthNavigator} />
      )}
    </RootStack.Navigator>
  );
};
export default AppNavigator;
EOF

# --- Filename: frontend/src/navigation/AuthNavigator.tsx ---
cat << 'EOF' > frontend/src/navigation/AuthNavigator.tsx
import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import LoginScreen from '@/screens/Auth/LoginScreen';
import RegisterScreen from '@/screens/Auth/RegisterScreen';

const Stack = createStackNavigator();

const AuthNavigator = () => (
  <Stack.Navigator>
    <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
    <Stack.Screen name="Register" component={RegisterScreen} options={{ title: 'Create Account' }}/>
  </Stack.Navigator>
);
export default AuthNavigator;
EOF

# --- Filename: frontend/src/navigation/MainTabNavigator.tsx ---
cat << 'EOF' > frontend/src/navigation/MainTabNavigator.tsx
import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import HomeScreen from '@/screens/Home/HomeScreen';

const Tab = createBottomTabNavigator();

const MainTabNavigator = () => (
  <Tab.Navigator>
    <Tab.Screen name="Home" component={HomeScreen} />
    {/* Add other tab screens here */}
  </Tab.Navigator>
);
export default MainTabNavigator;
EOF

# --- Filename: frontend/src/screens/Auth/LoginScreen.tsx ---
cat << 'EOF' > frontend/src/screens/Auth/LoginScreen.tsx
import React, { useState } from 'react';
import { View, Text, TextInput, Button, Alert, StyleSheet, TouchableOpacity } from 'react-native';
import { useAuthStore } from '@/state/authStore';
import apiClient from '@/api/apiClient';

const LoginScreen = ({ navigation }: any) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const setAuth = useAuthStore(state => state.setAuth);

    const handleLogin = async () => {
        if (!email || !password) return Alert.alert('Error', 'Please enter email and password.');
        try {
            const response = await apiClient.post('/auth/login', { email, password });
            setAuth(response.data.token, response.data.user);
        } catch (error: any) {
            Alert.alert('Login Failed', error.response?.data?.message || 'An error occurred.');
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.title}>laundr.me</Text>
            <TextInput style={styles.input} placeholder="Email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" />
            <TextInput style={styles.input} placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry />
            <Button title="Log In" onPress={handleLogin} color="#FF0088" />
            <TouchableOpacity onPress={() => navigation.navigate('Register')}>
                <Text style={styles.link}>Don't have an account? Sign Up</Text>
            </TouchableOpacity>
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 20, backgroundColor: '#000' },
    title: { fontSize: 48, fontWeight: '600', color: '#fff', textAlign: 'center', marginBottom: 40 },
    input: { backgroundColor: '#333', color: '#fff', padding: 15, borderRadius: 5, marginBottom: 15 },
    link: { color: '#FF0088', textAlign: 'center', marginTop: 20 }
});

export default LoginScreen;
EOF

# --- Filename: frontend/src/screens/Auth/RegisterScreen.tsx ---
cat << 'EOF' > frontend/src/screens/Auth/RegisterScreen.tsx
import React, { useState } from 'react';
import { View, TextInput, Button, Alert, StyleSheet } from 'react-native';
import apiClient from '@/api/apiClient';

const RegisterScreen = ({ navigation }: any) => {
    const [username, setUsername] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleRegister = async () => {
        if (!username || !email || !password) return Alert.alert('Error', 'Please fill all fields.');
        try {
            await apiClient.post('/auth/register', { username, email, password });
            Alert.alert('Success', 'You have registered successfully!', [{ text: 'OK', onPress: () => navigation.navigate('Login') }]);
        } catch (error: any) {
            Alert.alert('Registration Failed', error.response?.data?.message || 'An error occurred.');
        }
    };

    return (
        <View style={styles.container}>
            <TextInput style={styles.input} placeholder="Username" value={username} onChangeText={setUsername} />
            <TextInput style={styles.input} placeholder="Email" value={email} onChangeText={setEmail} autoCapitalize="none" keyboardType="email-address" />
            <TextInput style={styles.input} placeholder="Password" value={password} onChangeText={setPassword} secureTextEntry />
            <Button title="Register" onPress={handleRegister} color="#FF0088" />
        </View>
    );
};
const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', padding: 20, backgroundColor: '#000' },
    input: { backgroundColor: '#333', color: '#fff', padding: 15, borderRadius: 5, marginBottom: 15 },
});
export default RegisterScreen;
EOF

# --- Filename: frontend/src/screens/Home/HomeScreen.tsx ---
cat << 'EOF' > frontend/src/screens/Home/HomeScreen.tsx
import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { useAuthStore } from '@/state/authStore';

const HomeScreen = () => {
    const { user, logout } = useAuthStore();

    return (
        <View style={styles.container}>
            <Text style={styles.welcome}>Welcome, {user?.username}!</Text>
            <Button title="Logout" onPress={logout} color="#FF0088" />
        </View>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#000' },
    welcome: { color: '#fff', fontSize: 24, marginBottom: 20 }
});

export default HomeScreen;
EOF

echo "Frontend generation complete."
EOF

# --- Make script executable ---
chmod +x create_frontend.sh
echo "create_frontend.sh has been created."

