// schema.prisma
generator client {
  provider = "prisma-client-js"
  binaryTargets = ["native", "debian-openssl-3.0.x"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// =============================================================================
// ENUMS
// =============================================================================

enum KycStatus {
  PENDING
  APPROVED
  REJECTED
  REQUIRES_REVIEW
  EXPIRED
  SUSPENDED
}

enum KycLevel {
  BASIC
  INTERMEDIATE
  ADVANCED
  INSTITUTIONAL
}

enum KycDocumentStatus {
  PENDING
  APPROVED
  REJECTED
  EXPIRED
}

enum DocumentType {
  PASSPORT
  DRIVERS_LICENSE
  NATIONAL_ID
  PROOF_OF_ADDRESS
  SELFIE
  BANK_STATEMENT
  UTILITY_BILL
  BUSINESS_LICENSE
  ARTICLES_OF_INCORPORATION
}

enum WalletType {
  SPOT
  FUTURES
  MARGIN
  SAVINGS
  ISOLATED_MARGIN
}

enum TransactionType {
  DEPOSIT
  WITHDRAWAL
  TRANSFER_IN
  TRANSFER_OUT
  TRADE
  FEE
  COMMISSION
  FUNDING
  LIQUIDATION
  INSURANCE
  REALIZED_PNL
  REFERRAL_REWARD
  STAKING_REWARD
  INTEREST
}

enum TransactionStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  CANCELED
  EXPIRED
  CONFIRMING
  REJECTED
}

enum OrderSide {
  BUY
  SELL
}

enum OrderType {
  MARKET
  LIMIT
  STOP_LOSS
  TAKE_PROFIT
  STOP_LOSS_LIMIT
  TAKE_PROFIT_LIMIT
  LIMIT_MAKER
  TRAILING_STOP_MARKET
}

enum TimeInForce {
  GTC // Good Till Cancel
  IOC // Immediate or Cancel
  FOK // Fill or Kill
}

enum OrderStatus {
  NEW
  PARTIALLY_FILLED
  FILLED
  CANCELED
  REJECTED
  EXPIRED
  PENDING_CANCEL
  PENDING_TRIGGER
}

enum MarketType {
  SPOT
  FUTURES
  MARGIN
}

enum PositionSide {
  LONG
  SHORT
  BOTH
}

enum PositionStatus {
  OPEN
  CLOSED
  LIQUIDATED
}

enum MarginType {
  ISOLATED
  CROSS
}

enum NotificationPriority {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

enum NotificationStatus {
  PENDING
  SENT
  DELIVERED
  FAILED
  READ
}

// =============================================================================
// USER MANAGEMENT
// =============================================================================

model User {
  id                String      @id @default(cuid())
  email             String      @unique
  password          String
  isActive          Boolean     @default(true)
  kycStatus         KycStatus   @default(PENDING)
  twoFactorSecret   String?
  emailVerified     Boolean     @default(false)
  emailVerifiedAt   DateTime?
  lockedAt          DateTime?
  lockReason        String?
  lastLoginAt       DateTime?
  loginAttempts     Int         @default(0)
  createdAt         DateTime    @default(now())
  updatedAt         DateTime    @updatedAt

  // Relations
  profile           UserProfile?
  preferences       UserPreferences?
  wallets           Wallet[]
  orders            Order[]
  positions         Position[]
  apiKeys           ApiKey[]
  activity          UserActivity[]
  securityEvents    SecurityEvent[]
  securityAlerts    SecurityAlert[]
  trustedDevices    TrustedDevice[]
  notifications     Notification[]
  kycDocuments      KycDocument[]
  sessions          UserSession[]
  loginHistory      LoginHistory[]
  emailVerification EmailVerification[]
  passwordReset     PasswordReset[]
  twoFactorSetup    TwoFactorSetup?
  twoFactorBackupCode TwoFactorBackupCode[]

  kycSubmissions    KycSubmission[]
  
  // Buy/Sell trade relations
  buyTrades         Trade[]     @relation("BuyerTrades")
  sellTrades        Trade[]     @relation("SellerTrades")

  // *** NEW: Added for Fee Management ***
  feeTierId         String?     @map("fee_tier_id")
  feeTier           FeeTier?    @relation("UserFeeTier", fields: [feeTierId], references: [id])

  // *** NEW: Added for Referral Program ***
  referralsAsReferrer Referral[]   @relation("Referrer")
  referralsAsReferee  Referral[]   @relation("Referee")
  referralRewards     ReferralReward[]

  // *** NEW: Added for Staking ***
  stakes              Stake[]

  // *** NEW: Added for Funding Payments ***
  fundingPayments     FundingPayment[]

  // *** NEW: Added for Margin Trading ***
  marginAccounts      MarginAccount[]
  marginLoans         MarginLoan[]

  // *** NEW: Added for OTC Trading ***
  otcTrades           OtcTrade[]

  // *** NEW: Added for Webhooks ***
  webhooks            Webhook[]

  // *** NEW: Added for Market Maker Program ***
  marketMakerPrograms MarketMakerProgram[] @relation("MarketMakerParticipants")

  // *** NEW: Added for AML Alerts ***
  amlAlerts           AmlAlert[]

  // *** NEW: Added for Compliance Reports ***
  complianceReports   ComplianceReport[]

  // *** NEW: Added for Fiat Transactions ***
  fiatTransactions    FiatTransaction[]

  // *** NEW: Added for Trading Competitions ***
  tradingCompetitionParticipations TradingCompetitionParticipant[]

  // *** NEW: Added for API Rate Limits ***
  apiRateLimits       ApiRateLimit[]

  @@map("users")
}

model UserProfile {
  id            String    @id @default(cuid())
  userId        String    @unique
  firstName     String?
  lastName      String?
  phone         String?
  country       String?
  dateOfBirth   DateTime?
  address       String?
  city          String?
  state         String?
  postalCode    String?
  avatar        String?
  occupation    String?
  employer      String?
  annualIncome  String?
  sourceOfFunds String?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("user_profiles")
}

model UserPreferences {
  id            String   @id @default(cuid())
  userId        String   @unique
  language      String   @default("en")
  timezone      String   @default("UTC")
  currency      String   @default("USD")
  theme         String   @default("light")
  notifications Json     @default("{}")
  trading       Json     @default("{}")
  security      Json     @default("{}")
  display       Json     @default("{}")
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("user_preferences")
}

model ApiKey {
  id            String   @id @default(cuid())
  userId        String
  name          String
  keyId         String   @unique
  secretHash    String
  permissions   String[]
  ipWhitelist   String[] @default([])
  description   String?
  isActive      Boolean  @default(true)
  lastUsedAt    DateTime?
  expiresAt     DateTime?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // *** NEW: Added for API Rate Limits ***
  apiRateLimits ApiRateLimit[]

  @@map("api_keys")
}

model UserSession {
  id            String   @id @default(cuid())
  userId        String
  sessionToken  String   @unique
  refreshToken  String?  @unique
  deviceId      String?
  deviceName    String?
  userAgent     String?
  ip            String?
  location      Json?
  isActive      Boolean  @default(true)
  lastActiveAt  DateTime @default(now())
  expiresAt     DateTime
  createdAt     DateTime @default(now())
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("user_sessions")
}

// =============================================================================
// SECURITY & ACTIVITY
// =============================================================================

model UserActivity {
  id        String   @id @default(cuid())
  userId    String
  action    String
  details   String?
  ip        String?
  userAgent String?
  timestamp DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, timestamp])
  @@map("user_activities")
}

