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
  GTC
  IOC
  FOK
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
  createdAt         DateTime?
  updatedAt         DateTime?

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
  buyTrades         Trade[]     @relation("BuyerTrades")
  sellTrades        Trade[]     @relation("SellerTrades")
  referralsAsReferrer Referral[]  @relation("Referrer")
  referralsAsReferee  Referral[]  @relation("Referee")
  referralRewards     ReferralReward[]
  stakes              Staking[]
  campaignParticipants CampaignParticipant[]
  otcTrades           OtcTrade[]
  auditLogsAsUser     AuditLog[]  @relation("UserAuditLogs")
  auditLogsAsAdmin    AuditLog[]  @relation("AdminAuditLogs")

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
  createdAt     DateTime?
  updatedAt     DateTime?
  
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
  createdAt     DateTime?
  updatedAt     DateTime?
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("user_preferences")
}

model ApiKey {
  id            String   @id @default(cuid())
  userId        String
  name          String
  keyId         String   @unique
  secretHash    String
  permissions   String // Simplified from String[]
  ipWhitelist   String // Simplified from String[]
  description   String?
  isActive      Boolean  @default(true)
  lastUsedAt    DateTime?
  expiresAt     DateTime?
  createdAt     DateTime?
  updatedAt     DateTime?
  
  user          User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
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
  lastActiveAt  DateTime?
  expiresAt     DateTime
  createdAt     DateTime?
  
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
  timestamp DateTime?
  
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
  timestamp DateTime?
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, eventType, timestamp])
  @@map("security_events")
}

model SecurityAlert {
  id        String   @id @default(cuid())
  userId    String
  alertType String
  severity  String
  details   String?
  status    String   @default("ACTIVE")
  createdAt DateTime?
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
  lastUsedAt  DateTime?
  createdAt   DateTime?
  
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
  timestamp DateTime?
  
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
  createdAt DateTime?
  
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
  createdAt DateTime?
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("password_resets")
}

model TwoFactorSetup {
  id        String   @id @default(cuid())
  userId    String   @unique
  secret    String
  isActive  Boolean  @default(false)
  createdAt DateTime?
  updatedAt DateTime?
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@map("two_factor_setups")
}

model TwoFactorBackupCode {
  id        String   @id @default(cuid())
  userId    String
  code      String   @unique
  used      Boolean  @default(false)
  usedAt    DateTime?
  createdAt DateTime?
  
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
  timestamp   DateTime?
  
  @@index([email, timestamp])
  @@index([ip, timestamp])
  @@map("login_attempts")
}

model TokenBlacklist {
  id        String   @id @default(cuid())
  jti       String   @unique
  expiresAt DateTime
  createdAt DateTime?
  
  @@index([expiresAt])
  @@map("token_blacklist")
}

// =============================================================================
// REFERRAL & AFFILIATE PROGRAM
// =============================================================================

model Referral {
  id            String   @id @default(cuid())
  referrerId    String
  refereeId     String
  code          String   @unique
  rewardType    String
  rewardAmount  Decimal
  status        String   @default("PENDING")
  createdAt     DateTime?
  updatedAt     DateTime?

  referrer      User     @relation("Referrer", fields: [referrerId], references: [id])
  referee       User     @relation("Referee", fields: [refereeId], references: [id])
  rewards       ReferralReward[]

  @@map("referrals")
}

model ReferralReward {
  id            String   @id @default(cuid())
  referralId    String
  userId        String
  amount        Decimal
  asset         String
  status        String   @default("PENDING")
  paidAt        DateTime?
  createdAt     DateTime?
  updatedAt     DateTime?

  referral      Referral @relation(fields: [referralId], references: [id])
  user          User     @relation(fields: [userId], references: [id])

  @@map("referral_rewards")
}

// =============================================================================
// STAKING & SAVINGS
// =============================================================================

model StakingPool {
  id            String   @id @default(cuid())
  assetId       String
  name          String
  apy           Decimal
  minAmount     Decimal
  maxAmount     Decimal?
  lockPeriod    Int
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  asset         Asset    @relation(fields: [assetId], references: [id])
  stakes        Staking[]

  @@map("staking_pools")
}

