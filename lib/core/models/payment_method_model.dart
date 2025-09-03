import 'package:flutter/material.dart';

enum PaymentMethodType {
  card('card'),
  bankAccount('bank_account'),
  digitalWallet('digital_wallet');

  const PaymentMethodType(this.value);
  final String value;

  static PaymentMethodType fromString(String value) {
    return PaymentMethodType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PaymentMethodType.card,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.bankAccount:
        return 'Bank Account';
      case PaymentMethodType.digitalWallet:
        return 'Digital Wallet';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.bankAccount:
        return Icons.account_balance;
      case PaymentMethodType.digitalWallet:
        return Icons.account_balance_wallet;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethodType.card:
        return Colors.blue;
      case PaymentMethodType.bankAccount:
        return Colors.green;
      case PaymentMethodType.digitalWallet:
        return Colors.purple;
    }
  }
}

enum CardType {
  visa('visa'),
  mastercard('mastercard'),
  verve('verve'),
  americanExpress('american_express');

  const CardType(this.value);
  final String value;

  static CardType fromString(String value) {
    return CardType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CardType.visa,
    );
  }

  String get displayName {
    switch (this) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.verve:
        return 'Verve';
      case CardType.americanExpress:
        return 'American Express';
    }
  }

  Color get color {
    switch (this) {
      case CardType.visa:
        return Colors.blue;
      case CardType.mastercard:
        return Colors.red;
      case CardType.verve:
        return Colors.orange;
      case CardType.americanExpress:
        return Colors.green;
    }
  }
}

enum BankAccountType {
  savings('savings'),
  current('current'),
  domiciliary('domiciliary');

  const BankAccountType(this.value);
  final String value;

  static BankAccountType fromString(String value) {
    return BankAccountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BankAccountType.savings,
    );
  }

  String get displayName {
    switch (this) {
      case BankAccountType.savings:
        return 'Savings';
      case BankAccountType.current:
        return 'Current';
      case BankAccountType.domiciliary:
        return 'Domiciliary';
    }
  }
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String? cardLastFour;
  final CardType? cardType;
  final int? cardExpiryMonth;
  final int? cardExpiryYear;
  final String? cardHolderName;
  final String? bankName;
  final String? bankCode;
  final String? accountNumber;
  final String? accountName;
  final BankAccountType? bankAccountType;
  final String? walletProvider;
  final String? walletId;
  final bool isDefault;
  final bool isActive;
  final bool isVerified;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? metadata;
  final String displayName;
  final String maskedDetails;
  final bool isExpired;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.type,
    this.cardLastFour,
    this.cardType,
    this.cardExpiryMonth,
    this.cardExpiryYear,
    this.cardHolderName,
    this.bankName,
    this.bankCode,
    this.accountNumber,
    this.accountName,
    this.bankAccountType,
    this.walletProvider,
    this.walletId,
    required this.isDefault,
    required this.isActive,
    required this.isVerified,
    this.verifiedAt,
    this.metadata,
    required this.displayName,
    required this.maskedDetails,
    required this.isExpired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: PaymentMethodType.fromString(json['type'] ?? 'card'),
      cardLastFour: json['cardLastFour'],
      cardType: json['cardType'] != null
          ? CardType.fromString(json['cardType'])
          : null,
      cardExpiryMonth: json['cardExpiryMonth'],
      cardExpiryYear: json['cardExpiryYear'],
      cardHolderName: json['cardHolderName'],
      bankName: json['bankName'],
      bankCode: json['bankCode'],
      accountNumber: json['accountNumber'],
      accountName: json['accountName'],
      bankAccountType: json['bankAccountType'] != null
          ? BankAccountType.fromString(json['bankAccountType'])
          : null,
      walletProvider: json['walletProvider'],
      walletId: json['walletId'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      metadata: json['metadata'],
      displayName: json['displayName'] ?? '',
      maskedDetails: json['maskedDetails'] ?? '',
      isExpired: json['isExpired'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'cardLastFour': cardLastFour,
      'cardType': cardType?.value,
      'cardExpiryMonth': cardExpiryMonth,
      'cardExpiryYear': cardExpiryYear,
      'cardHolderName': cardHolderName,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankAccountType': bankAccountType?.value,
      'walletProvider': walletProvider,
      'walletId': walletId,
      'isDefault': isDefault,
      'isActive': isActive,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'metadata': metadata,
      'displayName': displayName,
      'maskedDetails': maskedDetails,
      'isExpired': isExpired,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
