-- Create tables
CREATE TABLE users (
    uid VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    profile_picture_url VARCHAR(255),
    user_type VARCHAR(50) NOT NULL,
    is_phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notification_preferences JSONB,
    last_login_at BIGINT,
    login_count INTEGER NOT NULL DEFAULT 0,
    referral_code VARCHAR(50),
    referred_by VARCHAR(255),
    default_payment_method_id VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE courier_profiles (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL REFERENCES users(uid),
    vehicle_type VARCHAR(50) NOT NULL,
    vehicle_make VARCHAR(100),
    vehicle_model VARCHAR(100),
    license_plate VARCHAR(50),
    id_verification_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    id_verification_documents JSONB,
    background_check_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    background_check_date BIGINT,
    service_areas JSONB,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    current_location JSONB,
    availability_status VARCHAR(50) NOT NULL DEFAULT 'offline',
    availability_schedule JSONB,
    account_balance NUMERIC NOT NULL DEFAULT 0,
    lifetime_deliveries INTEGER NOT NULL DEFAULT 0,
    lifetime_earnings NUMERIC NOT NULL DEFAULT 0,
    average_rating NUMERIC NOT NULL DEFAULT 0,
    total_ratings INTEGER NOT NULL DEFAULT 0,
    bank_account_info JSONB,
    max_package_size VARCHAR(50) NOT NULL DEFAULT 'medium',
    max_package_weight NUMERIC NOT NULL DEFAULT 20,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE business_profiles (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL REFERENCES users(uid),
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(100) NOT NULL,
    tax_id VARCHAR(100),
    website VARCHAR(255),
    business_phone VARCHAR(50),
    business_email VARCHAR(255) NOT NULL,
    logo_url VARCHAR(255),
    business_hours JSONB,
    billing_address JSONB,
    invoice_email VARCHAR(255),
    payment_terms INTEGER,
    monthly_deliveries INTEGER NOT NULL DEFAULT 0,
    total_deliveries INTEGER NOT NULL DEFAULT 0,
    require_approval_above NUMERIC,
    approval_workflow VARCHAR(50) NOT NULL DEFAULT 'none',
    invoice_frequency VARCHAR(50) NOT NULL DEFAULT 'weekly',
    subscription_plan VARCHAR(50) NOT NULL DEFAULT 'standard',
    subscription_status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE business_members (
    uid VARCHAR(255) PRIMARY KEY,
    business_id VARCHAR(255) NOT NULL REFERENCES business_profiles(uid),
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    role VARCHAR(50) NOT NULL,
    permissions JSONB,
    cost_center VARCHAR(100),
    max_order_value NUMERIC,
    requires_approval BOOLEAN NOT NULL DEFAULT FALSE,
    invited_by VARCHAR(255),
    invite_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE addresses (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    type VARCHAR(50) NOT NULL,
    label VARCHAR(100),
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(50) NOT NULL,
    line1 VARCHAR(255) NOT NULL,
    line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    latitude NUMERIC,
    longitude NUMERIC,
    delivery_instructions TEXT,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_business BOOLEAN NOT NULL DEFAULT FALSE,
    business_name VARCHAR(255),
    access_code VARCHAR(50),
    is_frequently_used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE payment_methods (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    payment_type VARCHAR(50) NOT NULL,
    provider_payment_token VARCHAR(255) NOT NULL,
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    billing_address JSONB,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE courier_payouts (
    uid VARCHAR(255) PRIMARY KEY,
    courier_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    amount NUMERIC NOT NULL,
    currency VARCHAR(10) NOT NULL,
    period_start BIGINT NOT NULL,
    period_end BIGINT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255),
    reference_number VARCHAR(100),
    earnings_count INTEGER NOT NULL,
    notes TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE delivery_requests (
    uid VARCHAR(255) PRIMARY KEY,
    sender_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    courier_id VARCHAR(255) REFERENCES users(uid),
    business_id VARCHAR(255) REFERENCES business_profiles(uid),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    request_time BIGINT NOT NULL,
    scheduled_pickup_time BIGINT NOT NULL,
    estimated_delivery_time BIGINT,
    actual_pickup_time BIGINT,
    actual_delivery_time BIGINT,
    package_size VARCHAR(50) NOT NULL,
    package_weight NUMERIC NOT NULL,
    package_type VARCHAR(100) NOT NULL,
    special_instructions TEXT,
    is_fragile BOOLEAN NOT NULL DEFAULT FALSE,
    requires_id_check BOOLEAN NOT NULL DEFAULT FALSE,
    proof_of_delivery_type VARCHAR(50) NOT NULL DEFAULT 'photo',
    pickup_location JSONB NOT NULL,
    dropoff_location JSONB NOT NULL,
    distance NUMERIC NOT NULL,
    estimated_duration INTEGER NOT NULL,
    price JSONB NOT NULL,
    payment_method_id VARCHAR(255) NOT NULL REFERENCES payment_methods(uid),
    payment_status VARCHAR(50) NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255),
    tracking_code VARCHAR(100) UNIQUE NOT NULL,
    notes TEXT,
    insurance_option JSONB,
    is_contactless_delivery BOOLEAN NOT NULL DEFAULT FALSE,
    cancellation_info JSONB,
    cost_center VARCHAR(100),
    approval_status VARCHAR(50) NOT NULL DEFAULT 'not_required',
    approved_by VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE delivery_tracking (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) UNIQUE NOT NULL REFERENCES delivery_requests(uid),
    status_updates JSONB,
    courier_locations JSONB,
    estimated_arrival_time BIGINT,
    is_delayed BOOLEAN NOT NULL DEFAULT FALSE,
    delay_reason VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE delivery_issues (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    reporter_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    issue_type VARCHAR(50) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'reported',
    resolution_notes TEXT,
    reported_at BIGINT NOT NULL,
    resolved_at BIGINT,
    photos JSONB,
    compensation_amount NUMERIC,
    assigned_to VARCHAR(255) REFERENCES users(uid),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE proof_of_delivery (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) UNIQUE NOT NULL REFERENCES delivery_requests(uid),
    type VARCHAR(50) NOT NULL,
    content_url VARCHAR(255),
    collected_at BIGINT NOT NULL,
    collected_by VARCHAR(255) NOT NULL REFERENCES users(uid),
    recipient_name VARCHAR(100),
    notes TEXT,
    verification_code VARCHAR(50),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE messages (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    sender_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    receiver_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    message_type VARCHAR(50) NOT NULL DEFAULT 'text',
    content TEXT,
    image_url VARCHAR(255),
    sent_at BIGINT NOT NULL,
    read_at BIGINT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE notifications (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    channels JSONB NOT NULL,
    status JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    scheduled_for BIGINT,
    expires_at BIGINT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE support_tickets (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    delivery_id VARCHAR(255) REFERENCES delivery_requests(uid),
    issue_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    priority VARCHAR(50) NOT NULL DEFAULT 'medium',
    assigned_to VARCHAR(255) REFERENCES users(uid),
    attachments JSONB,
    resolution_notes TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    closed_at BIGINT
);

CREATE TABLE support_messages (
    uid VARCHAR(255) PRIMARY KEY,
    ticket_id VARCHAR(255) NOT NULL REFERENCES support_tickets(uid),
    sender_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    sender_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    attachments JSONB,
    is_internal BOOLEAN NOT NULL DEFAULT FALSE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE ratings (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    rater_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    rated_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    rating INTEGER NOT NULL,
    feedback_categories JSONB,
    comments TEXT,
    rating_type VARCHAR(50) NOT NULL,
    is_dispute_filed BOOLEAN NOT NULL DEFAULT FALSE,
    dispute_reason TEXT,
    dispute_status VARCHAR(50),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE transactions (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    delivery_id VARCHAR(255) REFERENCES delivery_requests(uid),
    transaction_type VARCHAR(50) NOT NULL,
    amount NUMERIC NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_method_id VARCHAR(255) REFERENCES payment_methods(uid),
    provider_transaction_id VARCHAR(255),
    description TEXT,
    metadata JSONB,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE courier_earnings (
    uid VARCHAR(255) PRIMARY KEY,
    courier_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    base_fare NUMERIC NOT NULL,
    distance_fee NUMERIC NOT NULL,
    time_fee NUMERIC NOT NULL,
    special_fee NUMERIC NOT NULL DEFAULT 0,
    tip_amount NUMERIC NOT NULL DEFAULT 0,
    platform_fee NUMERIC NOT NULL,
    tax_amount NUMERIC NOT NULL,
    total_earning NUMERIC NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    payout_id VARCHAR(255) REFERENCES courier_payouts(uid),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE invoices (
    uid VARCHAR(255) PRIMARY KEY,
    business_id VARCHAR(255) NOT NULL REFERENCES business_profiles(uid),
    period_start BIGINT NOT NULL,
    period_end BIGINT NOT NULL,
    total_amount NUMERIC NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'draft',
    due_date BIGINT NOT NULL,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    issued_date BIGINT NOT NULL,
    paid_date BIGINT,
    pdf_url VARCHAR(255),
    line_items JSONB NOT NULL,
    payment_transaction_id VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE promo_codes (
    uid VARCHAR(255) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(50) NOT NULL,
    discount_value NUMERIC NOT NULL,
    start_date BIGINT NOT NULL,
    end_date BIGINT,
    usage_limit INTEGER,
    user_limit INTEGER,
    min_order_amount NUMERIC,
    is_first_time_only BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    times_used INTEGER NOT NULL DEFAULT 0,
    created_by VARCHAR(255) REFERENCES users(uid),
    applicable_user_types JSONB,
    region_restrictions JSONB,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE system_settings (
    uid VARCHAR(255) PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    setting_type VARCHAR(50) NOT NULL,
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    updated_by VARCHAR(255) REFERENCES users(uid),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE service_regions (
    uid VARCHAR(255) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    boundaries JSONB,
    timezone VARCHAR(50) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    base_fare NUMERIC NOT NULL,
    distance_rate NUMERIC NOT NULL,
    minimum_fare NUMERIC NOT NULL,
    surge_multiplier NUMERIC NOT NULL DEFAULT 1,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE audit_logs (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(uid),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at BIGINT NOT NULL
);

CREATE TABLE help_articles (
    uid VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    tags JSONB,
    author_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    view_count INTEGER NOT NULL DEFAULT 0,
    publish_date BIGINT,
    last_updated BIGINT,
    related_articles JSONB,
    user_types JSONB,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE faqs (
    uid VARCHAR(255) PRIMARY KEY,
    question VARCHAR(255) NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    user_types JSONB,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE app_feedback (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    feedback_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    rating INTEGER,
    screenshot_url VARCHAR(255),
    device_info JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'received',
    admin_notes TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE user_promo_usages (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    promo_id VARCHAR(255) NOT NULL REFERENCES promo_codes(uid),
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    discount_amount NUMERIC NOT NULL,
    created_at BIGINT NOT NULL
);

CREATE TABLE insurance_claims (
    uid VARCHAR(255) PRIMARY KEY,
    delivery_id VARCHAR(255) NOT NULL REFERENCES delivery_requests(uid),
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    claim_type VARCHAR(50) NOT NULL,
    claim_amount NUMERIC NOT NULL,
    description TEXT NOT NULL,
    evidence_urls JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'submitted',
    resolution_notes TEXT,
    approved_amount NUMERIC,
    processed_by VARCHAR(255) REFERENCES users(uid),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE emergency_contacts (
    uid VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL REFERENCES users(uid),
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

CREATE TABLE prohibited_items (
    uid VARCHAR(255) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    reason TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
);

-- Create indexes
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_courier_profiles_availability_status ON courier_profiles(availability_status);
CREATE INDEX idx_courier_profiles_avg_rating ON courier_profiles(average_rating);
CREATE INDEX idx_delivery_requests_sender_status ON delivery_requests(sender_id, status);
CREATE INDEX idx_delivery_requests_courier_status ON delivery_requests(courier_id, status);
CREATE INDEX idx_delivery_requests_pickup_time ON delivery_requests(scheduled_pickup_time);
CREATE INDEX idx_delivery_requests_status_created ON delivery_requests(status, created_at);
CREATE INDEX idx_messages_delivery_sent ON messages(delivery_id, sent_at);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at);
CREATE INDEX idx_transactions_user_created ON transactions(user_id, created_at);
CREATE INDEX idx_courier_earnings_courier_created ON courier_earnings(courier_id, created_at);
CREATE INDEX idx_invoices_business_status ON invoices(business_id, status);
CREATE INDEX idx_ratings_rating_created ON ratings(rating, created_at);
CREATE INDEX idx_addresses_user_postal ON addresses(user_id, postal_code);
CREATE INDEX idx_help_articles_category_published ON help_articles(category, is_published);
CREATE INDEX idx_faqs_category_published ON faqs(category, is_published);
CREATE INDEX idx_service_regions_country ON service_regions(country);
CREATE INDEX idx_audit_logs_entity_type_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_delivery_tracking_eta ON delivery_tracking(estimated_arrival_time);

-- Seed data for users table
INSERT INTO users (uid, email, phone_number, password_hash, first_name, last_name, profile_picture_url, user_type, is_phone_verified, is_email_verified, notification_preferences, last_login_at, login_count, referral_code, created_at, updated_at)
VALUES
('usr_001', 'john.smith@example.com', '+14155550101', '$2a$10$abcdefghijklmnopqrstuvwxyz012345', 'John', 'Smith', 'https://picsum.photos/seed/john123/200', 'sender', true, true, '{"push": true, "sms": true, "email": true, "quiet_hours_start": 1320, "quiet_hours_end": 420}', 1634721600000, 42, 'JOHNREF', 1609459200000, 1634721600000),
('usr_002', 'emily.jones@example.com', '+14155550102', '$2a$10$abcdefghijklmnopqrstuvwxyz012346', 'Emily', 'Jones', 'https://picsum.photos/seed/emily456/200', 'sender', true, true, '{"push": true, "sms": false, "email": true, "quiet_hours_start": 1380, "quiet_hours_end": 360}', 1634808000000, 38, 'EMILYREF', 1609545600000, 1634808000000),
('usr_003', 'michael.brown@example.com', '+14155550103', '$2a$10$abcdefghijklmnopqrstuvwxyz012347', 'Michael', 'Brown', 'https://picsum.photos/seed/michael789/200', 'courier', true, true, '{"push": true, "sms": true, "email": false, "quiet_hours_start": 0, "quiet_hours_end": 0}', 1634894400000, 76, 'MIKEREF', 1609632000000, 1634894400000),
('usr_004', 'sarah.wilson@example.com', '+14155550104', '$2a$10$abcdefghijklmnopqrstuvwxyz012348', 'Sarah', 'Wilson', 'https://picsum.photos/seed/sarah101112/200', 'courier', true, true, '{"push": true, "sms": true, "email": true, "quiet_hours_start": 1410, "quiet_hours_end": 390}', 1634980800000, 65, 'SARAHREF', 1609718400000, 1634980800000),
('usr_005', 'david.lee@example.com', '+14155550105', '$2a$10$abcdefghijklmnopqrstuvwxyz012349', 'David', 'Lee', 'https://picsum.photos/seed/david131415/200', 'business', true, true, '{"push": false, "sms": false, "email": true, "quiet_hours_start": 0, "quiet_hours_end": 0}', 1635067200000, 54, 'DAVIDREF', 1609804800000, 1635067200000),
('usr_006', 'jennifer.williams@example.com', '+14155550106', '$2a$10$abcdefghijklmnopqrstuvwxyz0123410', 'Jennifer', 'Williams', 'https://picsum.photos/seed/jennifer161718/200', 'business', true, true, '{"push": true, "sms": true, "email": true, "quiet_hours_start": 1350, "quiet_hours_end": 450}', 1635153600000, 47, 'JENREF', 1609891200000, 1635153600000),
('usr_007', 'robert.taylor@example.com', '+14155550107', '$2a$10$abcdefghijklmnopqrstuvwxyz0123411', 'Robert', 'Taylor', 'https://picsum.photos/seed/robert192021/200', 'admin', true, true, '{"push": true, "sms": true, "email": true, "quiet_hours_start": 0, "quiet_hours_end": 0}', 1635240000000, 103, 'ADMIN1REF', 1609977600000, 1635240000000),
('usr_008', 'james.anderson@example.com', '+14155550108', '$2a$10$abcdefghijklmnopqrstuvwxyz0123412', 'James', 'Anderson', 'https://picsum.photos/seed/james222324/200', 'sender', true, false, '{"push": true, "sms": false, "email": true, "quiet_hours_start": 1320, "quiet_hours_end": 420}', 1635326400000, 29, 'JAMESREF', 1610064000000, 1635326400000),
('usr_009', 'mary.jackson@example.com', '+14155550109', '$2a$10$abcdefghijklmnopqrstuvwxyz0123413', 'Mary', 'Jackson', 'https://picsum.photos/seed/mary252627/200', 'courier', true, true, '{"push": true, "sms": true, "email": true, "quiet_hours_start": 1440, "quiet_hours_end": 360}', 1635412800000, 88, 'MARYREF', 1610150400000, 1635412800000),
('usr_010', 'patricia.white@example.com', '+14155550110', '$2a$10$abcdefghijklmnopqrstuvwxyz0123414', 'Patricia', 'White', 'https://picsum.photos/seed/patricia282930/200', 'sender', false, true, '{"push": false, "sms": true, "email": true, "quiet_hours_start": 1380, "quiet_hours_end": 420}', 1635499200000, 31, 'PATRICIAREF', 1610236800000, 1635499200000);

-- Seed data for courier_profiles table
INSERT INTO courier_profiles (uid, user_id, vehicle_type, vehicle_make, vehicle_model, license_plate, id_verification_status, id_verification_documents, background_check_status, background_check_date, service_areas, current_location, availability_status, availability_schedule, account_balance, lifetime_deliveries, lifetime_earnings, average_rating, total_ratings, bank_account_info, created_at, updated_at)
VALUES
('cpr_001', 'usr_003', 'car', 'Toyota', 'Corolla', 'ABC123', 'verified', '[{"document_type": "drivers_license", "document_url": "https://example.com/docs/dl_michael.jpg", "uploaded_at": 1609632000000}]', 'approved', 1610150400000, '[{"latitude": 37.7749, "longitude": -122.4194}, {"latitude": 37.7749, "longitude": -122.4294}, {"latitude": 37.7849, "longitude": -122.4294}, {"latitude": 37.7849, "longitude": -122.4194}]', '{"latitude": 37.7749, "longitude": -122.4194, "last_updated_at": 1635412800000}', 'available', '[{"day_of_week": 1, "start_time": 540, "end_time": 1080}, {"day_of_week": 2, "start_time": 540, "end_time": 1080}, {"day_of_week": 3, "start_time": 540, "end_time": 1080}, {"day_of_week": 4, "start_time": 540, "end_time": 1080}, {"day_of_week": 5, "start_time": 540, "end_time": 1080}]', 258.75, 583, 13492.50, 4.8, 521, '{"account_holder_name": "Michael Brown", "bank_name": "Chase Bank", "account_number_last_four": "7890", "routing_number_last_four": "2345"}', 1609632000000, 1634894400000),
('cpr_002', 'usr_004', 'motorcycle', 'Honda', 'CB500F', 'XYZ789', 'verified', '[{"document_type": "drivers_license", "document_url": "https://example.com/docs/dl_sarah.jpg", "uploaded_at": 1609718400000}, {"document_type": "id_card", "document_url": "https://example.com/docs/id_sarah.jpg", "uploaded_at": 1609718400000}]', 'approved', 1610236800000, '[{"latitude": 37.3382, "longitude": -121.8863}, {"latitude": 37.3382, "longitude": -121.8963}, {"latitude": 37.3482, "longitude": -121.8963}, {"latitude": 37.3482, "longitude": -121.8863}]', '{"latitude": 37.3382, "longitude": -121.8863, "last_updated_at": 1635499200000}', 'busy', '[{"day_of_week": 1, "start_time": 600, "end_time": 1020}, {"day_of_week": 2, "start_time": 600, "end_time": 1020}, {"day_of_week": 3, "start_time": 600, "end_time": 1020}, {"day_of_week": 4, "start_time": 600, "end_time": 1020}, {"day_of_week": 5, "start_time": 600, "end_time": 1020}, {"day_of_week": 6, "start_time": 660, "end_time": 960}]', 175.25, 427, 9835.75, 4.7, 398, '{"account_holder_name": "Sarah Wilson", "bank_name": "Bank of America", "account_number_last_four": "4567", "routing_number_last_four": "8901"}', 1609718400000, 1634980800000),
('cpr_003', 'usr_009', 'bicycle', NULL, NULL, NULL, 'verified', '[{"document_type": "passport", "document_url": "https://example.com/docs/passport_mary.jpg", "uploaded_at": 1610150400000}, {"document_type": "id_card", "document_url": "https://example.com/docs/id_mary.jpg", "uploaded_at": 1610150400000}]', 'approved', 1610496000000, '[{"latitude": 40.7128, "longitude": -74.0060}, {"latitude": 40.7128, "longitude": -74.0160}, {"latitude": 40.7228, "longitude": -74.0160}, {"latitude": 40.7228, "longitude": -74.0060}]', '{"latitude": 40.7128, "longitude": -74.0060, "last_updated_at": 1635585600000}', 'offline', '[{"day_of_week": 2, "start_time": 540, "end_time": 900}, {"day_of_week": 3, "start_time": 540, "end_time": 900}, {"day_of_week": 4, "start_time": 540, "end_time": 900}, {"day_of_week": 5, "start_time": 540, "end_time": 900}, {"day_of_week": 6, "start_time": 660, "end_time": 1080}, {"day_of_week": 0, "start_time": 660, "end_time": 1080}]', 119.50, 315, 6872.25, 4.9, 289, '{"account_holder_name": "Mary Jackson", "bank_name": "Wells Fargo", "account_number_last_four": "6789", "routing_number_last_four": "3456"}', 1610150400000, 1635412800000);

-- Seed data for business_profiles table
INSERT INTO business_profiles (uid, user_id, business_name, business_type, tax_id, website, business_phone, business_email, logo_url, business_hours, billing_address, invoice_email, payment_terms, monthly_deliveries, total_deliveries, require_approval_above, approval_workflow, subscription_plan, subscription_status, created_at, updated_at)
VALUES
('bpr_001', 'usr_005', 'TechCorp Solutions', 'Technology', 'EIN-123456789', 'https://techcorp.example.com', '+14155550125', 'billing@techcorp.example.com', 'https://picsum.photos/seed/techcorp/200', '[{"day_of_week": 1, "open_time": 540, "close_time": 1020}, {"day_of_week": 2, "open_time": 540, "close_time": 1020}, {"day_of_week": 3, "open_time": 540, "close_time": 1020}, {"day_of_week": 4, "open_time": 540, "close_time": 1020}, {"day_of_week": 5, "open_time": 540, "close_time": 1020}]', '{"line1": "123 Tech Street", "line2": "Suite 400", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US"}', 'invoices@techcorp.example.com', 30, 152, 1834, 500.00, 'single', 'premium', 'active', 1609804800000, 1635067200000),
('bpr_002', 'usr_006', 'Retail Dynamics', 'Retail', 'EIN-987654321', 'https://retaildynamics.example.com', '+14155550126', 'billing@retaildynamics.example.com', 'https://picsum.photos/seed/retail/200', '[{"day_of_week": 0, "open_time": 600, "close_time": 1080}, {"day_of_week": 1, "open_time": 540, "close_time": 1140}, {"day_of_week": 2, "open_time": 540, "close_time": 1140}, {"day_of_week": 3, "open_time": 540, "close_time": 1140}, {"day_of_week": 4, "open_time": 540, "close_time": 1140}, {"day_of_week": 5, "open_time": 540, "close_time": 1140}, {"day_of_week": 6, "open_time": 600, "close_time": 1080}]', '{"line1": "456 Retail Avenue", "line2": "Floor 2", "city": "San Jose", "state": "CA", "postal_code": "95113", "country": "US"}', 'accounting@retaildynamics.example.com', 15, 247, 2856, 250.00, 'multi', 'enterprise', 'active', 1609891200000, 1635153600000);

-- Seed data for business_members table
INSERT INTO business_members (uid, business_id, user_id, role, permissions, cost_center, max_order_value, requires_approval, invited_by, invite_status, created_at, updated_at)
VALUES
('bme_001', 'bpr_001', 'usr_005', 'admin', '["manage_users", "manage_deliveries", "manage_billing", "approve_orders"]', 'MAIN', NULL, false, NULL, 'accepted', 1609804800000, 1609804800000),
('bme_002', 'bpr_001', 'usr_008', 'member', '["request_deliveries"]', 'ENG', 100.00, true, 'usr_005', 'accepted', 1610064000000, 1610064000000),
('bme_003', 'bpr_002', 'usr_006', 'admin', '["manage_users", "manage_deliveries", "manage_billing", "approve_orders"]', 'HQ', NULL, false, NULL, 'accepted', 1609891200000, 1609891200000),
('bme_004', 'bpr_002', 'usr_010', 'manager', '["request_deliveries", "approve_orders"]', 'RETAIL', 500.00, false, 'usr_006', 'accepted', 1610236800000, 1610236800000);

-- Seed data for addresses table
INSERT INTO addresses (uid, user_id, type, label, recipient_name, recipient_phone, line1, line2, city, state, postal_code, country, latitude, longitude, delivery_instructions, is_default, is_business, business_name, access_code, is_frequently_used, created_at, updated_at)
VALUES
('adr_001', 'usr_001', 'home', 'My Home', 'John Smith', '+14155550101', '123 Main Street', 'Apt 4B', 'San Francisco', 'CA', '94105', 'US', 37.7749, -122.4194, 'Ring doorbell twice', true, false, NULL, '1234', true, 1609459200000, 1609459200000),
('adr_002', 'usr_001', 'work', 'My Office', 'John Smith', '+14155550101', '555 Market Street', '10th Floor', 'San Francisco', 'CA', '94105', 'US', 37.7896, -122.3996, 'Check in with reception', false, true, 'Acme Corp', NULL, true, 1609459200000, 1609459200000),
('adr_003', 'usr_002', 'home', 'My Apartment', 'Emily Jones', '+14155550102', '789 Harrison Street', 'Unit 303', 'San Francisco', 'CA', '94107', 'US', 37.7812, -122.3984, 'Leave with doorman if not home', true, false, NULL, '5678', true, 1609545600000, 1609545600000),
('adr_004', 'usr_005', 'work', 'Main Office', 'David Lee', '+14155550105', '123 Tech Street', 'Suite 400', 'San Francisco', 'CA', '94105', 'US', 37.7749, -122.4194, 'Delivery entrance on side of building', true, true, 'TechCorp Solutions', '4321', true, 1609804800000, 1609804800000),
('adr_005', 'usr_006', 'work', 'Headquarters', 'Jennifer Williams', '+14155550106', '456 Retail Avenue', 'Floor 2', 'San Jose', 'CA', '95113', 'US', 37.3382, -121.8863, 'Delivery dock in rear', true, true, 'Retail Dynamics', '7890', true, 1609891200000, 1609891200000),
('adr_006', 'usr_008', 'home', 'My House', 'James Anderson', '+14155550108', '567 Oak Street', NULL, 'Palo Alto', 'CA', '94301', 'US', 37.4419, -122.1430, 'Leave packages at front door', true, false, NULL, NULL, true, 1610064000000, 1610064000000),
('adr_007', 'usr_010', 'home', 'Home', 'Patricia White', '+14155550110', '890 Pine Street', 'Apt 12C', 'San Francisco', 'CA', '94109', 'US', 37.7929, -122.4118, 'Call when arriving', true, false, NULL, '9876', false, 1610236800000, 1610236800000),
('adr_008', 'usr_002', 'other', 'Mom\'s House', 'Anna Jones', '+14155550120', '321 Maple Avenue', NULL, 'San Jose', 'CA', '95123', 'US', 37.2751, -121.8261, 'Knock loudly, mom is hard of hearing', false, false, NULL, NULL, false, 1609545600000, 1609545600000),
('adr_009', 'usr_001', 'other', 'Vacation Home', 'John Smith', '+14155550101', '789 Beach Drive', NULL, 'Santa Cruz', 'CA', '95060', 'US', 36.9741, -122.0308, 'Hidden key under plant pot', false, false, NULL, NULL, false, 1609459200000, 1609459200000),
('adr_010', 'usr_006', 'work', 'Branch Office', 'Jennifer Williams', '+14155550106', '222 Branch Street', 'Suite 15', 'Oakland', 'CA', '94612', 'US', 37.8044, -122.2711, 'Ask for shipping department', false, true, 'Retail Dynamics', NULL, true, 1609891200000, 1609891200000);

-- Seed data for payment_methods table
INSERT INTO payment_methods (uid, user_id, payment_type, provider_payment_token, card_last_four, card_brand, card_expiry_month, card_expiry_year, billing_address, is_default, created_at, updated_at)
VALUES
('pm_001', 'usr_001', 'credit_card', 'tok_visa_123456', '4242', 'Visa', 12, 2023, '{"line1": "123 Main Street", "line2": "Apt 4B", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US"}', true, 1609459200000, 1609459200000),
('pm_002', 'usr_001', 'apple_pay', 'tok_apple_789012', NULL, NULL, NULL, NULL, NULL, false, 1609459200000, 1609459200000),
('pm_003', 'usr_002', 'credit_card', 'tok_mastercard_345678', '5678', 'Mastercard', 10, 2024, '{"line1": "789 Harrison Street", "line2": "Unit 303", "city": "San Francisco", "state": "CA", "postal_code": "94107", "country": "US"}', true, 1609545600000, 1609545600000),
('pm_004', 'usr_005', 'credit_card', 'tok_amex_901234', '0123', 'American Express', 5, 2025, '{"line1": "123 Tech Street", "line2": "Suite 400", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US"}', true, 1609804800000, 1609804800000),
('pm_005', 'usr_006', 'credit_card', 'tok_visa_567890', '1234', 'Visa', 8, 2024, '{"line1": "456 Retail Avenue", "line2": "Floor 2", "city": "San Jose", "state": "CA", "postal_code": "95113", "country": "US"}', true, 1609891200000, 1609891200000),
('pm_006', 'usr_008', 'google_pay', 'tok_google_234567', NULL, NULL, NULL, NULL, NULL, true, 1610064000000, 1610064000000),
('pm_007', 'usr_010', 'credit_card', 'tok_discover_890123', '9012', 'Discover', 3, 2023, '{"line1": "890 Pine Street", "line2": "Apt 12C", "city": "San Francisco", "state": "CA", "postal_code": "94109", "country": "US"}', true, 1610236800000, 1610236800000);

-- Seed data for courier_payouts table
INSERT INTO courier_payouts (uid, courier_id, amount, currency, period_start, period_end, status, transaction_id, reference_number, earnings_count, notes, created_at, updated_at)
VALUES
('cpo_001', 'usr_003', 524.75, 'USD', 1633046400000, 1633651200000, 'completed', 'txn_payout_123456', 'REF123456', 23, NULL, 1633737600000, 1633737600000),
('cpo_002', 'usr_004', 398.50, 'USD', 1633046400000, 1633651200000, 'completed', 'txn_payout_234567', 'REF234567', 17, NULL, 1633737600000, 1633737600000),
('cpo_003', 'usr_009', 289.25, 'USD', 1633046400000, 1633651200000, 'completed', 'txn_payout_345678', 'REF345678', 13, NULL, 1633737600000, 1633737600000),
('cpo_004', 'usr_003', 612.50, 'USD', 1633651200000, 1634256000000, 'completed', 'txn_payout_456789', 'REF456789', 27, NULL, 1634342400000, 1634342400000),
('cpo_005', 'usr_004', 437.75, 'USD', 1633651200000, 1634256000000, 'completed', 'txn_payout_567890', 'REF567890', 19, NULL, 1634342400000, 1634342400000),
('cpo_006', 'usr_009', 342.00, 'USD', 1633651200000, 1634256000000, 'completed', 'txn_payout_678901', 'REF678901', 15, NULL, 1634342400000, 1634342400000),
('cpo_007', 'usr_003', 583.25, 'USD', 1634256000000, 1634860800000, 'pending', NULL, 'REF789012', 25, NULL, 1634947200000, 1634947200000),
('cpo_008', 'usr_004', 415.50, 'USD', 1634256000000, 1634860800000, 'pending', NULL, 'REF890123', 18, NULL, 1634947200000, 1634947200000),
('cpo_009', 'usr_009', 315.75, 'USD', 1634256000000, 1634860800000, 'pending', NULL, 'REF901234', 14, NULL, 1634947200000, 1634947200000);

-- Seed data for delivery_requests table
INSERT INTO delivery_requests (uid, sender_id, courier_id, business_id, status, request_time, scheduled_pickup_time, estimated_delivery_time, actual_pickup_time, actual_delivery_time, package_size, package_weight, package_type, special_instructions, is_fragile, requires_id_check, proof_of_delivery_type, pickup_location, dropoff_location, distance, estimated_duration, price, payment_method_id, payment_status, transaction_id, tracking_code, notes, insurance_option, is_contactless_delivery, created_at, updated_at)
VALUES
('del_001', 'usr_001', 'usr_003', NULL, 'completed', 1634720400000, 1634721600000, 1634725200000, 1634721900000, 1634725500000, 'small', 2.5, 'document', 'Handle with care', false, false, 'photo', '{"address_id": "adr_001", "line1": "123 Main Street", "line2": "Apt 4B", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US", "latitude": 37.7749, "longitude": -122.4194, "instructions": "Ring doorbell twice", "contact_name": "John Smith", "contact_phone": "+14155550101"}', '{"address_id": "adr_003", "line1": "789 Harrison Street", "line2": "Unit 303", "city": "San Francisco", "state": "CA", "postal_code": "94107", "country": "US", "latitude": 37.7812, "longitude": -122.3984, "instructions": "Leave with doorman if not home", "contact_name": "Emily Jones", "contact_phone": "+14155550102"}', 3.2, 15, '{"base_fare": 7.50, "distance_fare": 6.40, "weight_fare": 1.25, "time_fare": 3.75, "surge_multiplier": 1.0, "special_handling_fee": 0.00, "insurance_fee": 0.00, "tax": 1.89, "tip": 3.00, "total": 23.79, "currency": "USD"}', 'pm_001', 'charged', 'txn_charge_123456', 'TRACK123456', NULL, '{"level": "none", "coverage_amount": 0.00, "fee": 0.00}', false, 1634720400000, 1634725500000),
('del_002', 'usr_002', 'usr_004', NULL, 'completed', 1634735700000, 1634737200000, 1634741100000, 1634737500000, 1634741300000, 'medium', 5.8, 'package', NULL, false, false, 'signature', '{"address_id": "adr_003", "line1": "789 Harrison Street", "line2": "Unit 303", "city": "San Francisco", "state": "CA", "postal_code": "94107", "country": "US", "latitude": 37.7812, "longitude": -122.3984, "instructions": "Leave with doorman if not home", "contact_name": "Emily Jones", "contact_phone": "+14155550102"}', '{"address_id": "adr_008", "line1": "321 Maple Avenue", "line2": null, "city": "San Jose", "state": "CA", "postal_code": "95123", "country": "US", "latitude": 37.2751, "longitude": -121.8261, "instructions": "Knock loudly, mom is hard of hearing", "contact_name": "Anna Jones", "contact_phone": "+14155550120"}', 68.9, 65, '{"base_fare": 7.50, "distance_fare": 137.80, "weight_fare": 2.90, "time_fare": 16.25, "surge_multiplier": 1.1, "special_handling_fee": 0.00, "insurance_fee": 5.00, "tax": 16.95, "tip": 6.00, "total": 192.40, "currency": "USD"}', 'pm_003', 'charged', 'txn_charge_234567', 'TRACK234567', NULL, '{"level": "basic", "coverage_amount": 100.00, "fee": 5.00}', false, 1634735700000, 1634741300000),
('del_003', 'usr_005', 'usr_009', 'bpr_001', 'completed', 1634810400000, 1634812200000, 1634816400000, 1634812500000, 1634816700000, 'large', 12.3, 'equipment', 'Fragile equipment inside, handle with extreme care', true, true, 'photo', '{"address_id": "adr_004", "line1": "123 Tech Street", "line2": "Suite 400", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US", "latitude": 37.7749, "longitude": -122.4194, "instructions": "Delivery entrance on side of building", "contact_name": "David Lee", "contact_phone": "+14155550105"}', '{"line1": "980 Market Street", "line2": "Floor 5", "city": "San Francisco", "state": "CA", "postal_code": "94102", "country": "US", "latitude": 37.7837, "longitude": -122.4089, "instructions": "Check in at front desk", "contact_name": "Mike Chen", "contact_phone": "+14155550115"}', 2.1, 10, '{"base_fare": 7.50, "distance_fare": 4.20, "weight_fare": 6.15, "time_fare": 2.50, "surge_multiplier": 1.0, "special_handling_fee": 10.00, "insurance_fee": 15.00, "tax": 4.54, "tip": 0.00, "total": 49.89, "currency": "USD"}', 'pm_004', 'charged', 'txn_charge_345678', 'TRACK345678', 'Business delivery', '{"level": "premium", "coverage_amount": 1000.00, "fee": 15.00}', false, 1634810400000, 1634816700000),
('del_004', 'usr_006', 'usr_003', 'bpr_002', 'completed', 1634821200000, 1634823000000, 1634828700000, 1634823300000, 1634828900000, 'large', 15.7, 'merchandise', 'Retail inventory', false, false, 'photo', '{"address_id": "adr_005", "line1": "456 Retail Avenue", "line2": "Floor 2", "city": "San Jose", "state": "CA", "postal_code": "95113", "country": "US", "latitude": 37.3382, "longitude": -121.8863, "instructions": "Delivery dock in rear", "contact_name": "Jennifer Williams", "contact_phone": "+14155550106"}', '{"address_id": "adr_010", "line1": "222 Branch Street", "line2": "Suite 15", "city": "Oakland", "state": "CA", "postal_code": "94612", "country": "US", "latitude": 37.8044, "longitude": -122.2711, "instructions": "Ask for shipping department", "contact_name": "Jennifer Williams", "contact_phone": "+14155550106"}', 70.5, 55, '{"base_fare": 7.50, "distance_fare": 141.00, "weight_fare": 7.85, "time_fare": 13.75, "surge_multiplier": 1.0, "special_handling_fee": 5.00, "insurance_fee": 10.00, "tax": 18.51, "tip": 0.00, "total": 203.61, "currency": "USD"}', 'pm_005', 'charged', 'txn_charge_456789', 'TRACK456789', 'Branch office delivery', '{"level": "basic", "coverage_amount": 500.00, "fee": 10.00}', false, 1634821200000, 1634828900000),
('del_005', 'usr_008', 'usr_004', NULL, 'completed', 1634889600000, 1634892000000, 1634895600000, 1634892300000, 1634895800000, 'small', 1.8, 'gift', 'Birthday present, wrap nicely', false, false, 'signature', '{"address_id": "adr_006", "line1": "567 Oak Street", "line2": null, "city": "Palo Alto", "state": "CA", "postal_code": "94301", "country": "US", "latitude": 37.4419, "longitude": -122.1430, "instructions": "Leave packages at front door", "contact_name": "James Anderson", "contact_phone": "+14155550108"}', '{"line1": "789 University Avenue", "line2": null, "city": "Palo Alto", "state": "CA", "postal_code": "94301", "country": "US", "latitude": 37.4432, "longitude": -122.1599, "instructions": "Ring doorbell", "contact_name": "Thomas Rogers", "contact_phone": "+14155550130"}', 2.8, 8, '{"base_fare": 7.50, "distance_fare": 5.60, "weight_fare": 0.90, "time_fare": 2.00, "surge_multiplier": 1.0, "special_handling_fee": 2.00, "insurance_fee": 0.00, "tax": 1.80, "tip": 5.00, "total": 24.80, "currency": "USD"}', 'pm_006', 'charged', 'txn_charge_567890', 'TRACK567890', NULL, '{"level": "none", "coverage_amount": 0.00, "fee": 0.00}', false, 1634889600000, 1634895800000),
('del_006', 'usr_010', 'usr_009', NULL, 'completed', 1634900400000, 1634902200000, 1634906400000, 1634902500000, 1634906700000, 'medium', 4.2, 'food', 'Keep refrigerated', false, false, 'photo', '{"address_id": "adr_007", "line1": "890 Pine Street", "line2": "Apt 12C", "city": "San Francisco", "state": "CA", "postal_code": "94109", "country": "US", "latitude": 37.7929, "longitude": -122.4118, "instructions": "Call when arriving", "contact_name": "Patricia White", "contact_phone": "+14155550110"}', '{"line1": "1001 Van Ness Avenue", "line2": "Suite 301", "city": "San Francisco", "state": "CA", "postal_code": "94109", "country": "US", "latitude": 37.7850, "longitude": -122.4212, "instructions": "Office hours 9-5", "contact_name": "Linda Martinez", "contact_phone": "+14155550140"}', 1.9, 10, '{"base_fare": 7.50, "distance_fare": 3.80, "weight_fare": 2.10, "time_fare": 2.50, "surge_multiplier": 1.2, "special_handling_fee": 5.00, "insurance_fee": 0.00, "tax": 2.51, "tip": 4.00, "total": 29.83, "currency": "USD"}', 'pm_007', 'charged', 'txn_charge_678901', 'TRACK678901', NULL, '{"level": "none", "coverage_amount": 0.00, "fee": 0.00}', true, 1634900400000, 1634906700000),
('del_007', 'usr_001', 'usr_003', NULL, 'en_route_to_delivery', 1634997000000, 1634998800000, 1635002400000, 1634999100000, NULL, 'medium', 6.5, 'electronics', 'Handle with care, contains electronics', true, false, 'signature', '{"address_id": "adr_001", "line1": "123 Main Street", "line2": "Apt 4B", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US", "latitude": 37.7749, "longitude": -122.4194, "instructions": "Ring doorbell twice", "contact_name": "John Smith", "contact_phone": "+14155550101"}', '{"address_id": "adr_002", "line1": "555 Market Street", "line2": "10th Floor", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US", "latitude": 37.7896, "longitude": -122.3996, "instructions": "Check in with reception", "contact_name": "John Smith", "contact_phone": "+14155550101"}', 2.3, 12, '{"base_fare": 7.50, "distance_fare": 4.60, "weight_fare": 3.25, "time_fare": 3.00, "surge_multiplier": 1.0, "special_handling_fee": 8.00, "insurance_fee": 5.00, "tax": 3.14, "tip": 0.00, "total": 34.49, "currency": "USD"}', 'pm_001', 'authorized', 'txn_auth_789012', 'TRACK789012', NULL, '{"level": "basic", "coverage_amount": 100.00, "fee": 5.00}', false, 1634997000000, 1634999100000),
('del_008', 'usr_002', NULL, NULL, 'pending', 1635010000000, 1635013600000, 1635017200000, NULL, NULL, 'small', 1.5, 'document', 'Confidential documents', false, true, 'signature', '{"address_id": "adr_003", "line1": "789 Harrison Street", "line2": "Unit 303", "city": "San Francisco", "state": "CA", "postal_code": "94107", "country": "US", "latitude": 37.7812, "longitude": -122.3984, "instructions": "Leave with doorman if not home", "contact_name": "Emily Jones", "contact_phone": "+14155550102"}', '{"line1": "101 California Street", "line2": "Suite 2300", "city": "San Francisco", "state": "CA", "postal_code": "94111", "country": "US", "latitude": 37.7932, "longitude": -122.3984, "instructions": "ID required for delivery", "contact_name": "Robert Johnson", "contact_phone": "+14155550150"}', 1.7, 8, '{"base_fare": 7.50, "distance_fare": 3.40, "weight_fare": 0.75, "time_fare": 2.00, "surge_multiplier": 1.0, "special_handling_fee": 5.00, "insurance_fee": 0.00, "tax": 1.87, "tip": 0.00, "total": 20.52, "currency": "USD"}', 'pm_003', 'pending', NULL, 'TRACK890123', NULL, '{"level": "none", "coverage_amount": 0.00, "fee": 0.00}', false, 1635010000000, 1635010000000),
('del_009', 'usr_005', NULL, 'bpr_001', 'pending', 1635170400000, 1635254400000, 1635265200000, NULL, NULL, 'large', 18.6, 'equipment', 'Server equipment, handle carefully', true, true, 'photo', '{"address_id": "adr_004", "line1": "123 Tech Street", "line2": "Suite 400", "city": "San Francisco", "state": "CA", "postal_code": "94105", "country": "US", "latitude": 37.7749, "longitude": -122.4194, "instructions": "Delivery entrance on side of building", "contact_name": "David Lee", "contact_phone": "+14155550105"}', '{"line1": "1 Infinite Loop", "line2": null, "city": "Cupertino", "state": "CA", "postal_code": "95014", "country": "US", "latitude": 37.3318, "longitude": -122.0312, "instructions": "Check in at security", "contact_name": "Sarah Thompson", "contact_phone": "+14155550160"}', 74.8, 75, '{"base_fare": 7.50, "distance_fare": 149.60, "weight_fare": 9.30, "time_fare": 18.75, "surge_multiplier": 1.0, "special_handling_fee": 15.00, "insurance_fee": 20.00, "tax": 22.02, "tip": 0.00, "total": 242.17, "currency": "USD"}', 'pm_004', 'pending', NULL, 'TRACK901234', 'Scheduled business delivery', '{"level": "premium", "coverage_amount": 2000.00, "fee": 20.00}', false, 1635083400000, 1635083400000),
('del_010', 'usr_006', NULL, 'bpr_002', 'cancelled', 1635184800000, 1635271200000, 1635282000000, NULL, NULL, 'medium', 8.9, 'merchandise', 'Store inventory restock', false, false, 'photo', '{"address_id": "adr_005", "line1": "456 Retail Avenue", "line2": "Floor 2", "city": "San Jose", "state": "CA", "postal_code": "95113", "country": "US", "latitude": 37.3382, "longitude": -121.8863, "instructions": "Delivery dock in rear", "contact_name": "Jennifer Williams", "contact_phone": "+14155550106"}', '{"line1": "2855 Stevens Creek Blvd", "line2": null, "city": "Santa Clara", "state": "CA", "postal_code": "95050", "country": "US", "latitude": 37.3239, "longitude": -121.9453, "instructions": "Delivery entrance at back of mall", "contact_name": "Retail Store Manager", "contact_phone": "+14155550170"}', 10.3, 25, '{"base_fare": 7.50, "distance_fare": 20.60, "weight_fare": 4.45, "time_fare": 6.25, "surge_multiplier": 1.0, "special_handling_fee": 0.00, "insurance_fee": 5.00, "tax": 4.38, "tip": 0.00, "total": 48.18, "currency": "USD"}', 'pm_005', 'refunded', 'txn_refund_012345', 'TRACK012345', NULL, '{"level": "basic", "coverage_amount": 200.00, "fee": 5.00}', false, 1635097800000, 1635105000000);

-- Seed data for delivery_tracking table
INSERT INTO delivery_tracking (uid, delivery_id, status_updates, courier_locations, estimated_arrival_time, is_delayed, delay_reason, created_at, updated_at)
VALUES
('dtr_001', 'del_001', '[{"status": "pending", "timestamp": 1634720400000, "updated_by": "usr_001", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634720700000, "updated_by": "usr_003", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634721000000, "updated_by": "usr_003", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634721600000, "updated_by": "usr_003", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634721900000, "updated_by": "usr_003", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634722200000, "updated_by": "usr_003", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634725200000, "updated_by": "usr_003", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634725500000, "updated_by": "usr_003", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634725500000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.7749, "longitude": -122.4194, "timestamp": 1634720700000, "accuracy": 5}, {"latitude": 37.7755, "longitude": -122.4130, "timestamp": 1634721000000, "accuracy": 6}, {"latitude": 37.7749, "longitude": -122.4194, "timestamp": 1634721600000, "accuracy": 4}, {"latitude": 37.7765, "longitude": -122.4121, "timestamp": 1634722200000, "accuracy": 5}, {"latitude": 37.7785, "longitude": -122.4056, "timestamp": 1634723400000, "accuracy": 7}, {"latitude": 37.7812, "longitude": -122.3984, "timestamp": 1634725200000, "accuracy": 4}]', 1634725200000, false, NULL, 1634720400000, 1634725500000),
('dtr_002', 'del_002', '[{"status": "pending", "timestamp": 1634735700000, "updated_by": "usr_002", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634736000000, "updated_by": "usr_004", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634736300000, "updated_by": "usr_004", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634737200000, "updated_by": "usr_004", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634737500000, "updated_by": "usr_004", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634737800000, "updated_by": "usr_004", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634741100000, "updated_by": "usr_004", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634741300000, "updated_by": "usr_004", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634741300000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.7812, "longitude": -122.3984, "timestamp": 1634736000000, "accuracy": 4}, {"latitude": 37.7500, "longitude": -122.2000, "timestamp": 1634739000000, "accuracy": 8}, {"latitude": 37.2751, "longitude": -121.8261, "timestamp": 1634741100000, "accuracy": 5}]', 1634741100000, false, NULL, 1634735700000, 1634741300000),
('dtr_003', 'del_003', '[{"status": "pending", "timestamp": 1634810400000, "updated_by": "usr_005", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634810700000, "updated_by": "usr_009", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634811000000, "updated_by": "usr_009", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634812200000, "updated_by": "usr_009", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634812500000, "updated_by": "usr_009", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634812800000, "updated_by": "usr_009", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634816400000, "updated_by": "usr_009", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634816700000, "updated_by": "usr_009", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634816700000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.7749, "longitude": -122.4194, "timestamp": 1634810700000, "accuracy": 6}, {"latitude": 37.7780, "longitude": -122.4150, "timestamp": 1634812800000, "accuracy": 5}, {"latitude": 37.7837, "longitude": -122.4089, "timestamp": 1634816400000, "accuracy": 4}]', 1634816400000, false, NULL, 1634810400000, 1634816700000),
('dtr_004', 'del_004', '[{"status": "pending", "timestamp": 1634821200000, "updated_by": "usr_006", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634821500000, "updated_by": "usr_003", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634821800000, "updated_by": "usr_003", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634823000000, "updated_by": "usr_003", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634823300000, "updated_by": "usr_003", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634823600000, "updated_by": "usr_003", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634828700000, "updated_by": "usr_003", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634828900000, "updated_by": "usr_003", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634828900000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.3382, "longitude": -121.8863, "timestamp": 1634821500000, "accuracy": 5}, {"latitude": 37.5000, "longitude": -122.0000, "timestamp": 1634825000000, "accuracy": 10}, {"latitude": 37.8044, "longitude": -122.2711, "timestamp": 1634828700000, "accuracy": 6}]', 1634828700000, false, NULL, 1634821200000, 1634828900000),
('dtr_005', 'del_005', '[{"status": "pending", "timestamp": 1634889600000, "updated_by": "usr_008", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634889900000, "updated_by": "usr_004", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634890200000, "updated_by": "usr_004", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634892000000, "updated_by": "usr_004", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634892300000, "updated_by": "usr_004", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634892600000, "updated_by": "usr_004", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634895600000, "updated_by": "usr_004", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634895800000, "updated_by": "usr_004", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634895800000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.4419, "longitude": -122.1430, "timestamp": 1634889900000, "accuracy": 5}, {"latitude": 37.4425, "longitude": -122.1515, "timestamp": 1634892600000, "accuracy": 6}, {"latitude": 37.4432, "longitude": -122.1599, "timestamp": 1634895600000, "accuracy": 4}]', 1634895600000, false, NULL, 1634889600000, 1634895800000),
('dtr_006', 'del_006', '[{"status": "pending", "timestamp": 1634900400000, "updated_by": "usr_010", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634900700000, "updated_by": "usr_009", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634901000000, "updated_by": "usr_009", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634902200000, "updated_by": "usr_009", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634902500000, "updated_by": "usr_009", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634902800000, "updated_by": "usr_009", "notes": "En route to delivery"}, {"status": "at_delivery", "timestamp": 1634906400000, "updated_by": "usr_009", "notes": "Arrived at delivery location"}, {"status": "delivered", "timestamp": 1634906700000, "updated_by": "usr_009", "notes": "Package delivered"}, {"status": "completed", "timestamp": 1634906700000, "updated_by": "system", "notes": "Delivery complete"}]', '[{"latitude": 37.7929, "longitude": -122.4118, "timestamp": 1634900700000, "accuracy": 5}, {"latitude": 37.7890, "longitude": -122.4165, "timestamp": 1634902800000, "accuracy": 7}, {"latitude": 37.7850, "longitude": -122.4212, "timestamp": 1634906400000, "accuracy": 4}]', 1634906400000, false, NULL, 1634900400000, 1634906700000),
('dtr_007', 'del_007', '[{"status": "pending", "timestamp": 1634997000000, "updated_by": "usr_001", "notes": "Delivery requested"}, {"status": "accepted", "timestamp": 1634997300000, "updated_by": "usr_003", "notes": "Courier accepted"}, {"status": "en_route_to_pickup", "timestamp": 1634997600000, "updated_by": "usr_003", "notes": "En route to pickup"}, {"status": "at_pickup", "timestamp": 1634998800000, "updated_by": "usr_003", "notes": "Arrived at pickup"}, {"status": "picked_up", "timestamp": 1634999100000, "updated_by": "usr_003", "notes": "Package picked up"}, {"status": "en_route_to_delivery", "timestamp": 1634999400000, "updated_by": "usr_003", "notes": "En route to delivery"}]', '[{"latitude": 37.7749, "longitude": -122.4194, "timestamp": 1634997300000, "accuracy": 5}, {"latitude": 37.7749, "longitude": -122.4194, "timestamp": 1634998800000, "accuracy": 4}, {"latitude": 37.7820, "longitude": -122.4100, "timestamp": 1634999400000, "accuracy": 6}, {"latitude": 37.7850, "longitude": -122.4050, "timestamp": 1635000000000, "accuracy": 8}]', 1635002400000, false, NULL, 1634997000000, 1635000000000),
('dtr_008', 'del_008', '[{"status": "pending", "timestamp": 1635010000000, "updated_by": "usr_002", "notes": "Delivery requested"}]', '[]', 1635017200000, false, NULL, 1635010000000, 1635010000000),
('dtr_009', 'del_009', '[{"status": "pending", "timestamp": 1635083400000, "updated_by": "usr_005", "notes": "Delivery scheduled"}]', '[]', 1635265200000, false, NULL, 1635083400000, 1635083400000),
('dtr_010', 'del_010', '[{"status": "pending", "timestamp": 1635097800000, "updated_by": "usr_006", "notes": "Delivery scheduled"}, {"status": "cancelled", "timestamp": 1635105000000, "updated_by": "usr_006", "notes": "Delivery cancelled by sender"}]', '[]', 1635282000000, false, NULL, 1635097800000, 1635105000000);

-- Seed data for delivery_issues table
INSERT INTO delivery_issues (uid, delivery_id, reporter_id, issue_type, severity, description, status, resolution_notes, reported_at, resolved_at, photos, compensation_amount, assigned_to, created_at, updated_at)
VALUES
('dis_001', 'del_002', 'usr_002', 'delay', 'medium', 'Package arrived 5 minutes late', 'resolved', 'Apologized to customer. Traffic delay was unavoidable.', 1634741600000, 1634743400000, NULL, 0, 'usr_007', 1634741600000, 1634743400000),
('dis_002', 'del_003', 'usr_005', 'damage', 'high', 'Package was dented on one corner', 'resolved', 'Issued partial refund as compensation for the damaged item', 1634817000000, 1634820600000, '["https://picsum.photos/seed/damage1/800/600", "https://picsum.photos/seed/damage2/800/600"]', 25.00, 'usr_007', 1634817000000, 1634820600000),
('dis_003', 'del_004', 'usr_003', 'wrong_item', 'high', 'Wrong inventory items were loaded', 'closed', 'Not courier\'s fault, sender packed wrong items. No compensation issued.', 1634829200000, 1634832800000, NULL, 0, 'usr_007', 1634829200000, 1634832800000),
('dis_004', 'del_006', 'usr_010', 'other', 'low', 'Courier did not follow special instructions', 'closed', 'Reminded courier about importance of following delivery instructions', 1634907000000, 1634909700000, NULL, 0, 'usr_007', 1634907000000, 1634909700000);

-- Seed data for proof_of_delivery table
INSERT INTO proof_of_delivery (uid, delivery_id, type, content_url, collected_at, collected_by, recipient_name, notes, verification_code, created_at, updated_at)
VALUES
('pod_001', 'del_001', 'photo', 'https://picsum.photos/seed/pod1/800/600', 1634725500000, 'usr_003', 'Emily Jones', 'Left at doorman desk', NULL, 1634725500000, 1634725500000),
('pod_002', 'del_002', 'signature', 'https://picsum.photos/seed/signature1/400/200', 1634741300000, 'usr_004', 'Anna Jones', 'Recipient signed', NULL, 1634741300000, 1634741300000),
('pod_003', 'del_003', 'photo', 'https://picsum.photos/seed/pod2/800/600', 1634816700000, 'usr_009', 'Mike Chen', 'Received at front desk', 'VER123', 1634816700000, 1634816700000),
('pod_004', 'del_004', 'photo', 'https://picsum.photos/seed/pod3/800/600', 1634828900000, 'usr_003', 'Retail Staff', 'Delivered to shipping department', NULL, 1634828900000, 1634828900000),
('pod_005', 'del_005', 'signature', 'https://picsum.photos/seed/signature2/400/200', 1634895800000, 'usr_004', 'Thomas Rogers', 'Recipient signed at door', NULL, 1634895800000, 1634895800000),
('pod_006', 'del_006', 'photo', 'https://picsum.photos/seed/pod4/800/600', 1634906700000, 'usr_009', 'Linda Martinez', 'Left at reception', NULL, 1634906700000, 1634906700000);

-- Seed data for messages table
INSERT INTO messages (uid, delivery_id, sender_id, receiver_id, message_type, content, image_url, sent_at, read_at, created_at, updated_at)
VALUES
('msg_001', 'del_001', 'usr_001', 'usr_003', 'text', 'Hi, please be careful with the package.', NULL, 1634720700000, 1634720800000, 1634720700000, 1634720700000),
('msg_002', 'del_001', 'usr_003', 'usr_001', 'text', 'No problem, I\'ll handle it with care!', NULL, 1634720900000, 1634721000000, 1634720900000, 1634720900000),
('msg_003', 'del_001', 'usr_003', 'usr_001', 'text', 'I\'m at your door now.', NULL, 1634721550000, 1634721600000, 1634721550000, 1634721550000),
('msg_004', 'del_001', 'usr_003', 'usr_001', 'text', 'Package is on the way to recipient!', NULL, 1634722200000, 1634722500000, 1634722200000, 1634722200000),
('msg_005', 'del_001', 'usr_003', 'usr_001', 'image', 'Delivered to doorman as requested', 'https://picsum.photos/seed/delivery1/800/600', 1634725500000, 1634726000000, 1634725500000, 1634725500000),
('msg_006', 'del_002', 'usr_004', 'usr_002', 'text', 'I\'m running about 5 minutes behind schedule due to traffic', NULL, 1634740200000, 1634740300000, 1634740200000, 1634740200000),
('msg_007', 'del_002', 'usr_002', 'usr_004', 'text', 'No problem, thanks for letting me know!', NULL, 1634740400000, 1634740450000, 1634740400000, 1634740400000),
('msg_008', 'del_003', 'usr_005', 'usr_009', 'text', 'Please verify ID before delivery, it\'s valuable equipment', NULL, 1634810900000, 1634811000000, 1634810900000, 1634810900000),
('msg_009', 'del_003', 'usr_009', 'usr_005', 'text', 'Will do. I always check ID when required.', NULL, 1634811100000, 1634811200000, 1634811100000, 1634811100000),
('msg_010', 'del_003', 'usr_009', 'usr_005', 'text', 'ID verified, delivering now', NULL, 1634816450000, 1634816500000, 1634816450000, 1634816450000),
('msg_011', 'del_007', 'usr_001', 'usr_003', 'text', 'Please let me know when you\'re close to delivery', NULL, 1634998000000, 1634998100000, 1634998000000, 1634998000000),
('msg_012', 'del_007', 'usr_003', 'usr_001', 'text', 'Will do, picking up your package now', NULL, 1634999100000, 1634999200000, 1634999100000, 1634999100000),
('msg_013', 'del_007', 'usr_003', 'usr_001', 'text', 'On my way to delivery location, about 10 minutes out', NULL, 1634999900000, 1635000000000, 1634999900000, 1634999900000);

-- Seed data for notifications table
INSERT INTO notifications (uid, user_id, type, title, body, data, channels, status, is_read, created_at, updated_at)
VALUES
('not_001', 'usr_001', 'delivery_update', 'Courier accepted your request', 'Michael B. is on the way to pick up your package', '{"delivery_id": "del_001", "action": "view_delivery", "screen": "tracking", "entity_id": "del_001"}', '["push", "email"]', '{"push": "delivered", "email": "sent"}', true, 1634720700000, 1634720800000),
('not_002', 'usr_001', 'delivery_update', 'Package picked up', 'Your package has been picked up and is on its way', '{"delivery_id": "del_001", "action": "view_delivery", "screen": "tracking", "entity_id": "del_001"}', '["push"]', '{"push": "delivered"}', true, 1634721900000, 1634722000000),
('not_003', 'usr_001', 'delivery_update', 'Package delivered', 'Your package has been delivered successfully', '{"delivery_id": "del_001", "action": "view_delivery", "screen": "tracking", "entity_id": "del_001"}', '["push", "email", "sms"]', '{"push": "delivered", "email": "sent", "sms": "sent"}', true, 1634725500000, 1634726000000),
('not_004', 'usr_003', 'delivery_update', 'New delivery request', 'New delivery request in your area', '{"delivery_id": "del_001", "action": "view_request", "screen": "request_details", "entity_id": "del_001"}', '["push"]', '{"push": "delivered"}', true, 1634720400000, 1634720500000),
('not_005', 'usr_002', 'delivery_update', 'Courier accepted your request', 'Sarah W. is on the way to pick up your package', '{"delivery_id": "del_002", "action": "view_delivery", "screen": "tracking", "entity_id": "del_002"}', '["push", "email"]', '{"push": "delivered", "email": "sent"}', true, 1634736000000, 1634736100000),
('not_006', 'usr_002', 'message', 'New message from courier', 'I\'m running about 5 minutes behind schedule due to traffic', '{"delivery_id": "del_002", "action": "view_messages", "screen": "chat", "entity_id": "del_002"}', '["push"]', '{"push": "delivered"}', true, 1634740200000, 1634740300000),
('not_007', 'usr_002', 'delivery_update', 'Package delivered', 'Your package has been delivered successfully', '{"delivery_id": "del_002", "action": "view_delivery", "screen": "tracking", "entity_id": "del_002"}', '["push", "email", "sms"]', '{"push": "delivered", "email": "sent", "sms": "sent"}', true, 1634741300000, 1634741400000),
('not_008', 'usr_005', 'delivery_update', 'Courier accepted your request', 'Mary J. is on the way to pick up your equipment', '{"delivery_id": "del_003", "action": "view_delivery", "screen": "tracking", "entity_id": "del_003"}', '["email"]', '{"email": "sent"}', true, 1634810700000, 1634810800000),
('not_009', 'usr_005', 'delivery_update', 'Package delivered', 'Your equipment has been delivered successfully', '{"delivery_id": "del_003", "action": "view_delivery", "screen": "tracking", "entity_id": "del_003"}', '["email"]', '{"email": "sent"}', true, 1634816700000, 1634816800000),
('not_010', 'usr_001', 'delivery_update', 'Courier picked up your package', 'Your package is on the way to the destination', '{"delivery_id": "del_007", "action": "view_delivery", "screen": "tracking", "entity_id": "del_007"}', '["push", "email"]', '{"push": "delivered", "email": "sent"}', false, 1634999100000, 1634999100000);

-- Seed data for support_tickets table
INSERT INTO support_tickets (uid, user_id, delivery_id, issue_type, subject, description, status, priority, assigned_to, attachments, resolution_notes, created_at, updated_at, closed_at)
VALUES
('stk_001', 'usr_002', 'del_002', 'delay', 'Delivery was late', 'My delivery was about 5 minutes later than the estimated time.', 'closed', 'low', 'usr_007', NULL, 'Explained to customer that minor delays can happen due to traffic. Offered $5 credit for the inconvenience.', 1634741600000, 1634743400000, 1634743400000),
('stk_002', 'usr_005', 'del_003', 'damage', 'Damaged equipment', 'One of the server rack corners was dented during delivery.', 'closed', 'high', 'usr_007', '[{"url": "https://picsum.photos/seed/damage_evidence/800/600", "filename": "damage.jpg", "content_type": "image/jpeg", "size": 2450000}]', 'Issued $25 partial refund as compensation for the damage. Reminded courier to be more careful with fragile items.', 1634817000000, 1634820600000, 1634820600000),
('stk_003', 'usr_010', 'del_006', 'other', 'Delivery instructions ignored', 'I asked to be called upon arrival but courier did not call.', 'closed', 'low', 'usr_007', NULL, 'Reminded courier about following delivery instructions. Apologized to customer.', 1634907000000, 1634909700000, 1634909700000),
('stk_004', 'usr_008', NULL, 'app_issue', 'App crashes when uploading images', 'When I try to add photos to my delivery, the app crashes every time.', 'open', 'medium', 'usr_007', '[{"url": "https://picsum.photos/seed/app_crash/400/800", "filename": "screenshot.png", "content_type": "image/png", "size": 1230000}]', NULL, 1635000000000, 1635000000000, NULL);

-- Seed data for support_messages table
INSERT INTO support_messages (uid, ticket_id, sender_id, sender_type, message, attachments, is_internal, created_at, updated_at)
VALUES
('spm_001', 'stk_001', 'usr_002', 'user', 'My delivery was late and I had to wait longer than expected.', NULL, false, 1634741600000, 1634741600000),
('spm_002', 'stk_001', 'usr_007', 'support', 'I apologize for the delay. Can you tell me how late the delivery was?', NULL, false, 1634741900000, 1634741900000),
('spm_003', 'stk_001', 'usr_002', 'user', 'It was about 5 minutes late.', NULL, false, 1634742200000, 1634742200000),
('spm_004', 'stk_001', 'usr_007', 'support', 'Customer reports minor delay. Should we offer compensation?', NULL, true, 1634742500000, 1634742500000),
('spm_005', 'stk_001', 'usr_007', 'support', 'Thank you for this information. I apologize for the delay. As a goodwill gesture, I\'ve added a $5 credit to your account for your next delivery.', NULL, false, 1634743100000, 1634743100000),
('spm_006', 'stk_001', 'usr_002', 'user', 'Thank you, I appreciate that.', NULL, false, 1634743400000, 1634743400000),
('spm_007', 'stk_002', 'usr_005', 'user', 'The server rack arrived with a dent in one corner. I\'ve attached a photo of the damage.', '[{"url": "https://picsum.photos/seed/damage_evidence/800/600", "filename": "damage.jpg", "content_type": "image/jpeg", "size": 2450000}]', false, 1634817000000, 1634817000000),
('spm_008', 'stk_002', 'usr_007', 'support', 'I\'m sorry to see this damage. Let me look into this right away. Can you tell me if the equipment still functions properly?', NULL, false, 1634817300000, 1634817300000),
('spm_009', 'stk_002', 'usr_005', 'user', 'The equipment works, but the cosmetic damage is concerning as this was expensive equipment.', NULL, false, 1634817600000, 1634817600000),
('spm_010', 'stk_002', 'usr_007', 'support', 'This appears to be valid damage claim. Recommend $25 partial refund.', NULL, true, 1634818200000, 1634818200000),
('spm_011', 'stk_002', 'usr_007', 'support', 'After reviewing your case, I\'ve authorized a $25 refund for the damage. This will be processed back to your original payment method within 3-5 business days. We sincerely apologize for the inconvenience.', NULL, false, 1634820300000, 1634820300000),
('spm_012', 'stk_002', 'usr_005', 'user', 'Thank you for addressing this promptly.', NULL, false, 1634820600000, 1634820600000);

-- Seed data for ratings table
INSERT INTO ratings (uid, delivery_id, rater_id, rated_id, rating, feedback_categories, comments, rating_type, is_dispute_filed, created_at, updated_at)
VALUES
('rat_001', 'del_001', 'usr_001', 'usr_003', 5, '["punctual", "professional", "careful"]', 'Great service, very professional courier', 'sender_to_courier', false, 1634726800000, 1634726800000),
('rat_002', 'del_001', 'usr_003', 'usr_001', 5, '["clear_instructions", "respectful"]', 'Clear delivery instructions and responsive customer', 'courier_to_sender', false, 1634727100000, 1634727100000),
('rat_003', 'del_002', 'usr_002', 'usr_004', 4, '["professional", "careful"]', 'Good service but slightly late', 'sender_to_courier', false, 1634742600000, 1634742600000),
('rat_004', 'del_002', 'usr_004', 'usr_002', 5, '["clear_instructions", "respectful"]', 'Very understanding about the slight delay', 'courier_to_sender', false, 1634742900000, 1634742900000),
('rat_005', 'del_003', 'usr_005', 'usr_009', 3, '["professional"]', 'Package was delivered but had damage', 'sender_to_courier', true, 1634817900000, 1634817900000),
('rat_006', 'del_003', 'usr_009', 'usr_005', 4, '["clear_instructions"]', 'Good instructions but package was very heavy', 'courier_to_sender', false, 1634818200000, 1634818200000),
('rat_007', 'del_004', 'usr_006', 'usr_003', 5, '["punctual", "professional", "careful"]', 'Excellent service with a large delivery', 'sender_to_courier', false, 1634830700000, 1634830700000),
('rat_008', 'del_004', 'usr_003', 'usr_006', 5, '["clear_instructions", "respectful", "properly_packaged"]', 'Very organized business sender', 'courier_to_sender', false, 1634831000000, 1634831000000),
('rat_009', 'del_005', 'usr_008', 'usr_004', 5, '["punctual", "professional", "careful"]', 'Gift was delivered in perfect condition', 'sender_to_courier', false, 1634897400000, 1634897400000),
('rat_010', 'del_005', 'usr_004', 'usr_008', 5, '["clear_instructions", "respectful"]', 'Pleasant customer with clear instructions', 'courier_to_sender', false, 1634897700000, 1634897700000),
('rat_011', 'del_006', 'usr_010', 'usr_009', 4, '["professional"]', 'Good delivery but didn\'t call as requested', 'sender_to_courier', false, 1634907900000, 1634907900000),
('rat_012', 'del_006', 'usr_009', 'usr_010', 4, '["clear_instructions"]', 'Good customer but delivery location was hard to find', 'courier_to_sender', false, 1634908200000, 1634908200000);

-- Seed data for transactions table
INSERT INTO transactions (uid, user_id, delivery_id, transaction_type, amount, currency, status, payment_method_id, provider_transaction_id, description, metadata, created_at, updated_at)
VALUES
('trx_001', 'usr_001', 'del_001', 'charge', 23.79, 'USD', 'completed', 'pm_001', 'ch_123456789', 'Payment for delivery #TRACK123456', '{"reason_code": "delivery_payment"}', 1634720400000, 1634725500000),
('trx_002', 'usr_002', 'del_002', 'charge', 192.40, 'USD', 'completed', 'pm_003', 'ch_234567890', 'Payment for delivery #TRACK234567', '{"reason_code": "delivery_payment"}', 1634735700000, 1634741300000),
('trx_003', 'usr_005', 'del_003', 'charge', 49.89, 'USD', 'completed', 'pm_004', 'ch_345678901', 'Payment for delivery #TRACK345678', '{"reason_code": "delivery_payment"}', 1634810400000, 1634816700000),
('trx_004', 'usr_006', 'del_004', 'charge', 203.61, 'USD', 'completed', 'pm_005', 'ch_456789012', 'Payment for delivery #TRACK456789', '{"reason_code": "delivery_payment"}', 1634821200000, 1634828900000),
('trx_005', 'usr_008', 'del_005', 'charge', 24.80, 'USD', 'completed', 'pm_006', 'ch_567890123', 'Payment for delivery #TRACK567890', '{"reason_code": "delivery_payment"}', 1634889600000, 1634895800000),
('trx_006', 'usr_010', 'del_006', 'charge', 29.83, 'USD', 'completed', 'pm_007', 'ch_678901234', 'Payment for delivery #TRACK678901', '{"reason_code": "delivery_payment"}', 1634900400000, 1634906700000),
('trx_007', 'usr_001', 'del_007', 'charge', 34.49, 'USD', 'authorized', 'pm_001', 'ch_789012345', 'Payment for delivery #TRACK789012', '{"reason_code": "delivery_payment"}', 1634997000000, 1634997000000),
('trx_008', 'usr_003', NULL, 'payout', 524.75, 'USD', 'completed', NULL, 'po_123456789', 'Weekly payout for Oct 1-7', '{"reason_code": "courier_payout", "reference_id": "cpo_001"}', 1633737600000, 1633737600000),
('trx_009', 'usr_004', NULL, 'payout', 398.50, 'USD', 'completed', NULL, 'po_234567890', 'Weekly payout for Oct 1-7', '{"reason_code": "courier_payout", "reference_id": "cpo_002"}', 1633737600000, 1633737600000),
('trx_010', 'usr_009', NULL, 'payout', 289.25, 'USD', 'completed', NULL, 'po_345678901', 'Weekly payout for Oct 1-7', '{"reason_code": "courier_payout", "reference_id": "cpo_003"}', 1633737600000, 1633737600000),
('trx_011', 'usr_003', NULL, 'payout', 612.50, 'USD', 'completed', NULL, 'po_456789012', 'Weekly payout for Oct 8-14', '{"reason_code": "courier_payout", "reference_id": "cpo_004"}', 1634342400000, 1634342400000),
('trx_012', 'usr_004', NULL, 'payout', 437.75, 'USD', 'completed', NULL, 'po_567890123', 'Weekly payout for Oct 8-14', '{"reason_code": "courier_payout", "reference_id": "cpo_005"}', 1634342400000, 1634342400000),
('trx_013', 'usr_005', 'del_003', 'refund', 25.00, 'USD', 'completed', 'pm_004', 'rf_123456789', 'Partial refund for damage', '{"reason_code": "damage_compensation"}', 1634820600000, 1634820600000),
('trx_014', 'usr_006', 'del_010', 'refund', 48.18, 'USD', 'completed', 'pm_005', 'rf_234567890', 'Full refund for cancelled delivery', '{"reason_code": "delivery_cancelled"}', 1635105000000, 1635105000000);

-- Seed data for courier_earnings table
INSERT INTO courier_earnings (uid, courier_id, delivery_id, base_fare, distance_fee, time_fee, special_fee, tip_amount, platform_fee, tax_amount, total_earning, status, payout_id, created_at, updated_at)
VALUES
('cre_001', 'usr_003', 'del_001', 6.00, 5.12, 3.00, 0.00, 3.00, -3.42, 0.00, 13.70, 'paid', 'cpo_001', 1634725500000, 1634725500000),
('cre_002', 'usr_004', 'del_002', 6.00, 110.24, 13.00, 0.00, 6.00, -27.05, 0.00, 108.19, 'paid', 'cpo_001', 1634741300000, 1634741300000),
('cre_003', 'usr_009', 'del_003', 6.00, 3.36, 2.00, 8.00, 0.00, -3.87, 0.00, 15.49, 'paid', 'cpo_001', 1634816700000, 1634816700000),
('cre_004', 'usr_003', 'del_004', 6.00, 112.80, 11.00, 4.00, 0.00, -26.76, 0.00, 107.04, 'paid', 'cpo_004', 1634828900000, 1634828900000),
('cre_005', 'usr_004', 'del_005', 6.00, 4.48, 1.60, 1.60, 5.00, -2.74, 0.00, 15.94, 'paid', 'cpo_005', 1634895800000, 1634895800000),
('cre_006', 'usr_009', 'del_006', 6.00, 3.04, 2.00, 4.00, 4.00, -3.01, 0.00, 16.03, 'paid', 'cpo_006', 1634906700000, 1634906700000),
('cre_007', 'usr_003', 'del_007', 6.00, 3.68, 2.40, 6.40, 0.00, -3.70, 0.00, 14.78, 'pending', 'cpo_007', 1634999100000, 1634999100000);

-- Seed data for invoices table
INSERT INTO invoices (uid, business_id, period_start, period_end, total_amount, currency, status, due_date, invoice_number, issued_date, paid_date, pdf_url, line_items, payment_transaction_id, created_at, updated_at)
VALUES
('inv_001', 'bpr_001', 1633046400000, 1633651200000, 192.36, 'USD', 'paid', 1635724800000, 'INV-20211001-001', 1633737600000, 1634083200000, 'https://example.com/invoices/INV-20211001-001.pdf', '[{"description": "Delivery charge: TRACK135790", "quantity": 1, "unit_price": 45.12, "amount": 45.12, "delivery_id": "del_035"}, {"description": "Delivery charge: TRACK246801", "quantity": 1, "unit_price": 78.95, "amount": 78.95, "delivery_id": "del_036"}, {"description": "Delivery charge: TRACK357912", "quantity": 1, "unit_price": 68.29, "amount": 68.29, "delivery_id": "del_037"}]', 'txn_inv_123456', 1633737600000, 1634083200000),
('inv_002', 'bpr_002', 1633046400000, 1633651200000, 318.75, 'USD', 'paid', 1634688000000, 'INV-20211001-002', 1633737600000, 1634342400000, 'https://example.com/invoices/INV-20211001-002.pdf', '[{"description": "Delivery charge: TRACK468023", "quantity": 1, "unit_price": 92.45, "amount": 92.45, "delivery_id": "del_038"}, {"description": "Delivery charge: TRACK579134", "quantity": 1, "unit_price": 125.80, "amount": 125.80, "delivery_id": "del_039"}, {"description": "Delivery charge: TRACK680245", "quantity": 1, "unit_price": 100.50, "amount": 100.50, "delivery_id": "del_040"}]', 'txn_inv_234567', 1633737600000, 1634342400000),
('inv_003', 'bpr_001', 1633651200000, 1634256000000, 49.89, 'USD', 'paid', 1636329600000, 'INV-20211008-003', 1634342400000, 1634688000000, 'https://example.com/invoices/INV-20211008-003.pdf', '[{"description": "Delivery charge: TRACK345678", "quantity": 1, "unit_price": 49.89, "amount": 49.89, "delivery_id": "del_003"}]', 'txn_inv_345678', 1634342400000, 1634688000000),
('inv_004', 'bpr_002', 1633651200000, 1634256000000, 203.61, 'USD', 'paid', 1635292800000, 'INV-20211008-004', 1634342400000, 1634947200000, 'https://example.com/invoices/INV-20211008-004.pdf', '[{"description": "Delivery charge: TRACK456789", "quantity": 1, "unit_price": 203.61, "amount": 203.61, "delivery_id": "del_004"}]', 'txn_inv_456789', 1634342400000, 1634947200000),
('inv_005', 'bpr_001', 1634256000000, 1634860800000, 0.00, 'USD', 'draft', 1636934400000, 'INV-20211015-005', 1634947200000, NULL, NULL, '[]', NULL, 1634947200000, 1634947200000),
('inv_006', 'bpr_002', 1634256000000, 1634860800000, 0.00, 'USD', 'draft', 1635897600000, 'INV-20211015-006', 1634947200000, NULL, NULL, '[]', NULL, 1634947200000, 1634947200000);

-- Seed data for promo_codes table
INSERT INTO promo_codes (uid, code, description, discount_type, discount_value, start_date, end_date, usage_limit, user_limit, min_order_amount, is_first_time_only, is_active, times_used, created_by, applicable_user_types, region_restrictions, created_at, updated_at)
VALUES
('prc_001', 'WELCOME10', 'Get 10% off your first order', 'percentage', 10, 1609459200000, 1640995200000, 1000, 1, 15.00, true, true, 521, 'usr_007', '["sender"]', NULL, 1609459200000, 1635000000000),
('prc_002', 'SUMMER2021', '15% summer discount', 'percentage', 15, 1625097600000, 1630454400000, 500, 2, 20.00, false, false, 347, 'usr_007', '["sender", "business"]', '["sf", "oak", "sjc"]', 1625097600000, 1630454400000),
('prc_003', 'FALL5OFF', '$5 off any delivery', 'fixed_amount', 5, 1630454400000, 1638316800000, 1000, 1, 25.00, false, true, 189, 'usr_007', '["sender", "business"]', NULL, 1630454400000, 1635000000000),
('prc_004', 'BIZSHIP20', '20% off for business shipments', 'percentage', 20, 1633046400000, 1640995200000, 200, 5, 50.00, false, true, 43, 'usr_007', '["business"]', NULL, 1633046400000, 1635000000000),
('prc_005', 'WEEKEND25', '25% off weekend deliveries', 'percentage', 25, 1633737600000, 1640995200000, 400, 2, 30.00, false, true, 87, 'usr_007', '["sender", "business"]', NULL, 1633737600000, 1635000000000);

-- Seed data for system_settings table
INSERT INTO system_settings (uid, setting_key, setting_value, setting_type, description, is_public, updated_by, created_at, updated_at)
VALUES
('set_001', 'base_fare', '7.5', 'number', 'Base fare for all deliveries', true, 'usr_007', 1609459200000, 1625097600000),
('set_002', 'distance_rate', '2', 'number', 'Per kilometer rate for distance calculation', true, 'usr_007', 1609459200000, 1625097600000),
('set_003', 'platform_fee_percentage', '20', 'number', 'Platform fee percentage charged from courier earnings', false, 'usr_007', 1609459200000, 1633046400000),
('set_004', 'tax_rate', '8.5', 'number', 'Default tax rate for deliveries', true, 'usr_007', 1609459200000, 1633046400000),
('set_005', 'min_courier_rating', '4.2', 'number', 'Minimum allowed courier rating before account review', false, 'usr_007', 1609459200000, 1633046400000),
('set_006', 'support_email', 'support@speedsend.example.com', 'string', 'Support email address', true, 'usr_007', 1609459200000, 1609459200000),
('set_007', 'support_phone', '+1-800-SPEED-SEND', 'string', 'Support phone number', true, 'usr_007', 1609459200000, 1609459200000),
('set_008', 'courier_onboarding_steps', '["application", "background_check", "document_verification", "training", "activation"]', 'json', 'Required steps for courier onboarding', false, 'usr_007', 1609459200000, 1625097600000),
('set_009', 'maintenance_mode', 'false', 'boolean', 'System maintenance mode flag', true, 'usr_007', 1609459200000, 1634947200000),
('set_010', 'auto_assign_timeout', '30', 'number', 'Seconds before auto-assignment times out', false, 'usr_007', 1609459200000, 1633046400000);

-- Seed data for service_regions table
INSERT INTO service_regions (uid, name, code, country, is_active, boundaries, timezone, currency, base_fare, distance_rate, minimum_fare, surge_multiplier, created_at, updated_at)
VALUES
('reg_001', 'San Francisco Bay Area', 'sf', 'US', true, '[{"latitude": 37.7749, "longitude": -122.4194}, {"latitude": 37.7749, "longitude": -122.2194}, {"latitude": 37.5749, "longitude": -122.2194}, {"latitude": 37.5749, "longitude": -122.4194}]', 'America/Los_Angeles', 'USD', 7.50, 2.00, 10.00, 1.0, 1609459200000, 1634947200000),
('reg_002', 'Oakland Area', 'oak', 'US', true, '[{"latitude": 37.8044, "longitude": -122.2711}, {"latitude": 37.8044, "longitude": -122.0711}, {"latitude": 37.6044, "longitude": -122.0711}, {"latitude": 37.6044, "longitude": -122.2711}]', 'America/Los_Angeles', 'USD', 7.00, 1.95, 9.50, 1.0, 1609459200000, 1634947200000),
('reg_003', 'San Jose Area', 'sjc', 'US', true, '[{"latitude": 37.3382, "longitude": -121.8863}, {"latitude": 37.3382, "longitude": -121.6863}, {"latitude": 37.1382, "longitude": -121.6863}, {"latitude": 37.1382, "longitude": -121.8863}]', 'America/Los_Angeles', 'USD', 7.25, 1.90, 9.75, 1.0, 1609459200000, 1634947200000),
('reg_004', 'New York City', 'nyc', 'US', false, '[{"latitude": 40.7128, "longitude": -74.0060}, {"latitude": 40.7128, "longitude": -73.8060}, {"latitude": 40.5128, "longitude": -73.8060}, {"latitude": 40.5128, "longitude": -74.0060}]', 'America/New_York', 'USD', 8.50, 2.20, 12.00, 1.2, 1609459200000, 1634947200000),
('reg_005', 'Los Angeles', 'la', 'US', false, '[{"latitude": 34.0522, "longitude": -118.2437}, {"latitude": 34.0522, "longitude": -118.0437}, {"latitude": 33.8522, "longitude": -118.0437}, {"latitude": 33.8522, "longitude": -118.2437}]', 'America/Los_Angeles', 'USD', 7.75, 2.10, 11.00, 1.1, 1609459200000, 1634947200000);

-- Seed data for audit_logs table
INSERT INTO audit_logs (uid, user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent, created_at)
VALUES
('aud_001', 'usr_007', 'update', 'system_settings', 'set_001', '{"setting_value": "7.0"}', '{"setting_value": "7.5"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1625097600000),
('aud_002', 'usr_007', 'update', 'system_settings', 'set_003', '{"setting_value": "18"}', '{"setting_value": "20"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1633046400000),
('aud_003', 'usr_007', 'update', 'courier_profiles', 'cpr_001', '{"id_verification_status": "pending"}', '{"id_verification_status": "verified"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1610150400000),
('aud_004', 'usr_007', 'update', 'courier_profiles', 'cpr_002', '{"id_verification_status": "pending"}', '{"id_verification_status": "verified"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1610236800000),
('aud_005', 'usr_007', 'update', 'courier_profiles', 'cpr_003', '{"id_verification_status": "pending"}', '{"id_verification_status": "verified"}', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 1610496000000),
('aud_006', 'usr_001', 'create', 'delivery_requests', 'del_001', NULL, '{"status": "pending", "pickup_location": {"address_id": "adr_001"}, "dropoff_location": {"address_id": "adr_003"}}', '203.0.113.42', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15', 1634720400000),
('aud_007', 'usr_003', 'update', 'delivery_requests', 'del_001', '{"status": "pending"}', '{"status": "accepted", "courier_id": "usr_003"}', '198.51.100.73', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15', 1634720700000),
('aud_008', 'usr_003', 'update', 'delivery_requests', 'del_001', '{"status": "accepted"}', '{"status": "picked_up", "actual_pickup_time": 1634721900000}', '198.51.100.73', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15', 1634721900000),
('aud_009', 'usr_003', 'update', 'delivery_requests', 'del_001', '{"status": "picked_up"}', '{"status": "delivered", "actual_delivery_time": 1634725500000}', '198.51.100.73', 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15', 1634725500000),
('aud_010', 'usr_006', 'update', 'delivery_requests', 'del_010', '{"status": "pending"}', '{"status": "cancelled", "cancellation_info": {"cancelled_by_user_id": "usr_006", "cancellation_time": 1635105000000, "cancellation_reason": "Changed delivery plans"}}', '203.0.113.55', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15', 1635105000000);

-- Seed data for help_articles table
INSERT INTO help_articles (uid, title, slug, content, category, tags, author_id, is_published, view_count, publish_date, last_updated, related_articles, user_types, created_at, updated_at)
VALUES
('har_001', 'How to Schedule a Delivery', 'how-to-schedule-delivery', 'This guide will walk you through scheduling a delivery on our platform. First, log in to your account and click the "New Delivery" button...', 'getting-started', '["delivery", "scheduling", "tutorial"]', 'usr_007', true, 1245, 1609459200000, 1625097600000, '["har_003", "har_005"]', '["sender", "business"]', 1609459200000, 1625097600000),
('har_002', 'Becoming a Courier Partner', 'becoming-courier-partner', 'Learn how to join our courier network and start earning. Our application process includes background checks and document verification...', 'courier-info', '["courier", "onboarding", "earnings"]', 'usr_007', true, 984, 1609459200000, 1633046400000, '["har_007", "har_008"]', '["courier"]', 1609459200000, 1633046400000),
('har_003', 'Package Size and Weight Guidelines', 'package-size-weight-guidelines', 'Understand our package categories by size and weight to ensure accurate pricing and proper handling. Small packages are defined as...', 'shipping-guidelines', '["package", "size", "weight", "pricing"]', 'usr_007', true, 872, 1609459200000, 1625097600000, '["har_001", "har_004"]', '["sender", "courier", "business"]', 1609459200000, 1625097600000),
('har_004', 'Prohibited Items Policy', 'prohibited-items-policy', 'For safety and legal reasons, certain items cannot be shipped through our platform. These include: hazardous materials, illegal substances...', 'policies', '["prohibited", "restrictions", "safety", "legal"]', 'usr_007', true, 657, 1609545600000, 1633046400000, '["har_003"]', '["sender", "courier", "business"]', 1609545600000, 1633046400000),
('har_005', 'Tracking Your Delivery', 'tracking-delivery', 'Our real-time tracking system lets you monitor your delivery at every step. To track your package, use the tracking code provided...', 'getting-started', '["tracking", "delivery", "real-time"]', 'usr_007', true, 1532, 1609545600000, 1625097600000, '["har_001", "har_006"]', '["sender", "business"]', 1609545600000, 1625097600000),
('har_006', 'Delivery Issues and Resolution', 'delivery-issues-resolution', 'If you experience any issues with your delivery, we\'re here to help. Common issues include delays, damaged packages, or missed deliveries...', 'support', '["issues", "help", "support", "resolution"]', 'usr_007', true, 743, 1609632000000, 1633046400000, '["har_005", "har_009"]', '["sender", "courier", "business"]', 1609632000000, 1633046400000),
('har_007', 'Maximizing Your Earnings as a Courier', 'maximizing-courier-earnings', 'Tips and strategies to increase your earnings as a courier partner. Learn about peak hours, efficient route planning, and bonus opportunities...', 'courier-info', '["courier", "earnings", "tips", "strategy"]', 'usr_007', true, 621, 1609632000000, 1633046400000, '["har_002", "har_008"]', '["courier"]', 1609632000000, 1633046400000),
('har_008', 'Courier Safety Guidelines', 'courier-safety-guidelines', 'Your safety is our priority. Follow these guidelines to ensure safe deliveries. Topics include traffic safety, handling heavy packages...', 'courier-info', '["courier", "safety", "guidelines", "health"]', 'usr_007', true, 589, 1609718400000, 1625097600000, '["har_002", "har_007"]', '["courier"]', 1609718400000, 1625097600000),
('har_009', 'Delivery Insurance Options', 'delivery-insurance-options', 'Protect your valuable shipments with our insurance options. We offer different coverage levels based on the value of your items...', 'shipping-guidelines', '["insurance", "protection", "coverage", "valuable"]', 'usr_007', true, 432, 1609718400000, 1633046400000, '["har_006", "har_003"]', '["sender", "business"]', 1609718400000, 1633046400000),
('har_010', 'Business Shipping Solutions', 'business-shipping-solutions', 'Discover how our platform can streamline your business logistics. Features include batch scheduling, invoicing options, and integration APIs...', 'business', '["business", "solutions", "enterprise", "integration"]', 'usr_007', true, 387, 1609804800000, 1633046400000, NULL, '["business"]', 1609804800000, 1633046400000);

-- Seed data for faqs table
INSERT INTO faqs (uid, question, answer, category, "order", is_published, user_types, created_at, updated_at)
VALUES
('faq_001', 'How much does delivery cost?', 'Our delivery pricing is based on distance, package size, and delivery urgency. You can get an instant quote by entering your pickup and dropoff locations in our app.', 'pricing', 1, true, '["sender", "business"]', 1609459200000, 1609459200000),
('faq_002', 'How quickly can I get my package delivered?', 'For standard deliveries within the same city, packages typically arrive within 1-3 hours. For scheduled deliveries, you can select your preferred delivery window.', 'delivery', 2, true, '["sender", "business"]', 1609459200000, 1609459200000),
('faq_003', 'What if my package is damaged during delivery?', 'We take package safety seriously. If your package is damaged, please report it immediately through the app or contact support. We offer insurance options for valuable items.', 'issues', 3, true, '["sender", "business"]', 1609459200000, 1609459200000),
('faq_004', 'How do I become a courier?', 'To become a courier, download our app, select "Become a Courier," and follow the application process. You\'ll need to provide identification, undergo a background check, and have a reliable vehicle.', 'courier', 1, true, '["courier"]', 1609545600000, 1609545600000),
('faq_005', 'How and when do couriers get paid?', 'Couriers receive weekly payments for all completed deliveries. Earnings are transferred directly to your linked bank account every Friday for the previous week\'s deliveries.', 'courier', 2, true, '["courier"]', 1609545600000, 1609545600000),
('faq_006', 'Can I track my delivery in real-time?', 'Yes! Our app provides real-time GPS tracking of your package once a courier has accepted your delivery request. You\'ll receive notifications at each stage of the delivery process.', 'delivery', 1, true, '["sender", "business"]', 1609632000000, 1609632000000),
('faq_007', 'What size and weight restrictions apply to packages?', 'We accept packages up to 50kg (110lbs) and dimensions of 1m x 1m x 1m (40in x 40in x 40in). Larger items may require special handling and additional fees.', 'delivery', 3, true, '["sender", "business"]', 1609632000000, 1609632000000),
('faq_008', 'What items are prohibited from delivery?', 'Prohibited items include hazardous materials, illegal substances, firearms, live animals, and perishable food items without proper packaging. See our full prohibited items policy for details.', 'policies', 1, true, '["sender", "courier", "business"]', 1609718400000, 1609718400000),
('faq_009', 'Can I schedule a delivery for a future date?', 'Yes, you can schedule deliveries up to 14 days in advance. Simply select your preferred date and time window when creating your delivery request.', 'delivery', 4, true, '["sender", "business"]', 1609718400000, 1609718400000),
('faq_010', 'How do I contact my courier?', 'Once a courier accepts your delivery, you can message them directly through our app. Tap on your active delivery and select the "Message" option.', 'delivery', 5, true, '["sender", "business"]', 1609804800000, 1609804800000),
('faq_011', 'Do you offer business accounts with invoicing?', 'Yes, we offer business accounts with features like monthly invoicing, multiple user access, cost center tracking, and delivery analytics. Contact our sales team to set up a business account.', 'business', 1, true, '["business"]', 1609804800000, 1609804800000),
('faq_012', 'What happens if no one is available to receive the package?', 'If no one is available at the delivery location, the courier will follow your delivery instructions if provided. Otherwise, they\'ll contact you through the app to arrange an alternative.', 'delivery', 6, true, '["sender", "business"]', 1609891200000, 1609891200000),
('faq_013', 'Can I change the delivery address after scheduling?', 'You can modify the delivery address before a courier accepts your request. After acceptance, changes may be subject to additional fees if the new address is significantly different.', 'delivery', 7, true, '["sender", "business"]', 1609891200000, 1609891200000),
('faq_014', 'How do I report an issue with my delivery?', 'To report an issue, go to your delivery history, select the problematic delivery, and tap "Report an Issue." Our support team will respond within 24 hours.', 'issues', 2, true, '["sender", "business"]', 1609977600000, 1609977600000),
('faq_015', 'Do you deliver to rural areas?', 'Our service is primarily available in urban and suburban areas. Delivery to rural locations may be limited or subject to additional fees depending on distance from our service zones.', 'delivery', 8, true, '["sender", "business"]', 1609977600000, 1609977600000);

-- Seed data for app_feedback table
INSERT INTO app_feedback (uid, user_id, feedback_type, content, rating, screenshot_url, device_info, status, admin_notes, created_at, updated_at)
VALUES
('afb_001', 'usr_001', 'feature', 'Would love to see an option to save favorite couriers for future deliveries.', 4, NULL, '{"platform": "iOS", "os_version": "15.0", "app_version": "2.3.1", "device_model": "iPhone 12"}', 'reviewing', 'Good suggestion, adding to feature backlog for Q1 2022', 1634720400000, 1634806800000),
('afb_002', 'usr_002', 'bug', 'App crashes when I try to upload multiple photos for proof of delivery.', 2, 'https://picsum.photos/seed/bug_screenshot1/400/800', '{"platform": "Android", "os_version": "11", "app_version": "2.3.0", "device_model": "Samsung Galaxy S21"}', 'addressed', 'Fixed in version 2.3.2', 1634742600000, 1634829000000),
('afb_003', 'usr_003', 'general', 'Overall great experience as a courier. The navigation could be improved to show more delivery-friendly routes.', 4, NULL, '{"platform": "iOS", "os_version": "14.8", "app_version": "2.3.1", "device_model": "iPhone SE"}', 'received', NULL, 1634828900000, 1634828900000),
('afb_004', 'usr_004', 'feature', 'Would be helpful to have a way to indicate if we\'re on bicycle vs car directly from the delivery screen.', 5, NULL, '{"platform": "Android", "os_version": "12", "app_version": "2.3.0", "device_model": "Google Pixel 5"}', 'reviewing', 'Adding to vehicle toggle enhancement ticket', 1634895800000, 1634982200000),
('afb_005', 'usr_005', 'bug', 'Business invoice export to PDF is not working correctly, some line items are missing.', 3, 'https://picsum.photos/seed/bug_screenshot2/1200/800', '{"platform": "Web", "os_version": "Windows 10", "app_version": "2.3.0", "device_model": "Chrome 94"}', 'reviewing', 'Confirmed issue, fix scheduled for next release', 1634817000000, 1634903400000),
('afb_006', 'usr_008', 'general', 'The new interface is much cleaner and easier to use. Really enjoying the app!', 5, NULL, '{"platform": "iOS", "os_version": "15.0", "app_version": "2.3.1", "device_model": "iPhone 13 Pro"}', 'received', 'Great feedback, sharing with design team', 1634897400000, 1634983800000),
('afb_007', 'usr_009', 'feature', 'Please add the ability to pause accepting new deliveries temporarily without going fully offline.', 4, NULL, '{"platform": "Android", "os_version": "11", "app_version": "2.3.0", "device_model": "OnePlus 9"}', 'reviewing', 'Already planned for next sprint', 1634908200000, 1634994600000),
('afb_008', 'usr_010', 'bug', 'Notification sounds not working on my device even though they\'re enabled in settings.', 2, NULL, '{"platform": "Android", "os_version": "10", "app_version": "2.3.0", "device_model": "Samsung Galaxy A52"}', 'received', NULL, 1634907900000, 1634907900000);

-- Seed data for user_promo_usages table
INSERT INTO user_promo_usages (uid, user_id, promo_id, delivery_id, discount_amount, created_at)
VALUES
('upu_001', 'usr_001', 'prc_001', 'del_001', 2.64, 1634720400000),
('upu_002', 'usr_002', 'prc_001', 'del_002', 21.38, 1634735700000),
('upu_003', 'usr_008', 'prc_001', 'del_005', 2.76, 1634889600000),
('upu_004', 'usr_010', 'prc_003', 'del_006', 5.00, 1634900400000),
('upu_005', 'usr_005', 'prc_004', 'del_003', 12.47, 1634810400000);

-- Seed data for insurance_claims table
INSERT INTO insurance_claims (uid, delivery_id, user_id, claim_type, claim_amount, description, evidence_urls, status, resolution_notes, approved_amount, processed_by, created_at, updated_at)
VALUES
('icl_001', 'del_003', 'usr_005', 'damage', 25.00, 'Equipment arrived with dent in corner', '["https://picsum.photos/seed/damage_evidence1/800/600", "https://picsum.photos/seed/damage_evidence2/800/600"]', 'approved', 'Damage verified through submitted photos. Partial refund approved.', 25.00, 'usr_007', 1634817000000, 1634820600000),
('icl_002', 'del_002', 'usr_002', 'loss', 50.00, 'Item was damaged during transit', '["https://picsum.photos/seed/damage_evidence3/800/600"]', 'rejected', 'Claim denied as package was confirmed delivered and signed for in good condition.', 0.00, 'usr_007', 1634742600000, 1634829000000);

-- Seed data for emergency_contacts table
INSERT INTO emergency_contacts (uid, user_id, name, phone_number, relationship, is_primary, created_at, updated_at)
VALUES
('emc_001', 'usr_003', 'Amanda Brown', '+14155551234', 'spouse', true, 1609632000000, 1609632000000),
('emc_002', 'usr_003', 'James Brown', '+14155551235', 'brother', false, 1609632000000, 1609632000000),
('emc_003', 'usr_004', 'Thomas Wilson', '+14155551236', 'spouse', true, 1609718400000, 1609718400000),
('emc_004', 'usr_009', 'Robert Jackson', '+14155551237', 'father', true, 1610150400000, 1610150400000);

-- Seed data for prohibited_items table
INSERT INTO prohibited_items (uid, name, category, description, reason, is_active, created_at, updated_at)
VALUES
('pbi_001', 'Firearms', 'weapons', 'Any type of firearm or ammunition', 'Safety and legal restrictions', true, 1609459200000, 1609459200000),
('pbi_002', 'Flammable liquids', 'hazardous', 'Gasoline, lighter fluid, paint thinner, etc.', 'Fire hazard and safety', true, 1609459200000, 1609459200000),
('pbi_003', 'Illegal substances', 'controlled', 'Narcotics and other illegal drugs', 'Legal restrictions', true, 1609459200000, 1609459200000),
('pbi_004', 'Live animals', 'animals', 'Any live animals or insects', 'Ethical and safety concerns', true, 1609459200000, 1609459200000),
('pbi_005', 'Perishable food', 'food', 'Unproperly packaged perishable food items', 'Contamination risk', true, 1609459200000, 1609459200000),
('pbi_006', 'Explosives', 'hazardous', 'Fireworks, explosive materials', 'Safety and legal restrictions', true, 1609459200000, 1609459200000),
('pbi_007', 'Human remains', 'biological', 'Human remains or body parts', 'Legal and ethical restrictions', true, 1609459200000, 1609459200000),
('pbi_008', 'Counterfeit goods', 'illegal', 'Fake brands or counterfeit items', 'Legal restrictions', true, 1609459200000, 1609459200000),
('pbi_009', 'Lithium batteries', 'hazardous', 'Uninstalled or loose lithium batteries', 'Fire hazard', true, 1609459200000, 1609459200000),
('pbi_010', 'Cash', 'valuables', 'Large amounts of cash', 'Security risk', true, 1609459200000, 1609459200000);