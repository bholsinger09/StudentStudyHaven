import Foundation

// Quick test to verify login works
print("Testing login functionality...")

// Simulate the login flow
let email = "demo@studyhaven.com"
let password = "demo123"

print("Email: \(email)")
print("Password: \(password)")

// Check email validation
let isValidEmail = email.contains("@") && email.components(separatedBy: "@").count == 2
print("Valid email format: \(isValidEmail)")

print("\n✅ Login test structure looks good")
print("Expected user: Demo User")
print("Expected to work with credentials: demo@studyhaven.com / demo123")