model SecurityEvent {
  id        String   @id @default(cuid())
  userId    String
  eventType String
  ip        String
  userAgent String
  location  Json?
  details   String?
  timestamp DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, eventType, timestamp])
  @@map("security_events")
}

model SecurityAlert {
  id        String   @id @default(cuid())
  userId    String
  alertType String
  severity  String   // LOW, MEDIUM, HIGH, CRITICAL
  details   String?
  status    String   @default("ACTIVE") // ACTIVE, RESOLVED, DISMISSED
  createdAt DateTime @default(now())
  resolvedAt DateTime?
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("security_alerts")
}

model TrustedDevice {
  id          String   @id @default(cuid())
  userId      String
  deviceId    String
  deviceName  String
  userAgent   String
  ip          String
  location    Json?
  isActive    Boolean  @default(true)
  lastUsedAt  DateTime @default(now())
  createdAt   DateTime @default(now())
  
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([userId, deviceId])
  @@map("trusted_devices")
}

model LoginHistory {
  id        String   @id @default(cuid())
  userId    String
  ip        String
  userAgent String
  location  Json?
  success   Boolean
  reason    String?
  timestamp DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, timestamp])
  @@map("login_history")
}

model EmailVerification {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  used      Boolean  @default(false)
  usedAt    DateTime?
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("email_verifications")
}

