class DatabaseSchema {
  DatabaseSchema._();

  static const int version = 1;

  static const List<String> createStatements = [
    '''
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  first_name TEXT NOT NULL,
  middle_name TEXT NULL,
  last_name TEXT NULL,
  phone_number TEXT NULL,
  email TEXT NULL UNIQUE,
  status TEXT NOT NULL DEFAULT 'A',
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  CHECK (status IN ('A', 'I'))
)
''',
    '''
CREATE TABLE currencies (
  currency_id INTEGER PRIMARY KEY,
  currency_code TEXT NOT NULL UNIQUE,
  currency_name TEXT NOT NULL,
  currency_symbol TEXT NULL,
  decimal_places INTEGER NOT NULL DEFAULT 2,
  is_base_currency INTEGER NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  CHECK (decimal_places >= 0 AND decimal_places <= 6),
  CHECK (is_base_currency IN (0, 1)),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE main_heads (
  main_head_id INTEGER PRIMARY KEY,
  main_head_code INTEGER NOT NULL UNIQUE,
  main_head_name TEXT NOT NULL UNIQUE,
  accounting_type TEXT NOT NULL,
  normal_balance TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  CHECK (accounting_type IN ('ASSET', 'LIABILITY', 'INCOME', 'EXPENSE', 'EQUITY')),
  CHECK (normal_balance IN ('D', 'C')),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE subheads (
  subhead_id INTEGER PRIMARY KEY,
  subhead_code INTEGER NOT NULL UNIQUE,
  subhead_name TEXT NOT NULL,
  main_head_id INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (main_head_id) REFERENCES main_heads(main_head_id) ON DELETE RESTRICT,
  UNIQUE (main_head_id, subhead_name),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE chart_of_accounts (
  coa_id INTEGER PRIMARY KEY,
  coa_code TEXT NOT NULL UNIQUE,
  coa_name TEXT NOT NULL,
  subhead_id INTEGER NOT NULL,
  currency_id INTEGER NULL,
  description TEXT NULL,
  is_control_account INTEGER NOT NULL DEFAULT 0,
  allow_direct_posting INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 1,
  opening_balance TEXT NOT NULL DEFAULT '0.0000',
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (subhead_id) REFERENCES subheads(subhead_id) ON DELETE RESTRICT,
  FOREIGN KEY (currency_id) REFERENCES currencies(currency_id) ON DELETE RESTRICT,
  CHECK (is_control_account IN (0, 1)),
  CHECK (allow_direct_posting IN (0, 1)),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE transaction_types (
  transaction_type_id INTEGER PRIMARY KEY,
  transaction_type_code INTEGER NOT NULL UNIQUE,
  transaction_type_name TEXT NOT NULL UNIQUE,
  description TEXT NULL,
  is_system INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  CHECK (is_system IN (0, 1)),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE transaction_components (
  transaction_component_id INTEGER PRIMARY KEY,
  transaction_type_id INTEGER NOT NULL,
  component_code TEXT NOT NULL,
  component_name TEXT NOT NULL,
  description TEXT NULL,
  is_required INTEGER NOT NULL DEFAULT 1,
  is_active INTEGER NOT NULL DEFAULT 1,
  sequence_no INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id) ON DELETE RESTRICT,
  UNIQUE (transaction_type_id, component_code),
  UNIQUE (transaction_type_id, component_name),
  CHECK (sequence_no > 0),
  CHECK (is_required IN (0, 1)),
  CHECK (is_active IN (0, 1))
)
''',
    '''
CREATE TABLE financial_periods (
  financial_period_id INTEGER PRIMARY KEY,
  period_code TEXT NOT NULL,
  period_name TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'OPEN',
  created_at TEXT NOT NULL,
  closed_at TEXT NULL,
  user_id INTEGER NOT NULL,
  is_current INTEGER NOT NULL DEFAULT 0,
  opened_at TEXT NOT NULL,
  closed_by INTEGER NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (closed_by) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (status IN ('OPEN', 'CLOSED')),
  CHECK (is_current IN (0, 1)),
  UNIQUE (user_id, period_code)
)
''',
    '''
CREATE TABLE transactions (
  transaction_id INTEGER PRIMARY KEY,
  transaction_number TEXT NOT NULL UNIQUE,
  transaction_type_id INTEGER NOT NULL,
  financial_period_id INTEGER NOT NULL,
  transaction_date TEXT NOT NULL,
  description TEXT NULL,
  reference_number TEXT NULL,
  status TEXT NOT NULL DEFAULT 'DRAFT',
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  posted_at TEXT NULL,
  posted_by_user_id INTEGER NULL,
  voided_at TEXT NULL,
  voided_by_user_id INTEGER NULL,
  void_reason TEXT NULL,
  FOREIGN KEY (transaction_type_id) REFERENCES transaction_types(transaction_type_id) ON DELETE RESTRICT,
  FOREIGN KEY (financial_period_id) REFERENCES financial_periods(financial_period_id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (posted_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  FOREIGN KEY (voided_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (status IN ('DRAFT', 'VALIDATED', 'POSTED', 'VOIDED'))
)
''',
    '''
CREATE TABLE transaction_lines (
  transaction_line_id INTEGER PRIMARY KEY,
  transaction_id INTEGER NOT NULL,
  line_sequence INTEGER NOT NULL,
  coa_id INTEGER NOT NULL,
  debit_amount TEXT NOT NULL DEFAULT '0.0000',
  credit_amount TEXT NOT NULL DEFAULT '0.0000',
  description TEXT NULL,
  created_at TEXT NOT NULL,
  transaction_component_id INTEGER NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE RESTRICT,
  FOREIGN KEY (coa_id) REFERENCES chart_of_accounts(coa_id) ON DELETE RESTRICT,
  FOREIGN KEY (transaction_component_id) REFERENCES transaction_components(transaction_component_id) ON DELETE RESTRICT,
  UNIQUE (transaction_id, line_sequence)
)
''',
    '''
CREATE TABLE journals (
  journal_id INTEGER PRIMARY KEY,
  journal_number TEXT NOT NULL UNIQUE,
  transaction_id INTEGER NOT NULL,
  financial_period_id INTEGER NOT NULL,
  journal_date TEXT NOT NULL,
  description TEXT NULL,
  status TEXT NOT NULL DEFAULT 'POSTED',
  created_at TEXT NOT NULL,
  posted_at TEXT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE RESTRICT,
  FOREIGN KEY (financial_period_id) REFERENCES financial_periods(financial_period_id) ON DELETE RESTRICT,
  CHECK (status IN ('POSTED', 'VOIDED'))
)
''',
    '''
CREATE TABLE journal_lines (
  journal_line_id INTEGER PRIMARY KEY,
  journal_id INTEGER NOT NULL,
  line_sequence INTEGER NOT NULL,
  coa_id INTEGER NOT NULL,
  debit_amount TEXT NOT NULL DEFAULT '0.0000',
  credit_amount TEXT NOT NULL DEFAULT '0.0000',
  description TEXT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (journal_id) REFERENCES journals(journal_id) ON DELETE RESTRICT,
  FOREIGN KEY (coa_id) REFERENCES chart_of_accounts(coa_id) ON DELETE RESTRICT,
  UNIQUE (journal_id, line_sequence)
)
''',
    '''
CREATE TABLE budgets (
  budget_id INTEGER PRIMARY KEY,
  budget_code TEXT NOT NULL UNIQUE,
  budget_name TEXT NOT NULL,
  financial_period_id INTEGER NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'DRAFT',
  description TEXT NULL,
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (financial_period_id) REFERENCES financial_periods(financial_period_id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (status IN ('DRAFT', 'ACTIVE', 'CLOSED', 'VOIDED'))
)
''',
    '''
CREATE TABLE budget_lines (
  budget_line_id INTEGER PRIMARY KEY,
  budget_id INTEGER NOT NULL,
  line_sequence INTEGER NOT NULL,
  coa_id INTEGER NOT NULL,
  budget_amount TEXT NOT NULL DEFAULT '0.0000',
  description TEXT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (budget_id) REFERENCES budgets(budget_id) ON DELETE RESTRICT,
  FOREIGN KEY (coa_id) REFERENCES chart_of_accounts(coa_id) ON DELETE RESTRICT,
  UNIQUE (budget_id, coa_id),
  UNIQUE (budget_id, line_sequence)
)
''',
    '''
CREATE TABLE credits (
  credit_id INTEGER PRIMARY KEY,
  credit_code TEXT NOT NULL UNIQUE,
  credit_name TEXT NOT NULL,
  lender_name TEXT NOT NULL,
  principal_amount TEXT NOT NULL,
  interest_rate TEXT NOT NULL DEFAULT '0.0000',
  start_date TEXT NOT NULL,
  due_date TEXT NULL,
  status TEXT NOT NULL DEFAULT 'ACTIVE',
  description TEXT NULL,
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (status IN ('ACTIVE', 'PAID', 'OVERDUE', 'CLOSED', 'VOIDED')),
  CHECK (due_date IS NULL OR due_date >= start_date)
)
''',
    '''
CREATE TABLE credit_payments (
  credit_payment_id INTEGER PRIMARY KEY,
  credit_id INTEGER NOT NULL,
  payment_date TEXT NOT NULL,
  payment_amount TEXT NOT NULL,
  principal_amount TEXT NOT NULL,
  interest_amount TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  transaction_id INTEGER NULL,
  description TEXT NULL,
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (credit_id) REFERENCES credits(credit_id) ON DELETE RESTRICT,
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (payment_method IN ('MOBILE_MONEY', 'BANK', 'CASH'))
)
''',
    '''
CREATE TABLE savings_goals (
  savings_goal_id INTEGER PRIMARY KEY,
  goal_code TEXT NOT NULL UNIQUE,
  goal_name TEXT NOT NULL,
  target_amount TEXT NOT NULL,
  target_date TEXT NULL,
  status TEXT NOT NULL DEFAULT 'ACTIVE',
  description TEXT NULL,
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
  CHECK (status IN ('DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED'))
)
''',
    '''
CREATE TABLE savings_contributions (
  savings_contribution_id INTEGER PRIMARY KEY,
  savings_goal_id INTEGER NOT NULL,
  contribution_date TEXT NOT NULL,
  contribution_amount TEXT NOT NULL,
  source_coa_id INTEGER NOT NULL,
  savings_coa_id INTEGER NOT NULL,
  transaction_id INTEGER NULL,
  description TEXT NULL,
  created_by_user_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NULL,
  FOREIGN KEY (savings_goal_id) REFERENCES savings_goals(savings_goal_id) ON DELETE RESTRICT,
  FOREIGN KEY (source_coa_id) REFERENCES chart_of_accounts(coa_id) ON DELETE RESTRICT,
  FOREIGN KEY (savings_coa_id) REFERENCES chart_of_accounts(coa_id) ON DELETE RESTRICT,
  FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
)
''',
    '''
CREATE TABLE local_sync_state (
  sync_state_id INTEGER PRIMARY KEY,
  entity_name TEXT NOT NULL UNIQUE,
  last_server_version INTEGER NULL,
  last_sync_at TEXT NULL,
  sync_status TEXT NOT NULL DEFAULT 'IDLE',
  last_error TEXT NULL,
  updated_at TEXT NOT NULL,
  CHECK (sync_status IN ('IDLE', 'SYNCING', 'SUCCESS', 'FAILED'))
)
''',
    '''
CREATE TABLE sync_outbox (
  outbox_id INTEGER PRIMARY KEY,
  entity_name TEXT NOT NULL,
  entity_id INTEGER NOT NULL,
  operation TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  last_attempt_at TEXT NULL,
  last_error TEXT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING',
  CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
  CHECK (status IN ('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED'))
)
''',
  ];

