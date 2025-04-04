/// This file re-exports all service classes for backward compatibility
/// and to provide a central entry point for API functionality

export 'api_base.dart';
export 'auth_service.dart';
export 'user_service.dart';
export 'journal_service.dart';
export 'profile_service.dart';
export 'ai_service.dart';

/// Legacy API service class
/// @deprecated Use the specific service classes directly instead
class ApiService {
  // This class is kept for backward compatibility
  // Please use the specific service classes directly:
  // - AuthService for authentication
  // - UserService for user management
  // - JournalService for notebooks
  // - ProfileService for profiles
  // - AIService for OpenAI-related calls
}