model PasswordReset {
  id        String   @id @default(cuid())
  userId    String
  token     String   @unique
  expiresAt DateTime
  used      Boolean  @default(false)
  usedAt    DateTime?
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("password_resets")
}

model TwoFactorSetup {
  id        String   @id @default(cuid())
  userId    String   @unique
  secret    String
  isActive  Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("two_factor_setups")
}

model TwoFactorBackupCode {
  id        String   @id @default(cuid())
  userId    String
  code      String   @unique
  used      Boolean  @default(false)
  usedAt    DateTime?
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("two_factor_backup_codes")
}

model LoginAttempt {
  id          String   @id @default(cuid())
  email       String
  ip          String
  userAgent   String?
  success     Boolean
  failureReason String?
  timestamp   DateTime @default(now())
  
  @@index([email, timestamp])
  @@index([ip, timestamp])
  @@map("login_attempts")
}

model TokenBlacklist {
  id        String   @id @default(cuid())
  jti       String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())
  
  @@index([expiresAt])
  @@map("token_blacklist")
}

// =============================================================================
// WALLET & TRANSACTIONS
// =============================================================================

model Wallet {
  id         String     @id @default(cuid())
  userId     String
  asset      String     // BTC, ETH, USDT
  balance    Decimal    @default(0) @db.Decimal(36, 18)
  locked     Decimal    @default(0) @db.Decimal(36, 18)
  walletType WalletType @default(SPOT)
  address    String?    // Deposit address
  createdAt  DateTime   @default(now())
  updatedAt  DateTime   @updatedAt
  
  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // *** NEW: Added for Asset Metadata ***
  assetRef   Asset?     @relation(fields: [asset], references: [symbol])
  
  @@unique([userId, asset, walletType])
  @@map("wallets")
}

model Transaction {
  id            String            @id @default(cuid())
  userId        String
  type          TransactionType
  asset         String
  amount        Decimal           @db.Decimal(36, 18)
  fee           Decimal?          @db.Decimal(36, 18)
  status        TransactionStatus @default(PENDING)
  walletType    WalletType        @default(SPOT)
  address       String?           // For withdrawals/deposits
  txHash        String?           // Blockchain transaction hash
  memo          String?           // Address memo/tag
  notes         String?
  description   String?
  metadata      Json?
  failureReason String?
  processedAt   DateTime?
  createdAt     DateTime          @default(now())
  updatedAt     DateTime          @updatedAt
  
  user          User              @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // *** NEW: Added for Asset Metadata ***
  assetRef      Asset?            @relation(fields: [asset], references: [symbol])
  
  // *** NEW: Added for AML Alerts ***
  amlAlerts     AmlAlert[]
  
  // *** NEW: Added for Compliance Reports ***
  complianceReports ComplianceReport[]
  
  @@index([userId, type, status])
  @@index([txHash])
  @@map("transactions")
}

// *** NEW: Added for Asset Metadata ***
model Asset {
  id            String   @id @default(cuid())
  symbol        String   @unique // E.g., "BTC", "ETH"
  name          String   // E.g., "Bitcoin", "Ethereum"
  decimals      Int      // Number of decimal places
  network       String?  // E.g., "Bitcoin", "Ethereum", "TRC20"
  contractAddress String? // For ERC20/TRC20 tokens
  isActive      Boolean  @default(true)
  minDeposit    Decimal? @db.Decimal(36, 18)
  minWithdrawal Decimal? @db.Decimal(36, 18)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  wallets       Wallet[]
  transactions  Transaction[]
  
  // *** NEW: Added for Staking ***
  stakingPlans  StakingPlan[]
  
  // *** NEW: Added for OTC Trading ***
  otcTrades     OtcTrade[]        @relation("OtcAsset")
  otcQuoteTrades OtcTrade[]       @relation("OtcQuoteAsset")
  
  @@map("assets")
}

// =============================================================================
// TRADING PAIRS & MARKET DATA
// =============================================================================

