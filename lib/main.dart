import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/services/storage_service.dart';
import 'core/widgets/splash_screen.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/forgot_password_otp_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/guest/presentation/pages/guest_dashboard.dart';
import 'features/services/presentation/pages/service_category_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/change_email_page.dart';
import 'features/profile/presentation/pages/change_phone_page.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
import 'features/profile/presentation/pages/privacy_security_page.dart';
import 'features/profile/presentation/pages/saved_locations_page.dart';
import 'features/profile/presentation/pages/favorite_artisans_page.dart';
import 'features/profile/presentation/pages/payment_methods_page.dart';
import 'features/profile/presentation/pages/add_payment_method_page.dart';
import 'features/support/presentation/pages/faq_help_center_page.dart';
import 'features/support/presentation/pages/contact_support_page.dart';
import 'features/support/presentation/pages/send_feedback_page.dart';
import 'features/app_info/presentation/pages/terms_of_service_page.dart';
import 'features/app_info/presentation/pages/privacy_policy_page.dart';
import 'features/app_info/presentation/pages/about_kaira_page.dart';
import 'features/artisans/presentation/pages/artisan_profile_page.dart';
import 'features/artisans/presentation/pages/all_reviews_page.dart';
import 'features/bookings/presentation/pages/booking_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/home/presentation/pages/notifications_screen.dart';
import 'features/services/presentation/pages/all_services_page.dart';
import 'features/wallet/presentation/pages/wallet_page.dart';
import 'features/home/presentation/pages/map_test_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment is now controlled by AppModeConfig.currentMode
  // To switch modes, edit lib/core/config/app_mode.dart

  // Initialize dependencies
  await configureDependencies();

  // Initialize storage service
  final storageService = getIt<StorageService>();
  await storageService.initialize();

  runApp(const KairaApp());
}

class KairaApp extends StatelessWidget {
  const KairaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaira',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        // Performance optimizations
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/guest-dashboard': (context) => const GuestDashboard(),
        '/service-category': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ServiceCategoryPage(
            categoryName: args['categoryName'],
            categoryIcon: args['categoryIcon'],
            categoryColor: args['categoryColor'],
          );
        },
        '/signup': (context) => const SignUpPage(),
        '/otp-verification': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return OtpVerificationPage(
            signUpData: args['signUpData'],
            phoneNumber: args['phoneNumber'],
            email: args['email'],
          );
        },
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/forgot-password-otp': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ForgotPasswordOtpPage(email: args['email']);
        },
        '/reset-password': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ResetPasswordPage(
            email: args['email'],
            resetToken: args['resetToken'],
          );
        },
        '/profile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProfilePage(userData: args['userData']);
        },
        '/edit-profile': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return EditProfilePage(userData: args?['userData']);
        },
        '/change-email': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ChangeEmailPage(currentEmail: args['currentEmail']);
        },
        '/change-phone': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ChangePhonePage(currentPhone: args['currentPhone']);
        },
        '/change-password': (context) {
          return const ChangePasswordPage();
        },
        '/privacy-security': (context) {
          return const PrivacySecurityPage();
        },
        '/saved-locations': (context) {
          return const SavedLocationsPage();
        },
        '/favorite-artisans': (context) {
          return const FavoriteArtisansPage();
        },
        '/payment-methods': (context) {
          return const PaymentMethodsPage();
        },
        '/add-payment-method': (context) {
          return const AddPaymentMethodPage();
        },
        '/faq-help-center': (context) {
          return const FAQHelpCenterPage();
        },
        '/contact-support': (context) {
          return const ContactSupportPage();
        },
        '/send-feedback': (context) {
          return const SendFeedbackPage();
        },
        '/terms-of-service': (context) {
          return const TermsOfServicePage();
        },
        '/privacy-policy': (context) {
          return const PrivacyPolicyPage();
        },
        '/about-kaira': (context) {
          return const AboutKairaPage();
        },
        '/artisan-profile': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ArtisanProfilePage(artisan: args['artisan']);
        },
        '/all-reviews': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return AllReviewsPage(artisan: args['artisan']);
        },
        '/booking': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BookingPage(artisan: args['artisan']);
        },
        '/chat': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ChatPage(artisan: args['artisan']);
        },
        '/notifications': (context) {
          return const NotificationsScreen();
        },
        '/all-services': (context) {
          return const AllServicesPage();
        },
        '/wallet': (context) {
          return const WalletPage();
        },
        '/map-test': (context) {
          return const MapTestPage();
        },
        '/settings': (context) {
          return const SettingsPage();
        },
      },
    );
  }
}


// SendGrid API key removed for security