  static const List<String> createIndexStatements = [
    'CREATE INDEX idx_subheads_main_head_id ON subheads(main_head_id)',
    'CREATE INDEX idx_chart_of_accounts_subhead_id ON chart_of_accounts(subhead_id)',
    'CREATE INDEX idx_chart_of_accounts_currency_id ON chart_of_accounts(currency_id)',
    'CREATE INDEX idx_transactions_type ON transactions(transaction_type_id)',
    'CREATE INDEX idx_transactions_period ON transactions(financial_period_id)',
    'CREATE INDEX idx_transactions_date ON transactions(transaction_date)',
    'CREATE INDEX idx_transactions_status ON transactions(status)',
    'CREATE INDEX idx_transactions_created_by ON transactions(created_by_user_id)',
    'CREATE INDEX idx_transaction_lines_transaction_id ON transaction_lines(transaction_id)',
    'CREATE INDEX idx_journals_transaction_id ON journals(transaction_id)',
    'CREATE INDEX idx_journals_period_id ON journals(financial_period_id)',
    'CREATE INDEX idx_journal_lines_journal_id ON journal_lines(journal_id)',
    'CREATE INDEX idx_budgets_period_id ON budgets(financial_period_id)',
    'CREATE INDEX idx_budgets_created_by ON budgets(created_by_user_id)',
    'CREATE INDEX idx_budget_lines_budget_id ON budget_lines(budget_id)',
    'CREATE INDEX idx_budget_lines_coa_id ON budget_lines(coa_id)',
    'CREATE INDEX idx_credits_created_by ON credits(created_by_user_id)',
    'CREATE INDEX idx_credits_status ON credits(status)',
    'CREATE INDEX idx_credits_due_date ON credits(due_date)',
    'CREATE INDEX idx_credit_payments_credit_id ON credit_payments(credit_id)',
    'CREATE INDEX idx_credit_payments_transaction_id ON credit_payments(transaction_id)',
    'CREATE INDEX idx_credit_payments_created_by ON credit_payments(created_by_user_id)',
    'CREATE INDEX idx_savings_goals_created_by ON savings_goals(created_by_user_id)',
    'CREATE INDEX idx_savings_goals_status ON savings_goals(status)',
    'CREATE INDEX idx_savings_contributions_goal_id ON savings_contributions(savings_goal_id)',
    'CREATE INDEX idx_savings_contributions_source_coa_id ON savings_contributions(source_coa_id)',
    'CREATE INDEX idx_savings_contributions_savings_coa_id ON savings_contributions(savings_coa_id)',
    'CREATE INDEX idx_savings_contributions_transaction_id ON savings_contributions(transaction_id)',
    'CREATE INDEX idx_savings_contributions_created_by ON savings_contributions(created_by_user_id)',
    'CREATE INDEX idx_sync_outbox_status ON sync_outbox(status)',
    'CREATE INDEX idx_sync_outbox_created_at ON sync_outbox(created_at)',
    'CREATE UNIQUE INDEX ux_financial_periods_current_user ON financial_periods(user_id) WHERE is_current = 1',
  ];
}