model TradingPair {
  id                  String   @id @default(cuid())
  symbol              String   @unique // BTCUSDT
  baseAsset           String   // BTC
  quoteAsset          String   // USDT
  isActive            Boolean  @default(true)
  minQty              Decimal  @db.Decimal(36, 18)
  maxQty              Decimal  @db.Decimal(36, 18)
  stepSize            Decimal  @db.Decimal(36, 18)
  minPrice            Decimal  @db.Decimal(36, 18)
  maxPrice            Decimal  @db.Decimal(36, 18)
  tickSize            Decimal  @db.Decimal(36, 18)
  minNotional         Decimal  @db.Decimal(36, 18)
  allowMarketOrders   Boolean  @default(true)
  allowSpotTrading    Boolean  @default(true)
  allowFuturesTrading Boolean  @default(true)
  createdAt           DateTime @default(now())
  updatedAt           DateTime @updatedAt

  marketType          MarketType
  
  orders              Order[]
  trades              Trade[]
  positions           Position[]
  klines              Kline[]
  
  // *** NEW: Added for Funding Rate ***
  fundingRates        FundingRate[]
  
  // *** NEW: Added for Order Book ***
  orderBookEntries    OrderBookEntry[]
  
  @@map("trading_pairs")
}

model Kline {
  id         String   @id @default(cuid())
  symbol     String
  interval   String   // 1m, 5m, 1h, 1d, etc.
  openTime   DateTime
  closeTime  DateTime
  open       Decimal  @db.Decimal(36, 18)
  high       Decimal  @db.Decimal(36, 18)
  low        Decimal  @db.Decimal(36, 18)
  close      Decimal  @db.Decimal(36, 18)
  volume     Decimal  @db.Decimal(36, 18)
  quoteVolume Decimal @db.Decimal(36, 18)
  trades     Int
  
  tradingPair TradingPair @relation(fields: [symbol], references: [symbol])
  
  @@unique([symbol, interval, openTime])
  @@index([symbol, interval, openTime])
  @@map("klines")
}

// *** NEW: Added for Order Book ***
model OrderBookEntry {
  id            String   @id @default(cuid())
  symbol        String
  side          OrderSide // BUY, SELL
  price         Decimal  @db.Decimal(36, 18)
  quantity      Decimal  @db.Decimal(36, 18)
  timestamp     DateTime @default(now())
  
  tradingPair   TradingPair @relation(fields: [symbol], references: [symbol])
  
  @@index([symbol, side, timestamp])
  @@map("order_book_entries")
}

// =============================================================================
// ORDERS & TRADING
// =============================================================================

model Order {
  id                String      @id @default(cuid())
  userId            String
  symbol            String
  side              OrderSide   // BUY, SELL
  type              OrderType   // MARKET, LIMIT, STOP_LOSS, etc.
  timeInForce       TimeInForce @default(GTC)
  quantity          Decimal     @db.Decimal(36, 18)
  price             Decimal?    @db.Decimal(36, 18)
  stopPrice         Decimal?    @db.Decimal(36, 18)
  status            OrderStatus @default(NEW)
  executedQty       Decimal     @default(0) @db.Decimal(36, 18)
  executedQuoteQty  Decimal     @default(0) @db.Decimal(36, 18)
  orderType         MarketType  // SPOT, FUTURES

  parentOrderId     String?
  
  // Futures specific fields
  positionSide      PositionSide? // LONG, SHORT, BOTH
  leverage          Int?
  marginType        MarginType?   // ISOLATED, CROSS
  reduceOnly        Boolean?     @default(false)
  closePosition     Boolean?     @default(false)
  activationPrice   Decimal?     @db.Decimal(36, 18)
  callbackRate      Decimal?     @db.Decimal(36, 18)
  
  // Metadata
  commissionAsset   String?
  commission        Decimal?     @db.Decimal(36, 18)
  workingTime       DateTime?
  selfTradePreventionMode String?

  version         Int         @default(0)
  
  createdAt         DateTime     @default(now())
  updatedAt         DateTime     @updatedAt
  
  user              User         @relation(fields: [userId], references: [id])
  tradingPair       TradingPair  @relation(fields: [symbol], references: [symbol])
  
  // Trade relations
  buyTrades         Trade[]      @relation("BuyOrderTrades")
  sellTrades        Trade[]      @relation("SellOrderTrades")

  parentOrder       Order?       @relation("BracketOrders", fields: [parentOrderId], references: [id], onDelete: NoAction)
  childOrders       Order[]      @relation("BracketOrders")
  
  @@index([userId, status])
  @@index([symbol, status])
  @@index([userId, symbol, status])
  @@map("orders")
}

