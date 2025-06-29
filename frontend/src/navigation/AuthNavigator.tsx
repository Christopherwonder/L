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
