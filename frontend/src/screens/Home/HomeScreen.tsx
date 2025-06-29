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