model Trade {
  id              String      @id @default(cuid())
  symbol          String
  buyOrderId      String
  sellOrderId     String
  buyUserId       String
  sellUserId      String
  price           Decimal     @db.Decimal(36, 18)
  quantity        Decimal     @db.Decimal(36, 18)
  quoteQty        Decimal     @db.Decimal(36, 18)
  commission      Decimal     @db.Decimal(36, 18)
  commissionAsset String
  tradeType       MarketType  // SPOT, FUTURES
  
  version         Int         @default(0)
  // Futures specific
  realizedPnl     Decimal?    @db.Decimal(36, 18)
  
  createdAt       DateTime    @default(now())
  
  tradingPair     TradingPair @relation(fields: [symbol], references: [symbol])
  buyUser         User        @relation("BuyerTrades", fields: [buyUserId], references: [id])
  sellUser        User        @relation("SellerTrades", fields: [sellUserId], references: [id])
  buyOrder        Order       @relation("BuyOrderTrades", fields: [buyOrderId], references: [id])
  sellOrder       Order       @relation("SellOrderTrades", fields: [sellOrderId], references: [id])
  
  @@index([symbol, createdAt])
  @@index([buyUserId, createdAt])
  @@index([sellUserId, createdAt])
  @@map("trades")
}

model Position {
  id              String       @id @default(cuid())
  userId          String
  symbol          String
  side            PositionSide // LONG, SHORT
  size            Decimal      @db.Decimal(36, 18)
  entryPrice      Decimal      @db.Decimal(36, 18)
  markPrice       Decimal      @db.Decimal(36, 18)
  pnl             Decimal      @db.Decimal(36, 18)
  unrealizedPnl   Decimal      @db.Decimal(36, 18)
  percentage      Decimal?     @db.Decimal(20, 4)
  leverage        Int
  marginType      MarginType
  isolatedMargin  Decimal?     @db.Decimal(36, 18)
  notionalValue   Decimal?     @db.Decimal(36, 18)
  maintenanceMargin Decimal?   @db.Decimal(36, 18)
  marginRatio     Decimal?     @db.Decimal(10, 4)
  liquidationPrice Decimal?    @db.Decimal(36, 18)

  status          PositionStatus
  
  createdAt       DateTime     @default(now())
  updatedAt       DateTime     @updatedAt
  
  user            User         @relation(fields: [userId], references: [id])
  tradingPair     TradingPair  @relation(fields: [symbol], references: [symbol])
  
  // *** NEW: Added for Funding Payments ***
  fundingPayments FundingPayment[]
  
  @@unique([userId, symbol, side])
  @@index([userId, symbol, status])
  @@map("positions")
}

model Liquidation {
  id              String       @id @default(cuid())
  userId          String
  symbol          String
  side            PositionSide
  size            Decimal      @db.Decimal(36, 18)
  entryPrice      Decimal      @db.Decimal(36, 18)
  liquidationPrice Decimal     @db.Decimal(36, 18)
  pnl             Decimal      @db.Decimal(36, 18)
  fee             Decimal      @db.Decimal(36, 18)
  status          String       @default("COMPLETED")
  createdAt       DateTime     @default(now())
  
  @@index([userId, createdAt])
  @@map("liquidations")
}

// *** NEW: Added for Funding Rate ***
model FundingRate {
  id            String   @id @default(cuid())
  symbol        String   // Trading pair, e.g., "BTCUSDT"
  rate          Decimal  @db.Decimal(10, 8) // Funding rate percentage
  interval      String   // E.g., "8h", "4h"
  timestamp     DateTime @default(now())
  nextFundingTime DateTime?
  
  tradingPair   TradingPair @relation(fields: [symbol], references: [symbol])
  fundingPayments FundingPayment[]
  
  @@index([symbol, timestamp])
  @@map("funding_rates")
}

model FundingPayment {
  id            String   @id @default(cuid())
  userId        String
  symbol        String
  positionId    String
  amount        Decimal  @db.Decimal(36, 18) // Positive (receive) or negative (pay)
  fundingRateId String
  createdAt     DateTime @default(now())
  
  user          User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  position      Position   @relation(fields: [positionId], references: [id], onDelete: Cascade)
  fundingRate   FundingRate @relation(fields: [fundingRateId], references: [id], onDelete: Cascade)
  
  @@map("funding_payments")
}

// =============================================================================
// KYC & COMPLIANCE
// =============================================================================

model KycDocument {
  id            String        @id @default(cuid())
  userId        String
  documentType  DocumentType
  documentNumber String?
  fileName      String
  fileUrl       String
  fileSize      Int
  mimeType      String
  status        KycDocumentStatus @default(PENDING)
  verifiedAt    DateTime?
  rejectedAt    DateTime?
  rejectionReason String?
  expiryDate    DateTime?
  createdAt     DateTime      @default(now())
  updatedAt     DateTime      @updatedAt
  
  user          User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("kyc_documents")
}