model Staking {
  id            String   @id @default(cuid())
  userId        String
  poolId        String
  amount        Decimal
  startDate     DateTime
  endDate       DateTime?
  status        String   @default("ACTIVE")
  rewardAmount  Decimal?
  createdAt     DateTime?
  updatedAt     DateTime?

  user          User     @relation(fields: [userId], references: [id])
  pool          StakingPool @relation(fields: [poolId], references: [id])

  @@map("stakes")
}

// =============================================================================
// ASSET & BLOCKCHAIN NETWORK
// =============================================================================

model Asset {
  id            String   @id @default(cuid())
  symbol        String   @unique
  name          String
  networkId     String?
  decimals      Int
  minWithdrawal Decimal
  maxWithdrawal Decimal?
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  network       BlockchainNetwork? @relation(fields: [networkId], references: [id])
  wallets       Wallet[]
  transactions  Transaction[]
  stakingPools  StakingPool[]
  feeStructures FeeStructure[]
  tradingPairsBase  TradingPair[] @relation("BaseAsset")
  tradingPairsQuote TradingPair[] @relation("QuoteAsset")
  otcTradesAsset    OtcTrade[]    @relation("OtcAsset")
  otcTradesQuote    OtcTrade[]    @relation("OtcQuoteAsset")
  campaigns         Campaign[]

  @@map("assets")
}

model BlockchainNetwork {
  id            String   @id @default(cuid())
  name          String
  chainId       String   @unique
  rpcUrl        String?
  explorerUrl   String?
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  assets        Asset[]

  @@map("blockchain_networks")
}

// =============================================================================
// FEE STRUCTURE
// =============================================================================

model FeeStructure {
  id            String   @id @default(cuid())
  name          String
  userLevel     String?
  marketType    MarketType
  makerFee      Decimal
  takerFee      Decimal
  withdrawalFee Decimal?
  assetId       String?
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  asset         Asset?   @relation(fields: [assetId], references: [id])

  @@map("fee_structures")
}

// =============================================================================
// WALLET & TRANSACTIONS
// =============================================================================

model Wallet {
  id         String     @id @default(cuid())
  userId     String
  assetId    String
  balance    Decimal    @default(0)
  locked     Decimal    @default(0)
  walletType WalletType @default(SPOT)
  address    String?
  createdAt  DateTime?
  updatedAt  DateTime?
  
  user       User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  asset      Asset      @relation(fields: [assetId], references: [id])
  
  @@unique([userId, assetId, walletType])
  @@map("wallets")
}

model Transaction {
  id            String            @id @default(cuid())
  userId        String
  assetId       String
  type          TransactionType
  amount        Decimal
  fee           Decimal?
  status        TransactionStatus @default(PENDING)
  walletType    WalletType        @default(SPOT)
  address       String?
  txHash        String?
  memo          String?
  notes         String?
  description   String?
  metadata      Json?
  failureReason String?
  referenceId   String?
  processedAt   DateTime?
  createdAt     DateTime?
  updatedAt     DateTime?
  
  user          User              @relation(fields: [userId], references: [id], onDelete: Cascade)
  asset         Asset             @relation(fields: [assetId], references: [id])
  
  @@index([userId, type, status])
  @@index([txHash])
  @@map("transactions")
}

// =============================================================================
// TRADING PAIRS & MARKET DATA
// =============================================================================

model TradingPair {
  id                  String   @id @default(cuid())
  symbol              String   @unique
  baseAssetId         String
  quoteAssetId        String
  isActive            Boolean  @default(true)
  minQty              Decimal
  maxQty              Decimal
  stepSize            Decimal
  minPrice            Decimal
  maxPrice            Decimal
  tickSize            Decimal
  minNotional         Decimal
  pricePrecision      Int      @default(8)
  quantityPrecision   Int      @default(8)
  allowMarketOrders   Boolean  @default(true)
  allowSpotTrading    Boolean  @default(true)
  allowFuturesTrading Boolean  @default(true)
  createdAt           DateTime?
  updatedAt           DateTime?
  marketType          MarketType
  
  baseAsset           Asset    @relation("BaseAsset", fields: [baseAssetId], references: [id])
  quoteAsset          Asset    @relation("QuoteAsset", fields: [quoteAssetId], references: [id])
  orders              Order[]
  trades              Trade[]
  positions           Position[]
  klines              Kline[]
  
  @@map("trading_pairs")
}

