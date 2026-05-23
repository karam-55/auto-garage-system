-- Add missing indexes for performance optimization
-- Created: 2026-05-24
-- Updated for Supabase compatibility
-- Fixed: journal_entry_id -> entry_id

CREATE INDEX IF NOT EXISTS idx_customers_full_name ON customers(full_name);
CREATE INDEX IF NOT EXISTS idx_services_name ON services(name);
CREATE INDEX IF NOT EXISTS idx_accounts_account_type ON accounts(account_type);
CREATE INDEX IF NOT EXISTS idx_accounts_parent_id ON accounts(parent_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_by ON journal_entries(created_by);
CREATE INDEX IF NOT EXISTS idx_journal_entries_approved_by ON journal_entries(approved_by);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_mechanic_user_id ON part_suggestions(mechanic_user_id);
CREATE INDEX IF NOT EXISTS idx_part_suggestions_created_at ON part_suggestions(created_at);
CREATE INDEX IF NOT EXISTS idx_inventory_items_name ON inventory_items(name);
CREATE INDEX IF NOT EXISTS idx_vendors_name ON vendors(name);
CREATE INDEX IF NOT EXISTS idx_bookings_estimated_completion_date ON bookings(estimated_completion_date);
CREATE INDEX IF NOT EXISTS idx_bookings_notes ON bookings(notes);
CREATE INDEX IF NOT EXISTS idx_journal_lines_account_id ON journal_lines(account_id);
CREATE INDEX IF NOT EXISTS idx_journal_lines_entry_id ON journal_lines(entry_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_item_id ON inventory_transactions(item_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_id ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_quotations_customer_id ON quotations(customer_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_user_id ON leave_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_crm_leads_status ON crm_leads(status);
CREATE INDEX IF NOT EXISTS idx_crm_leads_assigned_to ON crm_leads(assigned_to);