model KycSubmission {
  id              String        @id @default(cuid())
  userId          String
  level           KycLevel
  status          KycStatus     @default(PENDING)
  submittedData   Json
  reviewedBy      String?
  reviewedAt      DateTime?
  rejectionReason String?
  notes           String?
  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt
  user            User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, status])
  @@map("kyc_submissions")
}

// *** NEW: Added for AML Compliance ***
model AmlAlert {
  id            String   @id @default(cuid())
  userId        String?
  transactionId String?
  alertType     String   // E.g., "HIGH_VALUE", "SUSPICIOUS_PATTERN"
  details       Json?
  severity      String   // LOW, MEDIUM, HIGH, CRITICAL
  status        String   @default("PENDING") // PENDING, REVIEWED, RESOLVED
  createdAt     DateTime @default(now())
  resolvedAt    DateTime?
  
  user          User?    @relation(fields: [userId], references: [id], onDelete: Cascade)
  transaction   Transaction? @relation(fields: [transactionId], references: [id], onDelete: Cascade)
  
  @@map("aml_alerts")
}

model ComplianceReport {
  id            String   @id @default(cuid())
  reportType    String   // E.g., "SAR", "CTR"
  userId        String?
  transactionId String?
  data          Json
  status        String   @default("DRAFT") // DRAFT, SUBMITTED, APPROVED
  submittedAt   DateTime?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User?    @relation(fields: [userId], references: [id], onDelete: Cascade)
  transaction   Transaction? @relation(fields: [transactionId], references: [id], onDelete: Cascade)
  
  @@map("compliance_reports")
}

// =============================================================================
// NOTIFICATIONS & COMMUNICATIONS
// =============================================================================

model Notification {
  id        String              @id @default(cuid())
  userId    String
  type      String
  title     String
  message   String
  channels  String[]            // email, sms, push, in_app
  priority  NotificationPriority @default(MEDIUM)
  status    NotificationStatus  @default(PENDING)
  data      Json?
  readAt    DateTime?
  sentAt    DateTime?
  failedAt  DateTime?
  createdAt DateTime            @default(now())
  
  user      User                @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, status])
  @@index([userId, createdAt])
  @@map("notifications")
}

// *** NEW: Added for Webhook/Callback ***
model Webhook {
  id            String   @id @default(cuid())
  userId        String
  url           String
  events        String[] // E.g., ["TRADE", "DEPOSIT", "WITHDRAWAL"]
  secret        String?  // For signing payloads
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("webhooks")
}

// =============================================================================
// ANALYTICS & STATISTICS
// =============================================================================

model TradeStatistics {
  id            String     @id @default(cuid())
  symbol        String
  tradeType     MarketType
  date          DateTime
  openPrice     Decimal    @db.Decimal(36, 18)
  closePrice    Decimal?   @db.Decimal(36, 18)
  highPrice     Decimal    @db.Decimal(36, 18)
  lowPrice      Decimal    @db.Decimal(36, 18)
  volume        Decimal    @db.Decimal(36, 18)
  quoteVolume   Decimal    @db.Decimal(36, 18)
  tradeCount    Int
  
  @@unique([symbol, tradeType, date])
  @@map("trade_statistics")
}

model DailyUserStats {
  id          String   @id @default(cuid())
  date        DateTime @unique
  newUsers    Int      @default(0)
  activeUsers Int      @default(0)
  totalUsers  Int      @default(0)
  totalTrades Int      @default(0)
  totalVolume Decimal  @default(0) @db.Decimal(36, 18)
  createdAt   DateTime @default(now())
  
  @@map("daily_user_stats")
}

// =============================================================================
// ADMIN & SYSTEM
// =============================================================================

model SystemSetting {
  id        String   @id @default(cuid())
  key       String   @unique
  value     String
  category  String
  description String?
  isPublic  Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  @@map("system_settings")
}

model MaintenanceMode {
  id          String   @id @default(cuid())
  enabled     Boolean  @default(false)
  message     String?
  startTime   DateTime?
  endTime     DateTime?
  affectedServices String[] @default([])
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("maintenance_mode")
}

model AuditLog {
  id          String   @id @default(cuid())
  userId      String?
  adminId     String?
  action      String
  resource    String
  resourceId  String?
  oldValues   Json?
  newValues   Json?
  ip          String?
  userAgent   String?
  timestamp   DateTime @default(now())
  
  @@index([userId, timestamp])
  @@index([adminId, timestamp])
  @@index([action, timestamp])
  @@map("audit_logs")
}