model Kline {
  id         String   @id @default(cuid())
  symbol     String
  interval   String
  openTime   DateTime
  closeTime  DateTime
  open       Decimal
  high       Decimal
  low        Decimal
  close      Decimal
  volume     Decimal
  quoteVolume Decimal
  trades     Int
  
  tradingPair TradingPair @relation(fields: [symbol], references: [symbol])
  
  @@unique([symbol, interval, openTime])
  @@index([symbol, interval, openTime])
  @@map("klines")
}

// =============================================================================
// ORDERS & TRADING
// =============================================================================

model Order {
  id                String      @id @default(cuid())
  userId            String
  symbol            String
  clientOrderId     String?     @unique
  side              OrderSide
  type              OrderType
  timeInForce       TimeInForce @default(GTC)
  quantity          Decimal
  price             Decimal?
  stopPrice         Decimal?
  status            OrderStatus @default(NEW)
  executedQty       Decimal     @default(0)
  executedQuoteQty  Decimal     @default(0)
  orderType         MarketType
  parentOrderId     String?
  positionSide      PositionSide?
  leverage          Int?
  marginType        MarginType?
  reduceOnly        Boolean?     @default(false)
  closePosition     Boolean?     @default(false)
  activationPrice   Decimal?
  callbackRate      Decimal?
  commissionAsset   String?
  commission        Decimal?
  workingTime       DateTime?
  selfTradePreventionMode String?
  version           Int         @default(0)
  createdAt         DateTime?
  updatedAt         DateTime?
  
  user              User        @relation(fields: [userId], references: [id])
  tradingPair       TradingPair @relation(fields: [symbol], references: [symbol])
  buyTrades         Trade[]     @relation("BuyOrderTrades")
  sellTrades        Trade[]     @relation("SellOrderTrades")
  parentOrder       Order?      @relation("BracketOrders", fields: [parentOrderId], references: [id], onDelete: NoAction)
  childOrders       Order[]     @relation("BracketOrders")
  
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
  price           Decimal
  quantity        Decimal
  quoteQty        Decimal
  commission      Decimal
  commissionAsset String
  tradeType       MarketType
  realizedPnl     Decimal?
  version         Int         @default(0)
  createdAt       DateTime?
  
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
  side            PositionSide
  size            Decimal
  entryPrice      Decimal
  markPrice       Decimal
  pnl             Decimal
  unrealizedPnl   Decimal
  percentage      Decimal?
  leverage        Int
  marginType      MarginType
  isolatedMargin  Decimal?
  notionalValue   Decimal?
  maintenanceMargin Decimal?
  marginRatio     Decimal?
  liquidationPrice Decimal?
  status          PositionStatus
  createdAt       DateTime?
  updatedAt       DateTime?
  
  user            User         @relation(fields: [userId], references: [id])
  tradingPair     TradingPair  @relation(fields: [symbol], references: [symbol])
  
  @@unique([userId, symbol, side])
  @@index([userId, symbol, status])
  @@map("positions")
}

model Liquidation {
  id              String       @id @default(cuid())
  userId          String
  symbol          String
  side            PositionSide
  size            Decimal
  entryPrice      Decimal
  liquidationPrice Decimal
  pnl             Decimal
  fee             Decimal
  status          String       @default("COMPLETED")
  createdAt       DateTime?
  
  user            User         @relation(fields: [userId], references: [id])
  
  @@index([userId, createdAt])
  @@map("liquidations")
}

// =============================================================================
// OTC TRADING
// =============================================================================

