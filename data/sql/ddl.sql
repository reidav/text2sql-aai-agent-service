-- Capital Market Database Schema

-- Core Market Participants
CREATE TABLE institutions (
    institution_id INT PRIMARY KEY,
    name VARCHAR(200),
    registration_number VARCHAR(50),
    institution_type VARCHAR(50),
    establishment_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE brokers (
    broker_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    license_number VARCHAR(50),
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE traders (
    trader_id INT PRIMARY KEY,
    broker_id INTEGER REFERENCES brokers(broker_id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    license_number VARCHAR(50),
    status VARCHAR(20),
    created_at TIMESTAMP
);

-- Securities and Instruments
CREATE TABLE exchanges (
    exchange_id INT PRIMARY KEY,
    name VARCHAR(100),
    country_code VARCHAR(3),
    timezone VARCHAR(50),
    operating_hours VARCHAR(100),
    created_at TIMESTAMP
);

CREATE TABLE stock_indices (
    index_id INT PRIMARY KEY,
    exchange_id INTEGER REFERENCES exchanges(exchange_id),
    name VARCHAR(100),
    symbol VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE companies (
    company_id INT PRIMARY KEY,
    name VARCHAR(200),
    ticker_symbol VARCHAR(20),
    isin VARCHAR(12),
    sector VARCHAR(100),
    industry VARCHAR(100),
    founded_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE stocks (
    stock_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    exchange_id INTEGER REFERENCES exchanges(exchange_id),
    stock_type VARCHAR(50),
    listing_date DATE,
    delisting_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

-- Bond Related Tables
CREATE TABLE bond_types (
    bond_type_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE bonds (
    bond_id INT PRIMARY KEY,
    issuer_id INTEGER REFERENCES institutions(institution_id),
    bond_type_id INTEGER REFERENCES bond_types(bond_type_id),
    isin VARCHAR(12),
    face_value DECIMAL(15,2),
    coupon_rate DECIMAL(5,2),
    issue_date DATE,
    maturity_date DATE,
    created_at TIMESTAMP
);

-- Derivatives
CREATE TABLE derivative_types (
    derivative_type_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE options (
    option_id INT PRIMARY KEY,
    underlying_stock_id INTEGER REFERENCES stocks(stock_id),
    strike_price DECIMAL(15,2),
    expiry_date DATE,
    option_type VARCHAR(4),
    contract_size INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE futures (
    future_id INT PRIMARY KEY,
    underlying_asset_type VARCHAR(50),
    contract_size INTEGER,
    delivery_date DATE,
    settlement_type VARCHAR(20),
    created_at TIMESTAMP
);

-- Market Data
CREATE TABLE stock_prices (
    price_id INT PRIMARY KEY,
    stock_id INTEGER REFERENCES stocks(stock_id),
    date DATE,
    open_price DECIMAL(15,2),
    high_price DECIMAL(15,2),
    low_price DECIMAL(15,2),
    close_price DECIMAL(15,2),
    volume BIGINT,
    created_at TIMESTAMP
);

CREATE TABLE bond_prices (
    price_id INT PRIMARY KEY,
    bond_id INTEGER REFERENCES bonds(bond_id),
    date DATE,
    price DECIMAL(15,2),
    yield DECIMAL(7,4),
    created_at TIMESTAMP
);

-- Trading and Orders
CREATE TABLE order_types (
    order_type_id INT PRIMARY KEY,
    name VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    trader_id INTEGER REFERENCES traders(trader_id),
    stock_id INTEGER REFERENCES stocks(stock_id),
    order_type_id INTEGER REFERENCES order_types(order_type_id),
    quantity INTEGER,
    price DECIMAL(15,2),
    status VARCHAR(20),
    created_at TIMESTAMP
);

-- Risk Management Tables

CREATE TABLE risk_types (
    risk_type_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE portfolio_risk_metrics (
    metric_id INT PRIMARY KEY,
    portfolio_id INTEGER,
    var_95 DECIMAL(15,4),
    var_99 DECIMAL(15,4),
    expected_shortfall DECIMAL(15,4),
    sharpe_ratio DECIMAL(10,4),
    calculation_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE counterparty_ratings (
    rating_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    rating_agency VARCHAR(50),
    credit_rating VARCHAR(10),
    rating_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE risk_limits (
    limit_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    risk_type_id INTEGER REFERENCES risk_types(risk_type_id),
    max_exposure DECIMAL(15,2),
    warning_threshold DECIMAL(5,2),
    created_at TIMESTAMP
);

CREATE TABLE stress_test_scenarios (
    scenario_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    market_condition VARCHAR(50),
    severity_level INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE risk_exposures (
    exposure_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    risk_type_id INTEGER REFERENCES risk_types(risk_type_id),
    exposure_amount DECIMAL(15,2),
    exposure_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE collateral_management (
    collateral_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    asset_type VARCHAR(50),
    value DECIMAL(15,2),
    haircut_percentage DECIMAL(5,2),
    valuation_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE margin_requirements (
    margin_id INT PRIMARY KEY,
    product_type VARCHAR(50),
    initial_margin_pct DECIMAL(5,2),
    maintenance_margin_pct DECIMAL(5,2),
    effective_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE risk_events (
    event_id INT PRIMARY KEY,
    event_type VARCHAR(100),
    severity VARCHAR(20),
    impact_amount DECIMAL(15,2),
    occurrence_date DATE,
    resolution_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE compliance_checks (
    check_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    check_type VARCHAR(100),
    status VARCHAR(20),
    last_check_date DATE,
    next_check_date DATE,
    created_at TIMESTAMP
);

-- Compliance Framework Tables
CREATE TABLE regulatory_frameworks (
    framework_id INT PRIMARY KEY,
    name VARCHAR(100),
    jurisdiction VARCHAR(50),
    effective_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_policies (
    policy_id INT PRIMARY KEY,
    framework_id INTEGER REFERENCES regulatory_frameworks(framework_id),
    title VARCHAR(200),
    description TEXT,
    version VARCHAR(20),
    effective_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE compliance_requirements (
    requirement_id INT PRIMARY KEY,
    policy_id INTEGER REFERENCES compliance_policies(policy_id),
    description TEXT,
    deadline DATE,
    priority VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_documents (
    document_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    document_type VARCHAR(100),
    file_path VARCHAR(500),
    upload_date DATE,
    expiry_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY,
    user_id INTEGER,
    action_type VARCHAR(50),
    entity_type VARCHAR(50),
    entity_id INTEGER,
    change_description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP
);

CREATE TABLE reporting_requirements (
    requirement_id INT PRIMARY KEY,
    framework_id INTEGER REFERENCES regulatory_frameworks(framework_id),
    report_name VARCHAR(200),
    frequency VARCHAR(50),
    submission_deadline INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE compliance_training (
    training_id INT PRIMARY KEY,
    title VARCHAR(200),
    description TEXT,
    frequency_months INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE training_completion (
    completion_id INT PRIMARY KEY,
    training_id INTEGER REFERENCES compliance_training(training_id),
    employee_id INTEGER,
    completion_date DATE,
    score INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE compliance_violations (
    violation_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    requirement_id INTEGER REFERENCES compliance_requirements(requirement_id),
    violation_date DATE,
    severity VARCHAR(20),
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE remediation_actions (
    action_id INT PRIMARY KEY,
    violation_id INTEGER REFERENCES compliance_violations(violation_id),
    description TEXT,
    deadline DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_reviews (
    review_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    reviewer_id INTEGER,
    review_date DATE,
    findings TEXT,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE regulatory_reports (
    report_id INT PRIMARY KEY,
    requirement_id INTEGER REFERENCES reporting_requirements(requirement_id),
    submission_date DATE,
    report_period_start DATE,
    report_period_end DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_alerts (
    alert_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    alert_type VARCHAR(100),
    severity VARCHAR(20),
    message TEXT,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE regulatory_communications (
    communication_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    regulator_name VARCHAR(100),
    communication_date DATE,
    subject VARCHAR(200),
    content TEXT,
    created_at TIMESTAMP
);

CREATE TABLE compliance_risk_assessments (
    assessment_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    assessment_date DATE,
    risk_level VARCHAR(20),
    findings TEXT,
    created_at TIMESTAMP
);

CREATE TABLE compliance_committees (
    committee_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    name VARCHAR(100),
    purpose TEXT,
    meeting_frequency VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE committee_meetings (
    meeting_id INT PRIMARY KEY,
    committee_id INTEGER REFERENCES compliance_committees(committee_id),
    meeting_date DATE,
    minutes TEXT,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_budgets (
    budget_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    year INTEGER,
    amount DECIMAL(15,2),
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_expenses (
    expense_id INT PRIMARY KEY,
    budget_id INTEGER REFERENCES compliance_budgets(budget_id),
    description TEXT,
    amount DECIMAL(15,2),
    expense_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE whistleblower_reports (
    report_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    report_date DATE,
    category VARCHAR(100),
    description TEXT,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE investigation_cases (
    case_id INT PRIMARY KEY,
    report_id INTEGER REFERENCES whistleblower_reports(report_id),
    investigator_id INTEGER,
    start_date DATE,
    end_date DATE,
    findings TEXT,
    created_at TIMESTAMP
);

CREATE TABLE sanction_lists (
    list_id INT PRIMARY KEY,
    name VARCHAR(100),
    issuing_authority VARCHAR(100),
    effective_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE sanctioned_entities (
    entity_id INT PRIMARY KEY,
    list_id INTEGER REFERENCES sanction_lists(list_id),
    entity_name VARCHAR(200),
    entity_type VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE compliance_certifications (
    certification_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    certification_type VARCHAR(100),
    issuing_body VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE regulatory_filings (
    filing_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    filing_type VARCHAR(100),
    due_date DATE,
    submission_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_vendors (
    vendor_id INT PRIMARY KEY,
    name VARCHAR(200),
    service_type VARCHAR(100),
    contract_start_date DATE,
    contract_end_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE vendor_assessments (
    assessment_id INT PRIMARY KEY,
    vendor_id INTEGER REFERENCES compliance_vendors(vendor_id),
    assessment_date DATE,
    risk_rating VARCHAR(20),
    findings TEXT,
    created_at TIMESTAMP
);

CREATE TABLE compliance_workflows (
    workflow_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    frequency VARCHAR(50),
    owner_role VARCHAR(100),
    created_at TIMESTAMP
);

CREATE TABLE workflow_tasks (
    task_id INT PRIMARY KEY,
    workflow_id INTEGER REFERENCES compliance_workflows(workflow_id),
    task_name VARCHAR(200),
    description TEXT,
    due_days INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE compliance_calendars (
    calendar_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    event_type VARCHAR(100),
    event_date DATE,
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE document_templates (
    template_id INT PRIMARY KEY,
    name VARCHAR(200),
    document_type VARCHAR(100),
    content TEXT,
    version VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_monitoring (
    monitoring_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    metric_name VARCHAR(100),
    threshold_value DECIMAL(15,2),
    current_value DECIMAL(15,2),
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE regulatory_changes (
    change_id INT PRIMARY KEY,
    framework_id INTEGER REFERENCES regulatory_frameworks(framework_id),
    change_description TEXT,
    effective_date DATE,
    impact_level VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_questionnaires (
    questionnaire_id INT PRIMARY KEY,
    title VARCHAR(200),
    description TEXT,
    frequency VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE questionnaire_responses (
    response_id INT PRIMARY KEY,
    questionnaire_id INTEGER REFERENCES compliance_questionnaires(questionnaire_id),
    institution_id INTEGER REFERENCES institutions(institution_id),
    completion_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_incidents (
    incident_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    incident_type VARCHAR(100),
    description TEXT,
    report_date DATE,
    resolution_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE incident_responses (
    response_id INT PRIMARY KEY,
    incident_id INTEGER REFERENCES compliance_incidents(incident_id),
    action_taken TEXT,
    responsible_party VARCHAR(100),
    completion_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE compliance_metrics (
    metric_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    metric_name VARCHAR(100),
    metric_value DECIMAL(15,2),
    measurement_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE regulatory_inspections (
    inspection_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    inspector_name VARCHAR(100),
    inspection_date DATE,
    findings TEXT,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE inspection_findings (
    finding_id INT PRIMARY KEY,
    inspection_id INTEGER REFERENCES regulatory_inspections(inspection_id),
    finding_type VARCHAR(100),
    description TEXT,
    severity VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE compliance_kpis (
    kpi_id INT PRIMARY KEY,
    institution_id INTEGER REFERENCES institutions(institution_id),
    kpi_name VARCHAR(100),
    target_value DECIMAL(15,2),
    actual_value DECIMAL(15,2),
    measurement_period VARCHAR(50),
    created_at TIMESTAMP
);

-- Dividend Management Tables

CREATE TABLE dividend_policies (
    policy_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    policy_type VARCHAR(50),
    payout_ratio DECIMAL(5,2),
    frequency VARCHAR(20),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_announcements (
    announcement_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    announcement_date DATE,
    record_date DATE,
    payment_date DATE,
    dividend_amount DECIMAL(10,4),
    currency VARCHAR(3),
    created_at TIMESTAMP
);

CREATE TABLE dividend_payments (
    payment_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    total_amount DECIMAL(15,2),
    payment_status VARCHAR(20),
    payment_method VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE dividend_histories (
    history_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    fiscal_year INTEGER,
    total_dividends DECIMAL(15,2),
    dividend_yield DECIMAL(5,2),
    created_at TIMESTAMP
);

CREATE TABLE special_dividends (
    special_div_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    amount DECIMAL(15,2),
    announcement_date DATE,
    payment_date DATE,
    reason TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_reinvestment_plans (
    drip_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    discount_rate DECIMAL(5,2),
    enrollment_deadline DATE,
    status VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE dividend_tax_rates (
    tax_rate_id INT PRIMARY KEY,
    country_code VARCHAR(3),
    investor_type VARCHAR(50),
    tax_rate DECIMAL(5,2),
    effective_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE dividend_currency_conversions (
    conversion_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    from_currency VARCHAR(3),
    to_currency VARCHAR(3),
    exchange_rate DECIMAL(10,6),
    conversion_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE dividend_adjustments (
    adjustment_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    adjustment_type VARCHAR(50),
    adjustment_factor DECIMAL(10,6),
    reason TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_withholding_taxes (
    withholding_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    tax_amount DECIMAL(15,2),
    tax_rate DECIMAL(5,2),
    country_code VARCHAR(3),
    created_at TIMESTAMP
);

CREATE TABLE dividend_distribution_methods (
    method_id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_eligibility_rules (
    rule_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    shareholder_type VARCHAR(50),
    minimum_shares INTEGER,
    holding_period_days INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE dividend_payment_schedules (
    schedule_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    frequency VARCHAR(20),
    typical_record_date VARCHAR(50),
    typical_payment_date VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE dividend_restrictions (
    restriction_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    restriction_type VARCHAR(50),
    description TEXT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE dividend_approvals (
    approval_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    board_approval_date DATE,
    shareholder_approval_date DATE,
    regulatory_approval_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE ex_dividend_dates (
    ex_div_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    ex_date DATE,
    price_adjustment DECIMAL(15,2),
    created_at TIMESTAMP
);

CREATE TABLE dividend_recipients (
    recipient_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    shareholder_id INTEGER,
    shares_held INTEGER,
    amount DECIMAL(15,2),
    created_at TIMESTAMP
);

CREATE TABLE dividend_bank_details (
    bank_detail_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    bank_name VARCHAR(100),
    account_number VARCHAR(50),
    swift_code VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE dividend_notifications (
    notification_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    notification_type VARCHAR(50),
    notification_date DATE,
    message TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_compliance_checks (
    check_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    check_type VARCHAR(50),
    status VARCHAR(20),
    comments TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_documents (
    document_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    document_type VARCHAR(50),
    file_path VARCHAR(500),
    upload_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE dividend_calculations (
    calculation_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    calculation_method VARCHAR(50),
    base_amount DECIMAL(15,2),
    adjustments DECIMAL(15,2),
    created_at TIMESTAMP
);

CREATE TABLE dividend_audits (
    audit_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    auditor VARCHAR(100),
    audit_date DATE,
    findings TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_metrics (
    metric_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    metric_type VARCHAR(50),
    value DECIMAL(15,4),
    calculation_date DATE,
    created_at TIMESTAMP
);

CREATE TABLE dividend_forecasts (
    forecast_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    forecast_date DATE,
    predicted_amount DECIMAL(15,2),
    confidence_level DECIMAL(5,2),
    created_at TIMESTAMP
);

CREATE TABLE dividend_authorizations (
    auth_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    authorized_by VARCHAR(100),
    authorization_date DATE,
    comments TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_suspensions (
    suspension_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    start_date DATE,
    end_date DATE,
    reason TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_reconciliations (
    reconciliation_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    reconciliation_date DATE,
    status VARCHAR(20),
    discrepancies TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_payment_methods (
    method_id INT PRIMARY KEY,
    name VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_registers (
    register_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    record_date DATE,
    total_shareholders INTEGER,
    total_shares BIGINT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_reports (
    report_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    report_type VARCHAR(50),
    report_date DATE,
    content TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_preferences (
    preference_id INT PRIMARY KEY,
    shareholder_id INTEGER,
    payment_method VARCHAR(50),
    currency_preference VARCHAR(3),
    created_at TIMESTAMP
);

CREATE TABLE dividend_exceptions (
    exception_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    exception_type VARCHAR(50),
    description TEXT,
    resolution TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_calendars (
    calendar_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    event_type VARCHAR(50),
    event_date DATE,
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_adjustments_history (
    history_id INT PRIMARY KEY,
    stock_id INTEGER REFERENCES stocks(stock_id),
    adjustment_date DATE,
    adjustment_factor DECIMAL(10,6),
    event_type VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE dividend_statistics (
    stat_id INT PRIMARY KEY,
    company_id INTEGER REFERENCES companies(company_id),
    period VARCHAR(20),
    average_dividend DECIMAL(15,2),
    growth_rate DECIMAL(5,2),
    created_at TIMESTAMP
);

CREATE TABLE dividend_waivers (
    waiver_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    shareholder_id INTEGER,
    waiver_date DATE,
    reason TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_templates (
    template_id INT PRIMARY KEY,
    template_name VARCHAR(100),
    document_type VARCHAR(50),
    content TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dividend_processing_status (
    status_id INT PRIMARY KEY,
    payment_id INTEGER REFERENCES dividend_payments(payment_id),
    processing_stage VARCHAR(50),
    status VARCHAR(20),
    last_updated TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE dividend_communications (
    communication_id INT PRIMARY KEY,
    announcement_id INTEGER REFERENCES dividend_announcements(announcement_id),
    communication_type VARCHAR(50),
    recipient_type VARCHAR(50),
    content TEXT,
    created_at TIMESTAMP
);