model OrderBookSnapshot {
  id        String   @id @default(cuid())
  symbol    String
  bidsData  String
  asksData  String
  timestamp DateTime
  type      String   @default("SCHEDULED") // SCHEDULED, EMERGENCY
  
  @@index([symbol, timestamp])
  @@map("orderbook_snapshots")
}

// *** NEW: Added for System Events ***
model SystemEvent {
  id          String   @id @default(cuid())
  type        String   // E.g., "ERROR", "WARNING", "INFO"
  category    String   // E.g., "DATABASE", "API", "MATCHING_ENGINE"
  message     String
  details     Json?
  severity    String   // LOW, MEDIUM, HIGH, CRITICAL
  timestamp   DateTime @default(now())
  
  @@index([type, category, timestamp])
  @@map("system_events")
}

// =============================================================================
// NEW MODELS (Added for Enhanced Features)
// =============================================================================

// *** NEW: Added for Fee Management ***
model FeeTier {
  id            String   @id @default(cuid())
  name          String   // E.g., "Basic", "VIP1", "VIP2"
  minVolume     Decimal? // Minimum trading volume to qualify
  makerFee      Decimal  @db.Decimal(10, 8) // Maker fee rate
  takerFee      Decimal  @db.Decimal(10, 8) // Taker fee rate
  withdrawalFee Json?    // Asset-specific withdrawal fees
  validFrom     DateTime?
  validUntil    DateTime?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  users         User[]   @relation("UserFeeTier")
  
  @@map("fee_tiers")
}

// *** NEW: Added for Referral/Affiliate Program ***
model Referral {
  id            String   @id @default(cuid())
  referrerId    String   // User who refers
  refereeId     String   // User who was referred
  code          String   @unique // Referral code
  rewardType    String   // E.g., "PERCENTAGE", "FIXED"
  rewardAmount  Decimal? @db.Decimal(36, 18)
  status        String   @default("PENDING") // PENDING, CLAIMED, EXPIRED
  createdAt     DateTime @default(now())
  claimedAt     DateTime?
  
  referrer      User     @relation("Referrer", fields: [referrerId], references: [id])
  referee       User     @relation("Referee", fields: [refereeId], references: [id])
  rewards       ReferralReward[]
  
  @@map("referrals")
}

model ReferralReward {
  id            String   @id @default(cuid())
  referralId    String
  userId        String
  asset         String   // E.g., "USDT", "BTC"
  amount        Decimal  @db.Decimal(36, 18)
  status        String   @default("PENDING") // PENDING, DISTRIBUTED, FAILED
  distributedAt DateTime?
  createdAt     DateTime @default(now())
  
  referral      Referral @relation(fields: [referralId], references: [id], onDelete: Cascade)
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("referral_rewards")
}

// *** NEW: Added for Staking/Lending ***
model StakingPlan {
  id            String   @id @default(cuid())
  asset         String   // E.g., "ETH", "ADA"
  duration      Int      // Duration in days
  apy           Decimal  @db.Decimal(10, 4) // Annual Percentage Yield
  minAmount     Decimal  @db.Decimal(36, 18)
  maxAmount     Decimal? @db.Decimal(36, 18)
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  stakes        Stake[]
  assetRef      Asset?   @relation(fields: [asset], references: [symbol])
  
  @@map("staking_plans")
}

model Stake {
  id            String   @id @default(cuid())
  userId        String
  stakingPlanId String
  amount        Decimal  @db.Decimal(36, 18)
  status        String   @default("ACTIVE") // ACTIVE, COMPLETED, CANCELED
  startDate     DateTime @default(now())
  endDate       DateTime?
  reward        Decimal? @db.Decimal(36, 18)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  stakingPlan   StakingPlan @relation(fields: [stakingPlanId], references: [id], onDelete: Cascade)
  
  @@map("stakes")
}

// *** NEW: Added for Margin Trading ***
model MarginAccount {
  id            String   @id @default(cuid())
  userId        String
  asset         String
  balance       Decimal  @db.Decimal(36, 18)
  borrowed      Decimal  @db.Decimal(36, 18)
  interest      Decimal  @db.Decimal(36, 18)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  assetRef      Asset?   @relation(fields: [asset], references: [symbol])
  
  @@unique([userId, asset])
  @@map("margin_accounts")
}