model OtcTrade {
  id            String   @id @default(cuid())
  userId        String
  assetId       String
  amount        Decimal
  price         Decimal
  quoteAssetId  String
  status        String   @default("PENDING")
  createdAt     DateTime?
  updatedAt     DateTime?

  user          User     @relation(fields: [userId], references: [id])
  asset         Asset    @relation("OtcAsset", fields: [assetId], references: [id])
  quoteAsset    Asset    @relation("OtcQuoteAsset", fields: [quoteAssetId], references: [id])

  @@map("otc_trades")
}

// =============================================================================
// CAMPAIGNS & PROMOTIONS
// =============================================================================

model Campaign {
  id            String   @id @default(cuid())
  name          String
  type          String
  description   String?
  startDate     DateTime
  endDate       DateTime
  rewardPool    Decimal?
  assetId       String?
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  asset         Asset?   @relation(fields: [assetId], references: [id])
  participants  CampaignParticipant[]

  @@map("campaigns")
}

model CampaignParticipant {
  id            String   @id @default(cuid())
  campaignId    String
  userId        String
  rewardAmount  Decimal?
  status        String   @default("PENDING")
  createdAt     DateTime?
  updatedAt     DateTime?

  campaign      Campaign @relation(fields: [campaignId], references: [id])
  user          User     @relation(fields: [userId], references: [id])

  @@map("campaign_participants")
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
  createdAt     DateTime?
  updatedAt     DateTime?
  
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
  reviewerNotes   String?
  reviewedAt      DateTime?
  rejectionReason String?
  notes           String?
  createdAt       DateTime?
  updatedAt       DateTime?
  
  user            User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, status])
  @@map("kyc_submissions")
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
  templateId String?
  channels  String              // Simplified from String[]
  priority  NotificationPriority @default(MEDIUM)
  status    NotificationStatus  @default(PENDING)
  data      Json?
  readAt    DateTime?
  sentAt    DateTime?
  failedAt  DateTime?
  createdAt DateTime?
  
  user      User                @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, status])
  @@index([userId, createdAt])
  @@map("notifications")
}

model Translation {
  id            String   @id @default(cuid())
  key           String
  language      String
  value         String
  category      String?
  createdAt     DateTime?
  updatedAt     DateTime?

  @@unique([key, language])
  @@map("translations")
}

// =============================================================================
// ANALYTICS & STATISTICS
// =============================================================================

model TradeStatistics {
  id            String     @id @default(cuid())
  symbol        String
  tradeType     MarketType
  date          DateTime
  openPrice     Decimal
  closePrice    Decimal?
  highPrice     Decimal
  lowPrice      Decimal
  volume        Decimal
  quoteVolume   Decimal
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
  totalVolume Decimal  @default(0)
  createdAt   DateTime?
  
  @@map("daily_user_stats")
}

model Report {
  id            String   @id @default(cuid())
  type          String
  periodStart   DateTime
  periodEnd     DateTime
  data          Json
  generatedBy   String?
  createdAt     DateTime?
  
  @@map("reports")
}

// =============================================================================
// RISK MANAGEMENT
// =============================================================================

model RiskRule {
  id            String   @id @default(cuid())
  name          String
  type          String
  conditions    Json
  action        String
  isActive      Boolean  @default(true)
  createdAt     DateTime?
  updatedAt     DateTime?

  @@map("risk_rules")
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
  createdAt DateTime?
  updatedAt DateTime?
  
  @@map("system_settings")
}

model MaintenanceMode {
  id          String   @id @default(cuid())
  enabled     Boolean  @default(false)
  message     String?
  startTime   DateTime?
  endTime     DateTime?
  affectedServices String // Simplified from String[]
  createdAt   DateTime?
  updatedAt   DateTime?
  
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
  timestamp   DateTime?
  
  user        User?    @relation("UserAuditLogs", fields: [userId], references: [id])
  admin       User?    @relation("AdminAuditLogs", fields: [adminId], references: [id])
  
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
  type      String   @default("SCHEDULED")
  
  @@index([symbol, timestamp])
  @@map("orderbook_snapshots")
}