model MarginLoan {
  id            String   @id @default(cuid())
  userId        String
  asset         String
  amount        Decimal  @db.Decimal(36, 18)
  interestRate  Decimal  @db.Decimal(10, 8)
  status        String   @default("ACTIVE") // ACTIVE, REPAID, LIQUIDATED
  borrowedAt    DateTime @default(now())
  repaidAt      DateTime?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  assetRef      Asset?   @relation(fields: [asset], references: [symbol])
  
  @@map("margin_loans")
}

// *** NEW: Added for OTC Trading ***
model OtcTrade {
  id            String   @id @default(cuid())
  userId        String
  asset         String
  quoteAsset    String
  amount        Decimal  @db.Decimal(36, 18)
  price         Decimal  @db.Decimal(36, 18)
  status        String   @default("PENDING") // PENDING, CONFIRMED, COMPLETED, CANCELED
  type          String   // BUY, SELL
  referenceId   String?  // External reference
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  assetRef      Asset?   @relation("OtcAsset", fields: [asset], references: [symbol])
  quoteAssetRef Asset?   @relation("OtcQuoteAsset", fields: [quoteAsset], references: [symbol])
  
  @@map("otc_trades")
}

// *** NEW: Added for Market Maker Program ***
model MarketMakerProgram {
  id            String   @id @default(cuid())
  name          String
  symbol        String
  minVolume     Decimal  @db.Decimal(36, 18)
  makerFee      Decimal  @db.Decimal(10, 8)
  takerFee      Decimal  @db.Decimal(10, 8)
  rewardType    String?  // E.g., "FEE_DISCOUNT", "CASHBACK"
  rewardAmount  Decimal? @db.Decimal(36, 18)
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  participants  User[]   @relation("MarketMakerParticipants")
  
  @@map("market_maker_programs")
}

// *** NEW: Added for Multi-Currency Support ***
model FiatCurrency {
  id            String   @id @default(cuid())
  code          String   @unique // E.g., "USD", "EUR"
  name          String   // E.g., "US Dollar", "Euro"
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  fiatTransactions FiatTransaction[]
  
  @@map("fiat_currencies")
}

model ExchangeRate {
  id            String   @id @default(cuid())
  baseCurrency  String   // E.g., "USD"
  quoteCurrency String   // E.g., "BTC"
  rate          Decimal  @db.Decimal(36, 18)
  source        String?  // E.g., "API", "MANUAL"
  timestamp     DateTime @default(now())
  
  @@index([baseCurrency, quoteCurrency, timestamp])
  @@map("exchange_rates")
}

model FiatTransaction {
  id            String   @id @default(cuid())
  userId        String
  currency      String   // E.g., "USD"
  amount        Decimal  @db.Decimal(36, 18)
  type          String   // DEPOSIT, WITHDRAWAL
  status        String   @default("PENDING")
  paymentMethod String?  // E.g., "BANK_TRANSFER", "CREDIT_CARD"
  referenceId   String?  // External payment reference
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User        @relation(fields: [userId], references: [id], onDelete: Cascade)
  currencyRef   FiatCurrency? @relation(fields: [currency], references: [code])
  
  @@map("fiat_transactions")
}

// *** NEW: Added for Trading Competitions ***
model TradingCompetition {
  id            String   @id @default(cuid())
  name          String
  startDate     DateTime
  endDate       DateTime
  symbols       String[] // E.g., ["BTCUSDT", "ETHUSDT"]
  prizePool     Json?    // E.g., { "1st": "1000 USDT", "2nd": "500 USDT" }
  rules         Json?    // Competition rules
  isActive      Boolean  @default(true)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  participants  TradingCompetitionParticipant[]
  
  @@map("trading_competitions")
}

model TradingCompetitionParticipant {
  id            String   @id @default(cuid())
  competitionId String
  userId        String
  score         Decimal  @db.Decimal(36, 18) // E.g., trading volume, ROI
  rank          Int?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  competition   TradingCompetition @relation(fields: [competitionId], references: [id], onDelete: Cascade)
  user          User              @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("trading_competition_participants")
}

// *** NEW: Added for API Rate Limits ***
model ApiRateLimit {
  id            String   @id @default(cuid())
  userId        String?
  apiKeyId      String?
  endpoint      String   // E.g., "/api/v1/order"
  limit         Int      // Max requests per interval
  interval      String   // E.g., "1m", "1h"
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  user          User?    @relation(fields: [userId], references: [id], onDelete: Cascade)
  apiKey        ApiKey?  @relation(fields: [apiKeyId], references: [id], onDelete: Cascade)
  
  @@map("api_rate_limits")
}
